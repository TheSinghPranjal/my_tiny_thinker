import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

abstract final class ButterflyGardenLogic {
  static final random = math.Random();

  static (double, double) basketAnchor(Size area) =>
      (area.width * 0.5, area.height * 0.88);

  static List<ButterflyEntity> spawnButterflies(Size area, int count) {
    final butterflies = <ButterflyEntity>[];
    for (var i = 0; i < count; i++) {
      butterflies.add(_createButterfly(area, i, isGolden: false, entering: false));
    }
    return butterflies;
  }

  static ButterflyEntity spawnFromEdge(
    Size area, {
    required bool isGolden,
  }) {
    final edge = random.nextInt(4);
    final (fx, fy) = switch (edge) {
      0 => (-40.0, area.height * (0.2 + random.nextDouble() * 0.5)),
      1 => (area.width + 40.0, area.height * (0.2 + random.nextDouble() * 0.5)),
      2 => (area.width * random.nextDouble(), -40.0),
      _ => (area.width * random.nextDouble(), area.height * 0.35),
    };
    return _createButterfly(
      area,
      random.nextInt(9999),
      isGolden: isGolden,
      entering: true,
      fromX: fx,
      fromY: fy,
    );
  }

  static ButterflyEntity _createButterfly(
    Size area,
    int seed, {
    required bool isGolden,
    required bool entering,
    double fromX = 0,
    double fromY = 0,
  }) {
    final pos = entering
        ? (fromX, fromY)
        : _pathPosition(area, seed, random.nextDouble() * math.pi * 2);
    return ButterflyEntity(
      id: 'bf_${DateTime.now().microsecondsSinceEpoch}_$seed',
      varietyIndex: isGolden ? 0 : seed,
      pathSeed: seed,
      isGolden: isGolden,
      phase: entering ? ButterflyPhase.entering : ButterflyPhase.flying,
      x: pos.$1,
      y: pos.$2,
      pathT: random.nextDouble() * math.pi * 2,
      sizeScale: isGolden ? 1.15 : (0.85 + random.nextDouble() * 0.3),
      enterFromX: fromX,
      enterFromY: fromY,
      enterProgress: entering ? 0 : 1,
    );
  }

  static (double, double) _pathPosition(Size area, int seed, double t) {
    final cx = area.width * (0.2 + (seed % 6) * 0.11);
    final cy = area.height * (0.15 + (seed % 5) * 0.07);
    final rx = area.width * (0.18 + (seed % 4) * 0.04);
    final ry = area.height * (0.12 + (seed % 3) * 0.03);
    final spiral = math.sin(t * 0.3 + seed) * 12;
    return (
      (cx + math.cos(t + seed * 0.4) * rx + spiral).clamp(48.0, area.width - 48),
      (cy + math.sin(t * 0.75 + seed * 0.5) * ry).clamp(56.0, area.height * 0.72),
    );
  }

  static double beeSpawnDelay(ButterflyGardenSettings settings) {
    final min = settings.beeSpawnMin;
    final max = settings.beeSpawnMax;
    return min + random.nextDouble() * (max - min);
  }

  static int beeBatchCount() => 1 + random.nextInt(2);

  static List<BeeEntity> spawnBees(Size area, int count) {
    final bees = <BeeEntity>[];
    for (var i = 0; i < count; i++) {
      final fromLeft = random.nextBool();
      bees.add(
        BeeEntity(
          id: 'bee_${DateTime.now().microsecondsSinceEpoch}_$i',
          x: fromLeft ? -30 : area.width + 30,
          y: area.height * (0.25 + random.nextDouble() * 0.4),
          vx: fromLeft ? 55 + random.nextDouble() * 25 : -(55 + random.nextDouble() * 25),
          vy: (random.nextDouble() - 0.5) * 20,
        ),
      );
    }
    return bees;
  }

  static ButterflyEntity updateButterfly(
    ButterflyEntity butterfly,
    Size area,
    double delta,
    ButterflyGardenSettings settings,
    BasketEntity basket,
  ) {
    if (butterfly.phase == ButterflyPhase.gone) return butterfly;

    final intensity = settings.reducedMotion ? 0.5 : settings.animationIntensity;
    final speed = settings.speedMult * intensity;
    final goldenSlow = butterfly.isGolden ? 0.72 : 1.0;
    var wing = butterfly.wingPhase + delta * (butterfly.phase == ButterflyPhase.tapped ? 28 : 14);

    return switch (butterfly.phase) {
      ButterflyPhase.flying => _updateFlying(butterfly, area, delta, speed * goldenSlow, wing),
      ButterflyPhase.entering => _updateEntering(butterfly, area, delta, speed, wing),
      ButterflyPhase.tapped => _updateTapped(butterfly, delta, wing),
      ButterflyPhase.collecting =>
        _updateCollecting(butterfly, basket, delta, speed, wing),
      ButterflyPhase.gone => butterfly,
    };
  }

  static ButterflyEntity _updateFlying(
    ButterflyEntity b,
    Size area,
    double delta,
    double speed,
    double wing,
  ) {
    var pathT = b.pathT + delta * 0.45 * speed;
    final hover = math.sin(pathT * 1.8 + b.pathSeed) * 0.15;
    final pos = _pathPosition(area, b.pathSeed, pathT + hover);
    var glow = b.glow;
    if (glow > 0) glow = (glow - delta * 2).clamp(0.0, 1.0);
    var highlight = b.highlight;
    if (highlight > 0) highlight = (highlight - delta * 2).clamp(0.0, 1.0);

    return b.copyWith(
      x: pos.$1,
      y: pos.$2 + math.sin(b.hoverPhase + pathT) * 4,
      pathT: pathT,
      wingPhase: wing,
      glow: glow,
      highlight: highlight,
      hoverPhase: b.hoverPhase + delta * 2,
    );
  }

  static ButterflyEntity _updateEntering(
    ButterflyEntity b,
    Size area,
    double delta,
    double speed,
    double wing,
  ) {
    final enter = (b.enterProgress + delta * 0.85 * speed).clamp(0.0, 1.0);
    final target = _pathPosition(area, b.pathSeed, b.pathT);
    if (enter >= 1) {
      return b.copyWith(
        phase: ButterflyPhase.flying,
        enterProgress: 1,
        x: target.$1,
        y: target.$2,
        wingPhase: wing,
      );
    }
    return b.copyWith(
      enterProgress: enter,
      x: b.enterFromX + (target.$1 - b.enterFromX) * enter,
      y: b.enterFromY + (target.$2 - b.enterFromY) * enter,
      wingPhase: wing,
    );
  }

  static ButterflyEntity _updateTapped(ButterflyEntity b, double delta, double wing) {
    final tap = (b.collectProgress + delta * 3).clamp(0.0, 1.0);
    if (tap >= 1) {
      return b.copyWith(
        phase: ButterflyPhase.collecting,
        collectProgress: 0,
        collectStartX: b.x,
        collectStartY: b.y,
        glow: 1,
        wingPhase: wing,
      );
    }
    return b.copyWith(
      collectProgress: tap,
      glow: 1,
      wingPhase: wing,
      y: b.y + math.sin(tap * math.pi * 4) * 3,
    );
  }

  static ButterflyEntity _updateCollecting(
    ButterflyEntity b,
    BasketEntity basket,
    double delta,
    double speed,
    double wing,
  ) {
    final collect = (b.collectProgress + delta * 1.6 * speed).clamp(0.0, 1.0);
    final tx = basket.x;
    final ty = basket.y - 50;
    final ctrlX = (b.collectStartX + tx) / 2;
    final ctrlY = math.min(b.collectStartY, ty) - 60;
    final t = collect;
    final u = 1 - t;
    final x = u * u * b.collectStartX + 2 * u * t * ctrlX + t * t * tx;
    final y = u * u * b.collectStartY + 2 * u * t * ctrlY + t * t * ty;
    if (collect >= 1) {
      return b.copyWith(phase: ButterflyPhase.gone, collectProgress: 1, x: tx, y: ty);
    }
    return b.copyWith(
      collectProgress: collect,
      x: x,
      y: y,
      wingPhase: wing,
      glow: (1 - collect * 0.5).clamp(0.0, 1.0),
    );
  }

  static BeeEntity updateBee(BeeEntity bee, Size area, double delta, ButterflyGardenSettings settings) {
    if (bee.phase == BeePhase.gone) return bee;

    final speed = settings.speedMult * settings.animationIntensity;
    var wing = bee.wingPhase + delta * 18;
    var lifetime = bee.lifetime - delta;

    if (bee.phase == BeePhase.leaving || bee.phase == BeePhase.flying || bee.phase == BeePhase.buzzed) {
      final nx = bee.x + bee.vx * delta * speed;
      final ny = bee.y + bee.vy * delta * speed + math.sin(bee.pathT) * 8 * delta;
      if (nx < -60 || nx > area.width + 60 || lifetime <= 0) {
        return bee.copyWith(phase: BeePhase.gone, lifetime: 0);
      }
      return bee.copyWith(
        x: nx,
        y: ny.clamp(40, area.height * 0.7),
        pathT: bee.pathT + delta * 3,
        wingPhase: wing,
        lifetime: lifetime,
        phase: bee.phase == BeePhase.buzzed ? BeePhase.leaving : bee.phase,
      );
    }
    return bee;
  }

  static BasketEntity updateBasket(BasketEntity basket, double delta) {
    var lid = basket.lidOpen;
    if (lid > 0) {
      lid = (lid - delta * 2.5).clamp(0.0, 1.0);
    }
    return basket.copyWith(
      lidOpen: lid,
      bouncePhase: basket.bouncePhase + delta * 4,
    );
  }

  static bool shouldMarkGoldenDue(int elapsed, int nextGoldenAt) => elapsed >= nextGoldenAt;

  static ({int points, int coins, int xp, int stars}) catchReward(
    ButterflyGardenSettings settings, {
    required bool isGolden,
    required int caught,
  }) {
    final m = settings.rewardMultiplier * (isGolden ? 2.0 : 1.0);
    final points = ((isGolden ? 20 : 10) * m).round().clamp(5, 40);
    final coins = ((isGolden ? 10 : 5) * m).round().clamp(2, 24);
    final xp = ((isGolden ? 10 : 5) * m).round().clamp(2, 24);
    final stars = isGolden ? 2 : (caught % 3 == 0 ? 1 : 0);
    return (points: points, coins: coins, xp: xp, stars: stars);
  }

  static ButterflyGardenResult buildResult(ButterflyGardenState state) =>
      ButterflyGardenResult(
        butterfliesCaught: state.butterfliesCaught,
        goldenCaught: state.goldenCaught,
        beesTapped: state.beesTapped,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickEncouragement(int count, {bool isGolden = false}) {
    if (isGolden) return 'Golden Butterfly!';
    return kButterflyEncouragements[count % kButterflyEncouragements.length];
  }

  static String pickBeeMessage(int count) =>
      kBeeMessages[count % kBeeMessages.length];
}
