import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/logic/flower_garden_logic.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

void main() {
  group('FlowerGardenLogic', () {
    test('bloom reward scales with multiplier', () {
      const settings = FlowerGardenSettings(rewardMultiplier: 2.0);
      final reward = FlowerGardenLogic.bloomReward(settings);
      expect(reward.coins, greaterThanOrEqualTo(2));
      expect(reward.xp, greaterThanOrEqualTo(3));
    });

    test('spawnSingleFlower creates centered bud', () {
      final flower = FlowerGardenLogic.spawnSingleFlower(
        const Size(360, 500),
      );
      expect(flower.phase, FlowerPhase.bud);
      expect(flower.anchorX, 180);
    });

    test('cooldown transitions to relocating', () {
      const flower = FlowerEntity(
        id: 'f1',
        anchorX: 100,
        anchorY: 200,
        phase: FlowerPhase.cooldown,
        bloomProgress: 0.5,
        phaseTimer: 1.35,
      );
      final updated = FlowerGardenLogic.updateFlower(
        flower,
        0.1,
        1,
        1,
        const Size(360, 500),
        const FlowerGardenSettings(),
      );
      expect(updated.phase, FlowerPhase.relocating);
      expect(updated.bloomProgress, 0);
    });

    test('spawnPollinators creates colourful butterflies', () {
      final pollinators = FlowerGardenLogic.spawnPollinators(
        const Size(360, 500),
        'flower_1',
        180,
        250,
      );
      expect(pollinators, isNotEmpty);
      expect(pollinators.first.phase, PollinatorPhase.entering);
      expect(pollinators.first.kind, PollinatorKind.butterfly);
    });

    test('pickDifferentPaletteIndex never returns current', () {
      for (var i = 0; i < 20; i++) {
        final next = FlowerGardenLogic.pickDifferentPaletteIndex(2);
        expect(next, isNot(2));
      }
    });

    test('open flower advances colour morph toward target palette', () {
      const flower = FlowerEntity(
        id: 'f1',
        anchorX: 100,
        anchorY: 200,
        phase: FlowerPhase.open,
        bloomProgress: 1,
        paletteIndex: 0,
        morphPaletteIndex: 3,
        colorMorph: 0.9,
      );
      final updated = FlowerGardenLogic.updateFlower(
        flower,
        0.3,
        1,
        1,
        const Size(360, 500),
        const FlowerGardenSettings(),
      );
      expect(updated.paletteIndex, 3);
      expect(updated.morphPaletteIndex, isNull);
    });

    test('leaving butterfly flies away and becomes gone', () {
      var p = const PollinatorEntity(
        id: 'p1',
        flowerId: 'f1',
        kind: PollinatorKind.butterfly,
        x: 180,
        y: 250,
        phase: PollinatorPhase.leaving,
        rotation: 0, // fly to the right
        progress: 0,
      );
      for (var i = 0; i < 120 && p.phase != PollinatorPhase.gone; i++) {
        p = FlowerGardenLogic.updatePollinator(
          p: p,
          flowerX: 180,
          flowerY: 250,
          delta: 1 / 60,
          intensity: 1,
          onNectarCollected: (_) {},
        );
      }
      expect(p.phase, PollinatorPhase.gone);
    });

    test('collecting butterfly eventually leaves with stable heading', () {
      var p = const PollinatorEntity(
        id: 'p1',
        flowerId: 'f1',
        kind: PollinatorKind.butterfly,
        x: 180,
        y: 230,
        phase: PollinatorPhase.collecting,
        rotation: 0.5,
        progress: 2.5,
      );
      p = FlowerGardenLogic.updatePollinator(
        p: p,
        flowerX: 180,
        flowerY: 250,
        delta: 0.2,
        intensity: 1,
        onNectarCollected: (_) {},
      );
      expect(p.phase, PollinatorPhase.leaving);
      final leaveAngle = p.rotation;
      p = FlowerGardenLogic.updatePollinator(
        p: p,
        flowerX: 180,
        flowerY: 250,
        delta: 1 / 60,
        intensity: 1,
        onNectarCollected: (_) {},
      );
      expect(p.rotation, leaveAngle);
      expect(p.phase, PollinatorPhase.leaving);
    });

    test('open flower phaseTimer advances for unbloom failsafe', () {
      const flower = FlowerEntity(
        id: 'f1',
        anchorX: 100,
        anchorY: 200,
        phase: FlowerPhase.open,
        bloomProgress: 1,
        phaseTimer: 0,
      );
      final updated = FlowerGardenLogic.updateFlower(
        flower,
        0.5,
        1,
        1,
        const Size(360, 500),
        const FlowerGardenSettings(),
      );
      expect(updated.phase, FlowerPhase.open);
      expect(updated.phaseTimer, closeTo(0.5, 0.001));
    });

    test('scareBird enters scared phase', () {
      const bird = BirdEntity(
        id: 'b1',
        x: 50,
        y: 50,
        targetX: 180,
        targetY: 200,
      );
      final scared = FlowerGardenLogic.scareBird(bird);
      expect(scared.phase, BirdPhase.scared);
    });
  });
}
