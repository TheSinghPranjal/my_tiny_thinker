import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';

abstract final class FeedFrogLogic {
  static final random = math.Random();

  static (double frogX, double frogY, double padRadius) frogAnchor(Size area) => (
        area.width / 2,
        area.height * 0.78,
        area.width * 0.22,
      );

  static bool isNight(double nightFactor) => nightFactor >= 0.5;

  static List<InsectEntity> spawnInsects(Size area, int count, double nightFactor) {
    final insects = <InsectEntity>[];
    final atNight = isNight(nightFactor);
    for (var i = 0; i < count; i++) {
      insects.add(_createInsect(area, i, isFirefly: atNight, entering: false));
    }
    return insects;
  }

  static InsectEntity spawnReplacement(Size area, double nightFactor) {
    final edge = random.nextInt(4);
    final (fx, fy) = switch (edge) {
      0 => (-30.0, area.height * random.nextDouble() * 0.55),
      1 => (area.width + 30.0, area.height * random.nextDouble() * 0.55),
      2 => (area.width * random.nextDouble(), -30.0),
      _ => (area.width * random.nextDouble(), area.height * 0.45),
    };
    return _createInsect(
      area,
      random.nextInt(9999),
      isFirefly: isNight(nightFactor),
      entering: true,
      fromX: fx,
      fromY: fy,
    );
  }

  static InsectEntity _createInsect(
    Size area,
    int seed, {
    required bool isFirefly,
    required bool entering,
    double fromX = 0,
    double fromY = 0,
  }) {
    final pos = entering
        ? (fromX, fromY)
        : _pathPosition(area, seed, random.nextDouble() * math.pi * 2);
    return InsectEntity(
      id: 'bug_${DateTime.now().microsecondsSinceEpoch}_$seed',
      kindIndex: seed,
      isFirefly: isFirefly,
      pathSeed: seed,
      phase: entering ? InsectPhase.entering : InsectPhase.flying,
      x: pos.$1,
      y: pos.$2,
      pathT: random.nextDouble() * math.pi * 2,
      enterFromX: fromX,
      enterFromY: fromY,
      enterProgress: entering ? 0 : 1,
    );
  }

  static (double, double) _pathPosition(Size area, int seed, double t) {
    final cx = area.width * (0.25 + (seed % 5) * 0.12);
    final cy = area.height * (0.18 + (seed % 4) * 0.08);
    final rx = area.width * (0.22 + (seed % 3) * 0.05);
    final ry = area.height * (0.14 + (seed % 2) * 0.04);
    return (
      (cx + math.cos(t + seed) * rx).clamp(40.0, area.width - 40),
      (cy + math.sin(t * 0.8 + seed * 0.5) * ry).clamp(60.0, area.height * 0.62),
    );
  }

  static double computeNightFactor(int elapsedSeconds, FeedFrogSettings settings) {
    final cycle = settings.dayNightCycleSeconds.clamp(40, 180);
    final start = settings.dayNightStartSeconds.clamp(10, cycle ~/ 2);
    final transition = settings.dayNightTransitionSeconds.clamp(3, 15);
    final pos = elapsedSeconds % cycle;

    if (pos < start) return 0;
    if (pos < start + transition) {
      return ((pos - start) / transition).clamp(0.0, 1.0);
    }
    final nightEnd = cycle - transition;
    if (pos < nightEnd) return 1;
    if (pos < cycle) {
      return (1 - (pos - nightEnd) / transition).clamp(0.0, 1.0);
    }
    return 0;
  }

  static InsectEntity updateInsect(
    InsectEntity insect,
    Size area,
    double delta,
    FeedFrogSettings settings,
    double nightFactor,
  ) {
    if (insect.phase == InsectPhase.gone ||
        insect.phase == InsectPhase.caught ||
        insect.phase == InsectPhase.selected) {
      return insect;
    }

    final speed = settings.speedMult * settings.animationIntensity;
    var wing = insect.wingPhase + delta * 16 * speed;
    var glow = insect.glowPhase + delta * 2.5;

    if (insect.phase == InsectPhase.entering) {
      final enter = (insect.enterProgress + delta * 0.9 * speed).clamp(0.0, 1.0);
      final target = _pathPosition(area, insect.pathSeed, insect.pathT);
      if (enter >= 1) {
        return insect.copyWith(
          phase: InsectPhase.flying,
          enterProgress: 1,
          x: target.$1,
          y: target.$2,
          wingPhase: wing,
          glowPhase: glow,
        );
      }
      return insect.copyWith(
        enterProgress: enter,
        x: insect.enterFromX + (target.$1 - insect.enterFromX) * enter,
        y: insect.enterFromY + (target.$2 - insect.enterFromY) * enter,
        wingPhase: wing,
        glowPhase: glow,
      );
    }

    var pathT = insect.pathT + delta * 0.55 * speed;
    final pos = _pathPosition(area, insect.pathSeed, pathT);
    var highlight = insect.highlight;
    if (highlight > 0) {
      highlight = (highlight - delta * 2).clamp(0.0, 1.0);
    }

    final shouldBeFirefly = isNight(nightFactor);

    return insect.copyWith(
      x: pos.$1,
      y: pos.$2,
      pathT: pathT,
      wingPhase: wing,
      glowPhase: glow,
      highlight: highlight,
      isFirefly: shouldBeFirefly,
    );
  }

  static ({double tipX, double tipY}) tongueTip(
    double frogX,
    double frogY,
    double insectX,
    double insectY,
    double progress,
  ) {
    final mouthX = frogX;
    final mouthY = frogY - 28;
    final ctrlX = (frogX + insectX) / 2 + (insectY - frogY) * 0.15;
    final ctrlY = (frogY + insectY) / 2 - 40;
    final t = progress.clamp(0.0, 1.0);
    final u = 1 - t;
    final x = u * u * mouthX + 2 * u * t * ctrlX + t * t * insectX;
    final y = u * u * mouthY + 2 * u * t * ctrlY + t * t * insectY;
    return (tipX: x, tipY: y);
  }

  static ({int points, int coins, int xp, int stars}) feedReward(
    FeedFrogSettings settings, {
    required bool isFirefly,
    required int eaten,
  }) {
    final m = settings.rewardMultiplier * (isFirefly ? 1.2 : 1.0);
    return (
      points: (10 * m).round().clamp(5, 20),
      coins: (5 * m).round().clamp(2, 12),
      xp: (5 * m).round().clamp(2, 12),
      stars: eaten % 3 == 0 ? 1 : 0,
    );
  }

  static FeedFrogResult buildResult(FeedFrogState state) => FeedFrogResult(
        insectsEaten: state.insectsEaten,
        firefliesCaught: state.firefliesCaught,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
        favoriteKind: state.favoriteKind,
      );

  static String encouragement(int count) =>
      kFeedEncouragements[count % kFeedEncouragements.length];
}
