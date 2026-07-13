import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_physics_engine.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

void main() {
  group('BubblePhysicsEngine', () {
    test('spawns a bubble for every number', () {
      const numbers = [3, 7, 1, 9, 5];
      final engine = BubblePhysicsEngine();
      final bubbles = engine.spawnBubbles(
        numbers: numbers,
        playArea: const Size(400, 600),
        difficulty: Difficulty.easy,
        speedMultiplier: 1,
        toddlerMode: true,
      );
      expect(bubbles.length, numbers.length);
      expect(bubbles.map((b) => b.number).toSet(), numbers.toSet());
    });

    test('toddler bubbles are spaced apart not stacked', () {
      final engine = BubblePhysicsEngine();
      final bubbles = engine.spawnBubbles(
        numbers: List.generate(8, (i) => i + 1),
        playArea: const Size(360, 500),
        difficulty: Difficulty.easy,
        speedMultiplier: 0.35,
        toddlerMode: true,
      );
      expect(bubbles.length, 8);
      for (var i = 0; i < bubbles.length; i++) {
        for (var j = i + 1; j < bubbles.length; j++) {
          final dx = bubbles[i].x - bubbles[j].x;
          final dy = bubbles[i].y - bubbles[j].y;
          final dist = dx * dx + dy * dy;
          final minDist = bubbles[i].radius + bubbles[j].radius;
          expect(dist, greaterThan(minDist * minDist * 0.25));
        }
      }
    });
  });

  group('BubbleScoring', () {
    test('wrong taps never reduce score', () {
      expect(BubbleScoring.mistakePenalty(Difficulty.hard), 0);
    });

    test('fast pop adds bonus points', () {
      final normal = BubbleScoring.pointsForCorrect(1, fastPop: false);
      final fast = BubbleScoring.pointsForCorrect(1, fastPop: true);
      expect(fast, normal + BubbleScoring.fastPopBonus);
    });

    test('result includes remaining time', () {
      const state = BubbleGameState(
        phase: GamePhase.victory,
        sortedNumbers: [1, 2],
        currentIndex: 2,
        remainingSeconds: 42,
        score: 30,
      );
      final result = BubbleScoring.calculateResult(state: state, previousBest: 0);
      expect(result.remainingSeconds, 42);
      expect(result.isVictory, isTrue);
    });
  });
}
