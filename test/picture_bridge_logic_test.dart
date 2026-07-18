import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/logic/picture_bridge_logic.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

void main() {
  group('PictureBridgeLogic', () {
    test('defaults to 60 seconds and 4 pairs', () {
      const s = PictureBridgeSettings();
      expect(s.sessionSeconds, 60);
      expect(s.pairCount, 4);
      expect(s.unlimitedTime, isFalse);
    });

    test('generates equal picture and word cards with matching vocab ids', () {
      final round = PictureBridgeLogic.generateRound(
        settings: const PictureBridgeSettings(pairCount: 4),
        recentVocabIds: const [],
        sequentialCursor: 0,
        round: 1,
      );
      expect(round.pictureCards.length, 4);
      expect(round.wordCards.length, 4);
      final picSet = round.pictureCards.map((c) => c.vocabId).toSet();
      final wordSet = round.wordCards.map((c) => c.vocabId).toSet();
      expect(picSet, wordSet);
      expect(round.pictureCards.every((c) => c.isPicture), isTrue);
      expect(round.wordCards.every((c) => !c.isPicture), isTrue);
    });

    test('respects pairCount 3–7', () {
      for (final count in [3, 5, 7]) {
        final round = PictureBridgeLogic.generateRound(
          settings: PictureBridgeSettings(pairCount: count),
          recentVocabIds: const [],
          sequentialCursor: 0,
          round: 1,
        );
        expect(round.pictureCards.length, count);
        expect(round.wordCards.length, count);
      }
    });

    test('prefers shorter vocabulary words first', () {
      final round = PictureBridgeLogic.generateRound(
        settings: const PictureBridgeSettings(pairCount: 3),
        recentVocabIds: const [],
        sequentialCursor: 0,
        round: 1,
      );
      final sorted = List.of(EducationVocabulary.items)
        ..sort((a, b) {
          final len = a.name.length.compareTo(b.name.length);
          if (len != 0) return len;
          return a.name.compareTo(b.name);
        });
      expect(round.chosenIds, sorted.take(3).map((v) => v.id).toList());
    });

    test('matchReward gives positive rewards', () {
      final r =
          PictureBridgeLogic.matchReward(const PictureBridgeSettings(), 1);
      expect(r.points, 10);
      expect(r.coins, 5);
      expect(r.xp, 5);
      expect(r.stars, 1);
    });

    test('roundBonus awards celebration rewards', () {
      final r = PictureBridgeLogic.roundBonus(const PictureBridgeSettings());
      expect(r.points, 50);
      expect(r.coins, 20);
      expect(r.xp, 20);
    });
  });
}
