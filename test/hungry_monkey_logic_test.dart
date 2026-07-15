import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/logic/hungry_monkey_logic.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

void main() {
  group('HungryMonkeyLogic', () {
    test('spawnBananas creates configured count', () {
      const area = Size(400, 600);
      final bananas = HungryMonkeyLogic.spawnBananas(area, 7);
      expect(bananas.length, 7);
      expect(bananas.every((b) => b.phase == BananaPhase.onTree), isTrue);
    });

    test('pickSlots avoids close neighbors', () {
      final slots = HungryMonkeyLogic.pickSlots(5);
      expect(slots.length, 5);
      for (var i = 0; i < slots.length; i++) {
        for (var j = i + 1; j < slots.length; j++) {
          final a = HungryMonkeyLogic.canopySlots[slots[i]];
          final b = HungryMonkeyLogic.canopySlots[slots[j]];
          final dx = a.$1 - b.$1;
          final dy = a.$2 - b.$2;
          final dist = (dx * dx + dy * dy);
          expect(dist, greaterThan(0.004));
        }
      }
    });

    test('feedReward grants points and coins', () {
      const settings = HungryMonkeySettings(rewardMultiplier: 1.0);
      final reward = HungryMonkeyLogic.feedReward(settings, fedCount: 1);
      expect(reward.points, greaterThanOrEqualTo(5));
      expect(reward.coins, greaterThanOrEqualTo(2));
    });

    test('monkeyAnchor places monkey near bottom center', () {
      final anchor = HungryMonkeyLogic.monkeyAnchor(const Size(400, 600));
      expect(anchor.$1, 200);
      expect(anchor.$2, greaterThan(400));
    });
  });
}
