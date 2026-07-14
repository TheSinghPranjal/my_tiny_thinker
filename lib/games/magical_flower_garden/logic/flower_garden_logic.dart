import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

abstract final class FlowerGardenLogic {
  static final random = math.Random();
  static int _pollinatorId = 0;
  static int _birdId = 0;

  static FlowerEntity spawnSingleFlower(Size area) {
    return FlowerEntity(
      id: 'flower_main',
      anchorX: area.width * 0.5,
      anchorY: area.height * 0.52,
      x: area.width * 0.5,
      y: area.height * 0.52,
      swayPhase: random.nextDouble() * math.pi * 2,
      petalCount: 5 + random.nextInt(4),
      petalSpread: 0.85 + random.nextDouble() * 0.35,
    );
  }

  static (double x, double y) randomRelocateAnchor(
    Size area,
    FlowerEntity flower,
    double maxMoveFraction,
  ) {
    final maxDist = area.shortestSide * maxMoveFraction;
    final angle = random.nextDouble() * math.pi * 2;
    final dist = maxDist * (0.45 + random.nextDouble() * 0.55);
    final margin = area.shortestSide * 0.18;
    return (
      (flower.anchorX + math.cos(angle) * dist)
          .clamp(margin, area.width - margin),
      (flower.anchorY + math.sin(angle) * dist)
          .clamp(margin, area.height - margin),
    );
  }

  static BloomPalette pickPalette(int bloomsCount) {
    final idx = (random.nextInt(kBloomPalettes.length) + bloomsCount) %
        kBloomPalettes.length;
    return kBloomPalettes[idx];
  }

  static int paletteIndexFor(BloomPalette palette) =>
      kBloomPalettes.indexWhere((p) => p.name == palette.name);

  static List<PollinatorEntity> spawnPollinators(
    Size area,
    String flowerId,
    double fx,
    double fy,
  ) {
    final count = 1 + random.nextInt(2);
    final kinds = <PollinatorKind>[PollinatorKind.bee, PollinatorKind.butterfly]
      ..shuffle(random);
    return List.generate(count, (i) {
      final kind = kinds[i % kinds.length];
      final edge = random.nextInt(4);
      final start = _edgePoint(area, edge);
      return PollinatorEntity(
        id: 'pollinator_${_pollinatorId++}',
        flowerId: flowerId,
        kind: kind,
        x: start.$1,
        y: start.$2,
        phase: PollinatorPhase.entering,
        rotation: _angleToward(start.$1, start.$2, fx, fy),
      );
    });
  }

  static BirdEntity spawnBird(Size area, double targetX, double targetY) {
    final start = _edgePoint(area, random.nextInt(2));
    return BirdEntity(
      id: 'bird_${_birdId++}',
      x: start.$1,
      y: start.$2,
      targetX: targetX,
      targetY: targetY - 20,
      rotation: _angleToward(start.$1, start.$2, targetX, targetY),
    );
  }

  static (double x, double y) _edgePoint(Size area, int edge) {
    const pad = 50.0;
    return switch (edge) {
      0 => (-pad, area.height * (0.2 + random.nextDouble() * 0.5)),
      1 => (area.width + pad, area.height * (0.2 + random.nextDouble() * 0.5)),
      2 => (area.width * random.nextDouble(), -pad),
      _ => (area.width * random.nextDouble(), area.height + pad),
    };
  }

  static double _angleToward(double x, double y, double tx, double ty) =>
      math.atan2(ty - y, tx - x);

  static ({int coins, int xp, int stars}) bloomReward(FlowerGardenSettings s) {
    final m = s.rewardMultiplier;
    return (
      coins: (5 * m).round().clamp(1, 8),
      xp: (10 * m).round().clamp(3, 20),
      stars: 0,
    );
  }

  static ({int coins, int xp, int stars}) pollinatorReward(
    FlowerGardenSettings s,
    int bloomsCount,
  ) {
    final m = s.rewardMultiplier;
    final star = bloomsCount > 0 && bloomsCount % 3 == 0 ? 1 : 0;
    return (
      coins: (5 * m).round().clamp(1, 8),
      xp: (8 * m).round().clamp(3, 18),
      stars: star,
    );
  }

  static FlowerGardenResult buildResult(FlowerGardenState state) =>
      FlowerGardenResult(
        bloomsCount: state.bloomsCount,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
        endReason: state.endReason,
      );

  static FlowerEntity updateFlower(
    FlowerEntity f,
    double delta,
    double intensity,
    double moveMult,
    Size area,
    FlowerGardenSettings settings,
  ) {
    final sway =
        math.sin(f.swayPhase + delta * 1.2 * intensity) * 12 * intensity * moveMult;
    final drift =
        math.cos(f.swayPhase * 0.7 + delta * 0.4) * 6 * intensity * moveMult;
    var updated = f.copyWith(
      swayPhase: f.swayPhase + delta * 1.1,
      breathePhase: f.breathePhase + delta * 1.5,
      blinkTimer: f.blinkTimer + delta,
    );

    switch (f.phase) {
      case FlowerPhase.bud:
        return updated.copyWith(
          x: f.anchorX + sway,
          y: f.anchorY + drift,
        );

      case FlowerPhase.blooming:
        final progress =
            (f.bloomProgress + delta * 0.45 * intensity).clamp(0.0, 1.0);
        return updated.copyWith(
          x: f.anchorX + sway * 0.5,
          y: f.anchorY,
          bloomProgress: progress,
          phase: progress >= 1 ? FlowerPhase.open : FlowerPhase.blooming,
        );

      case FlowerPhase.open:
        return updated.copyWith(
          x: f.anchorX + sway * 0.3,
          y: f.anchorY,
          bloomProgress: 1,
        );

      case FlowerPhase.cooldown:
        final timer = f.phaseTimer + delta;
        const closeDuration = 1.4;
        final bloom = (1.0 - (timer / closeDuration)).clamp(0.0, 1.0);
        if (bloom <= 0.02 || timer >= closeDuration) {
          final target = randomRelocateAnchor(
            area,
            f,
            settings.maxMoveDistance,
          );
          return updated.copyWith(
            phase: FlowerPhase.relocating,
            bloomProgress: 0,
            opacity: 1,
            phaseTimer: 0,
            targetAnchorX: target.$1,
            targetAnchorY: target.$2,
            petalCount: 5 + random.nextInt(4),
            petalSpread: 0.85 + random.nextDouble() * 0.35,
            paletteIndex: paletteIndexFor(pickPalette(f.petalCount)),
          );
        }
        return updated.copyWith(
          phaseTimer: timer,
          bloomProgress: bloom,
          x: f.anchorX + sway * 0.25,
          y: f.anchorY,
        );

      case FlowerPhase.relocating:
        final tx = f.targetAnchorX ?? f.anchorX;
        final ty = f.targetAnchorY ?? f.anchorY;
        final dx = tx - f.anchorX;
        final dy = ty - f.anchorY;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 4) {
          return updated.copyWith(
            phase: FlowerPhase.bud,
            anchorX: tx,
            anchorY: ty,
            x: tx,
            y: ty,
            clearTarget: true,
            bloomProgress: 0,
          );
        }
        final step = delta * 90 * moveMult * intensity;
        final t = step / dist;
        final nx = f.anchorX + dx * t;
        final ny = f.anchorY + dy * t;
        return updated.copyWith(
          anchorX: nx,
          anchorY: ny,
          x: nx + sway * 0.2,
          y: ny,
        );
    }
  }

  static PollinatorEntity updatePollinator({
    required PollinatorEntity p,
    required double flowerX,
    required double flowerY,
    required double delta,
    required double intensity,
    required void Function(PollinatorEntity p) onNectarCollected,
  }) {
    if (p.phase == PollinatorPhase.gone) return p;

    final wing = p.wingPhase + delta * 18 * intensity;
    return switch (p.phase) {
      PollinatorPhase.entering => _movePollinatorToward(
          p,
          flowerX,
          flowerY,
          delta * 120 * intensity,
          wing,
          PollinatorPhase.collecting,
          44,
        ),
      PollinatorPhase.collecting => () {
          final prog = p.progress + delta;
          if (prog >= 2.2) {
            onNectarCollected(p);
            return p.copyWith(
              phase: PollinatorPhase.leaving,
              progress: 0,
              wingPhase: wing,
            );
          }
          return p.copyWith(
            progress: prog,
            wingPhase: wing,
            x: flowerX + math.cos(prog * 3) * 8,
            y: flowerY + math.sin(prog * 2.5) * 6,
          );
        }(),
      PollinatorPhase.leaving =>
          _movePollinatorAway(p, flowerX, flowerY, delta * 140, wing),
      PollinatorPhase.gone => p,
    };
  }

  static PollinatorEntity _movePollinatorToward(
    PollinatorEntity p,
    double tx,
    double ty,
    double speed,
    double wing,
    PollinatorPhase next,
    double arriveDist,
  ) {
    final dx = tx - p.x;
    final dy = ty - p.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= arriveDist) {
      return p.copyWith(
        x: tx,
        y: ty - 12,
        phase: next,
        progress: 0,
        wingPhase: wing,
      );
    }
    final step = speed / dist;
    return p.copyWith(
      x: p.x + dx * step,
      y: p.y + dy * step,
      rotation: math.atan2(dy, dx),
      wingPhase: wing,
    );
  }

  static PollinatorEntity _movePollinatorAway(
    PollinatorEntity p,
    double fromX,
    double fromY,
    double speed,
    double wing,
  ) {
    final angle = p.rotation + math.pi + (random.nextDouble() - 0.5) * 0.6;
    final nx = p.x + math.cos(angle) * speed;
    final ny = p.y + math.sin(angle) * speed;
    final dist = math.sqrt(
      (nx - fromX) * (nx - fromX) + (ny - fromY) * (ny - fromY),
    );
    if (dist > 380) {
      return p.copyWith(phase: PollinatorPhase.gone, wingPhase: wing);
    }
    return p.copyWith(x: nx, y: ny, rotation: angle, wingPhase: wing);
  }

  static BirdEntity updateBird({
    required BirdEntity bird,
    required double delta,
    required double speedMult,
    required double intensity,
  }) {
    final wing = bird.wingPhase + delta * 14 * intensity;
    return switch (bird.phase) {
      BirdPhase.approaching => _moveBirdToward(
          bird,
          bird.targetX,
          bird.targetY,
          delta * 55 * speedMult * intensity,
          wing,
          BirdPhase.landing,
          36,
        ),
      BirdPhase.scared => () {
          final t = bird.scaredTimer - delta;
          final angle = bird.rotation + delta * 4;
          final nx = bird.x + math.cos(angle) * delta * 180;
          final ny = bird.y + math.sin(angle) * delta * 140 - delta * 30;
          if (t <= 0 || nx < -60 || nx > 500) {
            return bird.copyWith(phase: BirdPhase.gone, wingPhase: wing);
          }
          return bird.copyWith(
            x: nx,
            y: ny,
            rotation: angle,
            wingPhase: wing,
            scaredTimer: t,
          );
        }(),
      BirdPhase.landing => bird.copyWith(phase: BirdPhase.landing, wingPhase: wing),
      BirdPhase.gone => bird,
    };
  }

  static BirdEntity _moveBirdToward(
    BirdEntity b,
    double tx,
    double ty,
    double speed,
    double wing,
    BirdPhase next,
    double arriveDist,
  ) {
    final dx = tx - b.x;
    final dy = ty - b.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= arriveDist) {
      return b.copyWith(x: tx, y: ty, phase: next, wingPhase: wing);
    }
    final step = speed / dist;
    return b.copyWith(
      x: b.x + dx * step,
      y: b.y + dy * step,
      rotation: math.atan2(dy, dx),
      wingPhase: wing,
    );
  }

  static BirdEntity scareBird(BirdEntity bird) => bird.copyWith(
        phase: BirdPhase.scared,
        scaredTimer: 1.2,
      );
}
