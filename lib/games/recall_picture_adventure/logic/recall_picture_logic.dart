import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';

abstract final class RecallPictureLogic {
  static final _random = math.Random();

  static const animals = ['🐶', '🐱', '🐰', '🦊', '🐻'];

  static const _shapeAccents = [
    Color(0xFFFF8A80),
    Color(0xFF80D8FF),
    Color(0xFFA5D6A7),
    Color(0xFFFFE082),
    Color(0xFFCE93D8),
    Color(0xFFFFAB91),
  ];

  static RecallScene generateScene({RecallScene? exclude}) {
    RecallScene scene;
    var attempts = 0;
    do {
      final color = RecallSceneColor
          .values[_random.nextInt(RecallSceneColor.values.length)];
      final accentPool = [
        color.color,
        _shapeAccents[_random.nextInt(_shapeAccents.length)],
      ];
      scene = RecallScene(
        balloonCount: 2 + _random.nextInt(5), // 2–6
        animal: animals[_random.nextInt(animals.length)],
        color: color,
        shape: RecallSceneShape
            .values[_random.nextInt(RecallSceneShape.values.length)],
        shapeAccent: accentPool[_random.nextInt(accentPool.length)],
      );
      attempts++;
    } while (
        exclude != null &&
            scene.balloonCount == exclude.balloonCount &&
            scene.animal == exclude.animal &&
            scene.color == exclude.color &&
            scene.shape == exclude.shape &&
            attempts < 12);
    return scene;
  }

  static RecallQuestion generateQuestion(RecallScene scene) {
    final type = RecallQuestionType
        .values[_random.nextInt(RecallQuestionType.values.length)];
    return switch (type) {
      RecallQuestionType.balloonCount => _balloonQuestion(scene),
      RecallQuestionType.animal => _animalQuestion(scene),
      RecallQuestionType.color => _colorQuestion(scene),
      RecallQuestionType.shape => _shapeQuestion(scene),
    };
  }

  static RecallQuestion _balloonQuestion(RecallScene scene) {
    final correct = scene.balloonCount;
    final pool = <int>{correct};
    while (pool.length < 4) {
      pool.add(2 + _random.nextInt(5));
    }
    final values = pool.toList()..shuffle(_random);
    return RecallQuestion(
      type: RecallQuestionType.balloonCount,
      prompt: 'How many balloons?',
      correctKey: '$correct',
      options: [
        for (var i = 0; i < values.length; i++)
          RecallOption(
            id: 'opt_$i',
            valueKey: '${values[i]}',
            label: '${values[i]}',
          ),
      ],
    );
  }

  static RecallQuestion _animalQuestion(RecallScene scene) {
    final pool = List<String>.from(animals)..shuffle(_random);
    if (!pool.contains(scene.animal)) {
      pool[0] = scene.animal;
    }
    final picks = <String>[scene.animal];
    for (final a in pool) {
      if (picks.length >= 4) break;
      if (a != scene.animal) picks.add(a);
    }
    picks.shuffle(_random);
    return RecallQuestion(
      type: RecallQuestionType.animal,
      prompt: 'Which animal?',
      correctKey: scene.animal,
      options: [
        for (var i = 0; i < picks.length; i++)
          RecallOption(
            id: 'opt_$i',
            valueKey: picks[i],
            emoji: picks[i],
          ),
      ],
    );
  }

  static RecallQuestion _colorQuestion(RecallScene scene) {
    final pool = List<RecallSceneColor>.from(RecallSceneColor.values)
      ..shuffle(_random);
    final picks = <RecallSceneColor>[scene.color];
    for (final c in pool) {
      if (picks.length >= 4) break;
      if (c != scene.color) picks.add(c);
    }
    picks.shuffle(_random);
    return RecallQuestion(
      type: RecallQuestionType.color,
      prompt: 'What color?',
      correctKey: scene.color.key,
      options: [
        for (var i = 0; i < picks.length; i++)
          RecallOption(
            id: 'opt_$i',
            valueKey: picks[i].key,
            color: picks[i].color,
            label: picks[i].label,
          ),
      ],
    );
  }

  static RecallQuestion _shapeQuestion(RecallScene scene) {
    final pool = List<RecallSceneShape>.from(RecallSceneShape.values)
      ..shuffle(_random);
    final picks = <RecallSceneShape>[scene.shape];
    for (final s in pool) {
      if (picks.length >= 4) break;
      if (s != scene.shape) picks.add(s);
    }
    picks.shuffle(_random);
    return RecallQuestion(
      type: RecallQuestionType.shape,
      prompt: 'What shape?',
      correctKey: scene.shape.name,
      options: [
        for (var i = 0; i < picks.length; i++)
          RecallOption(
            id: 'opt_$i',
            valueKey: picks[i].name,
            shape: picks[i],
          ),
      ],
    );
  }

  /// Correct: +10 coins, +5 XP, +15 points; star on every 3rd combo hit.
  static ({int coins, int xp, int points, int stars}) correctReward(int combo) {
    return (
      coins: 10,
      xp: 5,
      points: 15,
      stars: combo > 0 && combo % 3 == 0 ? 1 : 0,
    );
  }

  static RecallPictureResult calculate(RecallPictureState state) {
    final praise =
        kRecallEndPraise[state.roundsCompleted % kRecallEndPraise.length];
    return RecallPictureResult(
      roundsCompleted: state.roundsCompleted,
      correctCount: state.correctCount,
      wrongCount: state.wrongCount,
      accuracy: state.accuracy,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: state.starsEarned,
      score: state.score,
      maxCombo: state.maxCombo,
      encouragement: praise,
    );
  }
}
