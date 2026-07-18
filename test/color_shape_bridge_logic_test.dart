import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/logic/color_shape_bridge_logic.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';

void main() {
  group('ColorShapeBridgeLogic', () {
    test('defaults to 60 seconds, 4 pairs, colorShape mode', () {
      const s = ColorShapeBridgeSettings();
      expect(s.sessionSeconds, 60);
      expect(s.pairCount, 4);
      expect(s.mode, ColorShapeBridgeMode.colorShape);
      expect(s.unlimitedTime, isFalse);
      expect(s.enabledColors.length, greaterThanOrEqualTo(2));
      expect(s.enabledShapes.length, greaterThanOrEqualTo(2));
    });

    test('generates equal prompt and visual cards with matching keys', () {
      final round = ColorShapeBridgeLogic.generateRound(
        settings: const ColorShapeBridgeSettings(pairCount: 4),
        recentKeys: const [],
        round: 1,
      );
      expect(round.prompts.length, 4);
      expect(round.visuals.length, 4);
      final promptKeys = round.prompts.map((c) => c.matchKey).toSet();
      final visualKeys = round.visuals.map((c) => c.matchKey).toSet();
      expect(promptKeys, visualKeys);
      expect(round.prompts.every((c) => c.isPrompt), isTrue);
      expect(round.visuals.every((c) => !c.isPrompt), isTrue);
    });

    test('chosen matchKeys are unique within a round', () {
      final round = ColorShapeBridgeLogic.generateRound(
        settings: const ColorShapeBridgeSettings(pairCount: 7),
        recentKeys: const [],
        round: 2,
      );
      expect(round.chosenKeys.toSet().length, 7);
    });

    test('colorShape mode creates combo match keys', () {
      final round = ColorShapeBridgeLogic.generateRound(
        settings: const ColorShapeBridgeSettings(
          pairCount: 4,
          mode: ColorShapeBridgeMode.colorShape,
        ),
        recentKeys: const [],
        round: 1,
      );
      expect(
        round.chosenKeys.every((k) => k.startsWith('combo_')),
        isTrue,
      );
    });

    test('color mode creates color match keys', () {
      final round = ColorShapeBridgeLogic.generateRound(
        settings: const ColorShapeBridgeSettings(
          pairCount: 4,
          mode: ColorShapeBridgeMode.color,
        ),
        recentKeys: const [],
        round: 1,
      );
      expect(
        round.chosenKeys.every((k) => k.startsWith('color_')),
        isTrue,
      );
    });

    test('shape mode creates shape match keys', () {
      final round = ColorShapeBridgeLogic.generateRound(
        settings: const ColorShapeBridgeSettings(
          pairCount: 4,
          mode: ColorShapeBridgeMode.shape,
        ),
        recentKeys: const [],
        round: 1,
      );
      expect(
        round.chosenKeys.every((k) => k.startsWith('shape_')),
        isTrue,
      );
    });

    test('matchReward gives positive rewards', () {
      final r = ColorShapeBridgeLogic.matchReward(
        const ColorShapeBridgeSettings(),
        1,
      );
      expect(r.points, 10);
      expect(r.coins, 5);
      expect(r.xp, 5);
      expect(r.stars, 1);
    });

    test('roundBonus awards celebration rewards', () {
      final r = ColorShapeBridgeLogic.roundBonus(const ColorShapeBridgeSettings());
      expect(r.points, 50);
      expect(r.coins, 20);
      expect(r.xp, 20);
    });

    test('mergeRecent prefers newest keys', () {
      final merged = ColorShapeBridgeLogic.mergeRecent(
        ['a', 'b', 'c'],
        ['x', 'y', 'z'],
      );
      expect(merged.take(3), ['x', 'y', 'z']);
    });
  });
}
