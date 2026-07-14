import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

abstract final class FlowerGardenLogic {
  static final random = math.Random();
  static int _flowerId = 0;
  static int _beeId = 0;

  static List<FlowerEntity> spawnFlowers(Size area, int count) {
    final slots = _flowerSlots(area, count);
    return List.generate(count, (i) {
      final pos = slots[i];
      final sway = random.nextDouble() * math.pi * 2;
      return FlowerEntity(
        id: 'flower_${_flowerId++}',
        anchorX: pos.$1,
        anchorY: pos.$2,
        x: pos.$1,
        y: pos.$2,
        swayPhase: sway,
        petalCount: 5 + random.nextInt(4),
        petalSpread: 0.85 + random.nextDouble() * 0.35,
      );
    });
  }

  static List<(double, double)> _flowerSlots(Size area, int count) {
    final margin = area.shortestSide * 0.14;
    final all = [
      (area.width * 0.28, area.height * 0.32),
      (area.width * 0.72, area.height * 0.32),
      (area.width * 0.32, area.height * 0.62),
      (area.width * 0.68, area.height * 0.62),
      (area.width * 0.5, area.height * 0.47),
    ];
    return all
        .take(count)
        .map(
          (p) => (
            p.$1.clamp(margin, area.width - margin),
            p.$2.clamp(margin, area.height - margin),
          ),
        )
        .toList(growable: false);
  }

  static (double x, double y) randomAnchor(Size area, List<FlowerEntity> existing) {
    final margin = area.shortestSide * 0.14;
    for (var attempt = 0; attempt < 24; attempt++) {
      final x = margin +
          random.nextDouble() * (area.width - margin * 2);
      final y = margin +
          random.nextDouble() * (area.height - margin * 2);
      final tooClose = existing.any((f) {
        if (f.phase == FlowerPhase.cooldown) return false;
        final dx = f.anchorX - x;
        final dy = f.anchorY - y;
        return math.sqrt(dx * dx + dy * dy) < area.shortestSide * 0.18;
      });
      if (!tooClose) return (x, y);
    }
    return (area.width * 0.5, area.height * 0.5);
  }

  static BloomPalette pickPalette(int bloomsCount) {
    final idx = (random.nextInt(kBloomPalettes.length) + bloomsCount) %
        kBloomPalettes.length;
    return kBloomPalettes[idx];
  }

  static int paletteIndexFor(BloomPalette palette) =>
      kBloomPalettes.indexWhere((p) => p.name == palette.name);

  static BeeEntity spawnBee(Size area, String flowerId, double fx, double fy) {
    final edge = random.nextInt(4);
    final start = _edgePoint(area, edge);
    return BeeEntity(
      id: 'bee_${_beeId++}',
      flowerId: flowerId,
      x: start.$1,
      y: start.$2,
      phase: PollinatorPhase.entering,
      rotation: _angleToward(start.$1, start.$2, fx, fy),
    );
  }

  static (double x, double y) _edgePoint(Size area, int edge) {
    const pad = 40.0;
    return switch (edge) {
      0 => (-pad, area.height * random.nextDouble()),
      1 => (area.width + pad, area.height * random.nextDouble()),
      2 => (area.width * random.nextDouble(), -pad),
      _ => (area.width * random.nextDouble(), area.height + pad),
    };
  }

  static double _angleToward(double x, double y, double tx, double ty) =>
      math.atan2(ty - y, tx - x);

  static ({int coins, int xp, int stars}) bloomReward(FlowerGardenSettings s) {
    final m = s.rewardMultiplier;
    return (
      coins: (2 * m).round().clamp(1, 6),
      xp: (5 * m).round().clamp(1, 15),
      stars: 0,
    );
  }

  static ({int coins, int xp, int stars}) beeReward(
    FlowerGardenSettings s,
    int bloomsCount,
  ) {
    final m = s.rewardMultiplier;
    final star = bloomsCount > 0 && bloomsCount % 3 == 0 ? 1 : 0;
    return (
      coins: (3 * m).round().clamp(1, 8),
      xp: (8 * m).round().clamp(1, 18),
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
      );

  static FlowerEntity updateFlower(
    FlowerEntity f,
    double delta,
    double intensity,
    double moveMult,
  ) {
    final sway = math.sin(f.swayPhase + delta * 1.2 * intensity) * 10 * intensity;
    final drift = math.cos(f.swayPhase * 0.7) * 4 * intensity;
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
            (f.bloomProgress + delta * 0.5 * intensity).clamp(0.0, 1.0);
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
        const closeDuration = 1.2;
        final bloom = (1.0 - (timer / closeDuration)).clamp(0.0, 1.0);
        if (bloom <= 0.02 || timer >= closeDuration) {
          return updated.copyWith(
            phase: FlowerPhase.bud,
            bloomProgress: 0,
            opacity: 1,
            phaseTimer: 0,
            x: f.anchorX + sway,
            y: f.anchorY + drift,
            petalCount: 5 + random.nextInt(4),
            petalSpread: 0.85 + random.nextDouble() * 0.35,
            paletteIndex: paletteIndexFor(
              pickPalette(f.petalCount),
            ),
          );
        }
        return updated.copyWith(
          phaseTimer: timer,
          bloomProgress: bloom,
          x: f.anchorX + sway * 0.25,
          y: f.anchorY,
        );
    }
  }

  static BeeEntity updateBee({
    required BeeEntity bee,
    required double flowerX,
    required double flowerY,
    required double delta,
    required double intensity,
    required void Function(BeeEntity bee) onNectarCollected,
  }) {
    if (bee.phase == PollinatorPhase.gone) return bee;

    final wing = bee.wingPhase + delta * 18 * intensity;
    return switch (bee.phase) {
      PollinatorPhase.entering => _moveToward(
          bee,
          flowerX,
          flowerY,
          delta * 130 * intensity,
          wing,
          PollinatorPhase.collecting,
          40,
        ),
      PollinatorPhase.collecting => () {
          final prog = bee.progress + delta;
          if (prog >= 2.0) {
            onNectarCollected(bee);
            return bee.copyWith(
              phase: PollinatorPhase.leaving,
              progress: 0,
              wingPhase: wing,
            );
          }
          return bee.copyWith(
            progress: prog,
            wingPhase: wing,
            x: flowerX + math.cos(prog * 3) * 6,
            y: flowerY + math.sin(prog * 2.5) * 5,
          );
        }(),
      PollinatorPhase.leaving => _moveAway(bee, flowerX, flowerY, delta * 150, wing),
      PollinatorPhase.gone => bee,
    };
  }

  static BeeEntity _moveToward(
    BeeEntity b,
    double tx,
    double ty,
    double speed,
    double wing,
    PollinatorPhase next,
    double arriveDist,
  ) {
    final dx = tx - b.x;
    final dy = ty - b.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= arriveDist) {
      return b.copyWith(
        x: tx,
        y: ty - 10,
        phase: next,
        progress: 0,
        wingPhase: wing,
      );
    }
    final step = speed / dist;
    return b.copyWith(
      x: b.x + dx * step,
      y: b.y + dy * step,
      rotation: math.atan2(dy, dx),
      wingPhase: wing,
    );
  }

  static BeeEntity _moveAway(
    BeeEntity b,
    double fromX,
    double fromY,
    double speed,
    double wing,
  ) {
    final angle = b.rotation + math.pi + (random.nextDouble() - 0.5) * 0.5;
    final nx = b.x + math.cos(angle) * speed;
    final ny = b.y + math.sin(angle) * speed;
    final dist = math.sqrt(
      (nx - fromX) * (nx - fromX) + (ny - fromY) * (ny - fromY),
    );
    if (dist > 350) {
      return b.copyWith(phase: PollinatorPhase.gone, wingPhase: wing);
    }
    return b.copyWith(x: nx, y: ny, rotation: angle, wingPhase: wing);
  }
}
