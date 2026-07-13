import 'dart:math' as math;

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

class GeneratedPattern {
  GeneratedPattern({
    required this.type,
    required this.sequence,
    required this.missingIndex,
    required this.answer,
    required this.options,
  });

  final PatternType type;
  final List<String> sequence;
  final int missingIndex;
  final String answer;
  final List<String> options;
}

abstract final class PatternMatchGenerator {
  static final _random = math.Random();

  static int roundsFor(PatternDifficulty d) => switch (d) {
        PatternDifficulty.easy => 8,
        PatternDifficulty.medium => 10,
        PatternDifficulty.hard => 12,
        PatternDifficulty.expert => 15,
      };

  static int sequenceLength(PatternDifficulty d) => switch (d) {
        PatternDifficulty.easy => 4,
        PatternDifficulty.medium => 5,
        PatternDifficulty.hard => 6,
        PatternDifficulty.expert => 7,
      };

  static GeneratedPattern generate(PatternDifficulty difficulty) {
    final types = PatternType.values;
    final type = types[_random.nextInt(types.length)];
    return switch (type) {
      PatternType.shape => _shapePattern(difficulty),
      PatternType.color => _colorPattern(difficulty),
      PatternType.number => _numberPattern(difficulty),
      PatternType.alphabet => _alphabetPattern(difficulty),
      PatternType.emoji => _emojiPattern(difficulty),
      PatternType.size => _sizePattern(difficulty),
      PatternType.direction => _directionPattern(difficulty),
      PatternType.alternating => _alternatingPattern(difficulty),
    };
  }

  static GeneratedPattern _shapePattern(PatternDifficulty d) {
    const shapes = ['⭐', '❤️', '🔷', '🔶'];
    return _abPattern(shapes, PatternType.shape, d);
  }

  static GeneratedPattern _colorPattern(PatternDifficulty d) {
    const colors = ['🟥', '🟦', '🟩', '🟨'];
    return _abPattern(colors, PatternType.color, d);
  }

  static GeneratedPattern _emojiPattern(PatternDifficulty d) {
    const emojis = ['😊', '😢', '😊', '😢'];
    return _abPattern(emojis, PatternType.emoji, d);
  }

  static GeneratedPattern _numberPattern(PatternDifficulty d) {
    final start = 2 + _random.nextInt(4);
    final step = 2;
    final len = sequenceLength(d);
    final seq = List.generate(len, (i) => '${start + i * step}');
    return _missingFromSeq(seq, PatternType.number);
  }

  static GeneratedPattern _alphabetPattern(PatternDifficulty d) {
    final start = _random.nextInt(5);
    final len = sequenceLength(d);
    final seq = List.generate(len, (i) => String.fromCharCode(65 + start + i * 2));
    return _missingFromSeq(seq, PatternType.alphabet);
  }

  static GeneratedPattern _sizePattern(PatternDifficulty d) {
    const sizes = ['●', '◉', '⬤', '●', '◉'];
    return _missingFromSeq(sizes.take(sequenceLength(d)).toList(), PatternType.size);
  }

  static GeneratedPattern _directionPattern(PatternDifficulty d) {
    const dirs = ['⬆️', '➡️', '⬇️', '⬅️'];
    final len = sequenceLength(d);
    final seq = List.generate(len, (i) => dirs[i % dirs.length]);
    return _missingFromSeq(seq, PatternType.direction);
  }

  static GeneratedPattern _alternatingPattern(PatternDifficulty d) {
    const a = ['🐶', '🐱'];
    final len = sequenceLength(d);
    final seq = List.generate(len, (i) => a[i % 2]);
    return _missingFromSeq(seq, PatternType.alternating);
  }

  static GeneratedPattern _abPattern(
    List<String> base,
    PatternType type,
    PatternDifficulty d,
  ) {
    final len = sequenceLength(d);
    final seq = List.generate(len, (i) => base[i % base.length]);
    return _missingFromSeq(seq, type);
  }

  static GeneratedPattern _missingFromSeq(List<String> full, PatternType type) {
    final missingIndex = full.length - 1;
    final answer = full[missingIndex];
    final display = List<String>.from(full)..[missingIndex] = '?';
    final options = {answer, ...full.where((e) => e != answer).take(3)}.toList();
    while (options.length < 4) {
      options.add('✨');
    }
    options.shuffle(_random);
    return GeneratedPattern(
      type: type,
      sequence: display,
      missingIndex: missingIndex,
      answer: answer,
      options: options.take(4).toList(),
    );
  }
}

abstract final class PatternMatchScoring {
  static int pointsForCorrect(int streak) => 10 + (streak >= 2 ? 5 : 0);

  static PatternMatchResult calculate(PatternMatchState state, int previousBest) {
    final isPerfect = state.mistakes == 0 && state.isComplete;
    var score = state.score;
    if (isPerfect) score += 100;
    final stars = isPerfect ? 3 : state.mistakes <= 2 ? 2 : 1;
    return PatternMatchResult(
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

  static GameRewardResult toReward(PatternMatchResult r) => GameRewardResult(
        coins: r.coins,
        stars: r.stars,
        xp: r.xp,
        isPerfect: r.isPerfect,
        isNewBest: r.isNewBest,
      );
}
