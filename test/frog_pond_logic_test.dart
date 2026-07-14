import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/logic/frog_pond_logic.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';

void main() {
  group('FrogPondLogic', () {
    test('spawnPads creates configured count', () {
      final pads = FrogPondLogic.spawnPads(const Size(400, 600), 2);
      expect(pads.length, 2);
    });

    test('spawnFrogsForPads assigns one frog per pad', () {
      final pads = FrogPondLogic.spawnPads(const Size(400, 600), 3);
      final frogs = FrogPondLogic.spawnFrogsForPads(pads);
      expect(frogs.length, 3);
      expect(frogs.every((f) => !f.isKing), isTrue);
    });

    test('tapReward doubles for king frog', () {
      const settings = FrogPondSettings(rewardMultiplier: 1.0);
      final normal = FrogPondLogic.tapReward(settings, isKing: false, tapCount: 1);
      final king = FrogPondLogic.tapReward(
        settings,
        isKing: true,
        tapCount: FrogEntity.kingTapRequired,
      );
      expect(king.points, greaterThan(normal.points));
      expect(king.coins, greaterThan(normal.coins));
    });

    test('shouldMarkKingDue at fifteen second intervals', () {
      expect(FrogPondLogic.shouldMarkKingDue(14, 15), isFalse);
      expect(FrogPondLogic.shouldMarkKingDue(15, 15), isTrue);
      expect(FrogPondLogic.shouldMarkKingDue(30, 30), isTrue);
    });

    test('updateFrog jumping completes to gone', () {
      const pad = LilyPadEntity(
        id: 'p0',
        centerX: 100,
        centerY: 200,
        radius: 50,
      );
      var frog = const FrogEntity(
        id: 'f1',
        padId: 'p0',
        varietyIndex: 0,
        phase: FrogPhase.jumping,
        jumpProgress: 0.95,
      );
      frog = FrogPondLogic.updateFrog(
        frog,
        pad,
        0.2,
        const FrogPondSettings(),
      );
      expect(frog.phase, FrogPhase.gone);
    });
  });
}
