import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

abstract final class CleanDirtyClothesSortLogic {
  static final random = math.Random();

  static const _minSpeed = 0.008;
  static const _maxSpeed = 0.022;

  static List<LaundryTarget> defaultTargets({bool leftHanded = false}) {
    final washer = const LaundryTarget(
      id: 'target_washer',
      accepts: ClothesCleanliness.dirty,
    );
    final cupboard = const LaundryTarget(
      id: 'target_cupboard',
      accepts: ClothesCleanliness.clean,
    );
    return leftHanded ? [cupboard, washer] : [washer, cupboard];
  }

  static ClothesCleanliness randomCleanliness() =>
      random.nextBool() ? ClothesCleanliness.clean : ClothesCleanliness.dirty;

  static ({double x, double y}) _spawnPosition(List<ClothesItem> existing) {
    if (existing.isEmpty) {
      return (x: random.nextDouble(), y: random.nextDouble());
    }
    var bestX = 0.5;
    var bestY = 0.5;
    var bestDistance = -1.0;
    for (var i = 0; i < 14; i++) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      var nearest = double.infinity;
      for (final other in existing.where((e) => !e.hidden)) {
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

  static ClothesItem spawnItem({
    List<ClothesItem> existing = const [],
    ClothesCleanliness? requireCleanliness,
  }) {
    final kind = ClothesCatalog.kinds[random.nextInt(ClothesCatalog.kinds.length)];
    final cleanliness = requireCleanliness ?? randomCleanliness();
    final position = _spawnPosition(existing);
    final angle = random.nextDouble() * math.pi * 2;
    final speed = _minSpeed + random.nextDouble() * (_maxSpeed - _minSpeed);

    return ClothesItem(
      id: 'clothes_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(99999)}',
      kind: kind,
      cleanliness: cleanliness,
      x: position.x,
      y: position.y,
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed,
      floatPhase: random.nextDouble() * math.pi * 2,
    );
  }

  static List<ClothesItem> spawnItems({
    required int count,
    List<ClothesItem> existing = const [],
  }) {
    final items = [...existing];
    for (var i = 0; i < count; i++) {
      ClothesCleanliness? require;
      final visible = items.where((e) => !e.hidden).toList();
      final hasClean = visible.any((e) => e.isClean);
      final hasDirty = visible.any((e) => !e.isClean);
      if (!hasClean) require = ClothesCleanliness.clean;
      if (!hasDirty) require = ClothesCleanliness.dirty;
      items.add(spawnItem(existing: items, requireCleanliness: require));
    }
    return items.skip(existing.length).toList();
  }

  static ClothesCleanliness? requiredCleanlinessFor(List<ClothesItem> visible) {
    if (visible.isEmpty) return null;
    final hasClean = visible.any((e) => e.isClean);
    final hasDirty = visible.any((e) => !e.isClean);
    if (!hasClean) return ClothesCleanliness.clean;
    if (!hasDirty) return ClothesCleanliness.dirty;
    return null;
  }

  static ClothesItem drift(ClothesItem item, double delta, {bool animate = true}) {
    if (!animate) return item.copyWith(floatPhase: item.floatPhase + delta);

    var x = item.x + item.vx * delta;
    var y = item.y + item.vy * delta;
    var vx = item.vx;
    var vy = item.vy;

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

    return item.copyWith(
      x: x.clamp(0.0, 1.0),
      y: y.clamp(0.0, 1.0),
      vx: vx,
      vy: vy,
      floatPhase: item.floatPhase + delta * 1.4,
    );
  }

  static ({
    List<ClothesItem> items,
    List<LaundryTarget> targets,
  }) tickAnimations(
    List<ClothesItem> items,
    List<LaundryTarget> targets,
    double delta, {
    bool floating = true,
  }) =>
      (
        items: [
          for (final item in items)
            drift(item, delta, animate: floating && !item.shake),
        ],
        targets: [
          for (final t in targets)
            t.copyWith(idlePhase: t.idlePhase + delta * 2.2),
        ],
      );

  static String encouragement() =>
      kLaundryEncouragements[random.nextInt(kLaundryEncouragements.length)];

  static String victoryTitle() => 'Clean & Dirty Clothes Celebration!';

  static ({int points, int coins, int xp, int stars}) matchReward(
    LaundrySortSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    final coins = settings.coinRewardsEnabled ? math.max(1, (3 * mult).round()) : 0;
    return (
      points: (10 * mult).round(),
      coins: coins,
      xp: math.max(2, (3 * mult).round()),
      stars: 10,
    );
  }

  static LaundrySortResult calculate(LaundrySortState state) {
    final accuracy = state.attempts == 0
        ? 1.0
        : state.correctSorts / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return LaundrySortResult(
      score: state.score,
      correctSorts: state.correctSorts,
      cleanStored: state.cleanStored,
      dirtyWashed: state.dirtyWashed,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: (state.starsEarned ~/ 10) + bonusStars,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(LaundrySortResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );
}
