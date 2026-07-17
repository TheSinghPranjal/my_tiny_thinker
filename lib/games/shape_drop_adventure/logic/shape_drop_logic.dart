import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

abstract final class ShapeDropLogic {
  static final random = math.Random();

  static ({
    ShapeDef target,
    List<ShapeOption> options,
    int nextSequentialIndex,
  }) generateRound(
    ShapeDropSettings settings, {
    required int sequentialIndex,
  }) {
    final pool = List<ShapeKind>.from(settings.activeShapes);
    if (pool.isEmpty) pool.addAll(ShapeCatalog.preschoolCore);

    ShapeKind targetKind;
    var nextIndex = sequentialIndex;
    if (settings.sequentialMode) {
      targetKind = pool[sequentialIndex % pool.length];
      nextIndex = sequentialIndex + 1;
    } else {
      targetKind = pool[random.nextInt(pool.length)];
    }

    final useObject = settings.objectLearningEnabled &&
        ShapeCatalog.objectsFor(targetKind).isNotEmpty &&
        random.nextBool();
    final target = useObject
        ? ShapeCatalog.objectVariant(targetKind, random.nextInt(99))
        : ShapeCatalog.geometric(targetKind);

    final distractors = pool.where((k) => k != targetKind).toList()..shuffle(random);
    while (distractors.length < 3) {
      final extra = ShapeCatalog.preschoolCore
          .where((k) => k != targetKind && !distractors.contains(k))
          .toList();
      if (extra.isEmpty) break;
      distractors.add(extra[random.nextInt(extra.length)]);
    }

    final optionDefs = <ShapeDef>[target];
    for (var i = 0; i < 3 && i < distractors.length; i++) {
      final k = distractors[i];
      final asObj = settings.objectLearningEnabled &&
          ShapeCatalog.objectsFor(k).isNotEmpty &&
          random.nextDouble() < 0.35;
      optionDefs.add(
        asObj
            ? ShapeCatalog.objectVariant(k, random.nextInt(99))
            : ShapeCatalog.geometric(k),
      );
    }
    while (optionDefs.length < 4) {
      optionDefs.add(ShapeCatalog.geometric(ShapeKind.star));
    }

    optionDefs.shuffle(random);
    final options = <ShapeOption>[
      for (var i = 0; i < optionDefs.length; i++)
        ShapeOption(
          id: 'opt_${targetKind.name}_$i',
          def: optionDefs[i],
          presentation: optionDefs[i].objectEmoji != null
              ? ShapePresentation.object
              : ShapePresentation.geometric,
        ),
    ];

    return (
      target: target,
      options: options,
      nextSequentialIndex: nextIndex,
    );
  }

  static ({int coins, int xp, int stars, int points}) matchReward(
    ShapeDropSettings settings,
    int streak,
  ) {
    final mult = settings.rewardMultiplier;
    final points = ((10 + (streak >= 3 ? 5 : 0)) * mult).round();
    return (
      points: points,
      coins: math.max(1, (5 * mult).round()),
      xp: math.max(3, (5 * mult).round()),
      stars: streak > 0 && streak % 4 == 0 ? 1 : 0,
    );
  }

  static ShapeKind? favoriteFrom(Map<ShapeKind, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static ShapeDropResult calculate(
    ShapeDropState state, {
    Map<ShapeKind, int> matchCounts = const {},
  }) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final stars = state.starsEarned +
        (accuracy >= 0.9 ? 1 : 0) +
        (state.maxStreak >= 5 ? 1 : 0);
    return ShapeDropResult(
      score: state.score,
      correctMatches: state.correctMatches,
      attempts: state.attempts,
      maxStreak: state.maxStreak,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: stars.clamp(0, 5),
      sessionSeconds: state.settings.sessionSeconds,
      accuracy: accuracy,
      shapesLearned: state.learnedShapes.length,
      favoriteShape: favoriteFrom(matchCounts) ?? state.favoriteShape,
    );
  }

  static GameRewardResult toReward(ShapeDropResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars,
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );
}
