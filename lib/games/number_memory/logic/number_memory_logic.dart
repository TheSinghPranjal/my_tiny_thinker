import 'dart:math' as math;

import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';

abstract final class NumberMemoryLogic {
  static final _random = math.Random();

  /// Random number in `[0, 10^digits - 1]`, padded with leading zeros.
  static String randomNumber(int digitCount, {String? exclude}) {
    final digits = digitCount.clamp(1, 10);
    final max = math.pow(10, digits).toInt();
    String next;
    var guard = 0;
    do {
      next = _random.nextInt(max).toString().padLeft(digits, '0');
      guard++;
    } while (next == exclude && max > 1 && guard < 20);
    return next;
  }

  static ({int coins, int xp, int points, int stars}) correctReward(int combo) {
    final comboBonus = combo >= 3 ? 1 : 0;
    return (
      coins: 10 + comboBonus,
      xp: 5 + comboBonus,
      points: 15 + (combo >= 3 ? 5 : 0),
      stars: combo >= 5 ? 1 : 0,
    );
  }

  static NumberMemoryResult calculate(NumberMemoryState state) {
    final praise = kEndPraise[state.correctCount % kEndPraise.length];
    final stars = math.max(
      state.starsEarned,
      state.correctCount > 0 ? 1 : 0,
    );
    return NumberMemoryResult(
      score: state.score,
      correctCount: state.correctCount,
      wrongCount: state.wrongCount,
      accuracy: state.accuracy,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: stars,
      maxCombo: state.maxCombo,
      encouragement: praise,
    );
  }
}
