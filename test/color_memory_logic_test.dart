import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/color_memory/logic/color_memory_logic.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

void main() {
  group('ColorMemoryLogic', () {
    test('grid size scales with difficulty', () {
      expect(ColorMemoryLogic.gridSize(ColorMemoryDifficulty.easy), 2);
      expect(ColorMemoryLogic.gridSize(ColorMemoryDifficulty.master), 5);
    });

    test('sequence length respects difficulty bounds', () {
      final len = ColorMemoryLogic.sequenceLength(
        ColorMemoryDifficulty.easy,
        1,
      );
      expect(len, greaterThanOrEqualTo(2));
      expect(len, lessThanOrEqualTo(4));
    });

    test('generateSequence stays within tile count', () {
      const tileCount = 4;
      final seq = ColorMemoryLogic.generateSequence(10, tileCount);
      expect(seq, hasLength(10));
      expect(seq.every((i) => i >= 0 && i < tileCount), isTrue);
    });

    test('calculate rewards perfect round bonus', () {
      const state = ColorMemoryState(
        level: 6,
        roundsTarget: 5,
        score: 50,
        mistakes: 0,
        longestStreak: 4,
      );
      final result = ColorMemoryLogic.calculate(state, 0);
      expect(result.isPerfect, isTrue);
      expect(result.stars, 3);
      expect(result.score, greaterThan(50));
    });
  });
}
