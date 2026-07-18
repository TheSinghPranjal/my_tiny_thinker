import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/logic/alphabet_bridge_logic.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';

void main() {
  group('AlphabetBridgeLogic', () {
    test('defaults to 60 seconds and 4 pairs', () {
      const s = AlphabetBridgeSettings();
      expect(s.sessionSeconds, 60);
      expect(s.pairCount, 4);
      expect(s.unlimitedTime, isFalse);
    });

    test('generates equal lower and upper cards with matching letters', () {
      final round = AlphabetBridgeLogic.generateRound(
        settings: const AlphabetBridgeSettings(pairCount: 4),
        recentLetterIndexes: const [],
        sequentialCursor: 0,
        round: 1,
      );
      expect(round.lower.length, 4);
      expect(round.upper.length, 4);
      final lowerSet = round.lower.map((c) => c.letterIndex).toSet();
      final upperSet = round.upper.map((c) => c.letterIndex).toSet();
      expect(lowerSet, upperSet);
      expect(round.lower.every((c) => !c.isUppercase), isTrue);
      expect(round.upper.every((c) => c.isUppercase), isTrue);
    });

    test('respects pairCount 3–7', () {
      for (final count in [3, 5, 7]) {
        final round = AlphabetBridgeLogic.generateRound(
          settings: AlphabetBridgeSettings(pairCount: count),
          recentLetterIndexes: const [],
          sequentialCursor: 0,
          round: 1,
        );
        expect(round.lower.length, count);
        expect(round.upper.length, count);
      }
    });

    test('sequential mode advances A–Z', () {
      final round = AlphabetBridgeLogic.generateRound(
        settings: const AlphabetBridgeSettings(
          pairCount: 3,
          orderMode: AlphabetOrderMode.sequential,
        ),
        recentLetterIndexes: const [],
        sequentialCursor: 0,
        round: 1,
      );
      expect(round.chosenIndexes, [0, 1, 2]);
      expect(round.nextSequentialCursor, 3);
    });

    test('matchReward gives positive rewards', () {
      final r = AlphabetBridgeLogic.matchReward(const AlphabetBridgeSettings(), 1);
      expect(r.points, 10);
      expect(r.coins, 5);
      expect(r.xp, 5);
      expect(r.stars, 1);
    });

    test('roundBonus awards celebration rewards', () {
      final r = AlphabetBridgeLogic.roundBonus(const AlphabetBridgeSettings());
      expect(r.points, 50);
      expect(r.coins, 20);
      expect(r.xp, 20);
    });

    test('mergeRecent prefers newest letters', () {
      final merged = AlphabetBridgeLogic.mergeRecent(
        [1, 2, 3],
        [10, 11, 12],
      );
      expect(merged.take(3), [10, 11, 12]);
    });
  });
}
