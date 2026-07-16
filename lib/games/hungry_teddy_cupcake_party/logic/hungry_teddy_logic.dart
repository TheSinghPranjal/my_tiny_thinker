import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/shared/cupcake_varieties.dart';

abstract final class HungryTeddyLogic {
  static final random = math.Random();
  static const snapDistance = 95.0;

  static const tableSlots = <(double, double)>[
    (0.12, 0.55),
    (0.22, 0.55),
    (0.32, 0.55),
    (0.12, 0.67),
    (0.22, 0.67),
    (0.32, 0.67),
  ];

  static const minSlotDistance = 0.07;

  static (double, double) teddyAnchor(Size area) =>
      (area.width * 0.74, area.height * 0.56);

  static (double, double) teddyMouth(Size area) {
    final (tx, ty) = teddyAnchor(area);
    return (tx - 18, ty - 28);
  }

  static (double, double) slotPosition(Size area, int slotIndex) {
    final slot = tableSlots[slotIndex % tableSlots.length];
    return (area.width * slot.$1, area.height * slot.$2);
  }

  static List<int> pickSlots(int count, {Set<int> exclude = const {}}) {
    final available = <int>[];
    for (var i = 0; i < tableSlots.length; i++) {
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
    final sa = tableSlots[a % tableSlots.length];
    final sb = tableSlots[b % tableSlots.length];
    final dx = sa.$1 - sb.$1;
    final dy = sa.$2 - sb.$2;
    return math.sqrt(dx * dx + dy * dy);
  }

  static List<CupcakeEntity> spawnCupcakes(Size area, int count) {
    final slots = pickSlots(count);
    return slots.map((slot) => _createCupcake(area, slot, isGolden: false)).toList();
  }

  static CupcakeEntity _createCupcake(Size area, int slot, {required bool isGolden}) {
    final (x, y) = slotPosition(area, slot);
    return CupcakeEntity(
      id: 'cupcake_${DateTime.now().microsecondsSinceEpoch}_$slot',
      slotIndex: slot,
      varietyIndex: random.nextInt(CupcakeVarieties.all.length),
      x: x,
      y: y,
      homeX: x,
      homeY: y,
      isGolden: isGolden,
      phase: CupcakePhase.onTable,
      scale: 0.85 + random.nextDouble() * 0.2,
    );
  }

  static CupcakeEntity spawnBakingCupcake(Size area, int slot, {required bool isGolden}) {
    final (x, y) = slotPosition(area, slot);
    return CupcakeEntity(
      id: 'cupcake_${DateTime.now().microsecondsSinceEpoch}_$slot',
      slotIndex: slot,
      varietyIndex: random.nextInt(CupcakeVarieties.all.length),
      x: x,
      y: y,
      homeX: x,
      homeY: y,
      isGolden: isGolden,
      phase: CupcakePhase.baking,
      bakeProgress: 0,
      scale: 0.3,
    );
  }

  static int pickRegrowSlot(List<CupcakeEntity> cupcakes) {
    final used = cupcakes
        .where((c) => c.phase != CupcakePhase.gone)
        .map((c) => c.slotIndex)
        .toSet();
    final slots = pickSlots(1, exclude: used);
    return slots.isEmpty ? pickSlots(1).first : slots.first;
  }

  static bool shouldMarkGoldenDue(int elapsed, int nextGoldenAt) => elapsed >= nextGoldenAt;

  static double effectiveSnapDistance(HungryTeddySettings settings) =>
      snapDistance * settings.snapRadiusMult;

  static bool isNearTeddy(Size area, double x, double y, HungryTeddySettings settings) {
    final (mx, my) = teddyMouth(area);
    final dx = x - mx;
    final dy = y - my;
    return math.sqrt(dx * dx + dy * dy) < effectiveSnapDistance(settings);
  }

  static double headAngleToward(Size area, double fromX, double fromY, double toX, double toY) {
    final (tx, ty) = teddyAnchor(area);
    final dx = toX - tx;
    final dy = toY - (ty - 20);
    return math.atan2(dy, dx).clamp(-0.55, 0.55);
  }

  static double computeEveningFactor(int elapsed, int sessionSeconds) {
    if (sessionSeconds <= 60) return 0;
    final half = sessionSeconds / 2;
    if (elapsed < half) return 0;
    return ((elapsed - half) / (sessionSeconds - half)).clamp(0.0, 1.0);
  }

  static double visitorSpawnDelay(HungryTeddySettings settings) {
    final min = settings.visitorSpawnMin;
    final max = settings.visitorSpawnMax;
    return min + random.nextDouble() * (max - min);
  }

  static PartyVisitorEntity spawnVisitor(Size area) {
    final kind = PartyVisitorKind.values[random.nextInt(PartyVisitorKind.values.length)];
    final (x, y) = switch (kind) {
      PartyVisitorKind.balloon => (area.width * random.nextDouble(), area.height * 0.85),
      PartyVisitorKind.toyAnimal => (area.width * 0.08, area.height * 0.22),
      PartyVisitorKind.giftBox => (area.width * 0.92, area.height * 0.78),
      PartyVisitorKind.bird => (area.width + 30.0, area.height * 0.12),
    };
    return PartyVisitorEntity(
      id: 'visitor_${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      x: x,
      y: y,
    );
  }

  static CupcakeEntity updateCupcake(
    CupcakeEntity cupcake,
    Size area,
    double delta,
    HungryTeddySettings settings,
    TeddyEntity teddy,
  ) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.7 : 1.0);

    return switch (cupcake.phase) {
      CupcakePhase.onTable => cupcake.copyWith(
          glow: (cupcake.glow - delta * 2).clamp(0.0, 1.0),
          sparklePhase: cupcake.sparklePhase + delta * 3,
        ),
      CupcakePhase.dragging => cupcake.copyWith(
          sparklePhase: cupcake.sparklePhase + delta * 6,
          glow: 1,
          scale: 1.12,
        ),
      CupcakePhase.snapping => _updateSnapping(cupcake, area, delta, speed),
      CupcakePhase.baking => _updateBaking(cupcake, delta, speed),
      CupcakePhase.gone => cupcake,
    };
  }

  static CupcakeEntity _updateSnapping(
    CupcakeEntity c,
    Size area,
    double delta,
    double speed,
  ) {
    final snap = (c.snapProgress + delta * 3.5 * speed).clamp(0.0, 1.0);
    final (mx, my) = teddyMouth(area);
    final t = _easeOut(snap);
    final x = c.homeX + (mx - c.homeX) * t;
    final y = c.homeY + (my - c.homeY) * t;
    if (snap >= 1) {
      return c.copyWith(
        phase: CupcakePhase.gone,
        snapProgress: 1,
        x: mx,
        y: my,
      );
    }
    return c.copyWith(snapProgress: snap, x: x, y: y, glow: 1);
  }

  static CupcakeEntity _updateBaking(CupcakeEntity c, double delta, double speed) {
    final bake = (c.bakeProgress + delta * 0.9 * speed).clamp(0.0, 1.0);
    final scale = 0.3 + bake * (c.isGolden ? 1.0 : 0.85);
    if (bake >= 1) {
      return c.copyWith(
        phase: CupcakePhase.onTable,
        bakeProgress: 1,
        scale: scale,
        glow: c.isGolden ? 1 : 0.5,
      );
    }
    return c.copyWith(bakeProgress: bake, scale: scale, sparklePhase: c.sparklePhase + delta * 4);
  }

  static TeddyEntity updateTeddy(
    TeddyEntity teddy,
    Size area,
    double delta,
    HungryTeddySettings settings, {
    Offset? dragPosition,
  }) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.65 : 1.0);
    var t = teddy.copyWith(
      animPhase: teddy.animPhase + delta * 2.4 * speed,
      blinkTimer: teddy.blinkTimer + delta,
    );

    if (dragPosition != null &&
        (t.phase == TeddyPhase.idle ||
            t.phase == TeddyPhase.watching ||
            t.phase == TeddyPhase.excited)) {
      final angle = headAngleToward(area, t.x, t.y, dragPosition.dx, dragPosition.dy);
      final (mx, my) = teddyMouth(area);
      final dist = math.sqrt(
        math.pow(dragPosition.dx - mx, 2) + math.pow(dragPosition.dy - my, 2),
      );
      final excited = (1 - (dist / (area.width * 0.5))).clamp(0.0, 1.0);
      t = t.copyWith(
        phase: excited > 0.55 ? TeddyPhase.excited : TeddyPhase.watching,
        headAngle: angle,
        excitedLevel: excited,
        mouthOpen: excited > 0.6 ? excited * 0.8 : 0,
      );
    }

    return switch (t.phase) {
      TeddyPhase.idle => _updateIdleTeddy(t, delta, speed),
      TeddyPhase.watching => _updateWatching(t, delta, speed),
      TeddyPhase.excited => _updateExcited(t, delta, speed),
      TeddyPhase.receiving => _updateReceiving(t, delta, speed),
      TeddyPhase.eating => _updateEating(t, delta, speed),
      TeddyPhase.celebrating => _updateCelebrating(t, delta, speed, golden: false),
      TeddyPhase.goldenCelebration => _updateCelebrating(t, delta, speed, golden: true),
    };
  }

  static TeddyEntity _updateIdleTeddy(TeddyEntity t, double delta, double speed) {
    var actionTimer = t.actionTimer + delta;
    var idleAction = t.idleAction;
    if (actionTimer > 3.5 + random.nextDouble() * 3) {
      actionTimer = 0;
      idleAction = random.nextInt(5);
    }
    return t.copyWith(
      actionTimer: actionTimer,
      idleAction: idleAction,
      headAngle: (t.headAngle * 0.92).clamp(-0.15, 0.15),
      excitedLevel: (t.excitedLevel * 0.9).clamp(0.0, 1.0),
      mouthOpen: (t.mouthOpen * 0.85).clamp(0.0, 1.0),
    );
  }

  static TeddyEntity _updateWatching(TeddyEntity t, double delta, double speed) {
    if (t.excitedLevel < 0.2 && t.actionTimer > 0.5) {
      return t.copyWith(phase: TeddyPhase.idle, actionTimer: 0);
    }
    return t.copyWith(actionTimer: t.actionTimer + delta);
  }

  static TeddyEntity _updateExcited(TeddyEntity t, double delta, double speed) {
    return t.copyWith(actionTimer: t.actionTimer + delta);
  }

  static TeddyEntity _updateReceiving(TeddyEntity t, double delta, double speed) {
    return t.copyWith(
      actionTimer: t.actionTimer + delta,
      mouthOpen: 0.65 + math.sin(t.actionTimer * 8) * 0.15,
    );
  }

  static TeddyEntity _updateEating(TeddyEntity t, double delta, double speed) {
    final eat = (t.eatProgress + delta * 2.4 * speed).clamp(0.0, 1.0);
    if (eat >= 1) {
      return t.copyWith(
        phase: t.feedWasGolden ? TeddyPhase.goldenCelebration : TeddyPhase.celebrating,
        eatProgress: 1,
        actionTimer: 0,
        celebrateProgress: 0,
        mouthOpen: 0,
        headAngle: 0,
      );
    }
    return t.copyWith(
      eatProgress: eat,
      mouthOpen: 0.5 + math.sin(eat * math.pi * 6) * 0.3,
      headAngle: 0,
    );
  }

  static TeddyEntity _updateCelebrating(
    TeddyEntity t,
    double delta,
    double speed, {
    required bool golden,
  }) {
    final timer = t.actionTimer + delta;
    final celebrate = (t.celebrateProgress + delta * 1.8 * speed).clamp(0.0, 1.0);
    final duration = golden ? 1.4 : 0.9;
    if (timer >= duration / speed) {
      return t.copyWith(
        phase: TeddyPhase.idle,
        actionTimer: 0,
        celebrateProgress: 0,
        eatProgress: 0,
        headAngle: 0,
        excitedLevel: 0,
        mouthOpen: 0,
        clearTarget: true,
        feedWasGolden: false,
      );
    }
    return t.copyWith(
      actionTimer: timer,
      celebrateProgress: celebrate,
      headAngle: 0,
    );
  }

  static PartyVisitorEntity updateVisitor(
    PartyVisitorEntity visitor,
    Size area,
    double delta,
    HungryTeddySettings settings,
  ) {
    final speed = settings.animationIntensity * (settings.reducedMotion ? 0.6 : 1.0);
    var v = visitor.copyWith(progress: visitor.progress + delta * speed);

    if (v.wasTapped && v.phase == PartyVisitorPhase.active) {
      final react = (v.reactProgress + delta * 2.5).clamp(0.0, 1.0);
      if (react >= 1) {
        v = v.copyWith(phase: PartyVisitorPhase.leaving, reactProgress: 1);
      } else {
        v = v.copyWith(reactProgress: react);
      }
    }

    if (v.phase == PartyVisitorPhase.leaving || (!v.wasTapped && v.progress > 6)) {
      final leave = v.progress;
      if (leave > 8) return v.copyWith(phase: PartyVisitorPhase.gone);
      return v.copyWith(phase: PartyVisitorPhase.leaving);
    }

    final (nx, ny) = switch (v.kind) {
      PartyVisitorKind.balloon => (v.x, v.y - delta * 28 * speed),
      PartyVisitorKind.toyAnimal => (v.x, v.y + math.sin(v.progress * 3) * 0.5),
      PartyVisitorKind.giftBox => (v.x, v.y + math.sin(v.progress * 5) * 2),
      PartyVisitorKind.bird => (v.x - delta * 45 * speed, v.y + math.sin(v.progress * 4) * 1.5),
    };
    return v.copyWith(x: nx, y: ny);
  }

  static ({int points, int coins, int xp, int stars}) feedReward(
    HungryTeddySettings settings, {
    required bool isGolden,
    required int fedCount,
  }) {
    final m = settings.rewardMultiplier * (isGolden ? 2.0 : 1.0);
    final points = (10 * m).round().clamp(5, 60);
    final coins = (5 * m).round().clamp(2, 30);
    final xp = (5 * m).round().clamp(2, 30);
    final stars = isGolden ? 2 : (fedCount % 3 == 0 ? 1 : 0);
    return (points: points, coins: coins, xp: xp, stars: stars);
  }

  static HungryTeddyResult buildResult(HungryTeddyState state) {
    final favorite = CupcakeVarieties.byIndex(state.favoriteFlavorIndex).name;
    return HungryTeddyResult(
      cupcakesFed: state.cupcakesFed,
      goldenFed: state.goldenFed,
      points: state.pointsEarned,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: state.starsEarned,
      longestStreak: state.longestStreak,
      sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      favoriteFlavor: favorite,
    );
  }

  static String pickEncouragement(int count, {required bool isGolden}) {
    if (isGolden) return kGoldenMessages[count % kGoldenMessages.length];
    return kTeddyEncouragements[count % kTeddyEncouragements.length];
  }

  static String pickVisitorMessage(int count) =>
      kPartyVisitorMessages[count % kPartyVisitorMessages.length];

  static double _easeOut(double t) => 1 - math.pow(1 - t, 3).toDouble();
}
