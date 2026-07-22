import 'dart:math' as math;

import 'package:my_tiny_thinker/games/complete_the_word_adventure/models/complete_word_models.dart';

abstract final class CompleteWordVocabulary {
  static const three = <WordEntry>[
    WordEntry(word: 'CAT', emoji: '🐱'),
    WordEntry(word: 'DOG', emoji: '🐶'),
    WordEntry(word: 'BAT', emoji: '🦇'),
    WordEntry(word: 'CAR', emoji: '🚗'),
    WordEntry(word: 'MAT', emoji: '🟫'),
    WordEntry(word: 'SUN', emoji: '☀️'),
    WordEntry(word: 'BOX', emoji: '📦'),
    WordEntry(word: 'HEN', emoji: '🐔'),
    WordEntry(word: 'PEN', emoji: '🖊️'),
    WordEntry(word: 'CUP', emoji: '☕'),
    WordEntry(word: 'FOX', emoji: '🦊'),
    WordEntry(word: 'MAP', emoji: '🗺️'),
    WordEntry(word: 'JAR', emoji: '🫙'),
    WordEntry(word: 'FAN', emoji: '🪭'),
    WordEntry(word: 'KEY', emoji: '🔑'),
    WordEntry(word: 'BED', emoji: '🛏️'),
    WordEntry(word: 'BUS', emoji: '🚌'),
    WordEntry(word: 'ANT', emoji: '🐜'),
    WordEntry(word: 'COW', emoji: '🐮'),
    WordEntry(word: 'PIG', emoji: '🐷'),
    WordEntry(word: 'HAT', emoji: '🎩'),
  ];

  static const four = <WordEntry>[
    WordEntry(word: 'BOAT', emoji: '🚤'),
    WordEntry(word: 'BOOK', emoji: '📖'),
    WordEntry(word: 'CRAB', emoji: '🦀'),
    WordEntry(word: 'DOOR', emoji: '🚪'),
    WordEntry(word: 'FISH', emoji: '🐟'),
    WordEntry(word: 'TREE', emoji: '🌳'),
    WordEntry(word: 'BIRD', emoji: '🐦'),
    WordEntry(word: 'LION', emoji: '🦁'),
    WordEntry(word: 'MILK', emoji: '🥛'),
    WordEntry(word: 'RAIN', emoji: '🌧️'),
    WordEntry(word: 'SHIP', emoji: '🚢'),
    WordEntry(word: 'STAR', emoji: '⭐'),
    WordEntry(word: 'MOON', emoji: '🌙'),
    WordEntry(word: 'HAND', emoji: '✋'),
    WordEntry(word: 'KING', emoji: '🤴'),
    WordEntry(word: 'CAKE', emoji: '🎂'),
    WordEntry(word: 'FROG', emoji: '🐸'),
    WordEntry(word: 'FIRE', emoji: '🔥'),
  ];

  static const five = <WordEntry>[
    WordEntry(word: 'CHAIR', emoji: '🪑'),
    WordEntry(word: 'TABLE', emoji: '🪵'),
    WordEntry(word: 'APPLE', emoji: '🍎'),
    WordEntry(word: 'PLANT', emoji: '🌱'),
    WordEntry(word: 'TIGER', emoji: '🐯'),
    WordEntry(word: 'MOUSE', emoji: '🐭'),
    WordEntry(word: 'TRAIN', emoji: '🚂'),
    WordEntry(word: 'CLOUD', emoji: '☁️'),
    WordEntry(word: 'GRAPE', emoji: '🍇'),
    WordEntry(word: 'SMILE', emoji: '😊'),
    WordEntry(word: 'BEACH', emoji: '🏖️'),
    WordEntry(word: 'BRUSH', emoji: '🖌️'),
    WordEntry(word: 'ROBOT', emoji: '🤖'),
    WordEntry(word: 'WATER', emoji: '💧'),
    WordEntry(word: 'HORSE', emoji: '🐴'),
    WordEntry(word: 'HEART', emoji: '❤️'),
  ];

  static const six = <WordEntry>[
    WordEntry(word: 'PENCIL', emoji: '✏️'),
    WordEntry(word: 'BOTTLE', emoji: '🧴'),
    WordEntry(word: 'ORANGE', emoji: '🍊'),
    WordEntry(word: 'SCHOOL', emoji: '🏫'),
    WordEntry(word: 'FLOWER', emoji: '🌸'),
    WordEntry(word: 'MONKEY', emoji: '🐵'),
    WordEntry(word: 'GARDEN', emoji: '🏡'),
    WordEntry(word: 'BASKET', emoji: '🧺'),
    WordEntry(word: 'RABBIT', emoji: '🐰'),
    WordEntry(word: 'WINTER', emoji: '❄️'),
    WordEntry(word: 'CAMERA', emoji: '📷'),
    WordEntry(word: 'BRIDGE', emoji: '🌉'),
    WordEntry(word: 'COOKIE', emoji: '🍪'),
    WordEntry(word: 'JACKET', emoji: '🧥'),
    WordEntry(word: 'POCKET', emoji: '👖'),
    WordEntry(word: 'CANDLE', emoji: '🕯️'),
  ];

  static List<WordEntry> forLength(int length) => switch (length) {
        3 => three,
        4 => four,
        5 => five,
        6 => six,
        _ => three,
      };
}

abstract final class CompleteWordLogic {
  static final _random = math.Random();

  static WordEntry pickWord(
    WordLengthDifficulty difficulty, {
    String? exclude,
  }) {
    final pool = List<WordEntry>.from(
      CompleteWordVocabulary.forLength(difficulty.length),
    );
    if (exclude != null) {
      pool.removeWhere((w) => w.word == exclude);
    }
    if (pool.isEmpty) {
      return CompleteWordVocabulary.forLength(difficulty.length).first;
    }
    return pool[_random.nextInt(pool.length)];
  }

  /// Scrambles letters; retries so they are not already in correct order.
  static List<LetterTile> scrambleTiles(String word) {
    final letters = word.split('');
    List<String> shuffled;
    var attempts = 0;
    do {
      shuffled = List<String>.from(letters)..shuffle(_random);
      attempts++;
    } while (shuffled.join() == word && attempts < 20 && word.length > 1);

    return [
      for (var i = 0; i < shuffled.length; i++)
        LetterTile(id: 'tile_$i', letter: shuffled[i]),
    ];
  }

  static List<String> emptySlots(int length) =>
      List.filled(length, '');

  static ({int coins, int xp, int stars, int points}) letterReward() =>
      (coins: 5, xp: 2, stars: 0, points: 10);

  static ({int coins, int xp, int stars, int points}) wordBonus(int combo) {
    final comboBonus = combo >= 3 ? 5 : 0;
    return (
      coins: 20 + comboBonus,
      xp: 10 + comboBonus,
      stars: 1,
      points: 40 + comboBonus * 2,
    );
  }

  static CompleteWordResult calculate(CompleteWordState state) {
    final praise = kEndPraise[state.wordsCompleted % kEndPraise.length];
    return CompleteWordResult(
      wordsCompleted: state.wordsCompleted,
      lettersCorrect: state.lettersCorrect,
      lettersWrong: state.lettersWrong,
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
