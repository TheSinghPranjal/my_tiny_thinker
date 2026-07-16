import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

abstract final class BunnyHopLogic {
  static final random = math.Random();

  static int crackedPadCount(int padCount) {
    if (padCount <= 9) return 1;
    if (padCount <= 14) return 2;
    return 3;
  }

  static List<int> pickCrackedIndices(int padCount) {
    final count = crackedPadCount(padCount);
    if (count <= 0 || padCount <= 0) return [];
    final available = List.generate(padCount, (i) => i);
    available.shuffle(random);
    final picked = <int>[];
    for (final idx in available) {
      if (picked.length >= count) break;
      if (picked.every((p) => (p - idx).abs() > 1)) {
        picked.add(idx);
      }
    }
    if (picked.length < count) {
      for (final idx in available) {
        if (picked.length >= count) break;
        if (!picked.contains(idx) && picked.every((p) => (p - idx).abs() > 1)) {
          picked.add(idx);
        }
      }
    }
    return picked..sort();
  }

  static double bankAX(Size area) => area.width * 0.08;
  static double bankBX(Size area) => area.width * 0.92;
  static double riverY(Size area) => area.height * 0.57;
  static double bankY(Size area) => area.height * 0.40;

  static List<LilyPadEntity> buildLilyPads(Size area, int count, Set<int> cracked) {
    final pads = <LilyPadEntity>[];
    final left = area.width * 0.16;
    final right = area.width * 0.84;
    final y = riverY(area);
    for (var i = 0; i < count; i++) {
      final t = count == 1 ? 0.5 : i / (count - 1);
      pads.add(
        LilyPadEntity(
          index: i,
          x: left + (right - left) * t,
          y: y,
          isCracked: cracked.contains(i),
          floatPhase: random.nextDouble() * math.pi * 2,
        ),
      );
    }
    return pads;
  }

  static (double x, double y) positionForStep(Size area, int step, int padCount) {
    if (step < 0) return (bankAX(area), bankY(area));
    if (step >= padCount) return (bankBX(area), bankY(area));
    final left = area.width * 0.16;
    final right = area.width * 0.84;
    final y = riverY(area);
    final t = padCount == 1 ? 0.5 : step / (padCount - 1);
    return (left + (right - left) * t, y);
  }

  static CarrotEntity buildCarrot(Size area, CarrotSide side) {
    final x = side == CarrotSide.sideB ? bankBX(area) : bankAX(area);
    return CarrotEntity(x: x, y: bankY(area) - 20, side: side);
  }

  static int nextStep(int current, TravelDirection dir) =>
      dir == TravelDirection.towardB ? current + 1 : current - 1;

  static bool reachedCarrot(int step, int padCount, CarrotSide carrotSide) {
    if (carrotSide == CarrotSide.sideB) return step >= padCount;
    return step < 0;
  }

  static int recoveryBank(TravelDirection dir, int padCount) =>
      dir == TravelDirection.towardB ? -1 : padCount;

  static bool isOnCrackedPad(int step, int padCount, List<LilyPadEntity> pads) =>
      step >= 0 && step < padCount && pads[step].isCracked && pads[step].phase == LilyPadPhase.floating;

  static ({int points, int coins, int xp, int stars}) hopReward(
    BunnyHopSettings settings, {
    required int hopCount,
  }) {
    final m = settings.rewardMultiplier;
    final points = (10 * m).round().clamp(5, 25);
    final coins = (5 * m).round().clamp(2, 15);
    final xp = (5 * m).round().clamp(2, 15);
    final stars = hopCount % 4 == 0 ? 1 : 0;
    return (points: points, coins: coins, xp: xp, stars: stars);
  }

  static ({int points, int coins, int xp, int stars}) carrotReward(
    BunnyHopSettings settings, {
    required int carrotCount,
  }) {
    final m = settings.rewardMultiplier * 2.0;
    final points = (20 * m).round().clamp(10, 50);
    final coins = (10 * m).round().clamp(5, 30);
    final xp = (10 * m).round().clamp(5, 30);
    final stars = 2;
    return (points: points, coins: coins, xp: xp, stars: stars);
  }

  static LilyPadEntity updateLilyPad(
    LilyPadEntity pad,
    double delta,
    BunnyHopSettings settings,
  ) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.6 : 1.0);
    var p = pad.copyWith(
      floatPhase: pad.floatPhase + delta * 1.8 * speed,
      bobOffset: math.sin(pad.floatPhase) * 4,
    );

    if (p.phase == LilyPadPhase.sinking) {
      final sink = (p.sinkProgress + delta * 0.35 * speed).clamp(0.0, 1.0);
      if (sink >= 1) return p.copyWith(phase: LilyPadPhase.sunk, sinkProgress: 1);
      return p.copyWith(sinkProgress: sink, y: p.y + sink * 30);
    }
    return p;
  }

  static BunnyEntity updateBunny(
    BunnyEntity bunny,
    double delta,
    BunnyHopSettings settings,
  ) {
    final speed = settings.animationIntensity * settings.hopSpeedMult;
    final reduced = settings.reducedMotion ? 0.7 : 1.0;
    var b = bunny.copyWith(
      animPhase: bunny.animPhase + delta * 2.5,
      blinkTimer: bunny.blinkTimer + delta,
    );

    return switch (bunny.phase) {
      BunnyPhase.idle => _updateIdle(b, delta),
      BunnyPhase.landed => _updateIdle(b, delta),
      BunnyPhase.hopping => _updateHop(b, delta, speed * reduced),
      BunnyPhase.celebrating => _updateCelebrate(b, delta, speed),
      BunnyPhase.falling => _updateFall(b, delta, speed),
      BunnyPhase.swimming => _updateSwim(b, delta, speed),
      BunnyPhase.recovering => _updateRecover(b, delta, speed),
    };
  }

  static BunnyEntity _updateIdle(BunnyEntity b, double delta) {
    var actionTimer = b.actionTimer + delta;
    var idleAction = b.idleAction;
    if (actionTimer > 3 + random.nextDouble() * 3) {
      actionTimer = 0;
      idleAction = random.nextInt(4);
    }
    return b.copyWith(
      actionTimer: actionTimer,
      idleAction: idleAction,
      squash: 1 + math.sin(b.animPhase * 3) * 0.02,
    );
  }

  static BunnyEntity _updateHop(BunnyEntity b, double delta, double speed) {
    final hop = (b.hopProgress + delta * 2.8 * speed).clamp(0.0, 1.0);
    final t = hop;
    final x = b.hopFromX + (b.hopToX - b.hopFromX) * t;
    final arc = math.sin(t * math.pi) * 38;
    final y = b.hopFromY + (b.hopToY - b.hopFromY) * t - arc;
    final squash = 1 + (t < 0.15 ? t * 0.3 : (t > 0.85 ? (1 - t) * 0.3 : -math.sin(t * math.pi) * 0.15));
    if (hop >= 1) {
      return b.copyWith(
        phase: BunnyPhase.landed,
        hopProgress: 1,
        x: b.hopToX,
        y: b.hopToY,
        squash: 1,
        actionTimer: 0,
      );
    }
    return b.copyWith(hopProgress: hop, x: x, y: y, squash: squash);
  }

  static BunnyEntity _updateCelebrate(BunnyEntity b, double delta, double speed) {
    final t = b.actionTimer + delta;
    final c = (b.celebrateProgress + delta * 1.5 * speed).clamp(0.0, 1.0);
    if (t >= 2.2 / speed) {
      return b.copyWith(
        phase: BunnyPhase.idle,
        actionTimer: 0,
        celebrateProgress: 0,
      );
    }
    return b.copyWith(
      actionTimer: t,
      celebrateProgress: c,
      squash: 1 + math.sin(t * 12) * 0.08,
    );
  }

  static BunnyEntity _updateFall(BunnyEntity b, double delta, double speed) {
    final fall = (b.fallProgress + delta * 2.2 * speed).clamp(0.0, 1.0);
    if (fall >= 1) {
      return b.copyWith(phase: BunnyPhase.swimming, fallProgress: 1, swimProgress: 0);
    }
    return b.copyWith(
      fallProgress: fall,
      y: b.y + fall * 35,
      squash: 1 - fall * 0.2,
    );
  }

  static BunnyEntity _updateSwim(BunnyEntity b, double delta, double speed) {
    final swim = (b.swimProgress + delta * 1.4 * speed).clamp(0.0, 1.0);
    if (swim >= 1) {
      return b.copyWith(phase: BunnyPhase.recovering, swimProgress: 1, shakeWater: 0);
    }
    return b.copyWith(
      swimProgress: swim,
      x: b.hopFromX + (b.hopToX - b.hopFromX) * swim,
      y: b.y + math.sin(swim * math.pi * 4) * 4,
    );
  }

  static BunnyEntity _updateRecover(BunnyEntity b, double delta, double speed) {
    final shake = (b.shakeWater + delta * 2).clamp(0.0, 1.0);
    if (shake >= 1) {
      return b.copyWith(phase: BunnyPhase.idle, shakeWater: 1, squash: 1);
    }
    return b.copyWith(
      shakeWater: shake,
    );
  }

  static CarrotEntity updateCarrot(CarrotEntity carrot, double delta, BunnyHopSettings settings) {
    if (!carrot.visible) return carrot;
    final speed = settings.animationIntensity;
    return carrot.copyWith(
      bouncePhase: carrot.bouncePhase + delta * 3 * speed,
      sparklePhase: carrot.sparklePhase + delta * 4,
      glow: 0.5 + math.sin(carrot.bouncePhase) * 0.3,
    );
  }

  static BunnyHopResult buildResult(BunnyHopState state) => BunnyHopResult(
        totalHops: state.totalHops,
        carrotsCollected: state.carrotsCollected,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        fallsRecovered: state.fallsRecovered,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickHopMessage(int count) => kHopEncouragements[count % kHopEncouragements.length];

  static String pickCarrotMessage(int count) => kCarrotMessages[count % kCarrotMessages.length];

  static String pickFallMessage(int count) => kFallMessages[count % kFallMessages.length];
}
