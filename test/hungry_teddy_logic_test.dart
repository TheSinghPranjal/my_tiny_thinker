import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/logic/hungry_teddy_logic.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

void main() {
  group('HungryTeddyLogic', () {
    test('spawnCupcakes creates configured count', () {
      const area = Size(400, 600);
      final cupcakes = HungryTeddyLogic.spawnCupcakes(area, 6);
      expect(cupcakes.length, 6);
      expect(cupcakes.every((c) => c.phase == CupcakePhase.onTable), isTrue);
    });

    test('spawnBakingCupcake creates golden cupcake', () {
      const area = Size(400, 600);
      final c = HungryTeddyLogic.spawnBakingCupcake(area, 0, isGolden: true);
      expect(c.phase, CupcakePhase.baking);
      expect(c.isGolden, isTrue);
    });

    test('feedReward doubles for golden cupcake', () {
      const settings = HungryTeddySettings(rewardMultiplier: 1.0);
      final normal = HungryTeddyLogic.feedReward(settings, isGolden: false, fedCount: 1);
      final golden = HungryTeddyLogic.feedReward(settings, isGolden: true, fedCount: 2);
      expect(golden.points, greaterThan(normal.points));
      expect(golden.coins, greaterThan(normal.coins));
    });

    test('computeEveningFactor increases after halfway', () {
      expect(HungryTeddyLogic.computeEveningFactor(30, 120), 0);
      expect(HungryTeddyLogic.computeEveningFactor(90, 120), closeTo(0.5, 0.01));
      expect(HungryTeddyLogic.computeEveningFactor(120, 120), 1);
    });

    test('isNearTeddy respects drag sensitivity', () {
      const area = Size(400, 600);
      final (mx, my) = HungryTeddyLogic.teddyMouth(area);
      const easy = HungryTeddySettings(dragSensitivity: TeddyDragSensitivity.veryLow);
      const hard = HungryTeddySettings(dragSensitivity: TeddyDragSensitivity.high);
      expect(
        HungryTeddyLogic.isNearTeddy(area, mx + 80, my, easy),
        isTrue,
      );
      expect(
        HungryTeddyLogic.isNearTeddy(area, mx + 80, my, hard),
        isFalse,
      );
    });
  });
}
