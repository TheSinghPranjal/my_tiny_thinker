import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

abstract final class PictureBridgeLogic {
  static final random = math.Random();

  static List<VocabItem> get _sortedVocab {
    final items = List<VocabItem>.from(EducationVocabulary.items)
      ..sort((a, b) {
        final len = a.name.length.compareTo(b.name.length);
        if (len != 0) return len;
        return a.name.compareTo(b.name);
      });
    return items;
  }

  static ({
    List<PicturePairCard> pictureCards,
    List<PicturePairCard> wordCards,
    List<String> chosenIds,
    int nextSequentialCursor,
  }) generateRound({
    required PictureBridgeSettings settings,
    required List<String> recentVocabIds,
    required int sequentialCursor,
    required int round,
  }) {
    final pairCount = settings.pairCount.clamp(3, 7);
    final pool = _sortedVocab;
    final chosen = <String>[];
    var cursor = sequentialCursor;

    for (var i = 0; i < pairCount; i++) {
      chosen.add(pool[cursor % pool.length].id);
      cursor = (cursor + 1) % pool.length;
    }

    final pictureOrder = List<String>.from(chosen);
    final wordOrder = List<String>.from(chosen)..shuffle(random);
    if (pairCount > 1 &&
        List.generate(pairCount, (i) => pictureOrder[i] == wordOrder[i])
            .every((e) => e)) {
      wordOrder.shuffle(random);
    }

    final pictureCards = <PicturePairCard>[
      for (var i = 0; i < pictureOrder.length; i++)
        PicturePairCard(
          id: 'pic_${round}_${pictureOrder[i]}_$i',
          vocabId: pictureOrder[i],
          isPicture: true,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];
    final wordCards = <PicturePairCard>[
      for (var i = 0; i < wordOrder.length; i++)
        PicturePairCard(
          id: 'word_${round}_${wordOrder[i]}_$i',
          vocabId: wordOrder[i],
          isPicture: false,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    return (
      pictureCards: pictureCards,
      wordCards: wordCards,
      chosenIds: chosen,
      nextSequentialCursor: cursor,
    );
  }

  static List<String> mergeRecent(List<String> recent, List<String> chosen) {
    final next = [...chosen, ...recent];
    if (next.length > 18) return next.take(18).toList();
    return next;
  }

  static ({int points, int coins, int xp, int stars}) matchReward(
    PictureBridgeSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (10 * mult).round(),
      coins: math.max(1, (5 * mult).round()),
      xp: math.max(2, (5 * mult).round()),
      stars: 1,
    );
  }

  static ({int points, int coins, int xp, int stars}) roundBonus(
    PictureBridgeSettings settings,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (50 * mult).round(),
      coins: math.max(5, (20 * mult).round()),
      xp: math.max(5, (20 * mult).round()),
      stars: 2,
    );
  }

  static String successPhrase(String vocabId) {
    final item = EducationVocabulary.byId(vocabId);
    if (item == null) return 'Great match!';
    final options = [
      '${item.emoji} matches ${item.name}!',
      'Great! ${item.name}!',
      'Excellent! ${item.emoji} is ${item.name}!',
    ];
    return options[random.nextInt(options.length)];
  }

  static String encouragePhrase() =>
      kPictureBridgeEncourage[random.nextInt(kPictureBridgeEncourage.length)];

  static PictureBridgeResult calculate(PictureBridgeState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return PictureBridgeResult(
      score: state.score,
      correctMatches: state.correctMatches,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      roundsCompleted: state.roundsCompleted,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: state.starsEarned + bonusStars,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(PictureBridgeResult result) =>
      GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 8),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static ({
    List<PicturePairCard> pictureCards,
    List<PicturePairCard> wordCards,
  }) tickAnimations(
    List<PicturePairCard> pictureCards,
    List<PicturePairCard> wordCards,
    double delta,
    bool reducedMotion,
  ) {
    if (reducedMotion) {
      return (pictureCards: pictureCards, wordCards: wordCards);
    }
    return (
      pictureCards: [
        for (final c in pictureCards)
          c.shake ? c.copyWith(animPhase: c.animPhase + delta * 18) : c,
      ],
      wordCards: [
        for (final c in wordCards)
          c.shake ? c.copyWith(animPhase: c.animPhase + delta * 18) : c,
      ],
    );
  }
}
