import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/logic/catch_the_falling_stars_logic.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

final catchTheFallingStarsControllerProvider = StateNotifierProvider<
    CatchTheFallingStarsController, CatchTheFallingStarsState>((ref) {
  return CatchTheFallingStarsController(ref);
});

class CatchTheFallingStarsController
    extends StateNotifier<CatchTheFallingStarsState> {
  CatchTheFallingStarsController(this._ref)
      : super(const CatchTheFallingStarsState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final changed = (size.width - _playArea.width).abs() > 1 ||
        (size.height - _playArea.height).abs() > 1;
    _playArea = size;
    if (!state.playAreaReady ||
        (changed &&
            state.stars.isEmpty &&
            state.sessionPhase != StarSessionPhase.playing)) {
      _seedStars(size, state.settings);
    }
  }

  void _seedStars(Size area, CatchTheFallingStarsSettings settings) {
    final stars = CatchTheFallingStarsLogic.spawnInitialStars(area, settings);
    state = state.copyWith(
      stars: stars,
      starsAppeared: stars.length,
      playAreaReady: true,
      pendingSpawns: const [],
    );
  }

  void startGame(CatchTheFallingStarsSettings settings) {
    _sessionTimer?.cancel();
    final stars = _playArea != Size.zero
        ? CatchTheFallingStarsLogic.spawnInitialStars(_playArea, settings)
        : <FallingStarEntity>[];
    state = CatchTheFallingStarsState(
      sessionPhase: StarSessionPhase.playing,
      settings: settings,
      stars: stars,
      starsAppeared: stars.length,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
      progressMeter: 0,
      activeConstellation: ConstellationShape.teddy,
    );
    if (!settings.practiceMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != StarSessionPhase.playing) return;
      if (state.settings.practiceMode) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _endSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void tick(double delta) {
    if (state.sessionPhase != StarSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var stars = state.stars
        .map(
          (s) => CatchTheFallingStarsLogic.updateStar(
            s,
            delta,
            state.settings,
            _playArea.height,
          ),
        )
        .toList();

    var pending = state.pendingSpawns
        .map((p) => p.copyWith(delay: p.delay - delta))
        .toList();
    var starsAppeared = state.starsAppeared;
    var moonCheer = math.max(0.0, state.moonCheer - delta * 0.8);
    final envPhase = state.envPhase + delta;

    // Queue replacements for collected / drifted stars that just finished.
    final goneIds = <String>{};
    for (final s in stars) {
      if (s.phase == StarLifePhase.gone) {
        goneIds.add(s.id);
      }
    }
    if (goneIds.isNotEmpty) {
      stars = stars.where((s) => !goneIds.contains(s.id)).toList();
    }

    // Process pending spawns.
    final stillPending = <PendingStarSpawn>[];
    for (final p in pending) {
      if (p.delay > 0) {
        stillPending.add(p);
        continue;
      }
      final radius = CatchTheFallingStarsLogic.starRadius(
        _playArea,
        state.settings.effectiveStarCount,
        state.settings.largerTouchTargets,
      );
      final pos = CatchTheFallingStarsLogic.pickSpawnPosition(
        _playArea,
        stars.where((s) => s.isTappable).toList(),
        radius: radius,
        leftHanded: state.settings.leftHandedLayout,
      );
      if (pos != null) {
        stars = [
          ...stars,
          CatchTheFallingStarsLogic.createStar(pos, radius, state.settings),
        ];
        starsAppeared += 1;
      } else {
        stillPending.add(const PendingStarSpawn(delay: 0.2));
      }
    }

    // Maintain target count via pending if short.
    final living = stars.where((s) => s.isTappable).length;
    final needed = state.settings.effectiveStarCount -
        living -
        stillPending.length;
    if (needed > 0) {
      for (var i = 0; i < needed; i++) {
        stillPending.add(
          PendingStarSpawn(delay: state.settings.replacementDelaySeconds),
        );
      }
    }

    var sparkles = state.sparkles
        .map((s) => CatchTheFallingStarsLogic.updateSparkle(s, delta))
        .where((s) => s.progress < 1)
        .toList();

    state = state.copyWith(
      stars: stars,
      pendingSpawns: stillPending,
      sparkles: sparkles,
      starsAppeared: starsAppeared,
      moonCheer: moonCheer,
      envPhase: envPhase,
    );
  }

  /// Returns true if a star was collected.
  bool tapStar(String starId) {
    if (state.sessionPhase != StarSessionPhase.playing) return false;

    final index = state.stars.indexWhere((s) => s.id == starId);
    if (index < 0) return false;
    final star = state.stars[index];
    if (!star.isTappable) return false;

    final streak = state.currentStreak + 1;
    final taps = state.starsCollected + 1;
    final reward = CatchTheFallingStarsLogic.tapReward(state.settings, streak);
    final meter = (state.progressMeter + 0.07).clamp(0.0, 1.0);

    var pieces = state.constellationPieces;
    var constellation = state.activeConstellation;
    var longestConst = state.longestConstellation;
    if (state.settings.constellationEnabled && taps % 3 == 0) {
      pieces += 1;
      longestConst = math.max(longestConst, pieces);
      if (pieces >= CatchTheFallingStarsLogic.piecesPerConstellation) {
        pieces = 0;
        constellation =
            CatchTheFallingStarsLogic.nextConstellation(constellation);
      }
    }

    final updated = [...state.stars];
    updated[index] = star.copyWith(
      phase: StarLifePhase.collected,
      collectProgress: 0,
    );

    final pending = [
      ...state.pendingSpawns,
      PendingStarSpawn(delay: state.settings.replacementDelaySeconds),
    ];

    state = state.copyWith(
      stars: updated,
      pendingSpawns: pending,
      starsCollected: taps,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      rewardPoints: state.rewardPoints + reward.rewardPoints,
      progressMeter: meter,
      constellationPieces: pieces,
      activeConstellation: constellation,
      longestConstellation: longestConst,
      moonCheer: taps % 3 == 0 ? 1.0 : state.moonCheer,
      feedbackMessage: state.settings.narrationEnabled
          ? CatchTheFallingStarsLogic.pickEncouragement(taps)
          : null,
      lastRewardText: state.settings.celebrationsEnabled
          ? '+${reward.coins > 0 ? '${reward.coins} Coins  ' : ''}'
              '+${reward.xp} XP'
              '${reward.stars > 0 ? '  +${reward.stars} Star' : ''}'
          : null,
      showMascot: state.settings.celebrationsEnabled && taps % 5 == 0,
      showSparkles: state.settings.celebrationsEnabled,
    );
    _scheduleFeedbackClear();
    return true;
  }

  void tapMiss(Offset local) {
    if (state.sessionPhase != StarSessionPhase.playing) return;
    final sparkle = TapSparkle(
      id: 'spark_${DateTime.now().microsecondsSinceEpoch}',
      x: local.dx,
      y: local.dy,
    );
    state = state.copyWith(sparkles: [...state.sparkles, sparkle]);
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showSparkles: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == StarSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: StarSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == StarSessionPhase.paused) {
      state = state.copyWith(sessionPhase: StarSessionPhase.playing);
      if (!state.settings.practiceMode) {
        _startTimer();
      }
    }
  }

  void endPractice() {
    if (state.settings.practiceMode &&
        state.sessionPhase == StarSessionPhase.playing) {
      _endSession();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: StarSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage:
          CatchTheFallingStarsLogic.pickEndMessage(state.starsCollected),
      moonCheer: 1.0,
    );
  }

  CatchTheFallingStarsResult getResult() =>
      CatchTheFallingStarsLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.starsCollected == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.catchTheFallingStars,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.starsCollected),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.starsCollected,
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref
        .read(profileProvider.notifier)
        .applyReward(CatchTheFallingStarsLogic.toReward(result));
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.catchTheFallingStars);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const CatchTheFallingStarsState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
