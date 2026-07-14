import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

abstract final class ShadowMatchLogic {
  static final _random = math.Random();

  static ({List<ShadowSlot> shadows, List<DraggableItemState> items}) generateRound(
    ShadowMatchSettings settings,
  ) {
    final count = settings.itemsPerRound;
    final pool = List<VocabItem>.from(EducationVocabulary.items)..shuffle(_random);
    final selected = pool.take(count).toList(growable: false);

    final shadows = selected
        .map((item) => ShadowSlot(itemId: item.id))
        .toList(growable: false);

    final items = (selected.toList()..shuffle(_random))
        .map((item) => DraggableItemState(itemId: item.id))
        .toList(growable: false);

    return (shadows: shadows, items: items);
  }

  static ({int coins, int xp, int stars, int points}) matchReward(
    ShadowMatchSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    final points = (10 + (streak >= 3 ? 5 : 0)) * mult.round();
    return (
      points: points,
      coins: math.max(1, (5 * mult).round()),
      xp: math.max(3, (5 * mult).round()),
      stars: streak % 4 == 0 ? 1 : 0,
    );
  }

  static ShadowMatchResult calculate(ShadowMatchState state) {
    final accuracy = state.attempts == 0
        ? 1.0
        : state.correctMatches / state.attempts;
    final stars = state.starsEarned +
        (accuracy >= 0.9 ? 1 : 0) +
        (state.maxStreak >= 5 ? 1 : 0);
    return ShadowMatchResult(
      score: state.score,
      correctMatches: state.correctMatches,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: stars.clamp(0, 5),
      sessionSeconds: state.settings.sessionSeconds,
      accuracy: accuracy,
    );
  }

  static GameRewardResult toReward(ShadowMatchResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars,
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );
}
