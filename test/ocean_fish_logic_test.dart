import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/logic/ocean_fish_logic.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';

void main() {
  group('FishSpawner', () {
    test('creates fish within play area bounds after movement', () {
      const settings = OceanFishSettings(maxFishOnScreen: 5);
      final fish = List.generate(
        5,
        (i) => FishSpawner.create(
          playArea: const Size(360, 500),
          settings: settings,
          slotIndex: i,
          totalSlots: 5,
        ),
      );
      expect(fish.length, 5);
      expect(fish.map((f) => f.variantIndex).toSet().length, greaterThan(1));
    });
  });

  group('OceanFishScoring', () {
    test('every 5 fish earns a star flag', () {
      expect(OceanFishScoring.fishTappedEveryN(5), isTrue);
      expect(OceanFishScoring.fishTappedEveryN(4), isFalse);
    });
  });
}
