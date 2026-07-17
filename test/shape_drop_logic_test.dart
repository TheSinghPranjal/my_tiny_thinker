import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/logic/shape_drop_logic.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

void main() {
  group('ShapeDropLogic', () {
    test('generateRound creates target and four options', () {
      final round = ShapeDropLogic.generateRound(
        const ShapeDropSettings(),
        sequentialIndex: 0,
      );
      expect(round.options.length, 4);
      expect(
        round.options.any((o) => o.def.kind == round.target.kind),
        isTrue,
      );
    });

    test('sequential mode advances shapes', () {
      const settings = ShapeDropSettings(sequentialMode: true);
      final a = ShapeDropLogic.generateRound(settings, sequentialIndex: 0);
      final b = ShapeDropLogic.generateRound(
        settings,
        sequentialIndex: a.nextSequentialIndex,
      );
      expect(a.target.kind, ShapeCatalog.preschoolCore.first);
      expect(b.nextSequentialIndex, greaterThan(a.nextSequentialIndex));
    });

    test('matchReward returns positive values', () {
      final r = ShapeDropLogic.matchReward(const ShapeDropSettings(), 1);
      expect(r.points, greaterThan(0));
      expect(r.coins, greaterThan(0));
      expect(r.xp, greaterThan(0));
    });

    test('calculate accuracy', () {
      const state = ShapeDropState(
        correctMatches: 8,
        attempts: 10,
        coinsEarned: 20,
        xpEarned: 20,
      );
      final result = ShapeDropLogic.calculate(state);
      expect(result.accuracy, closeTo(0.8, 0.001));
    });
  });
}
