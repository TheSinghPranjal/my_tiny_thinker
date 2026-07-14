import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/logic/peek_a_boo_animal_friends_logic.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';

void main() {
  group('PeekABooLogic', () {
    test('maxAnimalsForBushCount follows limits', () {
      expect(PeekABooSettings.maxAnimalsForBushCount(2), 1);
      expect(PeekABooSettings.maxAnimalsForBushCount(4), 2);
      expect(PeekABooSettings.maxAnimalsForBushCount(6), 3);
      expect(PeekABooSettings.maxAnimalsForBushCount(8), 4);
      expect(PeekABooSettings.maxAnimalsForBushCount(10), 5);
    });

    test('spawnBushes creates requested count', () {
      final bushes = PeekABooLogic.spawnBushes(const Size(400, 600), 2);
      expect(bushes.length, 2);
    });

    test('assignHiddenAnimals places animals on bushes', () {
      final bushes = PeekABooLogic.spawnBushes(const Size(400, 600), 4);
      final animals = PeekABooLogic.assignHiddenAnimals(
        bushes: bushes,
        animalCount: 2,
      );
      expect(animals.length, 2);
      expect(animals.every((a) => a.phase == AnimalPhase.hidden), isTrue);
    });

    test('discovery reward scales with multiplier', () {
      const settings = PeekABooSettings(rewardMultiplier: 2.0);
      final reward = PeekABooLogic.discoveryReward(settings, 1);
      expect(reward.points, greaterThanOrEqualTo(10));
      expect(reward.coins, greaterThanOrEqualTo(5));
    });

    test('updateAnimal transitions from popping to visible', () {
      const bush = BushEntity(
        id: 'b0',
        centerX: 100,
        centerY: 300,
        width: 120,
        height: 140,
        colorIndex: 0,
      );
      var animal = const AnimalEntity(
        id: 'a1',
        bushId: 'b0',
        animalId: 'dog',
        phase: AnimalPhase.popping,
        popProgress: 0.95,
      );
      animal = PeekABooLogic.updateAnimal(
        animal,
        bush,
        0.2,
        const Size(400, 600),
        const PeekABooSettings(),
      );
      expect(animal.phase, AnimalPhase.visible);
    });
  });
}
