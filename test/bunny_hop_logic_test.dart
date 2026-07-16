import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/logic/bunny_hop_logic.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

void main() {
  group('BunnyHopLogic', () {
    test('crackedPadCount scales with lily pad count', () {
      expect(BunnyHopLogic.crackedPadCount(7), 1);
      expect(BunnyHopLogic.crackedPadCount(12), 2);
      expect(BunnyHopLogic.crackedPadCount(16), 3);
    });

    test('pickCrackedIndices never places adjacent cracks', () {
      for (var n = 5; n <= 18; n++) {
        final indices = BunnyHopLogic.pickCrackedIndices(n);
        expect(indices.length, BunnyHopLogic.crackedPadCount(n));
        for (var i = 0; i < indices.length; i++) {
          for (var j = i + 1; j < indices.length; j++) {
            expect((indices[i] - indices[j]).abs(), greaterThan(1));
          }
        }
      }
    });

    test('hopReward returns positive values', () {
      const settings = BunnyHopSettings();
      final reward = BunnyHopLogic.hopReward(settings, hopCount: 1);
      expect(reward.points, greaterThan(0));
      expect(reward.coins, greaterThan(0));
    });

    test('carrotReward doubles hop values', () {
      const settings = BunnyHopSettings(rewardMultiplier: 1.0);
      final hop = BunnyHopLogic.hopReward(settings, hopCount: 1);
      final carrot = BunnyHopLogic.carrotReward(settings, carrotCount: 1);
      expect(carrot.points, greaterThan(hop.points));
      expect(carrot.stars, 2);
    });

    test('reachedCarrot detects bank arrival', () {
      expect(BunnyHopLogic.reachedCarrot(7, 7, CarrotSide.sideB), isTrue);
      expect(BunnyHopLogic.reachedCarrot(-1, 7, CarrotSide.sideA), isTrue);
      expect(BunnyHopLogic.reachedCarrot(3, 7, CarrotSide.sideB), isFalse);
    });
  });
}
