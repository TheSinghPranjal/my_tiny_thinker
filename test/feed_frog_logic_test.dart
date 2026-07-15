import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/logic/feed_frog_logic.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';

void main() {
  group('FeedFrogLogic', () {
    test('spawnInsects creates configured count', () {
      final dayBugs = FeedFrogLogic.spawnInsects(const Size(400, 600), 5, 0);
      expect(dayBugs.length, 5);
      expect(dayBugs.every((i) => !i.isFirefly), isTrue);

      final nightBugs = FeedFrogLogic.spawnInsects(const Size(400, 600), 5, 1);
      expect(nightBugs.every((i) => i.isFirefly), isTrue);
    });

    test('computeNightFactor transitions after start seconds', () {
      const settings = FeedFrogSettings(
        dayNightStartSeconds: 30,
        dayNightTransitionSeconds: 6,
        dayNightCycleSeconds: 60,
      );
      expect(FeedFrogLogic.computeNightFactor(10, settings), 0);
      expect(FeedFrogLogic.computeNightFactor(33, settings), closeTo(0.5, 0.01));
      expect(FeedFrogLogic.computeNightFactor(45, settings), 1);
    });

    test('feedReward grants points and coins', () {
      const settings = FeedFrogSettings(rewardMultiplier: 1.0);
      final reward = FeedFrogLogic.feedReward(settings, isFirefly: false, eaten: 1);
      expect(reward.points, greaterThanOrEqualTo(5));
      expect(reward.coins, greaterThanOrEqualTo(2));
    });

    test('frogAnchor places frog near bottom center', () {
      final anchor = FeedFrogLogic.frogAnchor(const Size(400, 600));
      expect(anchor.$1, 200);
      expect(anchor.$2, greaterThan(400));
    });
  });
}
