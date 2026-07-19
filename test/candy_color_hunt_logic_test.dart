import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/logic/candy_color_hunt_logic.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

void main() {
  group('CandyColorHuntLogic', () {
    test('spawnBowl creates up to 10 candies with guaranteed pairs', () {
      final candies = CandyColorHuntLogic.spawnBowl(const CandyHuntSettings());
      expect(candies.length, CandyColorHuntLogic.bowlCapacity);

      final counts = <CandyColorKind, int>{};
      for (final c in candies) {
        counts[c.colorKind] = (counts[c.colorKind] ?? 0) + 1;
        expect(c.style, CandyStyle.wrapped);
      }
      for (final color in CandyColorCatalog.defaultEnabled) {
        expect(counts[color] ?? 0, greaterThanOrEqualTo(2));
      }
    });

    test('pickTarget only chooses colors present in the bowl', () {
      final settings = const CandyHuntSettings();
      final candies = CandyColorHuntLogic.spawnBowl(settings);
      final target = CandyColorHuntLogic.pickTarget(candies, settings);
      expect(candies.any((c) => c.colorKind == target), isTrue);
      final count = candies.where((c) => c.colorKind == target).length;
      expect(count, greaterThanOrEqualTo(2));
    });

    test('replenish keeps at least two of next target', () {
      final settings = const CandyHuntSettings();
      var candies = CandyColorHuntLogic.spawnBowl(settings);
      final target = CandyColorHuntLogic.pickTarget(candies, settings);
      final idx = candies.indexWhere((c) => c.colorKind == target);
      candies = [
        for (var i = 0; i < candies.length; i++)
          if (i == idx) candies[i].copyWith(eaten: true) else candies[i],
      ];
      final next = CandyColorHuntLogic.replenish(candies, settings, target);
      expect(next.where((c) => !c.eaten).length, lessThanOrEqualTo(10));
      expect(
        next.where((c) => !c.eaten && c.colorKind == target).length,
        greaterThanOrEqualTo(2),
      );
    });

    test('correctReward returns positive values', () {
      final r = CandyColorHuntLogic.correctReward(const CandyHuntSettings(), 1);
      expect(r.points, 10);
      expect(r.coins, greaterThan(0));
      expect(r.xp, greaterThan(0));
    });

    test('settings refuse fewer than 4 colors via activeColors fallback', () {
      final s = CandyHuntSettings(
        enabledColors: [CandyColorKind.red, CandyColorKind.blue],
      );
      expect(s.activeColors.length, greaterThanOrEqualTo(4));
    });
  });
}
