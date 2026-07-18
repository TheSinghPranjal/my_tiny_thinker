import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';

abstract final class AlphabetBridgeLogic {
  static final random = math.Random();

  static ({
    List<BridgeCard> lower,
    List<BridgeCard> upper,
    List<int> chosenIndexes,
    int nextSequentialCursor,
  }) generateRound({
    required AlphabetBridgeSettings settings,
    required List<int> recentLetterIndexes,
    required int sequentialCursor,
    required int round,
  }) {
    final pairCount = settings.pairCount.clamp(3, 7);
    final chosen = <int>[];
    var cursor = sequentialCursor;

    if (settings.orderMode == AlphabetOrderMode.sequential) {
      for (var i = 0; i < pairCount; i++) {
        chosen.add(cursor % 26);
        cursor = (cursor + 1) % 26;
      }
    } else {
      final recent = recentLetterIndexes.toSet();
      final fresh = <int>[
        for (var i = 0; i < 26; i++)
          if (!recent.contains(i)) i,
      ]..shuffle(random);
      final pool = <int>[
        ...fresh,
        ...List<int>.generate(26, (i) => i)..shuffle(random),
      ];
      for (final i in pool) {
        if (chosen.contains(i)) continue;
        chosen.add(i);
        if (chosen.length >= pairCount) break;
      }
    }

    final lowerOrder = List<int>.from(chosen);
    // Left column keeps stable order for sequential; slight shuffle for random.
    if (settings.orderMode == AlphabetOrderMode.random) {
      lowerOrder.shuffle(random);
    }

    final upperOrder = List<int>.from(chosen)..shuffle(random);
    // Avoid accidental straight matches when possible.
    if (pairCount > 1 &&
        List.generate(pairCount, (i) => lowerOrder[i] == upperOrder[i])
            .every((e) => e)) {
      upperOrder.shuffle(random);
    }

    final lower = <BridgeCard>[
      for (var i = 0; i < lowerOrder.length; i++)
        BridgeCard(
          id: 'lower_${round}_${lowerOrder[i]}_$i',
          letterIndex: lowerOrder[i],
          isUppercase: false,
          floatPhase: random.nextDouble() * math.pi * 2,
        ),
    ];
    final upper = <BridgeCard>[
      for (var i = 0; i < upperOrder.length; i++)
        BridgeCard(
          id: 'upper_${round}_${upperOrder[i]}_$i',
          letterIndex: upperOrder[i],
          isUppercase: true,
          floatPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    return (
      lower: lower,
      upper: upper,
      chosenIndexes: chosen,
      nextSequentialCursor: cursor,
    );
  }

  static List<int> mergeRecent(List<int> recent, List<int> chosen) {
    final next = [...chosen, ...recent];
    // Keep roughly last 2–3 rounds worth of letters.
    if (next.length > 18) return next.take(18).toList();
    return next;
  }

  static ({int points, int coins, int xp, int stars}) matchReward(
    AlphabetBridgeSettings settings,
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
    AlphabetBridgeSettings settings,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (50 * mult).round(),
      coins: math.max(5, (20 * mult).round()),
      xp: math.max(5, (20 * mult).round()),
      stars: 2,
    );
  }

  static String successPhrase(int letterIndex) {
    final u = AlphabetLetter(letterIndex).upper;
    final l = AlphabetLetter(letterIndex).lower;
    final options = [
      '$u matches little $l!',
      'Great! $u and $l!',
      'Excellent! $u matches $l!',
    ];
    return options[random.nextInt(options.length)];
  }

  static String encouragePhrase() =>
      kAlphabetBridgeEncourage[random.nextInt(kAlphabetBridgeEncourage.length)];

  static AlphabetBridgeResult calculate(AlphabetBridgeState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return AlphabetBridgeResult(
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

  static GameRewardResult toReward(AlphabetBridgeResult result) =>
      GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 8),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static ({List<BridgeCard> lower, List<BridgeCard> upper}) tickAnimations(
    List<BridgeCard> lower,
    List<BridgeCard> upper,
    double delta,
    bool reducedMotion,
  ) {
    if (reducedMotion) return (lower: lower, upper: upper);
    // Only advance phase while shaking so cards stay visually locked otherwise.
    return (
      lower: [
        for (final c in lower)
          c.shake ? c.copyWith(floatPhase: c.floatPhase + delta * 18) : c,
      ],
      upper: [
        for (final c in upper)
          c.shake ? c.copyWith(floatPhase: c.floatPhase + delta * 18) : c,
      ],
    );
  }
}
