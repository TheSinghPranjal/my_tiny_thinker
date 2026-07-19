import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/balloon_parade/models/balloon_parade_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_logic.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

final balloonParadeControllerProvider =
    StateNotifierProvider<BalloonParadeController, BalloonParadeState>((ref) {
  return BalloonParadeController(ref);
});

class BalloonParadeController extends StateNotifier<BalloonParadeState> {
  BalloonParadeController(this._ref) : super(const BalloonParadeState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady) {
      state = state.copyWith(playAreaReady: true);
    }
  }

  void startGame(BalloonParadeSettings settings) {
    _sessionTimer?.cancel();
    state = BalloonParadeState(
      sessionPhase: BalloonParadeSessionPhase.playing,
      settings: settings,
      remainingSeconds: settings.sessionSeconds,
      spawnCooldown: 0.15,
      playAreaReady: _playArea != Size.zero,
    );
    if (_playArea != Size.zero) _spawnWave();
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != BalloonParadeSessionPhase.playing) return;
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
    final popping =
        state.balloons.any((b) => b.phase == BalloonPhase.popping);
    if (popping) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void _spawnWave() {
    if (_playArea == Size.zero) return;
    final count = state.settings.balloonsPerSpawn.clamp(1, 5);
    final lanes = BalloonLogic.pickLanes(
      count: count,
      existing: state.balloons,
      area: _playArea,
    );
    final spawned = lanes
        .map(
          (lane) => BalloonLogic.spawnRising(
            area: _playArea,
            lane: lane,
            sizeScale: 1.15,
          ),
        )
        .toList(growable: false);

    state = state.copyWith(
      balloons: [...state.balloons, ...spawned],
      balloonsGenerated: state.balloonsGenerated + spawned.length,
      spawnCooldown: state.settings.spawnIntervalSeconds.toDouble(),
    );
  }

  void tick(double delta) {
    if (state.sessionPhase != BalloonParadeSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var balloons = state.balloons
        .map(
          (b) => BalloonLogic.update(
            balloon: b,
            area: _playArea,
            delta: delta,
            animationIntensity: state.settings.animationIntensity,
            reducedMotion: state.settings.reducedMotion,
          ),
        )
        .where((b) => b.phase != BalloonPhase.gone)
        .toList();

    var cooldown = state.spawnCooldown - delta;
    var generated = state.balloonsGenerated;
    if (cooldown <= 0 && !state.pendingEnd) {
      final count = state.settings.balloonsPerSpawn.clamp(1, 5);
      final lanes = BalloonLogic.pickLanes(
        count: count,
        existing: balloons,
        area: _playArea,
      );
      final spawned = lanes
          .map(
            (lane) => BalloonLogic.spawnRising(
              area: _playArea,
              lane: lane,
              sizeScale: 1.15,
            ),
          )
          .toList(growable: false);
      balloons = [...balloons, ...spawned];
      generated += spawned.length;
      cooldown = state.settings.spawnIntervalSeconds.toDouble();
    }

    var inactivity = state.inactivitySeconds + delta;
    var showMascot = state.showMascot;
    if (inactivity >= 6) {
      showMascot = true;
      inactivity = 0;
      _scheduleFeedbackClear(showMascot: true);
    }

    if (state.pendingEnd &&
        !balloons.any((b) => b.phase == BalloonPhase.popping)) {
      _endSession();
      return;
    }

    state = state.copyWith(
      balloons: balloons,
      spawnCooldown: cooldown,
      balloonsGenerated: generated,
      inactivitySeconds: inactivity,
      showMascot: showMascot,
    );
  }

  Offset? tapBalloon(String id) {
    if (state.sessionPhase != BalloonParadeSessionPhase.playing) return null;
    final idx = state.balloons.indexWhere((b) => b.id == id);
    if (idx == -1) return null;
    final balloon = state.balloons[idx];
    if (!balloon.isTappable) return null;

    final reward = BalloonLogic.popReward(
      multiplier: state.settings.rewardMultiplier,
      poppedCount: state.balloonsPopped + 1,
    );
    final streak = state.currentStreak + 1;
    final maxStreak = math.max(state.maxStreak, streak);
    final showMascot = streak > 0 && streak % 5 == 0;
    final phrase = state.settings.narrationEnabled
        ? BalloonLogic.successPhrase(state.balloonsPopped + 1)
        : null;

    final updated = [...state.balloons];
    updated[idx] = BalloonLogic.beginPop(balloon);

    state = state.copyWith(
      balloons: updated,
      balloonsPopped: state.balloonsPopped + 1,
      currentStreak: streak,
      maxStreak: maxStreak,
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      inactivitySeconds: 0,
      showMascot: showMascot,
      feedbackMessage: phrase,
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP'
          '${reward.stars > 0 ? '  +${reward.stars} Happy Star' : ''}',
    );
    _scheduleFeedbackClear(showMascot: showMascot);
    return Offset(balloon.x, balloon.y);
  }

  void _scheduleFeedbackClear({bool showMascot = false}) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascot: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == BalloonParadeSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: BalloonParadeSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == BalloonParadeSessionPhase.paused) {
      state = state.copyWith(sessionPhase: BalloonParadeSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: BalloonParadeSessionPhase.finished,
      feedbackMessage: 'Amazing Balloon Parade!',
      showMascot: true,
    );
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const BalloonParadeState();
  }

  BalloonParadeResult getResult() => BalloonParadeResult(
        balloonsPopped: state.balloonsPopped,
        balloonsGenerated: state.balloonsGenerated,
        maxStreak: state.maxStreak,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds,
      );

  Future<void> saveResult() async {
    final result = getResult();
    if (result.balloonsPopped == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.balloonParade,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.balloonsPopped),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.balloonsPopped,
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.balloonParade);
    _ref.invalidate(allGameStatsProvider);
  }
}
