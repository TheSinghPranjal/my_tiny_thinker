import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/logic/pond_bounds.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

abstract final class HungryDuckLogic {
  static final random = math.Random();
  static const catchDistance = 42.0;

  static List<PondFishEntity> spawnFish(Size area, int count) {
    final fish = <PondFishEntity>[];
    for (var i = 0; i < count; i++) {
      fish.add(_createFish(area, i, isGolden: false, entering: false));
    }
    return fish;
  }

  static PondFishEntity spawnFromEdge(Size area, {required bool isGolden}) {
    final yMin = PondBounds.waterTop(area);
    final yMax = PondBounds.waterBottom(area);
    final fromLeft = random.nextBool();
    final fx = fromLeft ? -56.0 : area.width + 56.0;
    final fy = yMin + random.nextDouble() * (yMax - yMin);
    return _createFish(
      area,
      random.nextInt(9999),
      isGolden: isGolden,
      entering: true,
      fromX: fx,
      fromY: fy,
      facingRight: fromLeft,
    );
  }

  static PondFishEntity _createFish(
    Size area,
    int seed, {
    required bool isGolden,
    required bool entering,
    double fromX = 0,
    double fromY = 0,
    bool? facingRight,
  }) {
    final pos = entering
        ? (fromX, fromY)
        : _fishPath(area, seed, random.nextDouble() * math.pi * 2);
    return PondFishEntity(
      id: 'fish_${DateTime.now().microsecondsSinceEpoch}_$seed',
      varietyIndex: seed,
      pathSeed: seed,
      isGolden: isGolden,
      phase: entering ? FishPhase.entering : FishPhase.swimming,
      x: pos.$1,
      y: pos.$2,
      pathT: random.nextDouble() * math.pi * 2,
      depth: PondBounds.depthFactor(area, pos.$2),
      enterFromX: fromX,
      enterFromY: fromY,
      enterProgress: entering ? 0 : 1,
      facingRight: facingRight ?? random.nextBool(),
    );
  }

  static (double, double) _enterTarget(Size area, int seed) =>
      _fishPath(area, seed, 0);

  static (double, double) _fishPath(Size area, int seed, double t) {
    final yMin = PondBounds.waterTop(area);
    final yMax = PondBounds.waterBottom(area);
    final waterMid = (yMin + yMax) / 2;
    final waterSpan = yMax - yMin;
    final cx = area.width * (0.2 + (seed % 6) * 0.1);
    final cy = waterMid + (seed % 5 - 2) * waterSpan * 0.08;
    final rx = area.width * (0.18 + (seed % 4) * 0.04);
    final ry = waterSpan * (0.22 + (seed % 3) * 0.06);
    return PondBounds.clampPoint(
      area,
      cx + math.cos(t + seed * 0.35) * rx,
      cy + math.sin(t * 0.7 + seed * 0.4) * ry,
    );
  }

  static (double, double) duckPath(Size area, int seed, double t) =>
      _duckPath(area, seed, t);

  static (double, double) _duckPath(Size area, int seed, double t) {
    final yMin = PondBounds.waterTop(area);
    final yMax = PondBounds.waterBottom(area);
    final waterMid = (yMin + yMax) / 2;
    final waterSpan = yMax - yMin;
    final cx = area.width * 0.5;
    final cy = waterMid;
    final rx = area.width * 0.28;
    final ry = waterSpan * 0.35;
    return PondBounds.clampPoint(
      area,
      cx + math.cos(t * 0.6 + seed) * rx,
      cy + math.sin(t * 0.5 + seed * 0.3) * ry,
    );
  }

  static double computeSunsetFactor(int elapsed, int sessionSeconds) {
    if (sessionSeconds <= 60) return 0;
    final half = sessionSeconds / 2;
    if (elapsed < half) return 0;
    return ((elapsed - half) / (sessionSeconds - half)).clamp(0.0, 1.0);
  }

  static double visitorSpawnDelay(HungryDuckSettings settings) {
    final min = settings.visitorSpawnMin;
    final max = settings.visitorSpawnMax;
    return min + random.nextDouble() * (max - min);
  }

  static PondVisitorEntity spawnVisitor(Size area) {
    final kind = PondVisitorKind.values[random.nextInt(PondVisitorKind.values.length)];
    final yMin = PondBounds.waterTop(area);
    final yMax = PondBounds.waterBottom(area);
    final (x, y) = switch (kind) {
      PondVisitorKind.turtle => (-50.0, yMax - 8),
      PondVisitorKind.frog => (
          area.width * random.nextDouble(),
          yMax - 4 + random.nextDouble() * 12,
        ),
      PondVisitorKind.dragonfly => (
          area.width * random.nextDouble(),
          yMin + (yMax - yMin) * 0.15,
        ),
      PondVisitorKind.butterfly => (
          area.width * random.nextDouble(),
          yMin - 20,
        ),
    };
    return PondVisitorEntity(
      id: 'visitor_${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      x: x,
      y: y,
    );
  }

  static PondFishEntity updateFish(
    PondFishEntity fish,
    Size area,
    double delta,
    HungryDuckSettings settings,
  ) {
    if (fish.phase == FishPhase.gone) return fish;

    final speed = settings.fishSpeedMult * settings.animationIntensity;
    final goldenSlow = fish.isGolden ? 0.75 : 1.0;

    return switch (fish.phase) {
      FishPhase.swimming => _updateSwimming(fish, area, delta, speed * goldenSlow),
      FishPhase.selected => _updateSelected(fish, area, delta),
      FishPhase.sinking => _updateSinking(fish, area, delta),
      FishPhase.entering => _updateEntering(fish, area, delta, speed),
      FishPhase.gone => fish,
    };
  }

  static PondFishEntity _updateSwimming(
    PondFishEntity f,
    Size area,
    double delta,
    double speed,
  ) {
    var pathT = f.pathT + delta * 0.42 * speed;
    final pos = _fishPath(area, f.pathSeed, pathT);
    var glow = f.glow;
    if (glow > 0) glow = (glow - delta * 2).clamp(0.0, 1.0);
    return f.copyWith(
      x: pos.$1,
      y: pos.$2,
      pathT: pathT,
      glow: glow,
      depth: PondBounds.depthFactor(area, pos.$2),
      facingRight: pos.$1 >= f.x,
    );
  }

  static PondFishEntity _updateSelected(PondFishEntity f, Size area, double delta) {
    final wiggleY = f.y + math.sin(f.pathT * 8) * 0.8;
    return f.copyWith(
      glow: 1,
      highlight: 1,
      y: PondBounds.clampY(area, wiggleY),
    );
  }

  static PondFishEntity _updateSinking(PondFishEntity f, Size area, double delta) {
    final sink = (f.sinkProgress + delta * 1.8).clamp(0.0, 1.0);
    if (sink >= 1) return f.copyWith(phase: FishPhase.gone, sinkProgress: 1);
    final nextY = PondBounds.clampY(area, f.y + delta * 28);
    return f.copyWith(
      sinkProgress: sink,
      y: nextY,
      glow: (1 - sink).clamp(0.0, 1.0),
    );
  }

  static PondFishEntity _updateEntering(
    PondFishEntity f,
    Size area,
    double delta,
    double speed,
  ) {
    final enter = (f.enterProgress + delta * 0.32 * speed).clamp(0.0, 1.0);
    final target = _enterTarget(area, f.pathSeed);
    final eased = _easeOutCubic(enter);
    if (enter >= 1) {
      return f.copyWith(
        phase: FishPhase.swimming,
        enterProgress: 1,
        x: target.$1,
        y: target.$2,
        depth: PondBounds.depthFactor(area, target.$2),
      );
    }
    return f.copyWith(
      enterProgress: enter,
      x: f.enterFromX + (target.$1 - f.enterFromX) * eased,
      y: f.enterFromY + (target.$2 - f.enterFromY) * eased,
      depth: PondBounds.depthFactor(
        area,
        f.enterFromY + (target.$2 - f.enterFromY) * eased,
      ),
    );
  }

  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

  static DuckEntity updateDuck(
    DuckEntity duck,
    Size area,
    double delta,
    HungryDuckSettings settings,
    PondFishEntity? targetFish,
  ) {
    final speed = settings.duckSpeedMult * settings.animationIntensity;
    final reduced = settings.reducedMotion ? 0.65 : 1.0;
    var d = duck.copyWith(
      animPhase: duck.animPhase + delta * 2.2,
      blinkTimer: duck.blinkTimer + delta,
      ripplePhase: duck.ripplePhase + delta * 3,
      wingFlap: duck.wingFlap + delta * 5,
    );

    return switch (duck.phase) {
      DuckPhase.idleSwim => _updateIdleSwim(d, area, delta, speed * reduced),
      DuckPhase.chasing => _updateChasing(d, area, targetFish, delta, speed * 1.15),
      DuckPhase.eating => _updateEating(d, area, delta, speed),
      DuckPhase.celebrating => _updateCelebrating(d, area, delta, speed),
    };
  }

  static DuckEntity _updateIdleSwim(
    DuckEntity d,
    Size area,
    double delta,
    double speed,
  ) {
    // Stay where the duck caught the fish; bobbing is rendered in DuckWidget.
    final x = d.restX ?? d.x;
    final y = d.restY ?? d.y;
    return d.copyWith(
      x: PondBounds.clampX(area, x),
      y: PondBounds.clampY(area, y),
    );
  }

  static DuckEntity _updateChasing(
    DuckEntity d,
    Size area,
    PondFishEntity? target,
    double delta,
    double speed,
  ) {
    if (target == null) {
      return d.copyWith(phase: DuckPhase.idleSwim, clearTarget: true);
    }
    final dx = target.x - d.x;
    final dy = target.y - d.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= catchDistance) {
      return d.copyWith(
        phase: DuckPhase.eating,
        eatProgress: 0,
        chaseProgress: 1,
        restX: d.x,
        restY: d.y,
      );
    }
    final step = 90 * delta * speed * (d.chaseProgress.clamp(0.3, 1.0));
    final nx = d.x + (dx / dist) * step;
    final ny = d.y + (dy / dist) * step + math.sin(d.animPhase * 4) * 2;
    final chase = (d.chaseProgress + delta * 0.8).clamp(0.0, 1.0);
    final clamped = PondBounds.clampPoint(area, nx, ny);
    return d.copyWith(
      x: clamped.$1,
      y: clamped.$2,
      facingRight: dx >= 0,
      chaseProgress: chase,
    );
  }

  static DuckEntity _updateEating(DuckEntity d, Size area, double delta, double speed) {
    final baseY = d.restY ?? d.y;
    final eat = (d.eatProgress + delta * 2.2 * speed).clamp(0.0, 1.0);
    if (eat >= 1) {
      return d.copyWith(
        phase: DuckPhase.celebrating,
        celebrateProgress: 0,
        eatProgress: 1,
        x: d.restX ?? d.x,
        y: baseY,
      );
    }
    return d.copyWith(
      eatProgress: eat,
      x: d.restX ?? d.x,
      y: PondBounds.clampY(area, baseY + math.sin(eat * math.pi * 6) * 2),
      wingFlap: d.wingFlap + delta * 12,
    );
  }

  static DuckEntity _updateCelebrating(DuckEntity d, Size area, double delta, double speed) {
    final baseY = d.restY ?? d.y;
    final cel = (d.celebrateProgress + delta * 1.8 * speed).clamp(0.0, 1.0);
    if (cel >= 1) {
      return d.copyWith(
        phase: DuckPhase.idleSwim,
        celebrateProgress: 1,
        clearTarget: true,
        chaseProgress: 0,
        x: d.restX ?? d.x,
        y: baseY,
      );
    }
    return d.copyWith(
      celebrateProgress: cel,
      x: d.restX ?? d.x,
      y: PondBounds.clampY(area, baseY - math.sin(cel * math.pi) * 6),
      wingFlap: d.wingFlap + delta * 10,
    );
  }

  static PondVisitorEntity updateVisitor(
    PondVisitorEntity v,
    Size area,
    double delta,
    HungryDuckSettings settings,
  ) {
    if (v.phase == PondVisitorPhase.gone) return v;

    final speed = settings.animationIntensity * 40;
    var lifetime = v.lifetime - delta;
    var x = v.x;
    var y = v.y;
    var phase = v.phase;

    switch (v.kind) {
      case PondVisitorKind.turtle:
        x += delta * speed * 0.35;
        if (x > area.width + 60 || lifetime <= 0) phase = PondVisitorPhase.gone;
      case PondVisitorKind.frog:
        if (v.wasTapped && v.progress < 0.5) {
          y -= delta * 30;
        }
        if (lifetime <= 0) phase = PondVisitorPhase.gone;
      case PondVisitorKind.dragonfly:
        x += math.sin(v.animPhase) * delta * speed * 0.8;
        y += delta * speed * 0.15;
        if (y > area.height * 0.5 || lifetime <= 0) phase = PondVisitorPhase.gone;
      case PondVisitorKind.butterfly:
        x += math.cos(v.animPhase) * delta * speed * 0.5;
        y -= delta * speed * 0.25;
        if (y < -30 || lifetime <= 0) phase = PondVisitorPhase.gone;
    }

    if (v.wasTapped && phase == PondVisitorPhase.active) {
      phase = PondVisitorPhase.reacted;
    }

    return v.copyWith(
      x: x,
      y: y,
      lifetime: lifetime,
      animPhase: v.animPhase + delta * 3,
      progress: (v.progress + delta).clamp(0.0, 1.0),
      phase: phase,
    );
  }

  static bool shouldMarkGoldenDue(int elapsed, int nextGoldenAt) => elapsed >= nextGoldenAt;

  static ({int points, int coins, int xp, int stars}) catchReward(
    HungryDuckSettings settings, {
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

  static HungryDuckResult buildResult(HungryDuckState state) => HungryDuckResult(
        fishCaught: state.fishCaught,
        goldenCaught: state.goldenCaught,
        visitorsTapped: state.visitorsTapped,
        duckSwims: state.duckSwims,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickEncouragement(int count, {bool isGolden = false}) {
    if (isGolden) return 'Golden Fish!';
    return kFishEncouragements[count % kFishEncouragements.length];
  }

  static String pickVisitorMessage(int count) =>
      kVisitorMessages[count % kVisitorMessages.length];
}
