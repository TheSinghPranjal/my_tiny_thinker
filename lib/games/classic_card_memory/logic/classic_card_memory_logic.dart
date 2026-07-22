import 'dart:math' as math;

import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';

abstract final class ClassicCardMemoryLogic {
  static final _random = math.Random();

  static const _pools = <ClassicMemoryCategory, List<String>>{
    ClassicMemoryCategory.animals: [
      '🦁', '🐯', '🐻', '🐼', '🦊', '🐸', '🐵', '🐰', '🦄', '🐶', '🐱', '🐷',
    ],
    ClassicMemoryCategory.fruits: [
      '🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🥝', '🍌', '🍉', '🫐', '🍒', '🥭',
    ],
    ClassicMemoryCategory.shapes: [
      '🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '⬛', '⬜', '🔶', '🔷', '💠', '🔺',
    ],
    ClassicMemoryCategory.emojis: [
      '😊', '😂', '😎', '🥳', '😍', '🤩', '😇', '🤗', '😜', '🥰', '🤔', '😴',
    ],
    ClassicMemoryCategory.vehicles: [
      '🚗', '🚌', '🚕', '🚙', '🏎️', '🚓', '🚑', '🚒', '🛵', '🚲', '✈️', '🚀',
    ],
    ClassicMemoryCategory.ocean: [
      '🐠', '🐟', '🐬', '🐳', '🦈', '🐙', '🦀', '🦞', '🐚', '🌊', '🏖️', '⛵',
    ],
    ClassicMemoryCategory.dinosaurs: [
      '🦕', '🦖', '🐊', '🦴', '🌋', '🥚', '🌿', '🪨', '🦎', '🐢', '🦔', '🌴',
    ],
    ClassicMemoryCategory.space: [
      '🚀', '🌙', '⭐', '🪐', '🛸', '☄️', '🌟', '🌍', '🔭', '👽', '🌌', '🛰️',
    ],
  };

  static ClassicMemoryCategory pickCategory(
    ClassicCardMemorySettings settings,
  ) {
    if (!settings.rotateCategories) return settings.category;
    final values = ClassicMemoryCategory.values;
    return values[_random.nextInt(values.length)];
  }

  static List<MemoryCard> dealRound({
    required int pairCount,
    required ClassicMemoryCategory category,
  }) {
    final count = pairCount.clamp(2, 12);
    final pool = List<String>.from(_pools[category] ?? _pools[ClassicMemoryCategory.animals]!);
    pool.shuffle(_random);
    final faces = pool.take(count).toList();

    final cards = <MemoryCard>[];
    for (var i = 0; i < faces.length; i++) {
      final pairId = 'pair_$i';
      final face = faces[i];
      cards.add(MemoryCard(id: '${pairId}_a', pairId: pairId, face: face));
      cards.add(MemoryCard(id: '${pairId}_b', pairId: pairId, face: face));
    }
    cards.shuffle(_random);
    return cards;
  }

  static (int cols, int rows) gridForPairs(int pairCount) {
    final total = pairCount * 2;
    if (total <= 4) return (2, 2);
    if (total <= 6) return (3, 2);
    if (total <= 8) return (4, 2);
    if (total <= 12) return (4, 3);
    if (total <= 16) return (4, 4);
    if (total <= 20) return (5, 4);
    return (6, 4);
  }

  static ({int points, int coins, int xp, int stars}) matchReward(int combo) {
    final bonus = combo >= 3 ? 5 : 0;
    return (
      points: 10 + bonus,
      coins: 2 + (combo >= 3 ? 1 : 0),
      xp: 3,
      stars: combo >= 5 ? 1 : 0,
    );
  }

  static ClassicCardMemoryResult calculate(ClassicCardMemoryState state) {
    final stars = state.starsEarned.clamp(0, 99);
    return ClassicCardMemoryResult(
      score: state.score,
      coins: state.coinsEarned,
      xp: state.xpEarned,
      stars: math.max(stars, state.roundsCompleted > 0 ? 1 : 0),
      matches: state.matches,
      mistakes: state.mistakes,
      roundsCompleted: state.roundsCompleted,
      maxCombo: state.maxCombo,
    );
  }
}
