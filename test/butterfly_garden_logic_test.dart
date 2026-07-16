import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/logic/butterfly_garden_logic.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

void main() {
  group('ButterflyGardenLogic', () {
    test('spawnButterflies creates configured count', () {
      const area = Size(400, 600);
      final butterflies = ButterflyGardenLogic.spawnButterflies(area, 5);
      expect(butterflies.length, 5);
      expect(butterflies.every((b) => b.phase == ButterflyPhase.flying), isTrue);
    });

    test('spawnFromEdge creates entering butterfly', () {
      const area = Size(400, 600);
      final b = ButterflyGardenLogic.spawnFromEdge(area, isGolden: true);
      expect(b.phase, ButterflyPhase.entering);
      expect(b.isGolden, isTrue);
    });

    test('catchReward doubles for golden butterfly', () {
      const settings = ButterflyGardenSettings(rewardMultiplier: 1.0);
      final normal = ButterflyGardenLogic.catchReward(settings, isGolden: false, caught: 1);
      final golden = ButterflyGardenLogic.catchReward(settings, isGolden: true, caught: 2);
      expect(golden.points, greaterThan(normal.points));
      expect(golden.coins, greaterThan(normal.coins));
    });

    test('basketAnchor places basket near bottom center', () {
      final anchor = ButterflyGardenLogic.basketAnchor(const Size(400, 600));
      expect(anchor.$1, 200);
      expect(anchor.$2, greaterThan(500));
    });
  });
}
