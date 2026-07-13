import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

abstract final class BubbleNumberGenerator {
  static List<int> generate({
    required int count,
    required int minValue,
    required int maxValue,
    required Difficulty difficulty,
  }) {
    if (minValue > maxValue) return [];
    if (minValue == maxValue) {
      return List.filled(count.clamp(1, 50), minValue);
    }

    final range = maxValue - minValue + 1;
    if (range < count) {
      // Not enough unique values — use all available
      final all = List.generate(range, (i) => minValue + i);
      all.shuffle(math.Random());
      return all.take(count).toList();
    }

    final random = math.Random();
    final numbers = <int>{};

    // Evenly distribute across range
    final segmentSize = range / count;
    for (var i = 0; i < count; i++) {
      final segMin = minValue + (segmentSize * i).floor();
      final segMax = minValue + (segmentSize * (i + 1)).floor() - 1;
      final effectiveMax = segMax.clamp(segMin, maxValue);
      var attempts = 0;
      while (attempts < 100) {
        final value = segMin + random.nextInt(effectiveMax - segMin + 1);
        if (!numbers.contains(value)) {
          numbers.add(value);
          break;
        }
        attempts++;
      }
    }

    // Fill remaining if segments didn't produce enough
    while (numbers.length < count) {
      final value = minValue + random.nextInt(range);
      numbers.add(value);
    }

    return numbers.take(count).toList();
  }

  static List<int> sortNumbers(
    List<int> numbers,
    SortMode mode,
  ) {
    final sorted = List<int>.from(numbers);
    if (mode == SortMode.ascending) {
      sorted.sort();
    } else {
      sorted.sort((a, b) => b.compareTo(a));
    }
    return sorted;
  }

  static (int min, int max) defaultRangeForDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => (1, 20),
      Difficulty.medium => (-10, 50),
      Difficulty.hard => (-100, 500),
      Difficulty.expert => (-999, 9999),
    };
  }

  static double speedForDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => 0.6,
      Difficulty.medium => 1.0,
      Difficulty.hard => 1.5,
      Difficulty.expert => 2.0,
    };
  }

  static double radiusForDifficulty(Difficulty difficulty, double screenMin) {
    final base = screenMin * 0.08;
    return switch (difficulty) {
      Difficulty.easy => base * 1.4,
      Difficulty.medium => base * 1.1,
      Difficulty.hard => base * 0.9,
      Difficulty.expert => base * 0.75,
    };
  }
}

abstract final class BubbleScoring {
  static const int correctPoints = 10;
  static const int comboBonus = 10;
  static const int perfectBonus = 100;
  static const int fastPopBonus = 5;

  static const _encouragements = [
    'Great Job!',
    'Awesome!',
    'Fantastic!',
    'Super!',
    'You did it!',
    'Amazing!',
  ];

  static const _wrongMessages = [
    'Oops!',
    'Try Again!',
    'Almost!',
  ];

  static String encouragementFor(int combo, int popIndex) {
    if (combo >= 3) return comboLabel(combo);
    return _encouragements[popIndex % _encouragements.length];
  }

  static String wrongMessage(int mistakes) =>
      _wrongMessages[mistakes % _wrongMessages.length];

  static int comboMultiplier(int combo) {
    if (combo >= 10) return 4;
    if (combo >= 5) return 3;
    if (combo >= 3) return 2;
    if (combo >= 2) return 1;
    return 0;
  }

  static String comboLabel(int combo) {
    if (combo >= 10) return 'Excellent!';
    if (combo >= 5) return 'Super!';
    if (combo >= 3) return 'Fantastic!';
    if (combo >= 2) return 'Amazing!';
    return '';
  }

  static int pointsForCorrect(int combo, {bool fastPop = false}) {
    var points = correctPoints;
    if (combo >= 2) points += comboBonus;
    if (fastPop) points += fastPopBonus;
    return points;
  }

  static int mistakePenalty(Difficulty difficulty) => 0;

  static int speedBonus(int elapsedSeconds, int total) {
    if (total == 0) return 0;
    final avgTime = elapsedSeconds / total;
    if (avgTime < 2) return 50;
    if (avgTime < 4) return 25;
    if (avgTime < 6) return 10;
    return 0;
  }

  static BubbleGameResult calculateResult({
    required BubbleGameState state,
    required int previousBest,
  }) {
    var finalScore = state.score;
    final isPerfect = state.mistakes == 0 && state.isComplete;
    if (isPerfect) finalScore += perfectBonus;
    finalScore += speedBonus(state.elapsedSeconds, state.total);

    final stars = isPerfect
        ? 3
        : state.accuracy >= 0.9
            ? 2
            : state.accuracy >= 0.7
                ? 1
                : 0;

    final coins = (finalScore / 10).round() + stars * 2;
    final xp = finalScore ~/ 5;

    return BubbleGameResult(
      score: finalScore,
      stars: stars,
      coins: coins,
      xp: xp,
      accuracy: state.accuracy,
      mistakes: state.mistakes,
      elapsedSeconds: state.elapsedSeconds,
      remainingSeconds: state.remainingSeconds,
      longestCombo: state.longestCombo,
      isPerfect: isPerfect,
      isNewBest: finalScore > previousBest,
      isVictory: state.phase == GamePhase.victory,
    );
  }
}

abstract final class BubbleRewardCalculator {
  static GameRewardResult toGameReward(BubbleGameResult result) {
    return GameRewardResult(
      coins: result.coins,
      stars: result.stars,
      xp: result.xp,
      isPerfect: result.isPerfect,
      isNewBest: result.isNewBest,
    );
  }
}
