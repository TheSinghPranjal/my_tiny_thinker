import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

abstract final class NumberBridgeLogic {
  static final random = math.Random();

  static ({
    List<NumberPairCard> digitCards,
    List<NumberPairCard> wordCards,
    List<int> chosenValues,
    int nextSequentialCursor,
  }) generateRound({
    required NumberBridgeSettings settings,
    required List<int> recentValues,
    required int sequentialCursor,
    required int round,
  }) {
    final pairCount = settings.pairCount.clamp(3, 7);
    final maxNumber = settings.maxNumber.clamp(20, 100);
    final chosen = <int>[];
    var cursor = sequentialCursor;

    for (var i = 0; i < pairCount; i++) {
      chosen.add((cursor % maxNumber) + 1);
      cursor = (cursor + 1) % maxNumber;
    }

    final digitOrder = List<int>.from(chosen);
    final wordOrder = List<int>.from(chosen)..shuffle(random);
    if (pairCount > 1 &&
        List.generate(pairCount, (i) => digitOrder[i] == wordOrder[i])
            .every((e) => e)) {
      wordOrder.shuffle(random);
    }

    final digitCards = <NumberPairCard>[
      for (var i = 0; i < digitOrder.length; i++)
        NumberPairCard(
          id: 'digit_${round}_${digitOrder[i]}_$i',
          value: digitOrder[i],
          isDigit: true,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];
    final wordCards = <NumberPairCard>[
      for (var i = 0; i < wordOrder.length; i++)
        NumberPairCard(
          id: 'word_${round}_${wordOrder[i]}_$i',
          value: wordOrder[i],
          isDigit: false,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    return (
      digitCards: digitCards,
      wordCards: wordCards,
      chosenValues: chosen,
      nextSequentialCursor: cursor,
    );
  }

  static List<int> mergeRecent(List<int> recent, List<int> chosen) {
    final next = [...chosen, ...recent];
    if (next.length > 18) return next.take(18).toList();
    return next;
  }

  static ({int points, int coins, int xp, int stars}) matchReward(
    NumberBridgeSettings settings,
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
    NumberBridgeSettings settings,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (50 * mult).round(),
      coins: math.max(5, (20 * mult).round()),
      xp: math.max(5, (20 * mult).round()),
      stars: 2,
    );
  }

  static String successPhrase(int value) {
    final word = NumberWords.word(value);
    final options = [
      '$word matches $value!',
      'Great! $value is $word!',
      'Excellent! $word matches $value!',
    ];
    return options[random.nextInt(options.length)];
  }

  static String encouragePhrase() =>
      kNumberBridgeEncourage[random.nextInt(kNumberBridgeEncourage.length)];

  static NumberBridgeResult calculate(NumberBridgeState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return NumberBridgeResult(
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

  static GameRewardResult toReward(NumberBridgeResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 8),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static ({
    List<NumberPairCard> digitCards,
    List<NumberPairCard> wordCards,
  }) tickAnimations(
    List<NumberPairCard> digitCards,
    List<NumberPairCard> wordCards,
    double delta,
    bool reducedMotion,
  ) {
    if (reducedMotion) return (digitCards: digitCards, wordCards: wordCards);
    return (
      digitCards: [
        for (final c in digitCards)
          c.shake ? c.copyWith(animPhase: c.animPhase + delta * 18) : c,
      ],
      wordCards: [
        for (final c in wordCards)
          c.shake ? c.copyWith(animPhase: c.animPhase + delta * 18) : c,
      ],
    );
  }
}
