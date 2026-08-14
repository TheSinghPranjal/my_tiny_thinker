import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterflies.dart';

abstract final class ButterflyWebMatchingLogic {
  static final random = math.Random();

  static (double, double) _edgeSpawn(Size area) {
    final edge = random.nextInt(4);
    return switch (edge) {
      0 => (-50.0, area.height * (0.15 + random.nextDouble() * 0.55)),
      1 => (area.width + 50.0, area.height * (0.15 + random.nextDouble() * 0.55)),
      2 => (area.width * random.nextDouble(), -50.0),
      _ => (area.width * random.nextDouble(), area.height + 40.0),
    };
  }

  static (double, double) pathPosition(Size area, int seed, double t) {
    final cx = area.width * (0.18 + (seed % 7) * 0.1);
    final cy = area.height * (0.18 + (seed % 5) * 0.1);
    final rx = area.width * (0.16 + (seed % 4) * 0.045);
    final ry = area.height * (0.12 + (seed % 3) * 0.04);
    final wobble = math.sin(t * 0.55 + seed) * 14;
    return (
      (cx + math.cos(t + seed * 0.37) * rx + wobble)
          .clamp(44.0, area.width - 44),
      (cy + math.sin(t * 0.8 + seed * 0.51) * ry + math.cos(t * 1.1) * 8)
          .clamp(52.0, area.height * 0.78),
    );
  }

  static List<WebButterflyEntity> spawnBoard(
    Size area,
    ButterflyWebMatchingSettings settings,
  ) {
    final pairCount = settings.effectivePairCount;
    final varietyIndices = List.generate(
      GardenButterflies.varieties.length,
      (i) => i,
    )..shuffle(random);
    final accessories = ButterflyAccessory.values.toList()..shuffle(random);

    final butterflies = <WebButterflyEntity>[];
    for (var pair = 0; pair < pairCount; pair++) {
      final variety = varietyIndices[pair % varietyIndices.length];
      final accessory = accessories[pair % accessories.length];
      final isGolden = variety == 0 && random.nextDouble() < 0.12;
      for (var copy = 0; copy < 2; copy++) {
        final pathSeed = pair * 17 + copy * 31 + random.nextInt(200);
        final (fromX, fromY) = _edgeSpawn(area);
        final pathT = random.nextDouble() * math.pi * 2;
        final target = pathPosition(area, pathSeed, pathT);
        butterflies.add(
          WebButterflyEntity(
            id: 'bf_${pair}_${copy}_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(9999)}',
            pairId: pair,
            varietyIndex: variety,
            pathSeed: pathSeed,
            accessory: accessory,
            isGolden: isGolden,
            phase: WebButterflyPhase.entering,
            x: fromX,
            y: fromY,
            pathT: pathT,
            enterFromX: fromX,
            enterFromY: fromY,
            enterTargetX: target.$1,
            enterTargetY: target.$2,
            animProgress: 0,
            wingPhase: random.nextDouble() * math.pi * 2,
            hoverPhase: random.nextDouble() * math.pi * 2,
          ),
        );
      }
    }
    return butterflies;
  }

  static WebButterflyEntity updateButterfly(
    WebButterflyEntity b,
    Size area,
    double delta,
    ButterflyWebMatchingSettings settings,
  ) {
    final intensity = settings.reducedMotion
        ? 0.3
        : (settings.floatingAnimation ? 1.0 : 0.45);
    final fastWings = b.phase == WebButterflyPhase.matchedDance ||
        b.phase == WebButterflyPhase.flyingAway ||
        b.phase == WebButterflyPhase.entering ||
        b.phase == WebButterflyPhase.flyingToWeb;
    final wing = b.wingPhase + delta * (fastWings ? 12 : 4.2) * intensity;
    final hover = b.hoverPhase + delta * 1.8 * intensity;

    return switch (b.phase) {
      WebButterflyPhase.entering =>
        _updateEntering(b, area, delta, wing, hover, intensity),
      WebButterflyPhase.fluttering =>
        _updateFluttering(b, area, delta, settings, wing, hover, intensity),
      WebButterflyPhase.flyingToWeb => _lerpToWeb(b, delta, wing, hover),
      WebButterflyPhase.onWeb => b.copyWith(
          wingPhase: b.wingPhase + delta * 2.2 * intensity,
          hoverPhase: hover,
          webOpacity: 1,
          glow: 0.45 + 0.25 * (0.5 + 0.5 * math.sin(hover * 2)),
          x: b.webX,
          y: b.webY + 10 + math.sin(hover) * 1.5,
        ),
      WebButterflyPhase.mismatchRelease =>
        _releaseToFlutter(b, area, delta, wing, hover),
      WebButterflyPhase.matchedDance => _matchedDance(b, delta, wing, hover),
      WebButterflyPhase.flyingAway => _flyAway(b, area, delta, wing, hover),
      WebButterflyPhase.gone => b,
    };
  }

  static WebButterflyEntity _updateEntering(
    WebButterflyEntity b,
    Size area,
    double delta,
    double wing,
    double hover,
    double intensity,
  ) {
    final p = (b.animProgress + delta * 0.85 * intensity).clamp(0.0, 1.0);
    final t = CurvesEase.outCubic(p);
    final x = b.enterFromX + (b.enterTargetX - b.enterFromX) * t;
    final y = b.enterFromY + (b.enterTargetY - b.enterFromY) * t;
    if (p >= 1) {
      return b.copyWith(
        phase: WebButterflyPhase.fluttering,
        animProgress: 0,
        x: b.enterTargetX,
        y: b.enterTargetY,
        wingPhase: wing,
        hoverPhase: hover,
        pathT: b.pathT,
      );
    }
    return b.copyWith(
      animProgress: p,
      x: x,
      y: y,
      wingPhase: wing,
      hoverPhase: hover,
    );
  }

  static WebButterflyEntity _updateFluttering(
    WebButterflyEntity b,
    Size area,
    double delta,
    ButterflyWebMatchingSettings settings,
    double wing,
    double hover,
    double intensity,
  ) {
    if (!settings.floatingAnimation || settings.reducedMotion) {
      // Gentle hover in place when floating is off.
      return b.copyWith(
        wingPhase: wing,
        hoverPhase: hover,
        y: b.y + math.sin(hover) * 0.4,
        webOpacity: math.max(0, b.webOpacity - delta * 2),
        glow: math.max(0, b.glow - delta),
      );
    }
    final speed = 0.55 * intensity;
    final pathT = b.pathT + delta * speed;
    final pos = pathPosition(area, b.pathSeed, pathT);
    // Ease toward path so release-from-web doesn't teleport.
    final blend = (delta * 2.4).clamp(0.0, 1.0);
    return b.copyWith(
      pathT: pathT,
      x: b.x + (pos.$1 - b.x) * blend,
      y: b.y + (pos.$2 - b.y) * blend,
      wingPhase: wing,
      hoverPhase: hover,
      webOpacity: math.max(0, b.webOpacity - delta * 2),
      glow: math.max(0, b.glow - delta),
    );
  }

  static WebButterflyEntity _lerpToWeb(
    WebButterflyEntity b,
    double delta,
    double wing,
    double hover,
  ) {
    final p = (b.animProgress + delta * 3.2).clamp(0.0, 1.0);
    final t = CurvesEase.outBack(p);
    // Settle slightly downward onto the magical web at capture point.
    final restY = b.webY + 10;
    return b.copyWith(
      animProgress: p,
      wingPhase: wing,
      hoverPhase: hover,
      x: b.webX,
      y: b.webY + (restY - b.webY) * t,
      webOpacity: p,
      glow: p * 0.65,
      phase: p >= 1 ? WebButterflyPhase.onWeb : b.phase,
    );
  }

  static WebButterflyEntity _releaseToFlutter(
    WebButterflyEntity b,
    Size area,
    double delta,
    double wing,
    double hover,
  ) {
    final p = (b.animProgress + delta * 2.6).clamp(0.0, 1.0);
    if (p >= 1) {
      // Resume flight from current spot by syncing pathT near here.
      return b.copyWith(
        phase: WebButterflyPhase.fluttering,
        animProgress: 0,
        webOpacity: 0,
        glow: 0,
        wingPhase: wing,
        hoverPhase: hover,
        pathT: b.pathT + 0.4,
      );
    }
    return b.copyWith(
      animProgress: p,
      wingPhase: wing,
      hoverPhase: hover,
      webOpacity: 1 - p,
      glow: (1 - p) * 0.4,
      y: b.webY - 8 * p,
    );
  }

  static WebButterflyEntity _matchedDance(
    WebButterflyEntity b,
    double delta,
    double wing,
    double hover,
  ) {
    final p = (b.animProgress + delta * 1.15).clamp(0.0, 1.0);
    final angle = p * math.pi * 2 + (b.pairId.isEven ? 0 : math.pi);
    final radius = 22 * math.sin(p * math.pi);
    if (p >= 1) {
      return b.copyWith(
        phase: WebButterflyPhase.flyingAway,
        animProgress: 0,
        wingPhase: wing,
        hoverPhase: hover,
        webOpacity: 0,
        glow: 0.85,
      );
    }
    return b.copyWith(
      animProgress: p,
      wingPhase: wing,
      hoverPhase: hover,
      x: b.danceCenterX + math.cos(angle) * radius,
      y: b.danceCenterY + math.sin(angle) * radius * 0.65,
      webOpacity: (1 - p).clamp(0.0, 1.0),
      glow: 0.85,
    );
  }

  static WebButterflyEntity _flyAway(
    WebButterflyEntity b,
    Size area,
    double delta,
    double wing,
    double hover,
  ) {
    final progress = (b.animProgress + delta * 1.15).clamp(0.0, 1.0);
    final dir = b.pairId.isEven ? -1.0 : 1.0;
    final nx = b.x + dir * 90 * delta;
    final ny = b.y - 140 * delta;
    final offScreen = nx < -80 ||
        nx > area.width + 80 ||
        ny < -80 ||
        progress >= 1;
    return b.copyWith(
      animProgress: progress,
      wingPhase: wing,
      hoverPhase: hover,
      x: nx,
      y: ny,
      glow: 1 - progress,
      webOpacity: 0,
      phase: offScreen ? WebButterflyPhase.gone : b.phase,
    );
  }

  static TapSparkle updateSparkle(TapSparkle s, double delta) =>
      s.copyWith(progress: (s.progress + delta * 1.8).clamp(0.0, 1.0));

  static ({int coins, int xp, int stars, int rewardPoints, int rainbow})
      matchReward(ButterflyWebMatchingSettings settings, int streak) {
    final m = settings.rewardMultiplier;
    final bonus = (streak / 3).floor().clamp(0, 3);
    final coins = settings.coinRewardsEnabled
        ? ((8 + bonus * 2) * m).round().clamp(3, 20)
        : 0;
    final xp = ((10 + bonus * 2) * m).round().clamp(4, 24);
    final rewardPoints = ((5 + bonus) * m).round().clamp(2, 16);
    final stars = streak > 0 && streak % 3 == 0 ? 1 : 0;
    final rainbow = 1;
    return (
      coins: coins,
      xp: xp,
      stars: stars,
      rewardPoints: rewardPoints,
      rainbow: rainbow,
    );
  }

  static String pickEncouragement(int n) =>
      kButterflyWebEncouragements[n % kButterflyWebEncouragements.length];

  static String pickEndMessage(int n) =>
      kButterflyWebEndMessages[n % kButterflyWebEndMessages.length];

  static ButterflyWebMatchingResult buildResult(ButterflyWebMatchingState state) {
    final played = state.settings.practiceMode
        ? state.settings.sessionSeconds
        : (state.settings.sessionSeconds - state.remainingSeconds)
            .clamp(0, state.settings.sessionSeconds);
    return ButterflyWebMatchingResult(
      pairsMatched: state.pairsMatched,
      coins: state.coinsEarned,
      stars: state.starsEarned,
      xp: state.xpEarned,
      rewardPoints: state.rewardPoints,
      rainbowTokens: state.rainbowTokens,
      longestStreak: state.longestStreak,
      boardsCleared: state.boardsCleared,
      sessionSeconds: played,
      encouragement: pickEndMessage(state.pairsMatched),
    );
  }

  static GameRewardResult toReward(ButterflyWebMatchingResult result) =>
      GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.pairsMatched >= 3 && result.longestStreak >= 3,
      );
}

abstract final class CurvesEase {
  static double outCubic(double t) {
    final p = t - 1;
    return p * p * p + 1;
  }

  static double outBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final p = t - 1;
    return 1 + c3 * p * p * p + c1 * p * p;
  }
}
