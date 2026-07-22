import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

abstract final class HungryMonkeyLogic {
  static final random = math.Random();

  /// Normalized canopy slot positions (x, y) within play area.
  /// Y values sit lower so fruit stays inside the shifted-down canopy.
  static const canopySlots = <(double, double)>[
    (0.22, 0.18),
    (0.36, 0.15),
    (0.50, 0.13),
    (0.64, 0.15),
    (0.78, 0.18),
    (0.18, 0.28),
    (0.32, 0.25),
    (0.50, 0.23),
    (0.68, 0.25),
    (0.82, 0.28),
    (0.26, 0.38),
    (0.42, 0.36),
    (0.58, 0.36),
    (0.74, 0.38),
  ];

  static const minSlotDistance = 0.08;

  static (double, double) monkeyAnchor(Size area) =>
      (area.width * 0.5, area.height * 0.82);

  static (double, double) slotPosition(Size area, int slotIndex) {
    final slot = canopySlots[slotIndex % canopySlots.length];
    return (area.width * slot.$1, area.height * slot.$2);
  }

  static List<int> pickSlots(int count, {Set<int> exclude = const {}}) {
    final available = <int>[];
    for (var i = 0; i < canopySlots.length; i++) {
      if (!exclude.contains(i)) available.add(i);
    }
    available.shuffle(random);
    final picked = <int>[];
    for (final slot in available) {
      if (picked.length >= count) break;
      if (picked.every((p) => _slotDistance(p, slot) >= minSlotDistance)) {
        picked.add(slot);
      }
    }
    if (picked.length < count) {
      for (final slot in available) {
        if (picked.length >= count) break;
        if (!picked.contains(slot)) picked.add(slot);
      }
    }
    return picked;
  }

  static double _slotDistance(int a, int b) {
    final sa = canopySlots[a % canopySlots.length];
    final sb = canopySlots[b % canopySlots.length];
    final dx = sa.$1 - sb.$1;
    final dy = sa.$2 - sb.$2;
    return math.sqrt(dx * dx + dy * dy);
  }

  static List<BananaEntity> spawnBananas(Size area, int count) {
    final slots = pickSlots(count);
    return slots.map((slot) => _createBanana(area, slot)).toList();
  }

  static BananaEntity _createBanana(Size area, int slot) {
    final (x, y) = slotPosition(area, slot);
    return BananaEntity(
      id: 'banana_${DateTime.now().microsecondsSinceEpoch}_$slot',
      slotIndex: slot,
      x: x,
      y: y,
      sizeScale: 0.85 + random.nextDouble() * 0.3,
      rotation: (random.nextDouble() - 0.5) * 0.5,
      phase: BananaPhase.onTree,
    );
  }

  static BananaEntity spawnGrowingBanana(Size area, int slot) {
    final (x, y) = slotPosition(area, slot);
    return BananaEntity(
      id: 'banana_${DateTime.now().microsecondsSinceEpoch}_$slot',
      slotIndex: slot,
      x: x,
      y: y,
      sizeScale: 0.85 + random.nextDouble() * 0.3,
      rotation: (random.nextDouble() - 0.5) * 0.4,
      phase: BananaPhase.growing,
      growProgress: 0,
    );
  }

  static int pickRegrowSlot(Size area, List<BananaEntity> bananas) {
    final used = bananas
        .where((b) => b.phase != BananaPhase.gone)
        .map((b) => b.slotIndex)
        .toSet();
    final slots = pickSlots(1, exclude: used);
    return slots.isEmpty ? pickSlots(1).first : slots.first;
  }

  static List<AppleEntity> spawnApples(
    Size area,
    List<BananaEntity> bananas,
    int count,
  ) {
    final used = bananas
        .where((b) => b.phase == BananaPhase.onTree || b.phase == BananaPhase.growing)
        .map((b) => (b.x / area.width, b.y / area.height))
        .toList();
    final apples = <AppleEntity>[];
    var attempts = 0;
    while (apples.length < count && attempts < 40) {
      attempts++;
      final slot = random.nextInt(canopySlots.length);
      final (x, y) = slotPosition(area, slot);
      final nx = x / area.width;
      final ny = y / area.height;
      final overlaps = used.any((u) {
        final dx = u.$1 - nx;
        final dy = u.$2 - ny;
        return math.sqrt(dx * dx + dy * dy) < minSlotDistance * 0.85;
      });
      if (overlaps) continue;
      apples.add(
        AppleEntity(
          id: 'apple_${DateTime.now().microsecondsSinceEpoch}_$slot',
          x: x + (random.nextDouble() - 0.5) * area.width * 0.04,
          y: y + (random.nextDouble() - 0.5) * area.height * 0.03,
        ),
      );
    }
    return apples;
  }

  static double randomAppleSpawnDelay(HungryMonkeySettings settings) {
    final min = settings.appleSpawnMin;
    final max = settings.appleSpawnMax;
    return min + random.nextDouble() * (max - min);
  }

  static int randomAppleBatchCount(HungryMonkeySettings settings, int current) {
    if (settings.maxApples <= 0) return 0;
    final room = settings.maxApples - current;
    if (room <= 0) return 0;
    final batch = 1 + random.nextInt(4);
    return batch.clamp(1, room);
  }

  static BananaEntity updateBanana(
    BananaEntity banana,
    Size area,
    double delta,
    HungryMonkeySettings settings,
    MonkeyEntity monkey,
  ) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.7 : 1.0);

    return switch (banana.phase) {
      BananaPhase.onTree => banana.copyWith(
          glow: (banana.glow - delta * 2).clamp(0.0, 1.0),
        ),
      BananaPhase.tapped => _updateTapped(banana, delta, speed, monkey),
      BananaPhase.falling => _updateFalling(banana, area, delta, speed, monkey),
      BananaPhase.growing => _updateGrowing(banana, delta, speed),
      BananaPhase.gone => banana,
    };
  }

  static BananaEntity _updateTapped(
    BananaEntity b,
    double delta,
    double speed,
    MonkeyEntity monkey,
  ) {
    final tap = (b.tapProgress + delta * 4 * speed).clamp(0.0, 1.0);
    if (tap >= 1) {
      return b.copyWith(
        phase: BananaPhase.falling,
        tapProgress: 1,
        fallProgress: 0,
        fallStartX: b.x,
        fallStartY: b.y,
        glow: 1,
      );
    }
    return b.copyWith(
      tapProgress: tap,
      glow: 1,
      y: b.y + math.sin(tap * math.pi * 2) * 2,
    );
  }

  static BananaEntity _updateFalling(
    BananaEntity b,
    Size area,
    double delta,
    double speed,
    MonkeyEntity monkey,
  ) {
    final fall = (b.fallProgress + delta * 1.4 * speed).clamp(0.0, 1.0);
    final (mx, my) = (monkey.x, monkey.y - 70);
    final ctrlX = (b.fallStartX + mx) / 2 + 30;
    final ctrlY = (b.fallStartY + my) / 2 - 40;
    final t = fall;
    final u = 1 - t;
    final x = u * u * b.fallStartX + 2 * u * t * ctrlX + t * t * mx;
    final y = u * u * b.fallStartY + 2 * u * t * ctrlY + t * t * my;
    final rot = b.rotation + fall * 1.2;
    if (fall >= 1) {
      return b.copyWith(
        phase: BananaPhase.gone,
        fallProgress: 1,
        x: mx,
        y: my,
        rotation: rot,
      );
    }
    return b.copyWith(
      fallProgress: fall,
      x: x,
      y: y,
      rotation: rot,
      glow: (1 - fall * 0.5).clamp(0.0, 1.0),
    );
  }

  static BananaEntity _updateGrowing(BananaEntity b, double delta, double speed) {
    final grow = (b.growProgress + delta * 0.85 * speed).clamp(0.0, 1.0);
    if (grow >= 1) {
      return b.copyWith(phase: BananaPhase.onTree, growProgress: 1, glow: 0.6);
    }
    return b.copyWith(growProgress: grow);
  }

  static AppleEntity updateApple(AppleEntity apple, double delta, HungryMonkeySettings settings) {
    final speed = settings.animationIntensity;
    var updated = apple;

    if (updated.phase == ApplePhase.appearing) {
      final bounce = (updated.bounceProgress + delta * 3 * speed).clamp(0.0, 1.0);
      if (bounce >= 1) {
        updated = updated.copyWith(phase: ApplePhase.visible, bounceProgress: 1);
      } else {
        updated = updated.copyWith(bounceProgress: bounce);
      }
    }

    if (updated.phase == ApplePhase.wobble) {
      updated = updated.copyWith(wobblePhase: updated.wobblePhase + delta * 12);
    }

    final life = updated.lifetime - delta;
    if (life <= 0.5 && updated.phase != ApplePhase.gone && updated.phase != ApplePhase.fading) {
      updated = updated.copyWith(phase: ApplePhase.fading, fadeProgress: 0);
    }
    if (updated.phase == ApplePhase.fading) {
      final fade = (updated.fadeProgress + delta * 2).clamp(0.0, 1.0);
      if (fade >= 1) {
        return updated.copyWith(phase: ApplePhase.gone, fadeProgress: 1, lifetime: 0);
      }
      updated = updated.copyWith(fadeProgress: fade, lifetime: life);
    } else if (life <= 0) {
      return updated.copyWith(phase: ApplePhase.gone, lifetime: 0);
    } else {
      updated = updated.copyWith(lifetime: life);
    }
    return updated;
  }

  static MonkeyEntity updateMonkey(
    MonkeyEntity monkey,
    double delta,
    HungryMonkeySettings settings,
  ) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.6 : 1.0);
    var m = monkey.copyWith(
      animPhase: monkey.animPhase + delta * 2.2 * speed,
      blinkTimer: monkey.blinkTimer + delta,
      tailWag: monkey.tailWag + delta * 4,
    );

    return switch (monkey.phase) {
      MonkeyPhase.idle => _updateIdleMonkey(m, delta, speed),
      MonkeyPhase.reaching => _updateReach(m, delta, speed),
      MonkeyPhase.catching => _updateCatch(m, delta, speed),
      MonkeyPhase.eating => _updateEat(m, delta, speed),
      MonkeyPhase.sad => _updateSad(m, delta, speed),
      MonkeyPhase.clapping => _updateClap(m, delta, speed),
    };
  }

  static MonkeyEntity _updateIdleMonkey(MonkeyEntity m, double delta, double speed) {
    var actionTimer = m.actionTimer + delta;
    var idleAction = m.idleAction;
    if (actionTimer > 4 + random.nextDouble() * 3) {
      actionTimer = 0;
      idleAction = random.nextInt(4);
    }
    return m.copyWith(
      actionTimer: actionTimer,
      idleAction: idleAction,
      earDroop: 0,
      headShake: 0,
    );
  }

  static MonkeyEntity _updateReach(MonkeyEntity m, double delta, double speed) {
    final reach = (m.reachProgress + delta * 3.5 * speed).clamp(0.0, 1.0);
    if (reach >= 1) {
      return m.copyWith(phase: MonkeyPhase.catching, reachProgress: 1);
    }
    // Stay planted at the trunk base — only arm/face animates via reachProgress.
    return m.copyWith(reachProgress: reach);
  }

  static MonkeyEntity _updateCatch(MonkeyEntity m, double delta, double speed) {
    final t = m.actionTimer + delta;
    if (t >= 0.25 / speed) {
      return m.copyWith(phase: MonkeyPhase.eating, actionTimer: 0, eatProgress: 0);
    }
    return m.copyWith(actionTimer: t);
  }

  static MonkeyEntity _updateEat(MonkeyEntity m, double delta, double speed) {
    final eat = (m.eatProgress + delta * 2.2 * speed).clamp(0.0, 1.0);
    if (eat >= 1) {
      return m.copyWith(
        phase: MonkeyPhase.clapping,
        eatProgress: 1,
        actionTimer: 0,
      );
    }
    return m.copyWith(eatProgress: eat);
  }

  static MonkeyEntity _updateSad(MonkeyEntity m, double delta, double speed) {
    final sad = (m.sadProgress + delta * 2.5 * speed).clamp(0.0, 1.0);
    final shake = math.sin(sad * math.pi * 3) * sad * 0.15;
    if (sad >= 1) {
      return m.copyWith(
        phase: MonkeyPhase.idle,
        sadProgress: 0,
        earDroop: 0,
        headShake: 0,
        actionTimer: 0,
      );
    }
    return m.copyWith(
      sadProgress: sad,
      earDroop: sad * 0.8,
      headShake: shake,
    );
  }

  static MonkeyEntity _updateClap(MonkeyEntity m, double delta, double speed) {
    final t = m.actionTimer + delta;
    if (t >= 0.8 / speed) {
      return m.copyWith(phase: MonkeyPhase.idle, actionTimer: 0, reachProgress: 0, eatProgress: 0);
    }
    return m.copyWith(actionTimer: t);
  }

  static ({int points, int coins, int xp, int stars}) feedReward(
    HungryMonkeySettings settings, {
    required int fedCount,
  }) {
    final m = settings.rewardMultiplier;
    final points = (10 * m).round().clamp(5, 30);
    final coins = (5 * m).round().clamp(2, 15);
    final xp = (5 * m).round().clamp(2, 15);
    final stars = fedCount % 3 == 0 ? 1 : 0;
    return (points: points, coins: coins, xp: xp, stars: stars);
  }

  static HungryMonkeyResult buildResult(HungryMonkeyState state) => HungryMonkeyResult(
        bananasFed: state.bananasFed,
        applesTapped: state.applesTapped,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickBananaEncouragement(int count) =>
      kBananaEncouragements[count % kBananaEncouragements.length];

  static String pickAppleMessage(int count) =>
      kAppleMessages[count % kAppleMessages.length];
}
