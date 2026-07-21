import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';

void main() {
  test('BubbleNumberGenerator produces unique values', () {
    final numbers = BubbleNumberGenerator.generate(
      count: 10,
      minValue: 1,
      maxValue: 50,
      difficulty: Difficulty.easy,
      randomNumbers: true,
    );
    expect(numbers.length, 10);
    expect(numbers.toSet().length, 10);
  });
}
