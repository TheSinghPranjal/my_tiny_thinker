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

enum PatternPhase { ready, playing, feedback, paused, celebrating, finished }

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

/// Parent-configurable settings persisted from Parent Zone.
class PatternMatchSettings extends Equatable {
  const PatternMatchSettings({
    this.sessionSeconds = 60,
    this.difficulty = PatternDifficulty.easy,
    this.hintsEnabled = true,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final PatternDifficulty difficulty;
  final bool hintsEnabled;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  PatternMatchConfig toConfig() => PatternMatchConfig(
        difficulty: difficulty,
        hintsEnabled: hintsEnabled,
      );

  PatternMatchSettings copyWith({
    int? sessionSeconds,
    PatternDifficulty? difficulty,
    bool? hintsEnabled,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      PatternMatchSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        difficulty: difficulty ?? this.difficulty,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'difficulty': difficulty.name,
        'hintsEnabled': hintsEnabled,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
      };

  factory PatternMatchSettings.fromJson(Map<String, dynamic> json) {
    return PatternMatchSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      difficulty: PatternDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => PatternDifficulty.easy,
      ),
      hintsEnabled: json['hintsEnabled'] as bool? ?? true,
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        difficulty,
        hintsEnabled,
        rewardMultiplier,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
      ];
}

class PatternMatchState extends Equatable {
  const PatternMatchState({
    this.settings = const PatternMatchSettings(),
    this.phase = PatternPhase.ready,
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
    this.remainingSeconds = 0,
    this.pendingEnd = false,
    this.showSparkles = false,
    this.wrongOptionId,
  });

  final PatternMatchSettings settings;
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
  final int remainingSeconds;
  final bool pendingEnd;
  final bool showSparkles;
  final int? wrongOptionId;

  bool get roundsSolved => round > 1 || (round == 1 && score > 0);

  PatternMatchState copyWith({
    PatternMatchSettings? settings,
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
    int? remainingSeconds,
    bool? pendingEnd,
    bool? showSparkles,
    int? wrongOptionId,
    bool clearWrong = false,
  }) =>
      PatternMatchState(
        settings: settings ?? this.settings,
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
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        showSparkles: showSparkles ?? this.showSparkles,
        wrongOptionId: clearWrong ? null : (wrongOptionId ?? this.wrongOptionId),
      );

  @override
  List<Object?> get props => [
        settings,
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
        remainingSeconds,
        pendingEnd,
        showSparkles,
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
    required this.roundsSolved,
    required this.isPerfect,
    required this.isNewBest,
  });

  final int score;
  final int stars;
  final int coins;
  final int xp;
  final int longestStreak;
  final int mistakes;
  final int roundsSolved;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props => [
        score,
        stars,
        coins,
        xp,
        longestStreak,
        mistakes,
        roundsSolved,
        isPerfect,
        isNewBest,
      ];
}

const kPatternMatchSkills = [
  'Pattern Recognition',
  'Logical Thinking',
  'Sequencing',
  'Problem Solving',
  'Attention to Detail',
  'Early Math & Literacy',
];
