import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

abstract final class OddOneOutGenerator {
  static final _random = math.Random();

  static int gridSizeFor(OddOneOutDifficulty d) => switch (d) {
        OddOneOutDifficulty.easy => 2,
        OddOneOutDifficulty.medium => 3,
        OddOneOutDifficulty.hard => 4,
        OddOneOutDifficulty.expert => 5,
      };

  static int itemCountFor(OddOneOutDifficulty d) {
    final grid = gridSizeFor(d);
    final total = grid * grid;
    return switch (d) {
      OddOneOutDifficulty.easy => total.clamp(4, 4),
      OddOneOutDifficulty.medium => total.clamp(6, 9),
      OddOneOutDifficulty.hard => total.clamp(12, 16),
      OddOneOutDifficulty.expert => total.clamp(20, 25),
    };
  }

  static int roundsFor(OddOneOutDifficulty d) => switch (d) {
        OddOneOutDifficulty.easy => 8,
        OddOneOutDifficulty.medium => 10,
        OddOneOutDifficulty.hard => 12,
        OddOneOutDifficulty.expert => 15,
      };

  static List<OddOneItem> generatePuzzle(OddOneOutConfig config) {
    final count = itemCountFor(config.difficulty);
    final grid = gridSizeFor(config.difficulty);
    final (common, odd) = _pickPair(config.category, config.difficulty);

    final oddIndex = _random.nextInt(count);
    final items = <OddOneItem>[];

    for (var i = 0; i < count; i++) {
      final isOdd = i == oddIndex;
      final display = isOdd ? odd : common;
      items.add(
        OddOneItem(
          id: i,
          display: display,
          isOdd: isOdd,
          rotation: config.difficulty.index >= OddOneOutDifficulty.hard.index
              ? (_random.nextDouble() - 0.5) * 0.6
              : 0,
          scale: config.difficulty == OddOneOutDifficulty.expert
              ? 0.85 + _random.nextDouble() * 0.3
              : 1,
        ),
      );
    }
    items.shuffle(_random);
    for (var i = 0; i < items.length; i++) {
      items[i] = OddOneItem(
        id: i,
        display: items[i].display,
        isOdd: items[i].isOdd,
        rotation: items[i].rotation,
        scale: items[i].scale,
      );
    }
    return items;
  }

  static (String common, String odd) _pickPair(
    OddOneOutCategory category,
    OddOneOutDifficulty difficulty,
  ) {
    final pool = _pools[category] ?? _pools[OddOneOutCategory.animals]!;
    if (category == OddOneOutCategory.mixed) {
      final cat = OddOneOutCategory.values[
          _random.nextInt(OddOneOutCategory.values.length - 1)];
      return _pickPair(cat, difficulty);
    }
    final common = pool[_random.nextInt(pool.length)];
    var odd = pool[_random.nextInt(pool.length)];
    var attempts = 0;
    while (odd == common && attempts < 20) {
      odd = pool[_random.nextInt(pool.length)];
      attempts++;
    }
    if (difficulty.index >= OddOneOutDifficulty.hard.index) {
      final subtle = _subtlePairs[common];
      if (subtle != null) odd = subtle;
    }
    return (common, odd);
  }

  static const _subtlePairs = {
    '🐶': '🐕',
    '🐱': '🐈',
    '🍎': '🍏',
    '🔴': '🟠',
    '⭐': '🌟',
    '🚗': '🚙',
  };

  static const _pools = {
    OddOneOutCategory.animals: ['🐶', '🐱', '🐰', '🐻', '🦊', '🐼', '🦁', '🐯'],
    OddOneOutCategory.fruits: ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🍌', '🥝'],
    OddOneOutCategory.shapes: ['🔴', '🔵', '🟢', '🟡', '⭐', '💠', '🔶', '🔷'],
    OddOneOutCategory.vehicles: ['🚗', '🚌', '🚕', '🏎️', '✈️', '🚀', '🚲', '🛵'],
    OddOneOutCategory.dinosaurs: ['🦕', '🦖', '🦴', '🥚', '🌋', '🦎', '🐢'],
    OddOneOutCategory.ocean: ['🐠', '🐟', '🐬', '🐳', '🦈', '🐙', '🦀'],
    OddOneOutCategory.jungle: ['🐒', '🦜', '🐍', '🦧', '🌴', '🐅', '🦓'],
    OddOneOutCategory.farm: ['🐄', '🐷', '🐔', '🐑', '🐴', '🌾', '🚜'],
    OddOneOutCategory.birds: ['🐦', '🦅', '🦆', '🦉', '🐧', '🦜', '🕊️'],
    OddOneOutCategory.numbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
    OddOneOutCategory.letters: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    OddOneOutCategory.emojis: ['😊', '😂', '😎', '🥳', '😍', '🤩', '😇'],
    OddOneOutCategory.colors: ['🟥', '🟦', '🟩', '🟨', '🟪', '🟧'],
    OddOneOutCategory.objects: ['📚', '✏️', '⚽', '🎈', '🧸', '🎨', '🎵'],
    OddOneOutCategory.food: ['🍕', '🍔', '🍰', '🍦', '🌮', '🍩', '🥗'],
    OddOneOutCategory.space: ['🚀', '🌙', '⭐', '🪐', '👽', '🛸', '☄️'],
    OddOneOutCategory.seasonal: ['❄️', '🌸', '☀️', '🍂', '🎃', '🎄', '🌻'],
    OddOneOutCategory.fairyTale: ['👸', '🤴', '🐉', '🏰', '🧚', '🦄', '🪄'],
  };
}

abstract final class OddOneOutScoring {
  static String streakLabel(int streak) => switch (streak) {
        >= 15 => 'Memory Master!',
        >= 10 => 'Brain Hero!',
        >= 5 => 'Amazing!',
        >= 2 => 'Great!',
        _ => '',
      };

  static int pointsForCorrect(int streak) => 10 + (streak >= 2 ? 5 : 0);

  static OddOneOutResult calculate(OddOneOutState state, int previousBest) {
    final isPerfect = state.mistakes == 0 && state.isComplete;
    var score = state.score;
    if (isPerfect) score += 100;

    final stars = isPerfect
        ? 3
        : state.mistakes <= 2
            ? 2
            : 1;

    return OddOneOutResult(
      score: score,
      stars: stars,
      coins: score ~/ 8 + stars * 2,
      xp: score ~/ 5,
      longestStreak: state.longestStreak,
      mistakes: state.mistakes,
      isPerfect: isPerfect,
      isNewBest: score > previousBest,
    );
  }

  static GameRewardResult toReward(OddOneOutResult r) => GameRewardResult(
        coins: r.coins,
        stars: r.stars,
        xp: r.xp,
        isPerfect: r.isPerfect,
        isNewBest: r.isNewBest,
      );
}
