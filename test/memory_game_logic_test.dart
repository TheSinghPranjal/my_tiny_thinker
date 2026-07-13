import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

void main() {
  group('MemoryDifficultyConfig', () {
    test('card grid scales with difficulty', () {
      expect(MemoryDifficultyConfig.cardGrid(MemoryDifficulty.easy), (2, 2));
      expect(MemoryDifficultyConfig.cardGrid(MemoryDifficulty.master), (6, 6));
    });

    test('sequence length grows with round', () {
      final len1 = MemoryDifficultyConfig.sequenceLength(MemoryDifficulty.easy, 1);
      final len2 = MemoryDifficultyConfig.sequenceLength(MemoryDifficulty.easy, 3);
      expect(len2, greaterThan(len1));
    });
  });

  group('AdaptiveDifficulty', () {
    test('increases on success', () {
      final result = AdaptiveDifficulty.adjust(
        current: MemoryDifficulty.easy,
        lastRoundSuccess: true,
        adaptiveEnabled: true,
      );
      expect(result, MemoryDifficulty.medium);
    });

    test('stays same when adaptive disabled', () {
      final result = AdaptiveDifficulty.adjust(
        current: MemoryDifficulty.hard,
        lastRoundSuccess: false,
        adaptiveEnabled: false,
      );
      expect(result, MemoryDifficulty.hard);
    });
  });

  group('MemoryContent', () {
    test('theme items stay within theme', () {
      final items = MemoryContent.themeItems(MemoryCardTheme.fruits, 5);
      expect(items.length, 5);
    });
  });
}
