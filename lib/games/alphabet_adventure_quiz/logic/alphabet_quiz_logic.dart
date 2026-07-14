import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

abstract final class AlphabetQuizLogic {
  static final _random = math.Random();

  static List<String> buildLetterQueue(AlphabetQuizSettings settings) {
    final letters = EducationVocabulary.letters.split('');
    if (settings.alphabetOrder == AlphabetOrder.random) {
      letters.shuffle(_random);
    }
    return letters;
  }

  static AlphabetQuestion generateQuestion(
    String letter,
    LetterCaseMode caseMode,
  ) {
    final correctPool = EducationVocabulary.forLetter(letter);
    final correct = correctPool.isNotEmpty
        ? correctPool[_random.nextInt(correctPool.length)]
        : EducationVocabulary.items.first;

    final distractors = <VocabItem>[];
    final others = EducationVocabulary.items
        .where((i) => i.letter != letter && i.id != correct.id)
        .toList()
      ..shuffle(_random);

    for (final item in others) {
      if (distractors.length >= 3) break;
      if (!distractors.any((d) => d.id == item.id)) {
        distractors.add(item);
      }
    }

    while (distractors.length < 3) {
      distractors.add(EducationVocabulary.items[
          _random.nextInt(EducationVocabulary.items.length)]);
    }

    final options = ([correct, ...distractors]..shuffle(_random))
        .map(
          (item) => AlphabetOption(
            itemId: item.id,
            isCorrect: item.id == correct.id,
          ),
        )
        .toList(growable: false);

    final displayLetter = switch (caseMode) {
      LetterCaseMode.uppercase => letter.toUpperCase(),
      LetterCaseMode.lowercase => letter.toLowerCase(),
      LetterCaseMode.both => letter.toUpperCase(),
    };

    return AlphabetQuestion(
      letter: displayLetter,
      correctItemId: correct.id,
      options: options,
      prompt: '$displayLetter is for ${correct.name}!',
    );
  }

  static String displayLetter(String letter, LetterCaseMode mode) {
    return switch (mode) {
      LetterCaseMode.uppercase => letter.toUpperCase(),
      LetterCaseMode.lowercase => letter.toLowerCase(),
      LetterCaseMode.both =>
        '${letter.toUpperCase()}${letter.toLowerCase()}',
    };
  }

  static ({int coins, int xp, int stars, int points}) answerReward(
    AlphabetQuizSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    final points = (10 + (streak >= 3 ? 5 : 0)) * mult.round();
    return (
      points: points,
      coins: math.max(1, (5 * mult).round()),
      xp: math.max(3, (5 * mult).round()),
      stars: streak % 3 == 0 ? 1 : 0,
    );
  }

  static AlphabetQuizResult calculate(AlphabetQuizState state) {
    final accuracy = state.attempts == 0
        ? 1.0
        : state.correctAnswers / state.attempts;
    return AlphabetQuizResult(
      score: state.score,
      correctAnswers: state.correctAnswers,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      lettersCompleted: state.lettersCompleted,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: state.starsEarned + (accuracy >= 0.85 ? 1 : 0),
      sessionSeconds: state.settings.sessionSeconds,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(AlphabetQuizResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars,
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );
}
