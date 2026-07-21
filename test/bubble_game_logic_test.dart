import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';

void main() {
  group('BubbleNumberGenerator', () {
    test('generates unique numbers within range when random', () {
      final numbers = BubbleNumberGenerator.generate(
        count: 10,
        minValue: 1,
        maxValue: 50,
        difficulty: Difficulty.easy,
        randomNumbers: true,
      );
      expect(numbers.length, 10);
      expect(numbers.toSet().length, 10);
      for (final n in numbers) {
        expect(n, inInclusiveRange(1, 50));
      }
    });

    test('generates consecutive sequence when not random', () {
      final numbers = BubbleNumberGenerator.generate(
        count: 8,
        minValue: 0,
        maxValue: 20,
        difficulty: Difficulty.easy,
        randomNumbers: false,
      );
      expect(numbers.length, 8);
      for (var i = 1; i < numbers.length; i++) {
        expect(numbers[i], numbers[i - 1] + 1);
      }
      expect(numbers.first, greaterThanOrEqualTo(0));
      expect(numbers.last, lessThanOrEqualTo(20));
    });

    test('handles min equals max', () {
      final numbers = BubbleNumberGenerator.generate(
        count: 5,
        minValue: 7,
        maxValue: 7,
        difficulty: Difficulty.easy,
        randomNumbers: false,
      );
      expect(numbers.every((n) => n == 7), isTrue);
    });

    test('sorts ascending and descending', () {
      final nums = [5, 1, 3, 2, 4];
      expect(
        BubbleNumberGenerator.sortNumbers(nums, SortMode.ascending),
        [1, 2, 3, 4, 5],
      );
      expect(
        BubbleNumberGenerator.sortNumbers(nums, SortMode.descending),
        [5, 4, 3, 2, 1],
      );
    });

    test('random numbers still sort ascending for play order', () {
      final numbers = BubbleNumberGenerator.generate(
        count: 8,
        minValue: 0,
        maxValue: 20,
        difficulty: Difficulty.easy,
        randomNumbers: true,
      );
      final sorted =
          BubbleNumberGenerator.sortNumbers(numbers, SortMode.ascending);
      for (var i = 1; i < sorted.length; i++) {
        expect(sorted[i], greaterThan(sorted[i - 1]));
      }
    });

    test('word match round includes the target among bubbles', () {
      final round = BubbleNumberGenerator.generateWordMatchRound(
        count: 8,
        minValue: 0,
        maxValue: 50,
        randomNumbers: true,
      );
      expect(round.numbers.length, 8);
      expect(round.numbers, contains(round.target));
      expect(round.target, inInclusiveRange(0, 50));
    });
  });

  group('BubbleScoring', () {
    test('combo points increase with streak', () {
      expect(BubbleScoring.pointsForCorrect(1), 10);
      expect(BubbleScoring.pointsForCorrect(3), greaterThan(10));
    });
  });
}
