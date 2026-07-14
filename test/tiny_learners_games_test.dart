import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/logic/shadow_match_logic.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/logic/alphabet_quiz_logic.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';

void main() {
  group('ShadowMatchLogic', () {
    test('generateRound creates unique items', () {
      const settings = ShadowMatchSettings(difficulty: ShadowDifficulty.medium);
      final round = ShadowMatchLogic.generateRound(settings);
      expect(round.shadows.length, 4);
      expect(round.items.length, 4);
      final ids = round.shadows.map((s) => s.itemId).toSet();
      expect(ids.length, 4);
    });
  });

  group('AlphabetQuizLogic', () {
    test('generateQuestion has one correct option', () {
      final q = AlphabetQuizLogic.generateQuestion('A', LetterCaseMode.uppercase);
      expect(q.options.length, 4);
      expect(q.options.where((o) => o.isCorrect).length, 1);
      expect(q.letter, 'A');
    });

    test('buildLetterQueue sequential keeps A first', () {
      const settings = AlphabetQuizSettings(alphabetOrder: AlphabetOrder.sequential);
      final queue = AlphabetQuizLogic.buildLetterQueue(settings);
      expect(queue.first, 'A');
    });
  });
}
