import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/logic/flower_garden_logic.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

abstract final class CloudPopGardenLogic {
  static final random = math.Random();
  static int _pairId = 0;
  static int _cloudId = 0;

  static const rainDuration = 3.5;
  static const thunderDuration = 0.9;
  static const bounceDuration = 0.7;

  static ({List<GardenFlowerEntity> flowers, List<CloudEntity> clouds})
      spawnPairs(Size area, int count) {
    final slots = _flowerSlots(area, count);
    final flowers = <GardenFlowerEntity>[];
    final clouds = <CloudEntity>[];

    for (var i = 0; i < count; i++) {
      final pairId = 'pair_${_pairId++}';
      final pos = slots[i];
      final palette = FlowerGardenLogic.pickPalette(i);
      final flower = GardenFlowerEntity(
        id: 'flower_$pairId',
        pairId: pairId,
        anchorX: pos.$1,
        anchorY: pos.$2,
        swayPhase: random.nextDouble() * math.pi * 2,
        petalCount: 5 + random.nextInt(3),
        paletteIndex: FlowerGardenLogic.paletteIndexFor(palette),
        petalSpread: 0.75 + random.nextDouble() * 0.25,
      );
      flowers.add(flower);

      final targetX = pos.$1;
      final targetY = pos.$2 - area.height * 0.28;
      final start = _edgeSpawn(area, targetX, targetY);
      clouds.add(
        CloudEntity(
          id: 'cloud_${_cloudId++}',
          pairId: pairId,
          flowerId: flower.id,
          x: start.$1,
          y: start.$2,
          targetX: targetX,
          targetY: targetY,
          bobPhase: random.nextDouble() * math.pi * 2,
          spawnDelay: i * 0.35,
          blueLevel: 1,
        ),
      );
    }

    return (flowers: flowers, clouds: clouds);
  }

  static List<(double, double)> _flowerSlots(Size area, int count) {
    final y = area.height * 0.82;
    final positions = switch (count) {
      1 => [(area.width * 0.5, y)],
      2 => [
          (area.width * 0.35, y),
          (area.width * 0.65, y),
        ],
      3 => [
          (area.width * 0.25, y),
          (area.width * 0.5, y),
          (area.width * 0.75, y),
        ],
      4 => [
          (area.width * 0.22, y),
          (area.width * 0.42, y),
          (area.width * 0.62, y),
          (area.width * 0.82, y),
        ],
      _ => [
          (area.width * 0.15, y),
          (area.width * 0.35, y),
          (area.width * 0.55, y),
          (area.width * 0.75, y),
          (area.width * 0.9, y),
        ],
    };
    return positions.take(count).toList(growable: false);
  }

  static (double, double) _edgeSpawn(Size area, double tx, double ty) {
    final edge = random.nextInt(3);
    return switch (edge) {
      0 => (-area.width * 0.12, ty + random.nextDouble() * area.height * 0.15),
      1 => (area.width * 1.12, ty + random.nextDouble() * area.height * 0.15),
      _ => (tx + (random.nextDouble() - 0.5) * area.width * 0.3, -area.height * 0.1),
    };
  }

  static CloudEntity spawnReplacementCloud(
    Size area,
    GardenFlowerEntity flower, [
    double delay = 0,
  ]) {
    final targetX = flower.anchorX;
    final targetY = flower.anchorY - area.height * 0.28;
    final start = _edgeSpawn(area, targetX, targetY);
    return CloudEntity(
      id: 'cloud_${_cloudId++}',
      pairId: flower.pairId,
      flowerId: flower.id,
      x: start.$1,
      y: start.$2,
      targetX: targetX,
      targetY: targetY,
      bobPhase: random.nextDouble() * math.pi * 2,
      spawnDelay: delay,
      blueLevel: 1,
    );
  }

  static bool isAboveFlower(CloudEntity cloud, GardenFlowerEntity flower, Size area) {
    final dx = (cloud.x - flower.anchorX).abs();
    final dy = (cloud.y - cloud.targetY).abs();
    return dx < area.width * 0.09 && dy < area.height * 0.04;
  }

  static CloudTapResult classifyTap(
    CloudEntity cloud,
    GardenFlowerEntity flower,
    Size area,
  ) {
    if (cloud.phase == CloudPhase.raining) return CloudTapResult.ignored;
    if (cloud.phase == CloudPhase.leaving) return CloudTapResult.lateBounce;
    if (isAboveFlower(cloud, flower, area)) {
      return CloudTapResult.successRain;
    }
    if (cloud.phase == CloudPhase.approaching ||
        cloud.phase == CloudPhase.hovering) {
      return CloudTapResult.earlyThunder;
    }
    return CloudTapResult.ignored;
  }

  static CloudEntity updateCloud({
    required CloudEntity cloud,
    required GardenFlowerEntity flower,
    required Size area,
    required double delta,
    required CloudPopGardenSettings settings,
  }) {
    if (cloud.spawnDelay > 0) {
      return cloud.copyWith(spawnDelay: cloud.spawnDelay - delta);
    }

    final speed = 85 * settings.cloudSpeedMult * settings.animationIntensity;
    final bob = math.sin(cloud.bobPhase) * 6 * settings.animationIntensity;
    var updated = cloud.copyWith(
      bobPhase: cloud.bobPhase + delta * 2.2,
      rotation: math.sin(cloud.bobPhase * 0.7) * 0.08,
    );

    if (updated.thunderTimer > 0) {
      final t = updated.thunderTimer - delta;
      return updated.copyWith(
        thunderTimer: t.clamp(0, thunderDuration),
        blueLevel: 0.15,
      );
    }

    if (updated.bounceTimer > 0) {
      final t = updated.bounceTimer - delta;
      return updated.copyWith(
        bounceTimer: t.clamp(0, bounceDuration),
        showSmile: true,
        y: updated.y + math.sin((bounceDuration - t) * 12) * 2,
      );
    }

    return switch (updated.phase) {
      CloudPhase.approaching => _updateApproaching(updated, bob, delta, speed, area),
      CloudPhase.hovering => _updateHovering(updated, bob, delta),
      CloudPhase.raining => _updateRaining(updated, flower, delta, settings),
      CloudPhase.leaving => _updateLeaving(updated, bob, delta, speed, area),
      CloudPhase.gone => updated,
    };
  }

  static CloudEntity _updateApproaching(
    CloudEntity c,
    double bob,
    double delta,
    double speed,
    Size area,
  ) {
    final dx = c.targetX - c.x;
    final dy = c.targetY - c.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    final curve = math.sin(c.bobPhase * 0.9) * area.width * 0.04;

    if (dist < area.width * 0.06) {
      return c.copyWith(
        phase: CloudPhase.hovering,
        x: c.targetX + curve * 0.3,
        y: c.targetY + bob,
      );
    }

    final step = math.min(speed * delta, dist);
    final nx = c.x + (dx / dist) * step + curve * delta * 8;
    final ny = c.y + (dy / dist) * step + bob * delta * 3;
    return c.copyWith(x: nx, y: ny);
  }

  static CloudEntity _updateHovering(CloudEntity c, double bob, double delta) {
    return c.copyWith(
      x: c.targetX + math.sin(c.bobPhase * 1.1) * 8,
      y: c.targetY + bob,
    );
  }

  static CloudEntity _updateRaining(
    CloudEntity c,
    GardenFlowerEntity flower,
    double delta,
    CloudPopGardenSettings settings,
  ) {
    final timer = c.phaseTimer + delta;
    final progress = (timer / rainDuration).clamp(0.0, 1.0);
    final blue = (1.0 - progress).clamp(0.0, 1.0);

    var drops = [...c.rainDrops];
    if (settings.rainSoundEnabled || settings.soundEnabled) {
      if (random.nextDouble() < 0.45) {
        drops.add(
          RainDropEntity(
            x: c.x + (random.nextDouble() - 0.5) * 50,
            y: c.y + 20,
            speed: 180 + random.nextDouble() * 80,
            size: 3 + random.nextDouble() * 3,
          ),
        );
      }
    } else if (random.nextDouble() < 0.35) {
      drops.add(
        RainDropEntity(
          x: c.x + (random.nextDouble() - 0.5) * 50,
          y: c.y + 20,
          speed: 180 + random.nextDouble() * 80,
          size: 3 + random.nextDouble() * 3,
        ),
      );
    }

    drops = drops
        .map((d) => d.copyWith(y: d.y + d.speed * delta))
        .where((d) => d.y < flower.anchorY + 30)
        .take(24)
        .toList(growable: false);

    if (timer >= rainDuration) {
      return c.copyWith(
        phase: CloudPhase.leaving,
        phaseTimer: 0,
        blueLevel: 0.05,
        rainDrops: const [],
        showSmile: true,
      );
    }

    return c.copyWith(
      phaseTimer: timer,
      blueLevel: blue,
      rainDrops: drops,
      y: c.targetY + math.sin(c.bobPhase) * 4,
    );
  }

  static CloudEntity _updateLeaving(
    CloudEntity c,
    double bob,
    double delta,
    double speed,
    Size area,
  ) {
    final exitX = c.x < area.width / 2 ? -area.width * 0.15 : area.width * 1.15;
    final exitY = c.y - area.height * 0.08;
    final dx = exitX - c.x;
    final dy = exitY - c.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 20 || c.x < -80 || c.x > area.width + 80 || c.y < -80) {
      return c.copyWith(phase: CloudPhase.gone, rainDrops: const []);
    }
    final step = speed * 1.1 * delta;
    return c.copyWith(
      x: c.x + (dx / dist) * step,
      y: c.y + (dy / dist) * step + bob * 0.3,
      blueLevel: (c.blueLevel + delta * 0.15).clamp(0.0, 0.25),
    );
  }

  static GardenFlowerEntity updateFlower({
    required GardenFlowerEntity flower,
    required CloudEntity? cloud,
    required double delta,
    required CloudPopGardenSettings settings,
  }) {
    var updated = flower.copyWith(
      swayPhase: flower.swayPhase + delta * 1.2,
      breathePhase: flower.breathePhase + delta * 1.4,
      blinkTimer: flower.blinkTimer + delta,
    );

    if (cloud?.phase == CloudPhase.raining) {
      final bloom = (flower.bloomProgress +
              delta * 0.35 * settings.bloomSpeedMult * settings.animationIntensity)
          .clamp(0.0, 1.0);
      return updated.copyWith(
        phase: bloom >= 1 ? GardenFlowerPhase.open : GardenFlowerPhase.blooming,
        bloomProgress: bloom,
      );
    }

    if (cloud?.phase == CloudPhase.leaving ||
        cloud?.phase == CloudPhase.gone ||
        cloud == null) {
      if (flower.bloomProgress > 0.02) {
        final bloom = (flower.bloomProgress - delta * 0.4).clamp(0.0, 1.0);
        return updated.copyWith(
          phase: bloom <= 0.02 ? GardenFlowerPhase.closed : GardenFlowerPhase.closing,
          bloomProgress: bloom,
        );
      }
    }

    return updated.copyWith(phase: GardenFlowerPhase.closed, bloomProgress: 0);
  }

  static CloudPopReward rainReward(CloudPopGardenSettings settings, int streak) {
    final mult = settings.rewardMultiplier;
    final bonus = streak >= 3 ? 1 : 0;
    return CloudPopReward(
      coins: ((1 + random.nextInt(2)) * mult).round().clamp(1, 4),
      xp: ((4 + random.nextInt(3)) * mult).round().clamp(3, 12),
      stars: streak % 4 == 0 ? 1 + bonus : (streak % 2 == 0 ? 1 : 0),
    );
  }

  static FlowerEntity toFlowerEntity(GardenFlowerEntity f) {
    return FlowerEntity(
      id: f.id,
      anchorX: f.anchorX + math.sin(f.swayPhase) * 3,
      anchorY: f.anchorY,
      x: f.anchorX + math.sin(f.swayPhase) * 3,
      y: f.anchorY,
      bloomProgress: f.bloomProgress,
      swayPhase: f.swayPhase,
      breathePhase: f.breathePhase,
      blinkTimer: f.blinkTimer,
      petalCount: f.petalCount,
      paletteIndex: f.paletteIndex,
      petalSpread: f.petalSpread,
    );
  }
}
