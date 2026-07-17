import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

abstract final class CandyColorHuntLogic {
  static final random = math.Random();
  static const bowlCapacity = 10;
  static const minPerTargetColor = 2;

  static List<CandyEntity> spawnBowl(CandyHuntSettings settings) {
    final colors = List<CandyColorKind>.from(settings.activeColors);
    final candies = <CandyEntity>[];
    var slot = 0;

    // Guarantee at least 2 of each enabled color (trim if needed).
    final guaranteed = <CandyColorKind>[];
    for (final c in colors) {
      guaranteed.add(c);
      guaranteed.add(c);
    }
    while (guaranteed.length > bowlCapacity) {
      guaranteed.removeLast();
    }
    guaranteed.shuffle(random);

    for (final c in guaranteed) {
      candies.add(_makeCandy(c, slot++));
    }

    while (candies.length < bowlCapacity) {
      final c = colors[random.nextInt(colors.length)];
      candies.add(_makeCandy(c, slot++));
    }

    final shuffled = candies.toList()..shuffle(random);
    return [
      for (var i = 0; i < shuffled.length; i++)
        CandyEntity(
          id: shuffled[i].id,
          colorKind: shuffled[i].colorKind,
          style: shuffled[i].style,
          slotIndex: i,
          wigglePhase: random.nextDouble() * math.pi * 2,
        ),
    ];
  }

  static CandyEntity _makeCandy(CandyColorKind color, int slot) {
    return CandyEntity(
      id: 'candy_${DateTime.now().microsecondsSinceEpoch}_$slot',
      colorKind: color,
      style: CandyStyle.values[random.nextInt(CandyStyle.values.length)],
      slotIndex: slot,
      wigglePhase: random.nextDouble() * math.pi * 2,
    );
  }

  static CandyColorKind pickTarget(
    List<CandyEntity> candies,
    CandyHuntSettings settings,
  ) {
    final counts = <CandyColorKind, int>{};
    for (final c in candies.where((c) => !c.eaten)) {
      counts[c.colorKind] = (counts[c.colorKind] ?? 0) + 1;
    }
    var pool = settings.activeColors
        .where((k) => (counts[k] ?? 0) >= minPerTargetColor)
        .toList();
    if (pool.isEmpty) {
      pool = settings.activeColors
          .where((k) => (counts[k] ?? 0) >= 1)
          .toList();
    }
    if (pool.isEmpty) return settings.activeColors.first;
    return pool[random.nextInt(pool.length)];
  }

  /// Ensure target color has at least [minPerTargetColor] candies after a tap.
  static List<CandyEntity> replenish(
    List<CandyEntity> candies,
    CandyHuntSettings settings,
    CandyColorKind nextTarget,
  ) {
    var list = candies.where((c) => !c.eaten).toList();
    final usedSlots = list.map((c) => c.slotIndex).toSet();

    int countOf(CandyColorKind k) =>
        list.where((c) => c.colorKind == k).length;

    void addCandy(CandyColorKind color) {
      var slot = 0;
      while (usedSlots.contains(slot) && slot < bowlCapacity) {
        slot++;
      }
      if (slot >= bowlCapacity) return;
      usedSlots.add(slot);
      list.add(_makeCandy(color, slot));
    }

    while (countOf(nextTarget) < minPerTargetColor && list.length < bowlCapacity) {
      addCandy(nextTarget);
    }

    while (list.length < bowlCapacity) {
      final color = settings.activeColors[random.nextInt(settings.activeColors.length)];
      addCandy(color);
    }

    return list;
  }

  static ({int points, int coins, int xp, int stars}) correctReward(
    CandyHuntSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (10 * mult).round(),
      coins: math.max(1, (3 * mult).round()),
      xp: math.max(2, (3 * mult).round()),
      stars: streak > 0 && streak % 5 == 0 ? 1 : 0,
    );
  }

  static CandyHuntResult calculate(CandyHuntState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctTaps / state.attempts;
    final stars = state.starsEarned +
        (accuracy >= 0.9 ? 1 : 0) +
        (state.maxStreak >= 5 ? 1 : 0);
    return CandyHuntResult(
      score: state.score,
      correctTaps: state.correctTaps,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: stars.clamp(0, 5),
      sessionSeconds: state.settings.sessionSeconds,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(CandyHuntResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars,
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static List<CandyEntity> tickCandies(List<CandyEntity> candies, double delta) {
    return [
      for (final c in candies)
        c.copyWith(wigglePhase: c.wigglePhase + delta * 2.5),
    ];
  }
}
