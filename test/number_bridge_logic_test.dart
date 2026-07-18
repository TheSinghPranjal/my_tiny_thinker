import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/logic/number_bridge_logic.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

void main() {
  group('NumberBridgeLogic', () {
    test('defaults to 60 seconds and 4 pairs', () {
      const s = NumberBridgeSettings();
      expect(s.sessionSeconds, 60);
      expect(s.pairCount, 4);
      expect(s.maxNumber, 20);
      expect(s.unlimitedTime, isFalse);
    });

    test('generates equal digit and word cards with matching values', () {
      final round = NumberBridgeLogic.generateRound(
        settings: const NumberBridgeSettings(pairCount: 4),
        recentValues: const [],
        sequentialCursor: 0,
        round: 1,
      );
      expect(round.digitCards.length, 4);
      expect(round.wordCards.length, 4);
      final digitSet = round.digitCards.map((c) => c.value).toSet();
      final wordSet = round.wordCards.map((c) => c.value).toSet();
      expect(digitSet, wordSet);
      expect(round.digitCards.every((c) => c.isDigit), isTrue);
      expect(round.wordCards.every((c) => !c.isDigit), isTrue);
    });

    test('respects pairCount 3–7', () {
      for (final count in [3, 5, 7]) {
        final round = NumberBridgeLogic.generateRound(
          settings: NumberBridgeSettings(pairCount: count),
          recentValues: const [],
          sequentialCursor: 0,
          round: 1,
        );
        expect(round.digitCards.length, count);
        expect(round.wordCards.length, count);
      }
    });

    test('sequential mode advances 1..maxNumber', () {
      final round = NumberBridgeLogic.generateRound(
        settings: const NumberBridgeSettings(pairCount: 3, maxNumber: 20),
        recentValues: const [],
        sequentialCursor: 0,
        round: 1,
      );
      expect(round.chosenValues, [1, 2, 3]);
      expect(round.nextSequentialCursor, 3);
    });

    test('successPhrase mentions number and word', () {
      final phrase = NumberBridgeLogic.successPhrase(3);
      expect(phrase.contains('Three') || phrase.contains('3'), isTrue);
    });

    test('matchReward gives positive rewards', () {
      final r = NumberBridgeLogic.matchReward(const NumberBridgeSettings(), 1);
      expect(r.points, 10);
      expect(r.coins, 5);
      expect(r.xp, 5);
      expect(r.stars, 1);
    });

    test('roundBonus awards celebration rewards', () {
      final r = NumberBridgeLogic.roundBonus(const NumberBridgeSettings());
      expect(r.points, 50);
      expect(r.coins, 20);
      expect(r.xp, 20);
    });

    test('mergeRecent prefers newest values', () {
      final merged = NumberBridgeLogic.mergeRecent([1, 2, 3], [10, 11, 12]);
      expect(merged.take(3), [10, 11, 12]);
    });
  });
}
