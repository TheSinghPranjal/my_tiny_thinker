import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

abstract final class BubbleNumberGenerator {
  static List<int> generate({
    required int count,
    required int minValue,
    required int maxValue,
    required Difficulty difficulty,
    bool randomNumbers = true,
  }) {
    if (minValue > maxValue) return [];

    final clampedCount = count.clamp(1, 50);
    if (minValue == maxValue) {
      return List.filled(clampedCount, minValue);
    }

    final range = maxValue - minValue + 1;
    final effectiveCount = clampedCount > range ? range : clampedCount;

    if (!randomNumbers) {
      return _generateSequential(
        count: effectiveCount,
        minValue: minValue,
        maxValue: maxValue,
      );
    }

    return _generateRandom(
      count: effectiveCount,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  /// Consecutive run within [minValue, maxValue], e.g. 5,6,7,8,9,10,11,12.
  static List<int> _generateSequential({
    required int count,
    required int minValue,
    required int maxValue,
  }) {
    final range = maxValue - minValue + 1;
    final span = count;
    final maxStart = maxValue - span + 1;
    final start = maxStart <= minValue
        ? minValue
        : minValue + math.Random().nextInt(maxStart - minValue + 1);
    return List.generate(span.clamp(1, range), (i) => start + i);
  }

  static List<int> _generateRandom({
    required int count,
    required int minValue,
    required int maxValue,
  }) {
    final range = maxValue - minValue + 1;
    if (range <= count) {
      final all = List.generate(range, (i) => minValue + i);
      all.shuffle(math.Random());
      return all.take(count).toList();
    }

    final random = math.Random();
    final numbers = <int>{};

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

    while (numbers.length < count) {
      final value = minValue + random.nextInt(range);
      numbers.add(value);
    }

    return numbers.take(count).toList();
  }

  /// Builds a word-match round: floating bubble numbers + one target to find.
  ///
  /// When [randomNumbers] is true, the target can be any value in the range and
  /// distractors are filled from the same range. When false, bubbles are a
  /// consecutive run and the target is one of those values.
  static ({List<int> numbers, int target}) generateWordMatchRound({
    required int count,
    required int minValue,
    required int maxValue,
    bool randomNumbers = true,
  }) {
    if (minValue > maxValue) {
      return (numbers: const <int>[], target: minValue);
    }

    final random = math.Random();
    final clampedCount = count.clamp(1, 50);
    final range = maxValue - minValue + 1;
    final effectiveCount = clampedCount > range ? range : clampedCount;

    if (!randomNumbers) {
      final seq = _generateSequential(
        count: effectiveCount,
        minValue: minValue,
        maxValue: maxValue,
      );
      final shuffled = List<int>.from(seq)..shuffle(random);
      final target = shuffled[random.nextInt(shuffled.length)];
      return (numbers: shuffled, target: target);
    }

    // Prefer any value from the full range as the word target.
    final target = minValue + random.nextInt(range);
    final numbers = <int>{target};
    var attempts = 0;
    while (numbers.length < effectiveCount && attempts < 500) {
      numbers.add(minValue + random.nextInt(range));
      attempts++;
    }
    // If range is tiny, pad with available values.
    if (numbers.length < effectiveCount) {
      for (var i = minValue; i <= maxValue && numbers.length < effectiveCount; i++) {
        numbers.add(i);
      }
    }
    final list = numbers.toList()..shuffle(random);
    return (numbers: list.take(effectiveCount).toList(), target: target);
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
      Difficulty.easy => (0, 20),
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

  static int speedBonus(int elapsedSeconds, int totalCorrect) {
    if (totalCorrect == 0) return 0;
    final avgTime = elapsedSeconds / totalCorrect;
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
    final isPerfect = state.mistakes == 0 && state.totalCorrectPops > 0;
    if (isPerfect) finalScore += perfectBonus;
    finalScore += speedBonus(state.elapsedSeconds, state.totalCorrectPops);

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
      isVictory: state.totalCorrectPops > 0,
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
