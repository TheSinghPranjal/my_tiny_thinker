import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/odd_one_out/logic/odd_one_out_logic.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';
import 'package:my_tiny_thinker/games/pattern_match/logic/pattern_match_logic.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

void main() {
  group('OddOneOutGenerator', () {
    test('generates exactly one odd item', () {
      final items = OddOneOutGenerator.generatePuzzle(
        const OddOneOutConfig(difficulty: OddOneOutDifficulty.easy),
      );
      expect(items.where((i) => i.isOdd).length, 1);
      expect(items.where((i) => !i.isOdd).length, items.length - 1);
    });
  });

  group('PatternMatchGenerator', () {
    test('generates valid pattern with answer in options', () {
      final puzzle = PatternMatchGenerator.generate(PatternDifficulty.easy);
      expect(puzzle.sequence.last, '?');
      expect(puzzle.options, contains(puzzle.answer));
    });
  });
}
