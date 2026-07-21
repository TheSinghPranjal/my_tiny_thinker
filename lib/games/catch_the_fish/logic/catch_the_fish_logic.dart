import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

abstract final class CatchTheFishLogic {
  static final random = math.Random();

  /// Sky occupies the top 20% of the play area.
  static const oceanTopFraction = 0.20;

  /// Fixed lane grid so Y positions stay stable as fish count changes.
  static const _maxLanes = 10;

  static ({double top, double bottom, double left, double right}) oceanBounds(
    Size area,
  ) {
    final marginX = math.max(36.0, area.width * 0.04);
    return (
      top: area.height * 0.22,
      bottom: area.height * 0.92,
      left: marginX,
      right: area.width - marginX,
    );
  }

  /// Boat sits near the ocean surface, horizontally centered.
  static (double, double) boatAnchor(Size area) =>
      (area.width * 0.5, area.height * 0.18);

  static double _laneY(Size area, int lane) {
    final bounds = oceanBounds(area);
    final span = bounds.bottom - bounds.top;
    final t = (lane % _maxLanes) / (_maxLanes - 1);
    return bounds.top + span * (0.12 + t * 0.76);
  }

  static double _depthForY(Size area, double y) {
    final bounds = oceanBounds(area);
    final span = (bounds.bottom - bounds.top).clamp(1.0, double.infinity);
    return ((y - bounds.top) / span).clamp(0.0, 1.0);
  }

  static double _swimSpeed(CatchFishEntity fish) {
    final h = fish.id.hashCode.abs();
    return 40.0 + (h % 31); // 40–70 px/s
  }

  static List<CatchFishEntity> spawnFish(Size area, int count) {
    final n = count.clamp(5, 10);
    final varietyCount = PondFishVarieties.all.length;
    final fish = <CatchFishEntity>[];
    final bounds = oceanBounds(area);
    final usableWidth = bounds.right - bounds.left;
    final spacing = usableWidth / (n + 1);

    for (var i = 0; i < n; i++) {
      final facingRight = i.isEven;
      // Spread across the fixed lane grid so fish aren't stacked.
      final lane = ((i * _maxLanes) / n).floor().clamp(0, _maxLanes - 1);
      final x = bounds.left + spacing * (i + 1);
      final y = _laneY(area, lane);
      fish.add(
        CatchFishEntity(
          id: 'cf_${DateTime.now().microsecondsSinceEpoch}_$i',
          varietyIndex: i % varietyCount,
          x: x,
          y: y,
          lane: lane,
          facingRight: facingRight,
          phase: CatchFishPhase.swimming,
          pathT: random.nextDouble() * math.pi * 2,
          depth: _depthForY(area, y),
        ),
      );
    }
    return fish;
  }

  static CatchFishEntity spawnReplacement(
    Size area,
    List<CatchFishEntity> existing,
  ) {
    final bounds = oceanBounds(area);
    final fromLeft = random.nextBool();
    final varietyCount = PondFishVarieties.all.length;
    final usedVarieties = existing.map((f) => f.varietyIndex).toSet();
    var varietyIndex = random.nextInt(varietyCount);
    for (var i = 0; i < varietyCount; i++) {
      final candidate = (varietyIndex + i) % varietyCount;
      if (!usedVarieties.contains(candidate)) {
        varietyIndex = candidate;
        break;
      }
    }

    final usedLanes = existing.map((f) => f.lane).toSet();
    var lane = random.nextInt(_maxLanes);
    for (var i = 0; i < _maxLanes; i++) {
      final candidate = (lane + i) % _maxLanes;
      if (!usedLanes.contains(candidate)) {
        lane = candidate;
        break;
      }
    }

    final y = _laneY(area, lane);
    final x = fromLeft ? bounds.left - 48 : bounds.right + 48;
    final seed = random.nextInt(99999);

    return CatchFishEntity(
      id: 'cf_${DateTime.now().microsecondsSinceEpoch}_$seed',
      varietyIndex: varietyIndex,
      x: x,
      y: y,
      lane: lane,
      facingRight: fromLeft,
      phase: CatchFishPhase.swimming,
      pathT: random.nextDouble() * math.pi * 2,
      depth: _depthForY(area, y),
    );
  }

  static CatchFishEntity updateFish(
    CatchFishEntity fish,
    Size area,
    double delta,
    CatchFishSettings settings,
  ) {
    if (fish.phase == CatchFishPhase.gone) return fish;
    if (fish.phase == CatchFishPhase.reeling) {
      return updateReeling(fish, area, delta, settings);
    }
    return _updateSwimming(fish, area, delta, settings);
  }

  static CatchFishEntity _updateSwimming(
    CatchFishEntity fish,
    Size area,
    double delta,
    CatchFishSettings settings,
  ) {
    final intensity =
        settings.reducedMotion ? 0.5 : settings.animationIntensity;
    final speed = _swimSpeed(fish) * intensity;
    final dir = fish.facingRight ? 1.0 : -1.0;
    var x = fish.x + dir * speed * delta;
    final pathT = fish.pathT + delta * 1.6;
    final bob = math.sin(pathT) * 6 * intensity;
    final y = _laneY(area, fish.lane) + bob;

    final bounds = oceanBounds(area);
    final margin = 56.0;
    if (x < bounds.left - margin) {
      x = bounds.right + margin * 0.5;
    } else if (x > bounds.right + margin) {
      x = bounds.left - margin * 0.5;
    }

    var glow = fish.glow;
    if (glow > 0) glow = (glow - delta * 2).clamp(0.0, 1.0);

    return fish.copyWith(
      x: x,
      y: y,
      pathT: pathT,
      depth: _depthForY(area, y),
      glow: glow,
    );
  }

  /// Full reel completes in 1.0s; lerps from catch start to boat anchor.
  static CatchFishEntity updateReeling(
    CatchFishEntity fish,
    Size area,
    double delta,
    CatchFishSettings settings,
  ) {
    final intensity =
        settings.reducedMotion ? 0.75 : settings.animationIntensity;
    final progress = (fish.catchProgress + delta * intensity).clamp(0.0, 1.0);
    final (bx, by) = boatAnchor(area);
    final t = progress;
    final x = fish.catchStartX + (bx - fish.catchStartX) * t;
    final y = fish.catchStartY + (by - fish.catchStartY) * t;

    if (progress >= 1) {
      return fish.copyWith(
        phase: CatchFishPhase.gone,
        catchProgress: 1,
        x: bx,
        y: by,
        glow: 0,
      );
    }

    return fish.copyWith(
      catchProgress: progress,
      x: x,
      y: y,
      glow: (1 - progress * 0.4).clamp(0.0, 1.0),
      depth: _depthForY(area, y),
    );
  }

  static ({int coins, int xp, int stars}) catchReward(
    CatchFishSettings settings, {
    required int caught,
  }) {
    final m = settings.rewardMultiplier;
    final coins = (10 * m).round().clamp(1, 40);
    final xp = (5 * m).round().clamp(1, 30);
    final stars = caught % 5 == 0 ? 1 : 0;
    return (coins: coins, xp: xp, stars: stars);
  }

  static CatchTheFishResult buildResult(CatchTheFishState state) =>
      CatchTheFishResult(
        fishCaught: state.fishCaught,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
        endReason: state.endReason,
      );

  static String pickEncouragement(int count) =>
      kCatchEncouragements[count % kCatchEncouragements.length];

  static String pickEndMessage(int count) =>
      kCatchEndMessages[count % kCatchEndMessages.length];
}
