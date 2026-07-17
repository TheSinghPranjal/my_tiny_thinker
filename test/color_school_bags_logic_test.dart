import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/color_school_bags/logic/color_school_bags_logic.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

void main() {
  group('ColorSchoolBagsLogic', () {
    test('defaults to 60 seconds and 3 bags', () {
      const s = SortBagsSettings();
      expect(s.sessionSeconds, 60);
      expect(s.unlimitedTime, isFalse);
      expect(s.maxBackpacks, 3);
    });

    test('level 1 creates 2 books and 2 backpacks', () {
      final round = ColorSchoolBagsLogic.generateRound(
        settings: const SortBagsSettings(),
        level: 1,
      );
      expect(round.books.length, 2);
      expect(round.backpacks.length, 2);
      final bookColors = round.books.map((b) => b.colorKind).toSet();
      final bagColors = round.backpacks.map((b) => b.colorKind).toSet();
      expect(bookColors, bagColors);
    });

    test('default max of 3 caps later levels', () {
      final round = ColorSchoolBagsLogic.generateRound(
        settings: const SortBagsSettings(),
        level: 3,
      );
      expect(round.books.length, 3);
      expect(round.backpacks.length, 3);
    });

    test('level 3 creates 4 items when max allows', () {
      final round = ColorSchoolBagsLogic.generateRound(
        settings: const SortBagsSettings(maxBackpacks: 4),
        level: 3,
      );
      expect(round.books.length, 4);
      expect(round.backpacks.length, 4);
    });

    test('respects maxBackpacks cap', () {
      final round = ColorSchoolBagsLogic.generateRound(
        settings: const SortBagsSettings(maxBackpacks: 2),
        level: 5,
      );
      expect(round.books.length, 2);
      expect(round.backpacks.length, 2);
    });

    test('matchReward returns +10 stars', () {
      final r = ColorSchoolBagsLogic.matchReward(const SortBagsSettings(), 1);
      expect(r.points, 10);
      expect(r.stars, 10);
      expect(r.coins, greaterThan(0));
    });

    test('activeColors falls back when fewer than 2', () {
      final s = SortBagsSettings(
        enabledColors: [BagColorKind.red],
      );
      expect(s.activeColors.length, greaterThanOrEqualTo(2));
    });
  });
}
