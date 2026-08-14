import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

abstract final class CatchTheFallingStarsLogic {
  static final random = math.Random();

  static const piecesPerConstellation = 5;

  static double starRadius(Size area, int starCount, bool largerTouch) {
    final base = math.min(area.width, area.height);
    final density = switch (starCount.clamp(3, 8)) {
      3 || 4 => 0.11,
      5 || 6 => 0.095,
      _ => 0.085,
    };
    final r = base * density;
    return (largerTouch ? r * 1.12 : r).clamp(36.0, 72.0);
  }

  static Offset? pickSpawnPosition(
    Size area,
    List<FallingStarEntity> existing, {
    required double radius,
    bool leftHanded = false,
  }) {
    final padX = area.width * 0.08;
    final padTop = area.height * 0.08;
    final padBottom = area.height * 0.28;
    final minDist = radius * 2.6;

    for (var attempt = 0; attempt < 40; attempt++) {
      var x = padX + random.nextDouble() * (area.width - padX * 2);
      if (leftHanded) {
        x = area.width - x;
      }
      final y = padTop + random.nextDouble() * (area.height - padTop - padBottom);

      final tooClose = existing.any((s) {
        if (!s.isTappable && s.phase != StarLifePhase.appearing) return false;
        final dx = s.x - x;
        final dy = s.y - y;
        return math.sqrt(dx * dx + dy * dy) < minDist;
      });
      if (!tooClose) return Offset(x, y);
    }

    // Fallback grid slot if random fails.
    final cols = 3;
    final rows = 3;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final x = padX + (c + 0.5) * (area.width - padX * 2) / cols;
        final y = padTop + (r + 0.5) * (area.height - padTop - padBottom) / rows;
        final tooClose = existing.any((s) {
          if (!s.isTappable) return false;
          final dx = s.x - x;
          final dy = s.y - y;
          return math.sqrt(dx * dx + dy * dy) < minDist * 0.85;
        });
        if (!tooClose) return Offset(x, y);
      }
    }
    return null;
  }

  static FallingStarEntity createStar(
    Offset pos,
    double radius,
    CatchTheFallingStarsSettings settings,
  ) {
    final variants = StarVariant.values;
    final accessories = StarAccessory.values;
    final idles = StarIdleAnim.values;
    return FallingStarEntity(
      id: 'star_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(9999)}',
      x: pos.dx,
      y: pos.dy,
      radius: radius,
      phase: StarLifePhase.appearing,
      variant: variants[random.nextInt(variants.length)],
      accessory: accessories[random.nextInt(accessories.length)],
      idleAnim: idles[random.nextInt(idles.length)],
      appearProgress: 0,
      stationaryTimer: settings.stationarySeconds,
      swayPhase: random.nextDouble() * math.pi * 2,
      glowPulse: random.nextDouble() * math.pi * 2,
    );
  }

  static List<FallingStarEntity> spawnInitialStars(
    Size area,
    CatchTheFallingStarsSettings settings,
  ) {
    final count = settings.effectiveStarCount;
    final radius = starRadius(area, count, settings.largerTouchTargets);
    final stars = <FallingStarEntity>[];
    for (var i = 0; i < count; i++) {
      final pos = pickSpawnPosition(
        area,
        stars,
        radius: radius,
        leftHanded: settings.leftHandedLayout,
      );
      if (pos == null) break;
      stars.add(createStar(pos, radius, settings).copyWith(
        appearProgress: 1,
        phase: StarLifePhase.stationary,
      ));
    }
    return stars;
  }

  static FallingStarEntity updateStar(
    FallingStarEntity star,
    double delta,
    CatchTheFallingStarsSettings settings,
    double playHeight,
  ) {
    final intensity = settings.reducedMotion ? 0.35 : 1.0;
    final anim = star.animPhase + delta * 2.8 * intensity;
    final sway = star.swayPhase + delta * 1.6 * intensity;
    final glow = star.glowPulse + delta * 2.2 * intensity;

    return switch (star.phase) {
      StarLifePhase.appearing => _updateAppearing(star, delta, anim, sway, glow),
      StarLifePhase.stationary =>
        _updateStationary(star, delta, settings, anim, sway, glow),
      StarLifePhase.falling =>
        _updateFalling(star, delta, settings, playHeight, anim, sway, glow),
      StarLifePhase.collected =>
        _updateCollected(star, delta, anim, sway, glow),
      StarLifePhase.driftedOff =>
        _updateDrifted(star, delta, anim, sway, glow),
      StarLifePhase.gone => star,
    };
  }

  static FallingStarEntity _updateAppearing(
    FallingStarEntity s,
    double delta,
    double anim,
    double sway,
    double glow,
  ) {
    final p = (s.appearProgress + delta * 2.4).clamp(0.0, 1.0);
    if (p >= 1) {
      return s.copyWith(
        phase: StarLifePhase.stationary,
        appearProgress: 1,
        animPhase: anim,
        swayPhase: sway,
        glowPulse: glow,
      );
    }
    return s.copyWith(
      appearProgress: p,
      animPhase: anim,
      swayPhase: sway,
      glowPulse: glow,
    );
  }

  static FallingStarEntity _updateStationary(
    FallingStarEntity s,
    double delta,
    CatchTheFallingStarsSettings settings,
    double anim,
    double sway,
    double glow,
  ) {
    final timer = s.stationaryTimer - delta;
    if (timer <= 0) {
      return s.copyWith(
        phase: StarLifePhase.falling,
        stationaryTimer: 0,
        animPhase: anim,
        swayPhase: sway,
        glowPulse: glow,
      );
    }
    return s.copyWith(
      stationaryTimer: timer,
      animPhase: anim,
      swayPhase: sway,
      glowPulse: glow,
    );
  }

  static FallingStarEntity _updateFalling(
    FallingStarEntity s,
    double delta,
    CatchTheFallingStarsSettings settings,
    double playHeight,
    double anim,
    double sway,
    double glow,
  ) {
    final speed = settings.fallSpeedPxPerSec;
    final side = math.sin(sway) * (settings.reducedMotion ? 4 : 12);
    final ny = s.y + speed * delta;
    final nx = s.x + side * delta * 0.35;

    if (ny > playHeight + s.radius) {
      return s.copyWith(
        phase: StarLifePhase.driftedOff,
        y: ny,
        x: nx,
        driftProgress: 0,
        animPhase: anim,
        swayPhase: sway,
        glowPulse: glow,
      );
    }
    return s.copyWith(
      y: ny,
      x: nx,
      animPhase: anim,
      swayPhase: sway,
      glowPulse: glow,
    );
  }

  static FallingStarEntity _updateCollected(
    FallingStarEntity s,
    double delta,
    double anim,
    double sway,
    double glow,
  ) {
    final p = (s.collectProgress + delta * 2.2).clamp(0.0, 1.0);
    if (p >= 1) {
      return s.copyWith(phase: StarLifePhase.gone, collectProgress: 1);
    }
    return s.copyWith(
      collectProgress: p,
      y: s.y - 80 * delta,
      animPhase: anim + delta * 6,
      swayPhase: sway,
      glowPulse: glow,
    );
  }

  static FallingStarEntity _updateDrifted(
    FallingStarEntity s,
    double delta,
    double anim,
    double sway,
    double glow,
  ) {
    final p = (s.driftProgress + delta * 1.8).clamp(0.0, 1.0);
    if (p >= 1) {
      return s.copyWith(phase: StarLifePhase.gone, driftProgress: 1);
    }
    return s.copyWith(
      driftProgress: p,
      animPhase: anim,
      swayPhase: sway,
      glowPulse: glow,
    );
  }

  static TapSparkle updateSparkle(TapSparkle s, double delta) {
    return s.copyWith(progress: (s.progress + delta * 1.8).clamp(0.0, 1.0));
  }

  static ({int coins, int xp, int stars, int rewardPoints}) tapReward(
    CatchTheFallingStarsSettings settings,
    int streak,
  ) {
    final m = settings.rewardMultiplier;
    final streakBonus = (streak / 5).floor().clamp(0, 3);
    final coins = settings.coinRewardsEnabled
        ? ((5 + streakBonus) * m).round().clamp(2, 16)
        : 0;
    final xp = ((6 + streakBonus) * m).round().clamp(2, 18);
    final rewardPoints = ((3 + streakBonus) * m).round().clamp(1, 12);
    final stars = streak > 0 && streak % 5 == 0 ? 1 : 0;
    return (coins: coins, xp: xp, stars: stars, rewardPoints: rewardPoints);
  }

  static String pickEncouragement(int taps) =>
      kCatchStarsEncouragements[taps % kCatchStarsEncouragements.length];

  static String pickEndMessage(int taps) =>
      kCatchStarsEndMessages[taps % kCatchStarsEndMessages.length];

  static ConstellationShape nextConstellation(ConstellationShape current) {
    final values = ConstellationShape.values;
    final idx = (values.indexOf(current) + 1) % values.length;
    return values[idx];
  }

  static CatchTheFallingStarsResult buildResult(CatchTheFallingStarsState state) {
    final played = state.settings.practiceMode
        ? state.settings.sessionSeconds
        : (state.settings.sessionSeconds - state.remainingSeconds)
            .clamp(0, state.settings.sessionSeconds);
    return CatchTheFallingStarsResult(
      starsCollected: state.starsCollected,
      coins: state.coinsEarned,
      stars: state.starsEarned,
      xp: state.xpEarned,
      rewardPoints: state.rewardPoints,
      longestStreak: state.longestStreak,
      longestConstellation: state.longestConstellation,
      constellationPieces: state.constellationPieces,
      sessionSeconds: played,
      encouragement: pickEndMessage(state.starsCollected),
    );
  }

  static GameRewardResult toReward(CatchTheFallingStarsResult result) =>
      GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.starsCollected >= 15 && result.longestStreak >= 5,
      );
}
