import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

abstract final class MemoryDifficultyConfig {
  static int difficultyIndex(MemoryDifficulty d) => MemoryDifficulty.values.indexOf(d);

  static MemoryDifficulty fromIndex(int i) =>
      MemoryDifficulty.values[i.clamp(0, MemoryDifficulty.values.length - 1)];

  static MemoryDifficulty adjustUp(MemoryDifficulty d) {
    final i = difficultyIndex(d);
    if (i < MemoryDifficulty.values.length - 1) {
      return MemoryDifficulty.values[i + 1];
    }
    return d;
  }

  static MemoryDifficulty adjustDown(MemoryDifficulty d) {
    final i = difficultyIndex(d);
    if (i > 0) return MemoryDifficulty.values[i - 1];
    return d;
  }

  /// Classic card grid: cols x rows (pairs = cols*rows/2)
  static (int cols, int rows) cardGrid(MemoryDifficulty d) => switch (d) {
        MemoryDifficulty.easy => (2, 2),
        MemoryDifficulty.medium => (3, 2),
        MemoryDifficulty.hard => (4, 4),
        MemoryDifficulty.expert => (5, 4),
        MemoryDifficulty.master => (6, 6),
      };

  static int sequenceLength(MemoryDifficulty d, int round) {
    final base = switch (d) {
      MemoryDifficulty.easy => 2,
      MemoryDifficulty.medium => 3,
      MemoryDifficulty.hard => 5,
      MemoryDifficulty.expert => 7,
      MemoryDifficulty.master => 9,
    };
    return base + (round - 1);
  }

  static int colorSequenceLength(MemoryDifficulty d, int round) =>
      sequenceLength(d, round);

  static int roundsToWin(MemoryDifficulty d) => switch (d) {
        MemoryDifficulty.easy => 3,
        MemoryDifficulty.medium => 4,
        MemoryDifficulty.hard => 5,
        MemoryDifficulty.expert => 6,
        MemoryDifficulty.master => 7,
      };

  static String label(MemoryDifficulty d) => d.name[0].toUpperCase() + d.name.substring(1);
}

abstract final class AdaptiveDifficulty {
  static MemoryDifficulty adjust({
    required MemoryDifficulty current,
    required bool lastRoundSuccess,
    required bool adaptiveEnabled,
  }) {
    if (!adaptiveEnabled) return current;
    return lastRoundSuccess
        ? MemoryDifficultyConfig.adjustUp(current)
        : MemoryDifficultyConfig.adjustDown(current);
  }
}

abstract final class MemoryScoring {
  static const int correctPoints = 10;
  static const int perfectRoundBonus = 50;
  static const int comboBonus = 5;
  static const int speedBonusMax = 30;
  static const int streakBonus = 15;

  static String comboLabel(int combo) {
    if (combo >= 10) return 'Super Recall!';
    if (combo >= 7) return 'Brain Power!';
    if (combo >= 5) return 'Great Memory!';
    if (combo >= 3) return 'Fantastic!';
    if (combo >= 2) return 'Awesome!';
    return '';
  }

  static int pointsForCorrect({
    required int combo,
    required int elapsedMs,
    required int thresholdMs,
  }) {
    var points = correctPoints;
    if (combo >= 2) points += comboBonus * (combo - 1);
    if (elapsedMs < thresholdMs) {
      points += speedBonusMax ~/ 2;
    }
    return points;
  }

  static MemoryGameResult calculateResult({
    required MemorySessionState state,
    required int previousBest,
    required bool sessionComplete,
  }) {
    var finalScore = state.score;
    final isPerfect = state.mistakes == 0 && sessionComplete;
    if (isPerfect) finalScore += perfectRoundBonus;
    if (state.streak >= 3) finalScore += streakBonus;

    final stars = isPerfect
        ? 3
        : state.accuracy >= 0.85
            ? 2
            : state.accuracy >= 0.6
                ? 1
                : 0;

    final coins = (finalScore / 8).round() + stars * 3;
    final xp = finalScore ~/ 4;

    return MemoryGameResult(
      gameType: state.config!.gameType,
      score: finalScore,
      stars: stars,
      coins: coins,
      xp: xp,
      accuracy: state.accuracy,
      mistakes: state.mistakes,
      elapsedSeconds: state.elapsedSeconds,
      longestCombo: state.longestCombo,
      roundsCompleted: state.round,
      isPerfect: isPerfect,
      isNewBest: finalScore > previousBest,
    );
  }

  static GameRewardResult toGameReward(MemoryGameResult result) {
    return GameRewardResult(
      coins: result.coins,
      stars: result.stars,
      xp: result.xp,
      isPerfect: result.isPerfect,
      isNewBest: result.isNewBest,
    );
  }
}

abstract final class MemoryContent {
  static final math.Random _random = math.Random();

  static List<String> themeItems(MemoryCardTheme theme, int count) {
    final pool = _themePools[theme] ?? _themePools[MemoryCardTheme.animals]!;
    final shuffled = List<String>.from(pool)..shuffle(_random);
    if (shuffled.length >= count) return shuffled.take(count).toList();
    final result = <String>[];
    while (result.length < count) {
      result.addAll(shuffled);
    }
    return result.take(count).toList();
  }

  static const _themePools = {
    MemoryCardTheme.animals: ['🦁', '🐯', '🐻', '🐼', '🦊', '🐸', '🐵', '🐰', '🦄', '🐶', '🐱', '🐷'],
    MemoryCardTheme.fruits: ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🥝', '🍌', '🍉', '🫐', '🍒', '🥭'],
    MemoryCardTheme.vehicles: ['🚗', '🚌', '🚕', '🚙', '🏎️', '🚓', '🚑', '🚒', '🛵', '🚲', '✈️', '🚀'],
    MemoryCardTheme.dinosaurs: ['🦕', '🦖', '🐊', '🦴', '🌋', '🥚', '🌿', '🪨', '🦎', '🐢', '🦔', '🌴'],
    MemoryCardTheme.space: ['🚀', '🌙', '⭐', '🪐', '🛸', '☄️', '🌟', '🌍', '🔭', '👽', '🌌', '🛰️'],
    MemoryCardTheme.ocean: ['🐠', '🐟', '🐬', '🐳', '🦈', '🐙', '🦀', '🦞', '🐚', '🌊', '🏖️', '⛵'],
    MemoryCardTheme.shapes: ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '⬛', '⬜', '🔶', '🔷', '💠', '🔺'],
    MemoryCardTheme.letters: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'],
    MemoryCardTheme.numbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '10', '11'],
    MemoryCardTheme.emojis: ['😊', '😂', '😎', '🥳', '😍', '🤩', '😇', '🤗', '😜', '🥰', '🤔', '😴'],
    MemoryCardTheme.fairyTales: ['👸', '🤴', '🧚', '🐉', '🏰', '🪄', '🦄', '🧜', '🧝', '🧞', '🎠', '🌈'],
  };

  static const sequenceColors = [
    ('Red', 0xFFEF5350),
    ('Blue', 0xFF42A5F5),
    ('Green', 0xFF66BB6A),
    ('Yellow', 0xFFFFCA28),
    ('Purple', 0xFFAB47BC),
    ('Orange', 0xFFFF9800),
  ];

  static List<int> randomSequence(int length, int poolSize) {
    return List.generate(length, (_) => _random.nextInt(poolSize));
  }
}
