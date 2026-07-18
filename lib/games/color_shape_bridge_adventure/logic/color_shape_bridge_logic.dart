import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';

class ColorShapeTarget {
  const ColorShapeTarget({
    required this.matchKey,
    required this.mode,
    this.colorKind,
    this.shapeKind,
  });

  final String matchKey;
  final ColorShapeBridgeMode mode;
  final BridgeColorKind? colorKind;
  final BridgeShapeKind? shapeKind;
}

abstract final class ColorShapeBridgeLogic {
  static final random = math.Random();

  static ({
    List<ColorShapePairCard> prompts,
    List<ColorShapePairCard> visuals,
    List<String> chosenKeys,
  }) generateRound({
    required ColorShapeBridgeSettings settings,
    required List<String> recentKeys,
    required int round,
  }) {
    final pairCount = settings.pairCount.clamp(3, 7);
    final targets = <ColorShapeTarget>[];
    final used = <String>{};
    final recent = recentKeys.toSet();

    var guard = 0;
    while (targets.length < pairCount && guard < 200) {
      guard++;
      final t = _randomTarget(settings);
      if (used.contains(t.matchKey)) continue;
      if (recent.contains(t.matchKey) && targets.length + recent.length > 4) {
        // Prefer fresh, but allow if pool is small.
        if (guard < 80) continue;
      }
      used.add(t.matchKey);
      targets.add(t);
    }

    while (targets.length < pairCount) {
      final t = _randomTarget(settings);
      if (used.contains(t.matchKey)) continue;
      used.add(t.matchKey);
      targets.add(t);
    }

    final promptOrder = List<ColorShapeTarget>.from(targets)..shuffle(random);
    final visualOrder = List<ColorShapeTarget>.from(targets)..shuffle(random);
    if (pairCount > 1 &&
        List.generate(pairCount, (i) => promptOrder[i].matchKey == visualOrder[i].matchKey)
            .every((e) => e)) {
      visualOrder.shuffle(random);
    }

    final prompts = <ColorShapePairCard>[
      for (var i = 0; i < promptOrder.length; i++)
        ColorShapePairCard(
          id: 'prompt_${round}_${promptOrder[i].matchKey}_$i',
          matchKey: promptOrder[i].matchKey,
          isPrompt: true,
          mode: promptOrder[i].mode,
          colorKind: promptOrder[i].colorKind,
          shapeKind: promptOrder[i].shapeKind,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];
    final visuals = <ColorShapePairCard>[
      for (var i = 0; i < visualOrder.length; i++)
        ColorShapePairCard(
          id: 'visual_${round}_${visualOrder[i].matchKey}_$i',
          matchKey: visualOrder[i].matchKey,
          isPrompt: false,
          mode: visualOrder[i].mode,
          colorKind: visualOrder[i].colorKind,
          shapeKind: visualOrder[i].shapeKind,
          animPhase: random.nextDouble() * math.pi * 2,
        ),
    ];

    return (
      prompts: prompts,
      visuals: visuals,
      chosenKeys: [for (final t in targets) t.matchKey],
    );
  }

  static ColorShapeTarget _randomTarget(ColorShapeBridgeSettings settings) {
    final colors = settings.activeColors;
    final shapes = settings.activeShapes;
    final color = colors[random.nextInt(colors.length)];
    final shape = shapes[random.nextInt(shapes.length)];

    switch (settings.mode) {
      case ColorShapeBridgeMode.color:
        return ColorShapeTarget(
          matchKey: ColorShapeCatalog.matchKey(
            mode: ColorShapeBridgeMode.color,
            color: color,
          ),
          mode: ColorShapeBridgeMode.color,
          colorKind: color,
          shapeKind: BridgeShapeKind.circle,
        );
      case ColorShapeBridgeMode.shape:
        return ColorShapeTarget(
          matchKey: ColorShapeCatalog.matchKey(
            mode: ColorShapeBridgeMode.shape,
            shape: shape,
          ),
          mode: ColorShapeBridgeMode.shape,
          colorKind: color,
          shapeKind: shape,
        );
      case ColorShapeBridgeMode.colorShape:
        return ColorShapeTarget(
          matchKey: ColorShapeCatalog.matchKey(
            mode: ColorShapeBridgeMode.colorShape,
            color: color,
            shape: shape,
          ),
          mode: ColorShapeBridgeMode.colorShape,
          colorKind: color,
          shapeKind: shape,
        );
    }
  }

  static List<String> mergeRecent(List<String> recent, List<String> chosen) {
    final next = [...chosen, ...recent];
    if (next.length > 24) return next.take(24).toList();
    return next;
  }

  static ({int points, int coins, int xp, int stars}) matchReward(
    ColorShapeBridgeSettings settings,
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
    ColorShapeBridgeSettings settings,
  ) {
    final mult = settings.rewardMultiplier;
    return (
      points: (50 * mult).round(),
      coins: math.max(5, (20 * mult).round()),
      xp: math.max(5, (20 * mult).round()),
      stars: 2,
    );
  }

  static String successPhrase(ColorShapePairCard card) {
    final label = card.label;
    final options = [
      '$label!',
      'Excellent! $label!',
      'Great! $label!',
      'Wonderful! $label!',
    ];
    return options[random.nextInt(options.length)];
  }

  static String encouragePhrase() => kColorShapeBridgeEncourage[
      random.nextInt(kColorShapeBridgeEncourage.length)];

  static ColorShapeBridgeResult calculate(ColorShapeBridgeState state) {
    final accuracy =
        state.attempts == 0 ? 1.0 : state.correctMatches / state.attempts;
    final bonusStars =
        (accuracy >= 0.9 ? 1 : 0) + (state.maxStreak >= 5 ? 1 : 0);
    return ColorShapeBridgeResult(
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

  static GameRewardResult toReward(ColorShapeBridgeResult result) =>
      GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 8),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.95,
      );

  static ({
    List<ColorShapePairCard> prompts,
    List<ColorShapePairCard> visuals,
  }) tickAnimations(
    List<ColorShapePairCard> prompts,
    List<ColorShapePairCard> visuals,
    double delta,
    bool reducedMotion,
  ) {
    if (reducedMotion) return (prompts: prompts, visuals: visuals);
    return (
      prompts: [
        for (final c in prompts)
          c.shake ? c.copyWith(animPhase: c.animPhase + delta * 18) : c,
      ],
      visuals: [
        for (final c in visuals)
          c.shake || c.hintPulse
              ? c.copyWith(animPhase: c.animPhase + delta * 18)
              : c,
      ],
    );
  }
}
