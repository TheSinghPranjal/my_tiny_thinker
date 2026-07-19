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

enum OddOnePhase { ready, playing, feedback, paused, celebrating, finished }

/// Parent-configurable settings persisted from Parent Zone.
class OddOneOutSettings extends Equatable {
  const OddOneOutSettings({
    this.sessionSeconds = 60,
    this.category = OddOneOutCategory.animals,
    this.difficulty = OddOneOutDifficulty.easy,
    this.hintsEnabled = true,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final OddOneOutCategory category;
  final OddOneOutDifficulty difficulty;
  final bool hintsEnabled;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  OddOneOutConfig toConfig() => OddOneOutConfig(
        category: category,
        difficulty: difficulty,
        hintsEnabled: hintsEnabled,
      );

  OddOneOutSettings copyWith({
    int? sessionSeconds,
    OddOneOutCategory? category,
    OddOneOutDifficulty? difficulty,
    bool? hintsEnabled,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      OddOneOutSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        category: category ?? this.category,
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
        'category': category.name,
        'difficulty': difficulty.name,
        'hintsEnabled': hintsEnabled,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
      };

  factory OddOneOutSettings.fromJson(Map<String, dynamic> json) {
    return OddOneOutSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      category: OddOneOutCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => OddOneOutCategory.animals,
      ),
      difficulty: OddOneOutDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => OddOneOutDifficulty.easy,
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
        category,
        difficulty,
        hintsEnabled,
        rewardMultiplier,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
      ];
}

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
    this.settings = const OddOneOutSettings(),
    this.phase = OddOnePhase.ready,
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
    this.remainingSeconds = 0,
    this.pendingEnd = false,
    this.showSparkles = false,
  });

  final OddOneOutSettings settings;
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
  final int remainingSeconds;
  final bool pendingEnd;
  final bool showSparkles;

  bool get roundsSolved => round > 1 || (round == 1 && score > 0);

  OddOneOutState copyWith({
    OddOneOutSettings? settings,
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
    int? remainingSeconds,
    bool? pendingEnd,
    bool? showSparkles,
    bool clearWrong = false,
    bool clearHint = false,
  }) =>
      OddOneOutState(
        settings: settings ?? this.settings,
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
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        showSparkles: showSparkles ?? this.showSparkles,
      );

  @override
  List<Object?> get props => [
        settings,
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
        remainingSeconds,
        pendingEnd,
        showSparkles,
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

const kOddOneOutSkills = [
  'Visual Discrimination',
  'Observation',
  'Categorization',
  'Attention to Detail',
  'Logical Thinking',
  'Problem Solving',
];
