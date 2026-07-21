import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/logic/catch_the_fish_logic.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';

void main() {
  group('CatchTheFishLogic', () {
    const area = Size(390, 700);
    const settings = CatchFishSettings();

    test('spawnFish creates configured count in ocean lanes', () {
      final fish = CatchTheFishLogic.spawnFish(area, 5);
      expect(fish.length, 5);
      expect(fish.every((f) => f.phase == CatchFishPhase.swimming), isTrue);
      final bounds = CatchTheFishLogic.oceanBounds(area);
      for (final f in fish) {
        expect(f.y, greaterThanOrEqualTo(bounds.top - 10));
        expect(f.y, lessThanOrEqualTo(bounds.bottom + 10));
      }
    });

    test('fishCount clamps to 5–10', () {
      expect(const CatchFishSettings(fishCount: 3).effectiveFishCount, 5);
      expect(const CatchFishSettings(fishCount: 12).effectiveFishCount, 10);
      expect(CatchTheFishLogic.spawnFish(area, 10).length, 10);
    });

    test('catch reward grants coins and xp', () {
      final reward = CatchTheFishLogic.catchReward(settings, caught: 1);
      expect(reward.coins, 10);
      expect(reward.xp, 5);
      final starReward = CatchTheFishLogic.catchReward(settings, caught: 5);
      expect(starReward.stars, 1);
    });

    test('swimming fish wrap around the screen', () {
      var fish = const CatchFishEntity(
        id: 'f1',
        varietyIndex: 0,
        x: 450,
        y: 400,
        lane: 2,
        facingRight: true,
        phase: CatchFishPhase.swimming,
      );
      for (var i = 0; i < 180; i++) {
        fish = CatchTheFishLogic.updateFish(fish, area, 1 / 60, settings);
      }
      expect(fish.phase, CatchFishPhase.swimming);
      expect(fish.x, lessThan(area.width + 80));
    });

    test('reeling fish reaches boat and becomes gone', () {
      var fish = const CatchFishEntity(
        id: 'f1',
        varietyIndex: 0,
        x: 200,
        y: 450,
        lane: 3,
        facingRight: true,
        phase: CatchFishPhase.reeling,
        catchProgress: 0.95,
        catchStartX: 200,
        catchStartY: 450,
      );
      fish = CatchTheFishLogic.updateFish(fish, area, 0.1, settings);
      expect(fish.phase, CatchFishPhase.gone);
    });

    test('spawnReplacement keeps swimming phase', () {
      final existing = CatchTheFishLogic.spawnFish(area, 5);
      final next = CatchTheFishLogic.spawnReplacement(area, existing);
      expect(next.phase, CatchFishPhase.swimming);
      expect(next.id, isNotEmpty);
    });

    test('boatAnchor sits near ocean surface', () {
      final (bx, by) = CatchTheFishLogic.boatAnchor(area);
      expect(bx, closeTo(area.width * 0.5, 1));
      expect(by, lessThan(area.height * 0.3));
    });
  });
}
