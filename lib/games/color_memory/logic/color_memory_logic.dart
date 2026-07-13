import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

abstract final class ColorMemoryLogic {
  static final _random = math.Random();

  static int gridSize(ColorMemoryDifficulty d) => switch (d) {
        ColorMemoryDifficulty.easy => 2,
        ColorMemoryDifficulty.medium => 3,
        ColorMemoryDifficulty.hard => 4,
        ColorMemoryDifficulty.expert => 4,
        ColorMemoryDifficulty.master => 5,
      };

  static int sequenceLength(ColorMemoryDifficulty d, int level) {
    final (min, max) = switch (d) {
      ColorMemoryDifficulty.easy => (2, 4),
      ColorMemoryDifficulty.medium => (5, 8),
      ColorMemoryDifficulty.hard => (9, 15),
      ColorMemoryDifficulty.expert => (16, 30),
      ColorMemoryDifficulty.master => (30, 40),
    };
    return (min + level - 1).clamp(min, max);
  }

  static int showDelayMs(ColorMemoryDifficulty d) => switch (d) {
        ColorMemoryDifficulty.easy => 900,
        ColorMemoryDifficulty.medium => 700,
        ColorMemoryDifficulty.hard => 500,
        ColorMemoryDifficulty.expert => 350,
        ColorMemoryDifficulty.master => 250,
      };

  static int roundsTarget(ColorMemoryDifficulty d) => switch (d) {
        ColorMemoryDifficulty.easy => 5,
        ColorMemoryDifficulty.medium => 7,
        ColorMemoryDifficulty.hard => 10,
        ColorMemoryDifficulty.expert => 12,
        ColorMemoryDifficulty.master => 15,
      };

  static List<int> generateSequence(int length, int tileCount) {
    return List.generate(length, (_) => _random.nextInt(tileCount));
  }

  static int pointsForLevel(int level, int streak) =>
      10 * level + (streak >= 2 ? 5 : 0);

  static ColorMemoryResult calculate(ColorMemoryState state, int previousBest) {
    final isPerfect = state.mistakes == 0 && state.level > state.roundsTarget;
    var score = state.score;
    if (isPerfect) score += 100;
    final stars = isPerfect ? 3 : state.mistakes <= 2 ? 2 : 1;
    return ColorMemoryResult(
      score: score,
      stars: stars,
      coins: score ~/ 8 + stars * 2,
      xp: score ~/ 4,
      level: state.level,
      longestStreak: state.longestStreak,
      mistakes: state.mistakes,
      isPerfect: isPerfect,
      isNewBest: score > previousBest,
    );
  }

  static GameRewardResult toReward(ColorMemoryResult r) => GameRewardResult(
        coins: r.coins,
        stars: r.stars,
        xp: r.xp,
        isPerfect: r.isPerfect,
        isNewBest: r.isNewBest,
      );

  static const encouragingMessages = [
    'Almost!',
    "Let's try again!",
    'Great effort!',
    'You can do it!',
  ];
}
