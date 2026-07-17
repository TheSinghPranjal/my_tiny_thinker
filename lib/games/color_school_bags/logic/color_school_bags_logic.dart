import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

abstract final class ColorSchoolBagsLogic {
  static final random = math.Random();

  static int itemCountForLevel(int level, int maxBackpacks) {
    final desired = switch (level) {
      1 => 2,
      2 => 3,
      3 => 4,
      _ => math.min(6, 4 + (level - 3)),
    };
    return desired.clamp(2, maxBackpacks.clamp(2, 6));
  }

  static ({
    List<SortBook> books,
    List<SortBackpack> backpacks,
  }) generateRound({
    required SortBagsSettings settings,
    required int level,
  }) {
    final count = itemCountForLevel(level, settings.maxBackpacks);
    final pool = List<BagColorKind>.from(settings.activeColors);

    // Prefer high-contrast colors on early levels.
    if (level <= 2) {
      final contrast = pool
          .where(BagColorCatalog.contrasting.contains)
          .toList();
      if (contrast.length >= count) {
        pool
          ..clear()
          ..addAll(contrast);
      }
    }

    pool.shuffle(random);
    while (pool.length < count) {
      for (final c in BagColorCatalog.defaultEnabled) {
        if (!pool.contains(c)) pool.add(c);
        if (pool.length >= count) break;
      }
      if (pool.length < count) {
        pool.add(BagColorKind.values[random.nextInt(BagColorKind.values.length)]);
      }
    }

    final colors = pool.take(count).toList()..shuffle(random);
    final bookColors = List<BagColorKind>.from(colors)..shuffle(random);

    final books = <SortBook>[
      for (var i = 0; i < bookColors.length; i++)
        SortBook(
          id: 'book_${level}_${bookColors[i].name}_$i',
          colorKind: bookColors[i],
          floatPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    final backpacks = <SortBackpack>[
      for (var i = 0; i < colors.length; i++)
        SortBackpack(
          id: 'bag_${level}_${colors[i].name}_$i',
          colorKind: colors[i],
          breathPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    return (books: books, backpacks: backpacks);
  }

  static ({int points, int coins, int xp, int stars}) matchReward(
    SortBagsSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (10 * mult).round(),
      coins: math.max(1, (3 * mult).round()),
      xp: math.max(2, (3 * mult).round()),
      stars: 10, // +10 stars per correct match as per design
    );
  }

  static SortBagsResult calculate(SortBagsState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars = (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return SortBagsResult(
      score: state.score,
      correctMatches: state.correctMatches,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: (state.starsEarned ~/ 10) + bonusStars, // convert to reward stars
      levelReached: state.level,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(SortBagsResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static ({
    List<SortBook> books,
    List<SortBackpack> backpacks,
  }) tickAnimations(
    List<SortBook> books,
    List<SortBackpack> backpacks,
    double delta,
  ) {
    return (
      books: [
        for (final b in books)
          b.copyWith(floatPhase: b.floatPhase + delta * 2.2),
      ],
      backpacks: [
        for (final bag in backpacks)
          bag.copyWith(breathPhase: bag.breathPhase + delta * 1.8),
      ],
    );
  }
}
