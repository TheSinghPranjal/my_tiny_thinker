import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/logic/cloud_pop_garden_logic.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';

void main() {
  group('CloudPopGardenLogic', () {
    test('spawnPairs creates requested count', () {
      final result = CloudPopGardenLogic.spawnPairs(const Size(360, 640), 4);
      expect(result.flowers.length, 4);
      expect(result.clouds.length, 4);
      expect(result.clouds.every((c) => c.blueLevel == 1), isTrue);
    });

    test('classifyTap returns success when above flower', () {
      const cloud = CloudEntity(
        id: 'c1',
        pairId: 'p1',
        flowerId: 'f1',
        x: 180,
        y: 200,
        targetX: 180,
        targetY: 200,
        phase: CloudPhase.hovering,
        blueLevel: 1,
      );
      const flower = GardenFlowerEntity(
        id: 'f1',
        pairId: 'p1',
        anchorX: 180,
        anchorY: 420,
      );
      final result = CloudPopGardenLogic.classifyTap(
        cloud,
        flower,
        const Size(360, 640),
      );
      expect(result, CloudTapResult.successRain);
    });

    test('classifyTap returns thunder when too early', () {
      const cloud = CloudEntity(
        id: 'c1',
        pairId: 'p1',
        flowerId: 'f1',
        x: 40,
        y: 100,
        targetX: 180,
        targetY: 200,
        phase: CloudPhase.approaching,
        blueLevel: 1,
      );
      const flower = GardenFlowerEntity(
        id: 'f1',
        pairId: 'p1',
        anchorX: 180,
        anchorY: 420,
      );
      final result = CloudPopGardenLogic.classifyTap(
        cloud,
        flower,
        const Size(360, 640),
      );
      expect(result, CloudTapResult.earlyThunder);
    });

    test('rain reward scales with multiplier', () {
      const settings = CloudPopGardenSettings(rewardMultiplier: 2.0);
      final reward = CloudPopGardenLogic.rainReward(settings, 1);
      expect(reward.coins, greaterThanOrEqualTo(1));
      expect(reward.xp, greaterThanOrEqualTo(3));
    });
  });
}
