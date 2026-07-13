import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';

abstract final class FishSpawner {
  static final _random = math.Random();
  static int _idCounter = 0;

  static String _nextId() => 'fish_${_idCounter++}';

  static FishEntity create({
    required Size playArea,
    required OceanFishSettings settings,
    int? variantIndex,
    required int slotIndex,
    required int totalSlots,
  }) {
    final variant = variantIndex ?? _random.nextInt(kFishVariants.length);
    final entry = _randomEntry(playArea);
    final target = _slotTarget(playArea, slotIndex, totalSlots);
    final control = _bezierControl(entry.$1, entry.$2, target.$1, target.$2);
    final baseSize = 72.0 * settings.fishSizeScale;

    return FishEntity(
      id: _nextId(),
      variantIndex: variant % kFishVariants.length,
      slotIndex: slotIndex,
      x: entry.$1,
      y: entry.$2,
      rotation: entry.$3,
      phase: FishPhase.entering,
      size: baseSize.clamp(64, 110),
      startX: entry.$1,
      startY: entry.$2,
      controlX: control.$1,
      controlY: control.$2,
      targetX: target.$1,
      targetY: target.$2,
      waitAngle: _random.nextDouble() * math.pi * 2,
    );
  }

  static (double x, double y, double rotation) _randomEntry(Size area) {
    final edge = _random.nextInt(4);
    final pad = 40.0;
    return switch (edge) {
      0 => (-pad, _random.nextDouble() * area.height, 0.0), // left
      1 => (area.width + pad, _random.nextDouble() * area.height, math.pi), // right
      2 => (_random.nextDouble() * area.width, -pad, math.pi / 2), // top
      _ => (_random.nextDouble() * area.width, area.height + pad, -math.pi / 2), // bottom
    };
  }

  static (double x, double y) _slotTarget(Size area, int slot, int total) {
    final cx = area.width * 0.5;
    final cy = area.height * 0.5;
    final spread = math.min(area.width, area.height) * 0.26;
    final angle = (2 * math.pi * slot / total) - math.pi / 2;
    return (cx + math.cos(angle) * spread, cy + math.sin(angle) * spread);
  }

  /// Exit point far along the fish's current heading (head faces +rotation).
  static (double x, double y) exitAlongHeading(
    double x,
    double y,
    double rotation,
    Size area,
  ) {
    final dx = math.cos(rotation);
    final dy = math.sin(rotation);
    var t = 1200.0;
    if (dx > 0.001) t = math.min(t, (area.width + 80 - x) / dx);
    if (dx < -0.001) t = math.min(t, (-80 - x) / dx);
    if (dy > 0.001) t = math.min(t, (area.height + 80 - y) / dy);
    if (dy < -0.001) t = math.min(t, (-80 - y) / dy);
    return (x + dx * t, y + dy * t);
  }

  static (double x, double y) _bezierControl(
    double sx,
    double sy,
    double tx,
    double ty,
  ) {
    final mx = (sx + tx) / 2;
    final my = (sy + ty) / 2;
    final offset = 60 + _random.nextDouble() * 80;
    final angle = _random.nextDouble() * math.pi * 2;
    return (mx + math.cos(angle) * offset, my + math.sin(angle) * offset);
  }
}

abstract final class FishMovement {
  static List<FishEntity> update({
    required List<FishEntity> fish,
    required Size playArea,
    required double delta,
    required double speedMult,
  }) {
    return fish
        .map((f) => _updateOne(f, playArea, delta, speedMult))
        .where((f) => f.phase != FishPhase.gone)
        .toList(growable: false);
  }

  static FishEntity _updateOne(
    FishEntity f,
    Size playArea,
    double delta,
    double speedMult,
  ) {
    switch (f.phase) {
      case FishPhase.entering:
        final step = delta * 0.35 * speedMult;
        final t = (f.pathT + step).clamp(0.0, 1.0);
        final pos = _quadBezier(
          f.startX, f.startY,
          f.controlX, f.controlY,
          f.targetX, f.targetY,
          t,
        );
        final rot = _bezierTangent(
          f.startX, f.startY,
          f.controlX, f.controlY,
          f.targetX, f.targetY,
          t,
        );
        if (t >= 1.0) {
          return f.copyWith(
            x: pos.$1, y: pos.$2, rotation: rot,
            phase: FishPhase.waiting, pathT: 1,
          );
        }
        return f.copyWith(x: pos.$1, y: pos.$2, rotation: rot, pathT: t);

      case FishPhase.waiting:
        final angle = f.waitAngle + delta * 0.8 * speedMult;
        const orbitR = 16.0;
        final nx = f.targetX + math.cos(angle) * orbitR;
        final ny = f.targetY + math.sin(angle) * orbitR;
        return f.copyWith(
          x: nx,
          y: ny,
          rotation: angle + math.pi / 2,
          waitAngle: angle,
          wiggle: math.sin(angle * 3) * 0.03,
        );

      case FishPhase.tapped:
        final wiggle = f.wiggle + delta * 10;
        return f.copyWith(wiggle: math.sin(wiggle) * 0.04);

      case FishPhase.exiting:
        final speed = 320.0 * speedMult * delta;
        final nx = f.x + math.cos(f.rotation) * speed;
        final ny = f.y + math.sin(f.rotation) * speed;
        if (nx < -80 ||
            nx > playArea.width + 80 ||
            ny < -80 ||
            ny > playArea.height + 80) {
          return f.copyWith(phase: FishPhase.gone);
        }
        return f.copyWith(
          x: nx,
          y: ny,
          wiggle: math.sin(f.wiggle + delta * 8) * 0.025,
        );

      case FishPhase.gone:
        return f;
    }
  }

  static (double x, double y) _quadBezier(
    double sx, double sy,
    double cx, double cy,
    double tx, double ty,
    double t,
  ) {
    final u = 1 - t;
    final x = u * u * sx + 2 * u * t * cx + t * t * tx;
    final y = u * u * sy + 2 * u * t * cy + t * t * ty;
    return (x, y);
  }

  static double _bezierTangent(
    double sx, double sy,
    double cx, double cy,
    double tx, double ty,
    double t,
  ) {
    final u = 1 - t;
    final dx = 2 * u * (cx - sx) + 2 * t * (tx - cx);
    final dy = 2 * u * (cy - sy) + 2 * t * (ty - cy);
    if (dx.abs() < 0.001 && dy.abs() < 0.001) {
      return _angleToward(sx, sy, tx, ty);
    }
    return math.atan2(dy, dx);
  }

  static double _angleToward(double x, double y, double tx, double ty) {
    return math.atan2(ty - y, tx - x);
  }
}

abstract final class OceanFishScoring {
  static ({int coins, int xp, int stars}) rewardForTap(OceanFishSettings s) {
    final m = s.rewardMultiplier;
    return (
      coins: (1 * m).round().clamp(1, 5),
      xp: (5 * m).round().clamp(1, 15),
      stars: fishTappedEveryN(1) ? 1 : 0,
    );
  }

  static bool fishTappedEveryN(int count) => count > 0 && count % 5 == 0;

  static OceanFishResult buildResult(OceanFishState state) => OceanFishResult(
        fishTapped: state.fishTapped,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );
}
