import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/logic/whack_a_mole_logic.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

final whackAMoleControllerProvider =
    StateNotifierProvider<WhackAMoleController, WhackAMoleState>((ref) {
  return WhackAMoleController(ref);
});

class WhackAMoleController extends StateNotifier<WhackAMoleState> {
  WhackAMoleController(this._ref) : super(const WhackAMoleState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final changed = (size.width - _playArea.width).abs() > 1 ||
        (size.height - _playArea.height).abs() > 1;
    _playArea = size;
    if (!state.playAreaReady || (changed && state.holes.isEmpty)) {
      _initLevel(size, state.settings);
    } else if (changed && state.sessionPhase == WhackSessionPhase.playing) {
      final holes = WhackAMoleLogic.spawnHoles(
        size,
        state.settings.effectiveHoleCount,
        leftHanded: state.settings.leftHandedLayout,
      );
      state = state.copyWith(holes: holes, playAreaReady: true);
    }
  }

  void _initLevel(Size area, WhackAMoleSettings settings) {
    final holes = WhackAMoleLogic.spawnHoles(
      area,
      settings.effectiveHoleCount,
      leftHanded: settings.leftHandedLayout,
    );
    state = state.copyWith(
      holes: holes,
      playAreaReady: true,
      spawnDelay: 0.4,
      clearMole: true,
    );
  }

  void startGame(WhackAMoleSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = WhackAMoleState(
      sessionPhase: WhackSessionPhase.playing,
      settings: settings,
      holes: state.holes,
      remainingSeconds: settings.practiceMode ? settings.sessionSeconds : settings.sessionSeconds,
      spawnDelay: 0.5,
      playAreaReady: _playArea != Size.zero,
      progressMeter: 0,
    );
    if (!settings.practiceMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != WhackSessionPhase.playing) return;
      if (state.settings.practiceMode) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _requestEndSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.hasActiveMole) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != WhackSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    final holes = state.holes
        .map((h) => WhackAMoleLogic.updateHole(h, delta, state.settings))
        .toList();

    var mole = state.activeMole;
    var spawnDelay = state.spawnDelay;
    var molesAppeared = state.molesAppeared;
    var lastHoleId = state.lastHoleId;
    var moleAppearAtMs = state.moleAppearAtMs;
    var cheers = state.cheers
        .map((c) => WhackAMoleLogic.updateCheer(c, delta))
        .where((c) => c.progress < 1)
        .toList();
    var sparkles = state.sparkles
        .map((s) => WhackAMoleLogic.updateSparkle(s, delta))
        .where((s) => s.progress < 1)
        .toList();

    var currentStreak = state.currentStreak;
    if (mole != null) {
      final wasHiding = mole.phase == MolePhase.hiding;
      mole = WhackAMoleLogic.updateMole(mole, delta, state.settings);
      if (mole.phase == MolePhase.gone) {
        // Escaped moles gently reset streak (no scolding / penalties).
        if (wasHiding) currentStreak = 0;
        mole = null;
        spawnDelay = WhackAMoleLogic.randomDelay(state.settings);
        if (state.pendingEnd) {
          state = state.copyWith(
            holes: holes,
            clearMole: true,
            cheers: cheers,
            sparkles: sparkles,
            currentStreak: currentStreak,
          );
          _endSession();
          return;
        }
      }
    } else if (!state.pendingEnd) {
      spawnDelay -= delta;
      if (spawnDelay <= 0 && holes.isNotEmpty) {
        final holeId = WhackAMoleLogic.pickHoleId(holes, lastHoleId);
        mole = WhackAMoleLogic.createMole(holeId).copyWith(
          visibleTimer: state.settings.visibilitySeconds,
        );
        lastHoleId = holeId;
        molesAppeared += 1;
        moleAppearAtMs = DateTime.now().millisecondsSinceEpoch;
        spawnDelay = 0;
      }
    }

    state = state.copyWith(
      holes: holes,
      activeMole: mole,
      clearMole: mole == null,
      spawnDelay: spawnDelay,
      molesAppeared: molesAppeared,
      lastHoleId: lastHoleId,
      moleAppearAtMs: moleAppearAtMs,
      cheers: cheers,
      sparkles: sparkles,
      currentStreak: currentStreak,
    );
  }

  /// Returns true if a mole was hit.
  bool tapHole(String holeId) {
    if (state.sessionPhase != WhackSessionPhase.playing) return false;

    final mole = state.activeMole;
    if (mole == null || mole.holeId != holeId || !mole.isTappable) {
      _addMissSparkle(holeId);
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final reaction = state.moleAppearAtMs > 0
        ? (now - state.moleAppearAtMs).clamp(0, 10000)
        : 0;
    final streak = state.currentStreak + 1;
    final taps = state.molesTapped + 1;
    final reward = WhackAMoleLogic.tapReward(state.settings, streak);
    final meter = (state.progressMeter + 0.08).clamp(0.0, 1.0);

    final cheer = WhackAMoleLogic.maybeSpawnCheer(
      taps,
      state.settings.celebrationsEnabled,
    );
    final cheers = cheer != null ? [...state.cheers, cheer] : state.cheers;

    final fastest = state.fastestReactionMs == 0
        ? reaction
        : math.min(state.fastestReactionMs, reaction);

    state = state.copyWith(
      activeMole: mole.copyWith(phase: MolePhase.hit, hitProgress: 0),
      molesTapped: taps,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      fastestReactionMs: fastest,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      rewardPoints: state.rewardPoints + reward.rewardPoints,
      progressMeter: meter,
      feedbackMessage: state.settings.narrationEnabled
          ? WhackAMoleLogic.pickEncouragement(taps)
          : null,
      lastRewardText: state.settings.celebrationsEnabled
          ? '+${reward.coins > 0 ? '${reward.coins} Coins  ' : ''}'
              '+${reward.xp} XP'
              '${reward.stars > 0 ? '  +${reward.stars} Star' : ''}'
          : null,
      showMascot: state.settings.celebrationsEnabled && taps % 5 == 0,
      showSparkles: state.settings.celebrationsEnabled,
      cheers: cheers,
    );
    _scheduleFeedbackClear();
    return true;
  }

  void tapMiss(Offset local) {
    if (state.sessionPhase != WhackSessionPhase.playing) return;
    final sparkle = TapSparkle(
      id: 'spark_${DateTime.now().microsecondsSinceEpoch}',
      x: local.dx,
      y: local.dy,
    );
    state = state.copyWith(sparkles: [...state.sparkles, sparkle]);
  }

  void _addMissSparkle(String holeId) {
    final hole = state.holes.where((h) => h.id == holeId).firstOrNull;
    if (hole == null) return;
    final sparkle = TapSparkle(
      id: 'spark_${DateTime.now().microsecondsSinceEpoch}',
      x: hole.centerX,
      y: hole.centerY - hole.radius * 0.3,
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
    if (state.sessionPhase == WhackSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: WhackSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == WhackSessionPhase.paused) {
      state = state.copyWith(sessionPhase: WhackSessionPhase.playing);
      if (!state.settings.practiceMode) {
        _startTimer();
      }
    }
  }

  void endPractice() {
    if (state.settings.practiceMode &&
        state.sessionPhase == WhackSessionPhase.playing) {
      _endSession();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: WhackSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: WhackAMoleLogic.pickEndMessage(state.molesTapped),
      clearMole: true,
    );
  }

  WhackAMoleResult getResult() => WhackAMoleLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.molesTapped == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.whackAMole,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.molesTapped),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.molesTapped,
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref
        .read(profileProvider.notifier)
        .applyReward(WhackAMoleLogic.toReward(result));
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.whackAMole);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const WhackAMoleState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
