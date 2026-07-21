import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/animal_sounds/logic/animal_sounds_logic.dart';
import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';

void main() {
  group('AnimalSoundsLogic', () {
    test('buildQueue covers every animal once', () {
      final queue = AnimalSoundsLogic.buildQueue();
      expect(queue.length, kAnimals.length);
      expect(queue.toSet().length, kAnimals.length);
    });

    test('generateQuestion has one correct and three distractors', () {
      final q = AnimalSoundsLogic.generateQuestion('dog');
      expect(q.correct.id, 'dog');
      expect(q.options.length, 4);
      expect(q.options.where((o) => o.isCorrect).length, 1);
      expect(q.options.map((o) => o.animal.id).toSet().length, 4);
      expect(q.options.any((o) => o.animal.id == 'dog'), isTrue);
    });

    test('animals have emoji and sound assets named after them', () {
      for (final animal in kAnimals) {
        expect(animal.emoji, isNotEmpty);
        expect(animal.soundAsset, contains(animal.id));
        expect(
          animal.soundAsset.endsWith('.mp3') ||
              animal.soundAsset.endsWith('.wav'),
          isTrue,
        );
      }
    });

    test('reward grows with streak', () {
      const settings = AnimalSoundsSettings();
      final base = AnimalSoundsLogic.reward(
        settings,
        correctCount: 1,
        streak: 1,
      );
      final combo = AnimalSoundsLogic.reward(
        settings,
        correctCount: 4,
        streak: 4,
      );
      expect(combo.coins, greaterThan(base.coins));
      expect(combo.stars, 1);
    });

    test('sessionSeconds clamps to 60–1800', () {
      final low = AnimalSoundsSettings.fromJson({'sessionSeconds': 10});
      final high = AnimalSoundsSettings.fromJson({'sessionSeconds': 9999});
      expect(low.sessionSeconds, 60);
      expect(high.sessionSeconds, 1800);
    });
  });
}
