import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/number_memory/logic/number_memory_logic.dart';
import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';

final numberMemoryControllerProvider =
    StateNotifierProvider<NumberMemoryController, NumberMemoryState>((ref) {
  return NumberMemoryController(ref);
});

class NumberMemoryController extends StateNotifier<NumberMemoryState> {
  NumberMemoryController(this._ref) : super(const NumberMemoryState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  Timer? _showTimer;
  Timer? _celebrateTimer;
  Timer? _feedbackTimer;
  Timer? _shakeTimer;
  Timer? _advanceTimer;

  static const _showDuration = Duration(milliseconds: 2500);

  void startGame(NumberMemorySettings settings) {
    _cancelAll();
    final target = NumberMemoryLogic.randomNumber(settings.digitCount);
    state = NumberMemoryState(
      phase: NumberMemoryPhase.countdown,
      settings: settings,
      targetNumber: target,
      remainingSeconds: settings.sessionSeconds,
      countdown: 3,
      attemptsLeft: 2,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        timer.cancel();
        state = state.copyWith(countdown: 0);
        _startSessionTimer();
        _beginShowing();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != NumberMemoryPhase.showing &&
          state.phase != NumberMemoryPhase.input &&
          state.phase != NumberMemoryPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        if (state.phase == NumberMemoryPhase.celebrating) {
          state = state.copyWith(pendingEnd: true);
        } else {
          _endGame();
        }
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _beginShowing() {
    _showTimer?.cancel();
    state = state.copyWith(
      phase: NumberMemoryPhase.showing,
      input: '',
      showShake: false,
      showErrorBorder: false,
      clearFeedback: true,
      clearReward: true,
    );
    _showTimer = Timer(_showDuration, () {
      if (!mounted) return;
      if (state.phase != NumberMemoryPhase.showing) return;
      if (state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      state = state.copyWith(phase: NumberMemoryPhase.input);
    });
  }

  void tapDigit(String digit) {
    if (state.phase != NumberMemoryPhase.input) return;
    if (digit.length != 1 || digit.compareTo('0') < 0 || digit.compareTo('9') > 0) {
      return;
    }
    if (state.input.length >= state.settings.digitCount) return;
    state = state.copyWith(
      input: '${state.input}$digit',
      showShake: false,
      showErrorBorder: false,
    );
  }

  void clearInput() {
    if (state.phase != NumberMemoryPhase.input) return;
    state = state.copyWith(
      input: '',
      showShake: false,
      showErrorBorder: false,
    );
  }

  /// Returns `true` if correct, `false` if wrong, `null` if ignored.
  bool? submit() {
    if (state.phase != NumberMemoryPhase.input) return null;
    if (state.input.isEmpty) return null;

    if (state.input == state.targetNumber) {
      _onCorrect();
      return true;
    }
    _onWrong();
    return false;
  }

  void _onCorrect() {
    final combo = state.combo + 1;
    final reward = NumberMemoryLogic.correctReward(combo);
    final praise = kNumberPraise[state.correctCount % kNumberPraise.length];

    state = state.copyWith(
      phase: NumberMemoryPhase.celebrating,
      correctCount: state.correctCount + 1,
      combo: combo,
      maxCombo: math.max(state.maxCombo, combo),
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      score: state.score + reward.points,
      feedbackMessage: praise,
      lastRewardText: '+${reward.coins} Coins  +${reward.xp} XP',
      showShake: false,
      showErrorBorder: false,
    );

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (state.pendingEnd || state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      _loadNextNumber();
    });
  }

  void _onWrong() {
    final left = state.attemptsLeft - 1;
    state = state.copyWith(
      wrongCount: state.wrongCount + 1,
      combo: 0,
      attemptsLeft: left,
      input: '',
      showShake: true,
      showErrorBorder: true,
      feedbackMessage: left > 0 ? 'Try again!' : 'Next one!',
      clearReward: true,
    );
    _pulseShake();
    _scheduleFeedbackClear();

    if (left <= 0) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (state.remainingSeconds <= 0) {
          _endGame();
          return;
        }
        _loadNextNumber();
      });
    }
  }

  void _loadNextNumber() {
    final next = NumberMemoryLogic.randomNumber(
      state.settings.digitCount,
      exclude: state.targetNumber,
    );
    state = state.copyWith(
      targetNumber: next,
      input: '',
      attemptsLeft: 2,
      showShake: false,
      showErrorBorder: false,
      clearFeedback: true,
      clearReward: true,
    );
    _beginShowing();
  }

  void _pulseShake() {
    _shakeTimer?.cancel();
    _shakeTimer = Timer(const Duration(milliseconds: 550), () {
      if (mounted) {
        state = state.copyWith(showShake: false, showErrorBorder: false);
      }
    });
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, clearReward: true);
      }
    });
  }

  void pause() {
    if (state.phase == NumberMemoryPhase.showing ||
        state.phase == NumberMemoryPhase.input ||
        state.phase == NumberMemoryPhase.celebrating) {
      _sessionTimer?.cancel();
      _showTimer?.cancel();
      _celebrateTimer?.cancel();
      _advanceTimer?.cancel();
      state = state.copyWith(
        phase: NumberMemoryPhase.paused,
        phaseBeforePause: state.phase,
      );
    }
  }

  void resume() {
    if (state.phase != NumberMemoryPhase.paused) return;
    final resumePhase =
        state.phaseBeforePause ?? NumberMemoryPhase.input;
    state = state.copyWith(
      phase: resumePhase,
      clearPhaseBeforePause: true,
    );
    _startSessionTimer();
    if (resumePhase == NumberMemoryPhase.showing) {
      _beginShowing();
    } else if (resumePhase == NumberMemoryPhase.celebrating) {
      _celebrateTimer?.cancel();
      _celebrateTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (state.pendingEnd || state.remainingSeconds <= 0) {
          _endGame();
          return;
        }
        _loadNextNumber();
      });
    }
  }

  void _endGame() {
    _cancelAll();
    state = state.copyWith(phase: NumberMemoryPhase.finished);
  }

  void reset() {
    _cancelAll();
    state = const NumberMemoryState();
  }

  NumberMemoryResult getResult() => NumberMemoryLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    final existing = storage.getGameStats(GameId.numberMemory.id);
    var stats = existing != null
        ? GameStats.fromJson(existing)
        : const GameStats(gameId: GameId.numberMemory);

    stats = stats.copyWith(
      bestScore: math.max(stats.bestScore, result.score),
      starsEarned: stats.starsEarned + result.stars,
      timesPlayed: stats.timesPlayed + 1,
      totalCorrect: stats.totalCorrect + result.correctCount,
      totalMistakes: stats.totalMistakes + result.wrongCount,
      longestCombo: math.max(stats.longestCombo, result.maxCombo),
      lastPlayed: DateTime.now(),
    );

    await storage.saveGameStats(GameId.numberMemory.id, stats.toJson());
    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
            isPerfect: result.wrongCount == 0 && result.correctCount > 0,
            isNewBest: result.score >
                (existing != null
                    ? GameStats.fromJson(existing).bestScore
                    : 0),
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.numberMemory);
  }

  void _cancelAll() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _showTimer?.cancel();
    _celebrateTimer?.cancel();
    _feedbackTimer?.cancel();
    _shakeTimer?.cancel();
    _advanceTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}
