import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_logic.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

final colorBalloonPopControllerProvider =
    StateNotifierProvider<ColorBalloonPopController, ColorBalloonPopState>(
        (ref) {
  return ColorBalloonPopController(ref);
});

class ColorBalloonPopController extends StateNotifier<ColorBalloonPopState> {
  ColorBalloonPopController(this._ref) : super(const ColorBalloonPopState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  int _tryCount = 0;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final wasEmpty = _playArea == Size.zero;
    _playArea = size;
    if (!state.playAreaReady || wasEmpty) {
      state = state.copyWith(playAreaReady: true);
    }
  }

  void startGame(ColorBalloonPopSettings settings) {
    _sessionTimer?.cancel();
    _tryCount = 0;
    final target = BalloonLogic.pickTarget();
    state = ColorBalloonPopState(
      sessionPhase: ColorBalloonSessionPhase.playing,
      roundPhase: ColorBalloonRoundPhase.instructing,
      settings: settings,
      remainingSeconds: settings.sessionSeconds,
      targetHue: target,
      instructionText: BalloonLogic.instructionFor(target),
      feedbackMessage: settings.voiceEnabled
          ? BalloonLogic.instructionFor(target)
          : null,
      playAreaReady: _playArea != Size.zero,
      roundTimer: 0.8,
    );
    _startTimer();
    if (_playArea != Size.zero) {
      // Keep instruction brief, then spawn.
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != ColorBalloonSessionPhase.playing) return;
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
    // Finish current round before celebrating.
    if (state.roundPhase == ColorBalloonRoundPhase.celebrating ||
        state.roundPhase == ColorBalloonRoundPhase.clearing ||
        state.balloons.any((b) => b.phase == BalloonPhase.popping)) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void _beginRound() {
    if (_playArea == Size.zero) return;
    final target = BalloonLogic.pickTarget(avoid: state.targetHue);
    final instruction = BalloonLogic.instructionFor(target);
    final balloons = BalloonLogic.spawnColorRound(
      area: _playArea,
      target: target,
      sizeScale: state.settings.largerTouchTargets ? 1.25 : 1.1,
    );

    state = state.copyWith(
      roundPhase: ColorBalloonRoundPhase.rising,
      targetHue: target,
      instructionText: instruction,
      balloons: balloons,
      roundTimer: 0,
      feedbackMessage:
          state.settings.voiceEnabled ? instruction : state.feedbackMessage,
      clearReward: true,
    );
    if (state.settings.voiceEnabled) {
      _scheduleFeedbackClear();
    }
  }

  void tick(double delta) {
    if (state.sessionPhase != ColorBalloonSessionPhase.playing) return;

    if (state.roundPhase == ColorBalloonRoundPhase.instructing) {
      final t = state.roundTimer - delta;
      if (t <= 0) {
        if (_playArea == Size.zero) {
          state = state.copyWith(roundTimer: 0);
          return;
        }
        _beginRound();
      } else {
        state = state.copyWith(roundTimer: t);
      }
      return;
    }

    if (_playArea == Size.zero) return;

    final speed = state.settings.animationSpeed *
        (state.settings.reducedMotion ? 0.75 : 1.0);

    var balloons = state.balloons
        .map(
          (b) => BalloonLogic.update(
            balloon: b,
            area: _playArea,
            delta: delta,
            speedMult: speed,
            animationIntensity: speed,
            reducedMotion: state.settings.reducedMotion,
          ),
        )
        .toList();

    var roundPhase = state.roundPhase;
    var roundTimer = state.roundTimer;

    if (roundPhase == ColorBalloonRoundPhase.rising) {
      final allReady = balloons.every(
        (b) =>
            b.phase == BalloonPhase.bobbing ||
            b.phase == BalloonPhase.popping ||
            b.phase == BalloonPhase.gone,
      );
      if (allReady) {
        roundPhase = ColorBalloonRoundPhase.waiting;
      }
    }

    if (roundPhase == ColorBalloonRoundPhase.celebrating) {
      roundTimer += delta;
      if (roundTimer >= 0.45) {
        balloons = balloons
            .map((b) {
              if (b.phase == BalloonPhase.bobbing ||
                  b.phase == BalloonPhase.rising) {
                return BalloonLogic.beginLeave(b);
              }
              return b;
            })
            .toList();
        roundPhase = ColorBalloonRoundPhase.clearing;
        roundTimer = 0;
      }
    }

    if (roundPhase == ColorBalloonRoundPhase.clearing) {
      balloons = balloons.where((b) => b.phase != BalloonPhase.gone).toList();
      final stillLeaving = balloons.any(
        (b) =>
            b.phase == BalloonPhase.leaving ||
            b.phase == BalloonPhase.popping,
      );
      if (!stillLeaving) {
        if (state.pendingEnd) {
          _endSession();
          return;
        }
        roundPhase = ColorBalloonRoundPhase.instructing;
        roundTimer = 1.0;
        balloons = const [];
      }
    }

    balloons = balloons.where((b) => b.phase != BalloonPhase.gone).toList();

    state = state.copyWith(
      balloons: balloons,
      roundPhase: roundPhase,
      roundTimer: roundTimer,
    );
  }

  /// Returns (origin, correct) when a tap was handled.
  ({Offset origin, bool correct})? tapBalloon(String id) {
    if (state.sessionPhase != ColorBalloonSessionPhase.playing) return null;
    if (state.roundPhase != ColorBalloonRoundPhase.waiting &&
        state.roundPhase != ColorBalloonRoundPhase.rising) {
      return null;
    }

    final idx = state.balloons.indexWhere((b) => b.id == id);
    if (idx == -1) return null;
    final balloon = state.balloons[idx];
    if (!balloon.isTappable) return null;

    final origin = Offset(balloon.x, balloon.y);
    final correct = balloon.hue == state.targetHue;

    if (!correct) {
      _tryCount += 1;
      final updated = [...state.balloons];
      updated[idx] = BalloonLogic.beginWobble(balloon);
      state = state.copyWith(
        balloons: updated,
        currentStreak: 0,
        feedbackMessage: state.settings.voiceEnabled
            ? BalloonLogic.colorTryPhrase(state.targetHue, _tryCount)
            : 'Good Try!',
        clearReward: true,
      );
      _scheduleFeedbackClear();
      return (origin: origin, correct: false);
    }

    final reward = BalloonLogic.popReward(
      multiplier: state.settings.rewardMultiplier,
      poppedCount: state.balloonsPopped + 1,
    );
    final streak = state.currentStreak + 1;
    final mastered = {...state.colorsMastered, state.targetHue};
    final updated = [...state.balloons];
    updated[idx] = BalloonLogic.beginPop(balloon);

    state = state.copyWith(
      balloons: updated,
      roundPhase: ColorBalloonRoundPhase.celebrating,
      roundTimer: 0,
      balloonsPopped: state.balloonsPopped + 1,
      roundsCompleted: state.roundsCompleted + 1,
      currentStreak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      colorsMastered: mastered,
      showMascot: streak % 3 == 0,
      feedbackMessage: state.settings.voiceEnabled
          ? BalloonLogic.colorSuccessPhrase(
              state.targetHue,
              state.balloonsPopped + 1,
            )
          : 'Wonderful!',
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP'
          '${reward.stars > 0 ? '  +${reward.stars} Happy Star' : ''}',
    );
    _scheduleFeedbackClear(showMascot: streak % 3 == 0);
    return (origin: origin, correct: true);
  }

  void _scheduleFeedbackClear({bool showMascot = false}) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascot: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == ColorBalloonSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: ColorBalloonSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == ColorBalloonSessionPhase.paused) {
      state = state.copyWith(sessionPhase: ColorBalloonSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: ColorBalloonSessionPhase.finished,
      feedbackMessage: 'Wonderful Color Adventure!',
      showMascot: true,
    );
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _tryCount = 0;
    state = const ColorBalloonPopState();
  }

  ColorBalloonPopResult getResult() => ColorBalloonPopResult(
        balloonsPopped: state.balloonsPopped,
        roundsCompleted: state.roundsCompleted,
        maxStreak: state.maxStreak,
        colorsMastered: state.colorsMastered.length,
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
      GameId.colorBalloonPop,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.roundsCompleted),
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
        .recordPlay(GameId.colorBalloonPop);
    _ref.invalidate(allGameStatsProvider);
  }
}
