import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/logic/candy_color_hunt_logic.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

final candyColorHuntControllerProvider =
    StateNotifierProvider<CandyColorHuntController, CandyHuntState>((ref) {
  return CandyColorHuntController(ref);
});

class CandyColorHuntController extends StateNotifier<CandyHuntState> {
  CandyColorHuntController(this._ref) : super(const CandyHuntState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _moodTimer;

  void startGame(CandyHuntSettings settings) {
    _cancelTimers();
    final spawned = CandyColorHuntLogic.spawnBowl(settings);
    final target = CandyColorHuntLogic.pickTarget(spawned, settings);
    final candies =
        CandyColorHuntLogic.replenish(spawned, settings, target);
    state = CandyHuntState(
      phase: CandyHuntPhase.playing,
      settings: settings,
      candies: candies,
      targetColor: target,
      remainingSeconds: settings.sessionSeconds,
      antMood: AntMood.looking,
      bubbleScale: 0.6,
    );
    _startTimer();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) state = state.copyWith(bubbleScale: 1.0);
    });
  }

  void tick(double delta) {
    if (state.phase != CandyHuntPhase.playing &&
        state.phase != CandyHuntPhase.celebrating) {
      return;
    }
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      antAnimPhase: state.antAnimPhase + delta * 2.4,
      blinkTimer: state.blinkTimer + delta,
      candies: CandyColorHuntLogic.tickCandies(state.candies, delta),
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != CandyHuntPhase.playing &&
          state.phase != CandyHuntPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        _requestEnd();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEnd() {
    if (state.pendingEnd) return;
    if (state.phase == CandyHuntPhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  /// Returns true if correct.
  bool tapCandy(String id) {
    if (state.phase != CandyHuntPhase.playing || state.targetColor == null) {
      return false;
    }
    final idx = state.candies.indexWhere((c) => c.id == id && !c.eaten);
    if (idx < 0) return false;

    final candy = state.candies[idx];
    final attempts = state.attempts + 1;
    final correct = candy.colorKind == state.targetColor;

    if (!correct) {
      final candies = [...state.candies];
      candies[idx] = candy.copyWith(wrongShake: true);
      // Pulse hint on correct-color candies
      for (var i = 0; i < candies.length; i++) {
        if (candies[i].colorKind == state.targetColor && !candies[i].eaten) {
          candies[i] = candies[i].copyWith(pulseHint: true);
        }
      }
      state = state.copyWith(
        candies: candies,
        attempts: attempts,
        streak: 0,
        antMood: AntMood.shakeNo,
        feedbackMessage: 'Almost! Try again!',
        showMascot: true,
      );
      _scheduleFeedbackClear();
      _moodTimer?.cancel();
      _moodTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(
          antMood: AntMood.looking,
          candies: state.candies
              .map(
                (c) => c.copyWith(wrongShake: false, pulseHint: false),
              )
              .toList(),
        );
      });
      return false;
    }

    final streak = state.streak + 1;
    final reward = CandyColorHuntLogic.correctReward(state.settings, streak);
    final name = candy.colorDef.name;

    var candies = [...state.candies];
    candies[idx] = candy.copyWith(eaten: true);

    final nextPool = CandyColorHuntLogic.replenish(
      candies,
      state.settings,
      candy.colorKind,
    );
    final nextTarget =
        CandyColorHuntLogic.pickTarget(nextPool, state.settings);
    final refreshed = CandyColorHuntLogic.replenish(
      nextPool,
      state.settings,
      nextTarget,
    );

    state = state.copyWith(
      candies: refreshed,
      attempts: attempts,
      correctTaps: state.correctTaps + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      antMood: AntMood.eating,
      phase: CandyHuntPhase.celebrating,
      feedbackMessage: name.toUpperCase(),
      spokenColorName: name,
      lastRewardText: '+${reward.points} Points',
      showSparkles: true,
      showMascot: streak % 4 == 0,
      bubbleScale: 0.7,
      targetColor: nextTarget,
    );
    _scheduleFeedbackClear(showMascot: state.showMascot);

    _moodTimer?.cancel();
    _moodTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      state = state.copyWith(
        phase: CandyHuntPhase.playing,
        antMood: AntMood.happy,
        showSparkles: false,
        bubbleScale: 1.0,
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) state = state.copyWith(antMood: AntMood.looking);
      });
      if (state.pendingEnd) _endSession();
    });

    return true;
  }

  void _scheduleFeedbackClear({bool showMascot = false}) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearSpoken: true,
          showMascot: false,
        );
      }
    });
  }

  void pause() {
    if (state.phase == CandyHuntPhase.playing ||
        state.phase == CandyHuntPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: CandyHuntPhase.paused);
    }
  }

  void resume() {
    if (state.phase == CandyHuntPhase.paused) {
      state = state.copyWith(phase: CandyHuntPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: CandyHuntPhase.finished);
  }

  void reset() {
    _cancelTimers();
    state = const CandyHuntState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _moodTimer?.cancel();
  }

  CandyHuntResult getResult() => CandyColorHuntLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctTaps == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.candyColorHunt,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctTaps,
        totalMistakes:
            s.totalMistakes + (result.attempts - result.correctTaps),
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          CandyColorHuntLogic.toReward(result),
        );
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
