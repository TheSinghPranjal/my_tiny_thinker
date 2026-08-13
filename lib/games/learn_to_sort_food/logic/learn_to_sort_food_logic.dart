import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

abstract final class LearnToSortFoodLogic {
  static final random = math.Random();

  /// Slowest/fastest bubble drift in normalised units per second. Kept very low
  /// so a toddler can still catch a moving bubble.
  static const _minSpeed = 0.014;
  static const _maxSpeed = 0.038;

  static int poolSizeForDifficulty(FoodSortDifficulty difficulty) =>
      switch (difficulty) {
        FoodSortDifficulty.beginner => 4,
        FoodSortDifficulty.easy => 6,
        FoodSortDifficulty.medium => 10,
        FoodSortDifficulty.advanced => 999,
      };

  /// How many bubbles float at once.
  static int bubbleCountForDifficulty(FoodSortDifficulty difficulty) =>
      switch (difficulty) {
        FoodSortDifficulty.beginner => 3,
        FoodSortDifficulty.easy => 4,
        FoodSortDifficulty.medium => 5,
        FoodSortDifficulty.advanced => 5,
      };

  static FoodSortDifficulty effectiveDifficulty(
    FoodSortSettings settings,
    int round,
  ) {
    final max = settings.maxDifficulty;
    final progress = switch (round) {
      <= 3 => FoodSortDifficulty.beginner,
      <= 6 => FoodSortDifficulty.easy,
      <= 10 => FoodSortDifficulty.medium,
      _ => FoodSortDifficulty.advanced,
    };
    if (max.index < progress.index) return max;
    return progress;
  }

  static List<FoodKind> activePool(FoodSortSettings settings, int round) {
    final diff = effectiveDifficulty(settings, round);
    final size = poolSizeForDifficulty(diff);

    final healthy = settings.activeHealthy;
    final junk = settings.activeJunk;
    final all = [...healthy, ...junk];

    if (diff == FoodSortDifficulty.beginner) {
      // Two from each category, drawn from whatever the parent enabled — not a
      // fixed apple/banana/burger/pizza quartet.
      final shuffledHealthy = List<FoodKind>.from(healthy)..shuffle(random);
      final shuffledJunk = List<FoodKind>.from(junk)..shuffle(random);
      return [
        ...shuffledHealthy.take(2),
        ...shuffledJunk.take(2),
      ];
    }

    if (size >= all.length) {
      final copy = List<FoodKind>.from(all)..shuffle(random);
      return copy;
    }

    final pool = <FoodKind>[];
    final hCount = (size / 2).ceil().clamp(1, healthy.length);
    final jCount = (size - hCount).clamp(1, junk.length);
    final shuffledHealthy = List<FoodKind>.from(healthy)..shuffle(random);
    final shuffledJunk = List<FoodKind>.from(junk)..shuffle(random);
    pool.addAll(shuffledHealthy.take(hCount));
    pool.addAll(shuffledJunk.take(jCount));
    while (pool.length < size && pool.length < all.length) {
      final next = all[random.nextInt(all.length)];
      if (!pool.contains(next)) pool.add(next);
    }
    return pool;
  }

  /// Picks the next food kind, preferring ones not already floating.
  ///
  /// [requireCategory] forces a category so at least one food for each basket
  /// stays on screen.
  static FoodKind _nextKind({
    required FoodSortSettings settings,
    required int round,
    required Iterable<FoodKind> onScreen,
    FoodCategory? requireCategory,
  }) {
    final pool = activePool(settings, round);
    var candidates = pool
        .where(
          (k) =>
              requireCategory == null ||
              FoodCatalog.def(k).category == requireCategory,
        )
        .toList();
    if (candidates.isEmpty) candidates = pool;

    final fresh = candidates.where((k) => !onScreen.contains(k)).toList();
    final from = fresh.isNotEmpty ? fresh : candidates;
    return from[random.nextInt(from.length)];
  }

  /// Places a bubble in the emptiest spot by sampling a few candidate positions
  /// and keeping whichever sits furthest from the bubbles already floating.
  static ({double x, double y}) _spawnPosition(List<FloatingFood> existing) {
    if (existing.isEmpty) {
      return (x: random.nextDouble(), y: random.nextDouble());
    }

    var bestX = 0.5;
    var bestY = 0.5;
    var bestDistance = -1.0;
    for (var attempt = 0; attempt < 12; attempt++) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      var nearest = double.infinity;
      for (final other in existing) {
        final dx = other.x - x;
        final dy = other.y - y;
        nearest = math.min(nearest, dx * dx + dy * dy);
      }
      if (nearest > bestDistance) {
        bestDistance = nearest;
        bestX = x;
        bestY = y;
      }
    }
    return (x: bestX, y: bestY);
  }

  static FloatingFood spawnFood({
    required FoodSortSettings settings,
    required int round,
    List<FloatingFood> existing = const [],
    FoodCategory? requireCategory,
  }) {
    final kind = _nextKind(
      settings: settings,
      round: round,
      onScreen: existing.map((f) => f.kind),
      requireCategory: requireCategory,
    );
    final position = _spawnPosition(existing);
    final angle = random.nextDouble() * math.pi * 2;
    final speed = _minSpeed + random.nextDouble() * (_maxSpeed - _minSpeed);

    return FloatingFood(
      id: 'food_${round}_${kind.name}_${random.nextInt(999999)}',
      kind: kind,
      x: position.x,
      y: position.y,
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed,
      floatPhase: random.nextDouble() * math.pi * 2,
      rotationPhase: random.nextDouble() * math.pi * 2,
    );
  }

  /// Fills the sky with [count] bubbles, guaranteeing at least one healthy and
  /// one junk food so both baskets are always reachable.
  static List<FloatingFood> spawnFoods({
    required FoodSortSettings settings,
    required int round,
    required int count,
  }) {
    final foods = <FloatingFood>[];
    for (var i = 0; i < count; i++) {
      final requireCategory = switch (i) {
        0 => FoodCategory.healthy,
        1 => FoodCategory.junk,
        _ => null,
      };
      foods.add(
        spawnFood(
          settings: settings,
          round: round,
          existing: foods,
          requireCategory: requireCategory,
        ),
      );
    }
    foods.shuffle(random);
    return foods;
  }

  /// The category a replacement bubble must have so [remaining] never ends up
  /// holding only one category, which would leave a basket unusable.
  static FoodCategory? requiredCategoryFor(List<FloatingFood> remaining) {
    if (remaining.isEmpty) return null;
    final hasHealthy =
        remaining.any((f) => f.category == FoodCategory.healthy);
    final hasJunk = remaining.any((f) => f.category == FoodCategory.junk);
    if (!hasHealthy) return FoodCategory.healthy;
    if (!hasJunk) return FoodCategory.junk;
    return null;
  }

  static List<SortBasket> defaultBaskets() => const [
        SortBasket(
          id: 'basket_healthy',
          category: FoodCategory.healthy,
        ),
        SortBasket(
          id: 'basket_junk',
          category: FoodCategory.junk,
        ),
      ];

  static ({int points, int coins, int xp, int stars}) matchReward(
    FoodSortSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (10 * mult).round(),
      coins: math.max(1, (3 * mult).round()),
      xp: math.max(2, (3 * mult).round()),
      stars: 10,
    );
  }

  static FoodSortResult calculate(FoodSortState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return FoodSortResult(
      score: state.score,
      correctMatches: state.correctMatches,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: (state.starsEarned ~/ 10) + bonusStars,
      roundReached: state.round,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(FoodSortResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  /// Drifts a bubble, reflecting it off the edges of its 0..1 play area.
  static FloatingFood drift(FloatingFood food, double delta) {
    var x = food.x + food.vx * delta;
    var y = food.y + food.vy * delta;
    var vx = food.vx;
    var vy = food.vy;

    if (x < 0) {
      x = -x;
      vx = -vx;
    } else if (x > 1) {
      x = 2 - x;
      vx = -vx;
    }
    if (y < 0) {
      y = -y;
      vy = -vy;
    } else if (y > 1) {
      y = 2 - y;
      vy = -vy;
    }

    return food.copyWith(
      x: x.clamp(0.0, 1.0),
      y: y.clamp(0.0, 1.0),
      vx: vx,
      vy: vy,
      floatPhase: food.floatPhase + delta * 1.6,
      rotationPhase: food.rotationPhase + delta * 0.4,
    );
  }

  static ({
    List<FloatingFood> foods,
    List<SortBasket> baskets,
  }) tickAnimations(
    List<FloatingFood> foods,
    List<SortBasket> baskets,
    double delta,
  ) {
    return (
      foods: [for (final f in foods) drift(f, delta)],
      baskets: [
        for (final b in baskets) b.copyWith(idlePhase: b.idlePhase + delta * 2.4),
      ],
    );
  }
}
