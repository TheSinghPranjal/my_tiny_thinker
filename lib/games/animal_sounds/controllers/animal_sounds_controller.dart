import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/animal_sounds/logic/animal_sounds_logic.dart';
import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';

final animalSoundsControllerProvider =
    StateNotifierProvider<AnimalSoundsController, AnimalSoundsState>((ref) {
  return AnimalSoundsController(ref);
});

class AnimalSoundsController extends StateNotifier<AnimalSoundsState> {
  AnimalSoundsController(this._ref) : super(const AnimalSoundsState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _nextQuestionTimer;
  Timer? _shakeClearTimer;

  void startGame(AnimalSoundsSettings settings) {
    _cancelTimers();
    final queue = AnimalSoundsLogic.buildQueue();
    final question = AnimalSoundsLogic.generateQuestion(queue.first);
    state = AnimalSoundsState(
      phase: AnimalSoundsPhase.playing,
      settings: settings,
      question: question,
      remainingSeconds: settings.sessionSeconds,
      queue: queue,
      queueIndex: 0,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != AnimalSoundsPhase.playing &&
          state.phase != AnimalSoundsPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _requestEnd();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEnd() {
    if (state.pendingEnd) return;
    if (state.phase == AnimalSoundsPhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void _loadNextQuestion() {
    if (state.phase == AnimalSoundsPhase.finished) return;

    var index = state.queueIndex + 1;
    var queue = state.queue;
    if (index >= queue.length) {
      queue = AnimalSoundsLogic.buildQueue();
      index = 0;
    }

    state = state.copyWith(
      phase: AnimalSoundsPhase.playing,
      question: AnimalSoundsLogic.generateQuestion(queue[index]),
      queue: queue,
      queueIndex: index,
      showSparkles: false,
    );

    if (state.pendingEnd) _endSession();
  }

  /// Wrong answer: vibrate/highlight the correct option; stay on question.
  /// Correct: celebrate, reward, then next question.
  bool selectOption(String animalId) {
    if (state.phase != AnimalSoundsPhase.playing || state.question == null) {
      return false;
    }

    final question = state.question!;
    final selected = question.options.firstWhere(
      (o) => o.animal.id == animalId,
      orElse: () => question.options.first,
    );
    final attempts = state.attempts + 1;

    if (!selected.isCorrect) {
      // Soft hint: vibrate/highlight the correct animal (not the wrong tap).
      final options = question.options
          .map(
            (o) => o.copyWith(
              shake: o.isCorrect,
              highlight: o.isCorrect,
            ),
          )
          .toList();
      state = state.copyWith(
        question: AnimalQuestion(correct: question.correct, options: options),
        attempts: attempts,
        streak: 0,
        feedbackMessage: 'Listen again!',
      );
      _shakeClearTimer?.cancel();
      _shakeClearTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted || state.question == null) return;
        final q = state.question!;
        state = state.copyWith(
          question: AnimalQuestion(
            correct: q.correct,
            options: q.options
                .map((o) => o.copyWith(shake: false, highlight: false))
                .toList(),
          ),
        );
      });
      _scheduleFeedbackClear();
      return false;
    }

    final correctCount = state.correctCount + 1;
    final streak = state.streak + 1;
    final reward = AnimalSoundsLogic.reward(
      state.settings,
      correctCount: correctCount,
      streak: streak,
    );
    final msg = AnimalSoundsLogic.encouragement(correctCount);

    state = state.copyWith(
      phase: AnimalSoundsPhase.celebrating,
      correctCount: correctCount,
      attempts: attempts,
      streak: streak,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: msg,
      lastRewardText:
          '+${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +⭐' : ''}',
      showSparkles: true,
    );

    _nextQuestionTimer?.cancel();
    _nextQuestionTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) _loadNextQuestion();
    });
    _scheduleFeedbackClear();
    return true;
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true,
          clearReward: true, showSparkles: false);
      }
    });
  }

  void pause() {
    if (state.phase == AnimalSoundsPhase.playing ||
        state.phase == AnimalSoundsPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: AnimalSoundsPhase.ready);
    }
  }

  void resume() {
    if (state.phase == AnimalSoundsPhase.ready && state.question != null) {
      state = state.copyWith(phase: AnimalSoundsPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(
      phase: AnimalSoundsPhase.finished,
      remainingSeconds: 0,
      feedbackMessage: 'Super Listener!',
      showSparkles: true,
    );
  }

  AnimalSoundsResult getResult() => AnimalSoundsLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctCount == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.animalSounds,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.correctCount),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctCount,
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
        .recordPlay(GameId.animalSounds);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _cancelTimers();
    state = const AnimalSoundsState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();
    _shakeClearTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
