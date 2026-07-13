import 'package:equatable/equatable.dart';

enum ColorMemoryDifficulty { easy, medium, hard, expert, master }

enum ColorMemoryTheme {
  classic('Classic', ['🟥', '🟦', '🟨', '🟩', '🟪', '🟧']),
  rainbow('Rainbow', ['🔴', '🟠', '🟡', '🟢', '🔵', '🟣']),
  candy('Candy', ['🍬', '🍭', '🧁', '🍩', '🎂', '🍫']),
  pastel('Pastel', ['🩷', '🩵', '💛', '💚', '💜', '🧡']),
  ocean('Ocean', ['🌊', '🐠', '🐚', '💎', '🔷', '🌀']),
  galaxy('Galaxy', ['⭐', '🌙', '🪐', '☄️', '🌟', '💫']);

  const ColorMemoryTheme(this.label, this.tiles);
  final String label;
  final List<String> tiles;
}

enum ColorMemoryPhase { setup, showing, input, feedback, victory, gameOver }

class ColorMemoryConfig extends Equatable {
  const ColorMemoryConfig({
    this.difficulty = ColorMemoryDifficulty.easy,
    this.theme = ColorMemoryTheme.classic,
    this.hintsEnabled = true,
  });

  final ColorMemoryDifficulty difficulty;
  final ColorMemoryTheme theme;
  final bool hintsEnabled;

  ColorMemoryConfig copyWith({
    ColorMemoryDifficulty? difficulty,
    ColorMemoryTheme? theme,
    bool? hintsEnabled,
  }) =>
      ColorMemoryConfig(
        difficulty: difficulty ?? this.difficulty,
        theme: theme ?? this.theme,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      );

  @override
  List<Object?> get props => [difficulty, theme, hintsEnabled];
}

class ColorMemoryState extends Equatable {
  const ColorMemoryState({
    this.config = const ColorMemoryConfig(),
    this.phase = ColorMemoryPhase.setup,
    this.sequence = const [],
    this.playerInput = const [],
    this.showIndex = 0,
    this.activeTile = -1,
    this.gridSize = 2,
    this.level = 1,
    this.score = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.hintsRemaining = 1,
    this.elapsedSeconds = 0,
    this.roundsTarget = 5,
    this.feedbackMessage,
  });

  final ColorMemoryConfig config;
  final ColorMemoryPhase phase;
  final List<int> sequence;
  final List<int> playerInput;
  final int showIndex;
  final int activeTile;
  final int gridSize;
  final int level;
  final int score;
  final int streak;
  final int longestStreak;
  final int mistakes;
  final int hintsUsed;
  final int hintsRemaining;
  final int elapsedSeconds;
  final int roundsTarget;
  final String? feedbackMessage;

  int get tileCount => gridSize * gridSize;

  ColorMemoryState copyWith({
    ColorMemoryConfig? config,
    ColorMemoryPhase? phase,
    List<int>? sequence,
    List<int>? playerInput,
    int? showIndex,
    int? activeTile,
    int? gridSize,
    int? level,
    int? score,
    int? streak,
    int? longestStreak,
    int? mistakes,
    int? hintsUsed,
    int? hintsRemaining,
    int? elapsedSeconds,
    int? roundsTarget,
    String? feedbackMessage,
    bool clearFeedback = false,
    bool clearActive = false,
  }) =>
      ColorMemoryState(
        config: config ?? this.config,
        phase: phase ?? this.phase,
        sequence: sequence ?? this.sequence,
        playerInput: playerInput ?? this.playerInput,
        showIndex: showIndex ?? this.showIndex,
        activeTile: clearActive ? -1 : (activeTile ?? this.activeTile),
        gridSize: gridSize ?? this.gridSize,
        level: level ?? this.level,
        score: score ?? this.score,
        streak: streak ?? this.streak,
        longestStreak: longestStreak ?? this.longestStreak,
        mistakes: mistakes ?? this.mistakes,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        hintsRemaining: hintsRemaining ?? this.hintsRemaining,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        roundsTarget: roundsTarget ?? this.roundsTarget,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      );

  @override
  List<Object?> get props => [
        config,
        phase,
        sequence,
        playerInput,
        showIndex,
        activeTile,
        gridSize,
        level,
        score,
        streak,
        longestStreak,
        mistakes,
        hintsUsed,
        hintsRemaining,
        elapsedSeconds,
        roundsTarget,
        feedbackMessage,
      ];
}

class ColorMemoryResult extends Equatable {
  const ColorMemoryResult({
    required this.score,
    required this.stars,
    required this.coins,
    required this.xp,
    required this.level,
    required this.longestStreak,
    required this.mistakes,
    required this.isPerfect,
    required this.isNewBest,
  });

  final int score;
  final int stars;
  final int coins;
  final int xp;
  final int level;
  final int longestStreak;
  final int mistakes;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props =>
      [score, stars, coins, xp, level, longestStreak, mistakes, isPerfect, isNewBest];
}
