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
      expect(reward.xp, greaterThanOrEqualTo(2));
    });

    test('spawnFlowers creates requested count', () {
      final flowers = FlowerGardenLogic.spawnFlowers(
        const Size(360, 500),
        4,
      );
      expect(flowers.length, 4);
      expect(flowers.every((f) => f.phase == FlowerPhase.bud), isTrue);
    });

    test('cooldown returns to bud when petals close', () {
      const flower = FlowerEntity(
        id: 'f1',
        anchorX: 100,
        anchorY: 200,
        phase: FlowerPhase.cooldown,
        bloomProgress: 0.5,
        phaseTimer: 1.15,
      );
      final updated = FlowerGardenLogic.updateFlower(
        flower,
        0.1,
        1,
        1,
      );
      expect(updated.phase, FlowerPhase.bud);
      expect(updated.bloomProgress, 0);
    });
    test('spawnBee creates bee for flower', () {
      final bee = FlowerGardenLogic.spawnBee(
        const Size(360, 500),
        'flower_1',
        180,
        250,
      );
      expect(bee.flowerId, 'flower_1');
      expect(bee.phase, PollinatorPhase.entering);
    });
  });
}
