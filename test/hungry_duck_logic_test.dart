import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/logic/hungry_duck_logic.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/logic/pond_bounds.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

void main() {
  group('HungryDuckLogic', () {
    test('spawnFish creates configured count', () {
      const area = Size(400, 600);
      final fish = HungryDuckLogic.spawnFish(area, 5);
      expect(fish.length, 5);
      expect(fish.every((f) => f.phase == FishPhase.swimming), isTrue);
    });

    test('spawnFromEdge enters from left or right within water column', () {
      const area = Size(400, 600);
      final yMin = PondBounds.waterTop(area);
      final yMax = PondBounds.waterBottom(area);

      for (var i = 0; i < 10; i++) {
        final f = HungryDuckLogic.spawnFromEdge(area, isGolden: i.isOdd);
        expect(f.phase, FishPhase.entering);
        expect(f.enterFromX < 0 || f.enterFromX > area.width, isTrue);
        expect(f.enterFromY, inInclusiveRange(yMin, yMax));
      }
    });

    test('catchReward doubles for golden fish', () {
      const settings = HungryDuckSettings(rewardMultiplier: 1.0);
      final normal = HungryDuckLogic.catchReward(settings, isGolden: false, caught: 1);
      final golden = HungryDuckLogic.catchReward(settings, isGolden: true, caught: 2);
      expect(golden.points, greaterThan(normal.points));
    });

    test('duck stays at catch position after celebration', () {
      const area = Size(400, 600);
      const settings = HungryDuckSettings();
      var duck = const DuckEntity(
        x: 210,
        y: 360,
        phase: DuckPhase.celebrating,
        celebrateProgress: 0.95,
        restX: 210,
        restY: 360,
      );
      duck = HungryDuckLogic.updateDuck(duck, area, 0.08, settings, null);
      expect(duck.phase, DuckPhase.idleSwim);
      expect(duck.x, closeTo(210, 1));
      expect(duck.y, closeTo(360, 1));
    });

    test('fish stay within pond water bounds', () {
      const area = Size(400, 600);
      final fish = HungryDuckLogic.spawnFish(area, 8);
      final yMin = PondBounds.waterTop(area);
      final yMax = PondBounds.waterBottom(area);

      for (final f in fish) {
        expect(f.y, greaterThanOrEqualTo(yMin));
        expect(f.y, lessThanOrEqualTo(yMax));
      }

      var swimming = fish.first;
      for (var i = 0; i < 120; i++) {
        swimming = HungryDuckLogic.updateFish(
          swimming,
          area,
          1 / 60,
          const HungryDuckSettings(),
        );
        expect(swimming.y, greaterThanOrEqualTo(yMin - 1));
        expect(swimming.y, lessThanOrEqualTo(yMax + 1));
      }
    });

    test('computeSunsetFactor increases after halfway', () {
      expect(HungryDuckLogic.computeSunsetFactor(30, 120), 0);
      expect(HungryDuckLogic.computeSunsetFactor(90, 120), closeTo(0.5, 0.01));
      expect(HungryDuckLogic.computeSunsetFactor(120, 120), 1);
    });
  });
}
