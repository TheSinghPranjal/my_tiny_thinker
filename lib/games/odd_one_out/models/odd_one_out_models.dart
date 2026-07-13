import 'package:equatable/equatable.dart';

enum OddOneOutCategory {
  animals('Animals', '🐾'),
  fruits('Fruits', '🍎'),
  shapes('Shapes', '🔷'),
  vehicles('Vehicles', '🚗'),
  dinosaurs('Dinosaurs', '🦕'),
  ocean('Ocean', '🐠'),
  jungle('Jungle', '🌴'),
  farm('Farm', '🐄'),
  birds('Birds', '🐦'),
  numbers('Numbers', '🔢'),
  letters('Letters', '🔤'),
  emojis('Emojis', '😊'),
  colors('Colors', '🎨'),
  objects('Objects', '📦'),
  food('Food', '🍕'),
  space('Space', '🚀'),
  seasonal('Seasonal', '🌸'),
  fairyTale('Fairy Tale', '🧚'),
  mixed('Mixed', '🎲');

  const OddOneOutCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum OddOneOutDifficulty { easy, medium, hard, expert }

enum OddOnePhase { setup, playing, feedback, victory, gameOver }

class OddOneItem extends Equatable {
  const OddOneItem({
    required this.id,
    required this.display,
    required this.isOdd,
    this.rotation = 0,
    this.scale = 1,
    this.color,
  });

  final int id;
  final String display;
  final bool isOdd;
  final double rotation;
  final double scale;
  final int? color;

  @override
  List<Object?> get props => [id, display, isOdd, rotation, scale, color];
}

class OddOneOutConfig extends Equatable {
  const OddOneOutConfig({
    this.category = OddOneOutCategory.animals,
    this.difficulty = OddOneOutDifficulty.easy,
    this.hintsEnabled = true,
  });

  final OddOneOutCategory category;
  final OddOneOutDifficulty difficulty;
  final bool hintsEnabled;

  OddOneOutConfig copyWith({
    OddOneOutCategory? category,
    OddOneOutDifficulty? difficulty,
    bool? hintsEnabled,
  }) =>
      OddOneOutConfig(
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      );

  @override
  List<Object?> get props => [category, difficulty, hintsEnabled];
}

class OddOneOutState extends Equatable {
  const OddOneOutState({
    this.config = const OddOneOutConfig(),
    this.phase = OddOnePhase.setup,
    this.items = const [],
    this.gridSize = 2,
    this.score = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.round = 1,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.showHint = false,
    this.wrongItemId,
    this.elapsedSeconds = 0,
    this.roundsTarget = 10,
  });

  final OddOneOutConfig config;
  final OddOnePhase phase;
  final List<OddOneItem> items;
  final int gridSize;
  final int score;
  final int streak;
  final int longestStreak;
  final int round;
  final int mistakes;
  final int hintsUsed;
  final bool showHint;
  final int? wrongItemId;
  final int elapsedSeconds;
  final int roundsTarget;

  bool get isComplete => round > roundsTarget;

  OddOneOutState copyWith({
    OddOneOutConfig? config,
    OddOnePhase? phase,
    List<OddOneItem>? items,
    int? gridSize,
    int? score,
    int? streak,
    int? longestStreak,
    int? round,
    int? mistakes,
    int? hintsUsed,
    bool? showHint,
    int? wrongItemId,
    int? elapsedSeconds,
    int? roundsTarget,
    bool clearWrong = false,
    bool clearHint = false,
  }) =>
      OddOneOutState(
        config: config ?? this.config,
        phase: phase ?? this.phase,
        items: items ?? this.items,
        gridSize: gridSize ?? this.gridSize,
        score: score ?? this.score,
        streak: streak ?? this.streak,
        longestStreak: longestStreak ?? this.longestStreak,
        round: round ?? this.round,
        mistakes: mistakes ?? this.mistakes,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        showHint: clearHint ? false : (showHint ?? this.showHint),
        wrongItemId: clearWrong ? null : (wrongItemId ?? this.wrongItemId),
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        roundsTarget: roundsTarget ?? this.roundsTarget,
      );

  @override
  List<Object?> get props => [
        config,
        phase,
        items,
        gridSize,
        score,
        streak,
        longestStreak,
        round,
        mistakes,
        hintsUsed,
        showHint,
        wrongItemId,
        elapsedSeconds,
        roundsTarget,
      ];
}

class OddOneOutResult extends Equatable {
  const OddOneOutResult({
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
