import 'package:equatable/equatable.dart';

enum PatternType {
  shape,
  color,
  number,
  alphabet,
  emoji,
  size,
  direction,
  alternating,
}

enum PatternDifficulty { easy, medium, hard, expert }

enum PatternPhase { setup, playing, feedback, victory }

class PatternOption extends Equatable {
  const PatternOption({required this.id, required this.display});
  final int id;
  final String display;
  @override
  List<Object?> get props => [id, display];
}

class PatternMatchConfig extends Equatable {
  const PatternMatchConfig({
    this.difficulty = PatternDifficulty.easy,
    this.hintsEnabled = true,
  });

  final PatternDifficulty difficulty;
  final bool hintsEnabled;

  PatternMatchConfig copyWith({
    PatternDifficulty? difficulty,
    bool? hintsEnabled,
  }) =>
      PatternMatchConfig(
        difficulty: difficulty ?? this.difficulty,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      );

  @override
  List<Object?> get props => [difficulty, hintsEnabled];
}

class PatternMatchState extends Equatable {
  const PatternMatchState({
    this.config = const PatternMatchConfig(),
    this.phase = PatternPhase.setup,
    this.sequence = const [],
    this.missingIndex = 0,
    this.options = const [],
    this.correctOptionId = 0,
    this.patternType = PatternType.shape,
    this.score = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.round = 1,
    this.mistakes = 0,
    this.roundsTarget = 10,
    this.elapsedSeconds = 0,
    this.wrongOptionId,
  });

  final PatternMatchConfig config;
  final PatternPhase phase;
  final List<String> sequence;
  final int missingIndex;
  final List<PatternOption> options;
  final int correctOptionId;
  final PatternType patternType;
  final int score;
  final int streak;
  final int longestStreak;
  final int round;
  final int mistakes;
  final int roundsTarget;
  final int elapsedSeconds;
  final int? wrongOptionId;

  bool get isComplete => round > roundsTarget;

  PatternMatchState copyWith({
    PatternMatchConfig? config,
    PatternPhase? phase,
    List<String>? sequence,
    int? missingIndex,
    List<PatternOption>? options,
    int? correctOptionId,
    PatternType? patternType,
    int? score,
    int? streak,
    int? longestStreak,
    int? round,
    int? mistakes,
    int? roundsTarget,
    int? elapsedSeconds,
    int? wrongOptionId,
    bool clearWrong = false,
  }) =>
      PatternMatchState(
        config: config ?? this.config,
        phase: phase ?? this.phase,
        sequence: sequence ?? this.sequence,
        missingIndex: missingIndex ?? this.missingIndex,
        options: options ?? this.options,
        correctOptionId: correctOptionId ?? this.correctOptionId,
        patternType: patternType ?? this.patternType,
        score: score ?? this.score,
        streak: streak ?? this.streak,
        longestStreak: longestStreak ?? this.longestStreak,
        round: round ?? this.round,
        mistakes: mistakes ?? this.mistakes,
        roundsTarget: roundsTarget ?? this.roundsTarget,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        wrongOptionId: clearWrong ? null : (wrongOptionId ?? this.wrongOptionId),
      );

  @override
  List<Object?> get props => [
        config,
        phase,
        sequence,
        missingIndex,
        options,
        correctOptionId,
        patternType,
        score,
        streak,
        longestStreak,
        round,
        mistakes,
        roundsTarget,
        elapsedSeconds,
        wrongOptionId,
      ];
}

class PatternMatchResult extends Equatable {
  const PatternMatchResult({
    required this.score,
    required this.stars,
    required this.coins,
    required this.xp,
    required this.longestStreak,
    required this.mistakes,
    required this.isPerfect,
    required this.isNewBest,
  });

  final int score;
  final int stars;
  final int coins;
  final int xp;
  final int longestStreak;
  final int mistakes;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props =>
      [score, stars, coins, xp, longestStreak, mistakes, isPerfect, isNewBest];
}
