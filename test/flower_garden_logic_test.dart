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

    test('spawnPollinators creates bee or butterfly', () {
      final pollinators = FlowerGardenLogic.spawnPollinators(
        const Size(360, 500),
        'flower_1',
        180,
        250,
      );
      expect(pollinators, isNotEmpty);
      expect(pollinators.first.phase, PollinatorPhase.entering);
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
