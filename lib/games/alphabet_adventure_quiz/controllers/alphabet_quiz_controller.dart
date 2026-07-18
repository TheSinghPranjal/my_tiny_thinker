import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/logic/alphabet_quiz_logic.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

final alphabetQuizControllerProvider =
    StateNotifierProvider<AlphabetQuizController, AlphabetQuizState>((ref) {
  return AlphabetQuizController(ref);
});

class AlphabetQuizController extends StateNotifier<AlphabetQuizState> {
  AlphabetQuizController(this._ref) : super(const AlphabetQuizState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _nextQuestionTimer;

  void startGame(AlphabetQuizSettings settings) {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();

    final queue = AlphabetQuizLogic.buildLetterQueue(settings);
    final letter = queue.first;
    final question = AlphabetQuizLogic.generateQuestion(
      letter,
      settings.letterCaseMode,
    );

    state = AlphabetQuizState(
      phase: AlphabetQuizPhase.playing,
      settings: settings,
      question: question,
      remainingSeconds: settings.sessionSeconds,
      letterQueue: queue,
      letterQueueIndex: 0,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != AlphabetQuizPhase.playing &&
          state.phase != AlphabetQuizPhase.celebrating) {
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
    if (state.phase == AlphabetQuizPhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void _loadNextQuestion() {
    if (state.phase == AlphabetQuizPhase.finished) return;

    var index = state.letterQueueIndex + 1;
    var queue = state.letterQueue;
    if (index >= queue.length) {
      queue = AlphabetQuizLogic.buildLetterQueue(state.settings);
      index = 0;
    }

    final letter = queue[index];
    final question = AlphabetQuizLogic.generateQuestion(
      letter,
      state.settings.letterCaseMode,
    );

    state = state.copyWith(
      phase: AlphabetQuizPhase.playing,
      question: question,
      letterQueue: queue,
      letterQueueIndex: index,
      showSparkles: false,
    );

    if (state.pendingEnd) _endSession();
  }

  bool selectOption(String itemId) {
    if (state.phase != AlphabetQuizPhase.playing || state.question == null) {
      return false;
    }

    final question = state.question!;
    final option = question.options.firstWhere(
      (o) => o.itemId == itemId,
      orElse: () => question.options.first,
    );
    final attempts = state.attempts + 1;

    if (!option.isCorrect) {
      final options = question.options
          .map((o) => o.itemId == itemId ? o.copyWith(shake: true) : o)
          .toList();
      state = state.copyWith(
        question: AlphabetQuestion(
          letter: question.letter,
          correctItemId: question.correctItemId,
          options: options,
          prompt: question.prompt,
        ),
        attempts: attempts,
        streak: 0,
        feedbackMessage: kAlphabetEncouragementsWrong[
            attempts % kAlphabetEncouragementsWrong.length],
        showMascot: true,
      );
      _scheduleFeedbackClear();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || state.question == null) return;
        final resetOptions = state.question!.options
            .map((o) => o.itemId == itemId ? o.copyWith(shake: false) : o)
            .toList();
        state = state.copyWith(
          question: AlphabetQuestion(
            letter: question.letter,
            correctItemId: question.correctItemId,
            options: resetOptions,
            prompt: question.prompt,
          ),
        );
      });
      return false;
    }

    final reward = AlphabetQuizLogic.answerReward(state.settings, state.streak + 1);
    final streak = state.streak + 1;
    final correctItem = EducationVocabulary.byId(itemId);

    final options = question.options
        .map((o) => o.itemId == itemId ? o.copyWith(glow: true) : o)
        .toList();

    state = state.copyWith(
      question: AlphabetQuestion(
        letter: question.letter,
        correctItemId: question.correctItemId,
        options: options,
        prompt: 'Excellent! ${question.letter} is for ${correctItem?.name ?? 'it'}!',
      ),
      attempts: attempts,
      correctAnswers: state.correctAnswers + 1,
      lettersCompleted: state.lettersCompleted + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage:
          kAlphabetEncouragementsRight[state.correctAnswers % kAlphabetEncouragementsRight.length],
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP',
      showMascot: streak % 3 == 0,
      showSparkles: true,
      phase: AlphabetQuizPhase.celebrating,
    );
    _scheduleFeedbackClear(showMascot: state.showMascot);

    _nextQuestionTimer?.cancel();
    _nextQuestionTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _loadNextQuestion();
    });

    return true;
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
    if (state.phase == AlphabetQuizPhase.playing ||
        state.phase == AlphabetQuizPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: AlphabetQuizPhase.paused);
    }
  }

  void resume() {
    if (state.phase == AlphabetQuizPhase.paused) {
      state = state.copyWith(phase: AlphabetQuizPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _nextQuestionTimer?.cancel();
    state = state.copyWith(phase: AlphabetQuizPhase.finished);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();
    state = const AlphabetQuizState();
  }

  AlphabetQuizResult getResult() => AlphabetQuizLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctAnswers == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.alphabetAdventureQuiz,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctAnswers,
        totalMistakes: s.totalMistakes + (result.attempts - result.correctAnswers),
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          AlphabetQuizLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.alphabetAdventureQuiz);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _nextQuestionTimer?.cancel();
    super.dispose();
  }
}
