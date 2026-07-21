import 'dart:math' as math;

import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';

abstract final class AnimalSoundsLogic {
  static final random = math.Random();

  static AnimalDef byId(String id) =>
      kAnimals.firstWhere((a) => a.id == id, orElse: () => kAnimals.first);

  static List<String> buildQueue() {
    final ids = kAnimals.map((a) => a.id).toList()..shuffle(random);
    return ids;
  }

  static AnimalQuestion generateQuestion(String correctId) {
    final correct = byId(correctId);
    final distractors = kAnimals.where((a) => a.id != correctId).toList()
      ..shuffle(random);
    final picks = distractors.take(3).toList();
    final options = <AnimalOption>[
      AnimalOption(animal: correct, isCorrect: true),
      ...picks.map((a) => AnimalOption(animal: a, isCorrect: false)),
    ]..shuffle(random);

    return AnimalQuestion(correct: correct, options: options);
  }

  static ({int coins, int xp, int stars}) reward(
    AnimalSoundsSettings settings, {
    required int correctCount,
    required int streak,
  }) {
    final m = settings.rewardMultiplier;
    final combo = streak >= 3 ? 1.25 : 1.0;
    return (
      coins: (8 * m * combo).round().clamp(1, 30),
      xp: (6 * m * combo).round().clamp(1, 25),
      stars: correctCount % 4 == 0 ? 1 : 0,
    );
  }

  static AnimalSoundsResult buildResult(AnimalSoundsState state) =>
      AnimalSoundsResult(
        correctCount: state.correctCount,
        attempts: state.attempts,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String encouragement(int n) =>
      kAnimalEncouragements[n % kAnimalEncouragements.length];
}
