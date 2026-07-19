import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

abstract final class BalloonLogic {
  static final random = math.Random();
  static int _id = 0;

  static const laneCount = 5;
  static const popDuration = 0.35;
  static const bounceDuration = 0.12;
  static const wobbleDuration = 0.55;
  static const riseSpeed = 95.0; // px/sec
  static const minLaneGap = 0.18; // fraction of screen height

  static double laneCenterX(Size area, int lane) {
    final laneW = area.width / laneCount;
    return laneW * (lane + 0.5);
  }

  /// Prefer less-crowded lanes; still allows consecutive same-lane spawns.
  static List<int> pickLanes({
    required int count,
    required List<BalloonEntity> existing,
    required Size area,
  }) {
    final occupied = <int, double>{};
    for (final b in existing) {
      if (b.phase == BalloonPhase.gone || b.phase == BalloonPhase.popping) {
        continue;
      }
      final prev = occupied[b.lane];
      if (prev == null || b.y > prev) occupied[b.lane] = b.y;
    }

    final picked = <int>[];
    final available = List<int>.generate(laneCount, (i) => i);

    for (var i = 0; i < count; i++) {
      available.sort((a, b) {
        final ya = occupied[a] ?? -1;
        final yb = occupied[b] ?? -1;
        // Prefer lanes with more clearance near the bottom.
        final scoreA = ya < 0 ? 2.0 : (ya / area.height);
        final scoreB = yb < 0 ? 2.0 : (yb / area.height);
        final cmp = scoreB.compareTo(scoreA);
        if (cmp != 0) return cmp;
        return random.nextBool() ? -1 : 1;
      });

      var lane = available.first;
      // Soft collision: skip if another balloon is too close to spawn.
      for (final candidate in available) {
        final bottomY = occupied[candidate];
        if (bottomY == null || bottomY < area.height * (1 - minLaneGap)) {
          lane = candidate;
          break;
        }
      }

      // Avoid immediate double-pick of same lane in one wave when possible.
      if (picked.contains(lane) && available.length > 1) {
        lane = available.firstWhere((l) => !picked.contains(l), orElse: () => lane);
      }

      picked.add(lane);
      occupied[lane] = area.height + 40;
    }

    return picked;
  }

  static BalloonEntity spawnRising({
    required Size area,
    required int lane,
    BalloonHue? hue,
    double? targetY,
    double sizeScale = 1,
  }) {
    final size = (72 + random.nextDouble() * 28) * sizeScale;
    final x = laneCenterX(area, lane);
    return BalloonEntity(
      id: 'balloon_${_id++}',
      lane: lane,
      hue: hue ?? BalloonHue.values[random.nextInt(BalloonHue.values.length)],
      x: x,
      y: area.height + size * 0.6,
      size: size,
      phase: BalloonPhase.rising,
      pattern: BalloonPattern.values[random.nextInt(BalloonPattern.values.length)],
      face: BalloonFace.values[random.nextInt(BalloonFace.values.length)],
      ribbon: BalloonRibbon.values[random.nextInt(BalloonRibbon.values.length)],
      swayPhase: random.nextDouble() * math.pi * 2,
      bobPhase: random.nextDouble() * math.pi * 2,
      shineSeed: random.nextDouble(),
      targetY: targetY,
    );
  }

  /// Five balloons for Color Balloon Pop: unique hues, exactly one target.
  static List<BalloonEntity> spawnColorRound({
    required Size area,
    required BalloonHue target,
    double sizeScale = 1.15,
  }) {
    final hues = <BalloonHue>[target];
    final pool = [...BalloonHue.learningTargets]..remove(target);
    pool.shuffle(random);
    while (hues.length < 5 && pool.isNotEmpty) {
      hues.add(pool.removeLast());
    }
    while (hues.length < 5) {
      hues.add(BalloonHue.values[random.nextInt(BalloonHue.values.length)]);
    }
    hues.shuffle(random);

    final stopY = area.height * 0.48;
    final balloons = <BalloonEntity>[];
    for (var lane = 0; lane < 5; lane++) {
      balloons.add(
        spawnRising(
          area: area,
          lane: lane,
          hue: hues[lane],
          targetY: stopY + (random.nextDouble() - 0.5) * 18,
          sizeScale: sizeScale,
        ),
      );
    }
    return balloons;
  }

  static BalloonHue pickTarget({BalloonHue? avoid}) {
    final pool = [...BalloonHue.learningTargets];
    if (avoid != null && pool.length > 1) pool.remove(avoid);
    return pool[random.nextInt(pool.length)];
  }

  static BalloonEntity update({
    required BalloonEntity balloon,
    required Size area,
    required double delta,
    double speedMult = 1,
    double animationIntensity = 1,
    bool reducedMotion = false,
  }) {
    var b = balloon;
    final swayAmp = reducedMotion ? 4.0 : 10.0 * animationIntensity;
    final swaySpeed = reducedMotion ? 1.2 : 2.4;

    if (b.wobbleTimer > 0) {
      final t = (b.wobbleTimer - delta).clamp(0.0, wobbleDuration);
      final shake = math.sin((wobbleDuration - t) * 28) * 6;
      return b.copyWith(
        wobbleTimer: t,
        x: laneCenterX(area, b.lane) + shake,
      );
    }

    if (b.bounceTimer > 0) {
      final t = (b.bounceTimer - delta).clamp(0.0, bounceDuration);
      final squash = 1.0 + math.sin((1 - t / bounceDuration) * math.pi) * 0.12;
      return b.copyWith(bounceTimer: t, scale: squash);
    }

    return switch (b.phase) {
      BalloonPhase.rising => _updateRising(
          b,
          area,
          delta,
          speedMult,
          swayAmp,
          swaySpeed,
        ),
      BalloonPhase.bobbing => _updateBobbing(b, area, delta, swayAmp, swaySpeed),
      BalloonPhase.popping => _updatePopping(b, delta),
      BalloonPhase.leaving => _updateLeaving(
          b,
          area,
          delta,
          speedMult,
          swayAmp,
          swaySpeed,
        ),
      BalloonPhase.gone => b,
    };
  }

  static BalloonEntity _updateRising(
    BalloonEntity b,
    Size area,
    double delta,
    double speedMult,
    double swayAmp,
    double swaySpeed,
  ) {
    final sway = b.swayPhase + delta * swaySpeed;
    final laneX = laneCenterX(area, b.lane);
    final x = laneX + math.sin(sway) * swayAmp;
    final y = b.y - riseSpeed * speedMult * delta;

    if (b.targetY != null && y <= b.targetY!) {
      return b.copyWith(
        x: x,
        y: b.targetY,
        swayPhase: sway,
        bobPhase: b.bobPhase + delta * 2,
        phase: BalloonPhase.bobbing,
      );
    }

    if (y < -b.size) {
      return b.copyWith(phase: BalloonPhase.gone, y: y, x: x, swayPhase: sway);
    }

    return b.copyWith(x: x, y: y, swayPhase: sway, bobPhase: b.bobPhase + delta);
  }

  static BalloonEntity _updateBobbing(
    BalloonEntity b,
    Size area,
    double delta,
    double swayAmp,
    double swaySpeed,
  ) {
    final sway = b.swayPhase + delta * swaySpeed * 0.7;
    final bob = b.bobPhase + delta * 2.2;
    final laneX = laneCenterX(area, b.lane);
    final baseY = b.targetY ?? b.y;
    return b.copyWith(
      x: laneX + math.sin(sway) * swayAmp * 0.7,
      y: baseY + math.sin(bob) * 6,
      swayPhase: sway,
      bobPhase: bob,
    );
  }

  static BalloonEntity _updatePopping(BalloonEntity b, double delta) {
    final p = b.popProgress + delta / popDuration;
    if (p >= 1) {
      return b.copyWith(phase: BalloonPhase.gone, popProgress: 1, scale: 0);
    }
    final scale = 1.15 - p * 1.15;
    return b.copyWith(popProgress: p, scale: scale.clamp(0.0, 1.3));
  }

  static BalloonEntity _updateLeaving(
    BalloonEntity b,
    Size area,
    double delta,
    double speedMult,
    double swayAmp,
    double swaySpeed,
  ) {
    final sway = b.swayPhase + delta * swaySpeed;
    final laneX = laneCenterX(area, b.lane);
    final y = b.y - riseSpeed * speedMult * 1.25 * delta;
    if (y < -b.size) {
      return b.copyWith(phase: BalloonPhase.gone, y: y);
    }
    return b.copyWith(
      x: laneX + math.sin(sway) * swayAmp,
      y: y,
      swayPhase: sway,
      wave: true,
    );
  }

  static BalloonEntity beginPop(BalloonEntity b) => b.copyWith(
        bounceTimer: bounceDuration,
        phase: BalloonPhase.popping,
        popProgress: 0,
      );

  static BalloonEntity beginWobble(BalloonEntity b) =>
      b.copyWith(wobbleTimer: wobbleDuration);

  static BalloonEntity beginLeave(BalloonEntity b) => b.copyWith(
        phase: BalloonPhase.leaving,
        clearTargetY: true,
        wave: true,
      );

  static BalloonPopReward popReward({
    required double multiplier,
    required int poppedCount,
  }) {
    final m = multiplier.clamp(0.5, 2.0);
    return BalloonPopReward(
      points: (10 * m).round().clamp(5, 30),
      coins: (5 * m).round().clamp(2, 15),
      xp: (5 * m).round().clamp(2, 15),
      stars: poppedCount % 3 == 0 ? 1 : 0,
    );
  }

  static String successPhrase(int n) =>
      kBalloonPopPhrases[n % kBalloonPopPhrases.length];

  static String colorSuccessPhrase(BalloonHue hue, int n) {
    if (n % 3 == 0) return "That's ${hue.displayName}!";
    return kBalloonColorSuccessPhrases[n % kBalloonColorSuccessPhrases.length];
  }

  static String colorTryPhrase(BalloonHue hue, int n) {
    if (n % 2 == 0) return "Let's Find the ${hue.displayName} Balloon!";
    if (n % 3 == 0) return 'Can You Find the ${hue.displayName} One?';
    return kBalloonColorTryPhrases[n % kBalloonColorTryPhrases.length];
  }

  static String instructionFor(BalloonHue hue) {
    final options = [
      'Pop the ${hue.displayName} Balloon!',
      'Find the ${hue.displayName} Balloon!',
      'Can You Pop the ${hue.displayName} Balloon?',
    ];
    return options[random.nextInt(options.length)];
  }
}
