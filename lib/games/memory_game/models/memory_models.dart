import 'package:equatable/equatable.dart';

/// Five-tier difficulty used across all memory mini-games.
enum MemoryDifficulty { easy, medium, hard, expert, master }

enum MemoryPhase {
  setup,
  countdown,
  showing,
  input,
  feedback,
  playing,
  paused,
  roundComplete,
  victory,
  gameOver,
}

enum MemoryMiniGameType {
  classicCard('classic_card', '🃏', 'Classic Card Memory', 0),
  sequence('sequence', '🔴', 'Sequence Memory', 0),
  position('position', '📍', 'Position Memory', 50),
  pictureRecall('picture_recall', '🖼️', 'Picture Recall', 100),
  sound('sound', '🔊', 'Sound Memory', 150),
  flash('flash', '⚡', 'Flash Memory', 200),
  number('number', '🔢', 'Number Memory', 0),
  color('color', '🎨', 'Color Memory', 0),
  emojiMemory('emoji', '😊', 'Emoji Memory', 75),
  objectTray('object_tray', '🧺', 'Object Tray', 125);

  const MemoryMiniGameType(this.id, this.emoji, this.displayName, this.unlockCost);
  final String id;
  final String emoji;
  final String displayName;
  final int unlockCost;

  /// Hub-visible games after standalone extraction / removals.
  static const hubGames = <MemoryMiniGameType>[
    MemoryMiniGameType.classicCard,
    MemoryMiniGameType.sequence,
    MemoryMiniGameType.color,
  ];
}

enum MemoryCardTheme {
  animals('animals', '🦁', 'Animals'),
  fruits('fruits', '🍎', 'Fruits'),
  vehicles('vehicles', '🚗', 'Vehicles'),
  dinosaurs('dinosaurs', '🦕', 'Dinosaurs'),
  space('space', '🚀', 'Space'),
  ocean('ocean', '🐠', 'Ocean'),
  shapes('shapes', '🔷', 'Shapes'),
  letters('letters', '🔤', 'Letters'),
  numbers('numbers', '🔢', 'Numbers'),
  emojis('emojis', '😊', 'Emojis'),
  fairyTales('fairy_tales', '🧚', 'Fairy Tales');

  const MemoryCardTheme(this.id, this.emoji, this.displayName);
  final String id;
  final String emoji;
  final String displayName;
}

enum MemoryBadge {
  firstWin('first_win', '🌟', 'First Memory Win'),
  perfectRound('perfect_round', '💯', 'Perfect Round'),
  combo5('combo_5', '⚡', '5 Combo Streak'),
  streak7('streak_7', '🔥', '7 Day Streak'),
  masterMind('master_mind', '🧠', 'Master Mind'),
  allGames('all_games', '🏆', 'All Games Played');

  const MemoryBadge(this.id, this.emoji, this.title);
  final String id;
  final String emoji;
  final String title;
}

class MemoryGameConfig extends Equatable {
  const MemoryGameConfig({
    required this.gameType,
    this.difficulty = MemoryDifficulty.easy,
    this.cardTheme = MemoryCardTheme.animals,
    this.adaptiveEnabled = false,
  });

  final MemoryMiniGameType gameType;
  final MemoryDifficulty difficulty;
  final MemoryCardTheme cardTheme;
  final bool adaptiveEnabled;

  MemoryGameConfig copyWith({
    MemoryDifficulty? difficulty,
    MemoryCardTheme? cardTheme,
    bool? adaptiveEnabled,
  }) =>
      MemoryGameConfig(
        gameType: gameType,
        difficulty: difficulty ?? this.difficulty,
        cardTheme: cardTheme ?? this.cardTheme,
        adaptiveEnabled: adaptiveEnabled ?? this.adaptiveEnabled,
      );

  @override
  List<Object?> get props => [gameType, difficulty, cardTheme, adaptiveEnabled];
}

class MemorySessionState extends Equatable {
  const MemorySessionState({
    this.config,
    this.phase = MemoryPhase.setup,
    this.score = 0,
    this.combo = 0,
    this.longestCombo = 0,
    this.mistakes = 0,
    this.round = 1,
    this.streak = 0,
    this.elapsedSeconds = 0,
    this.countdown = 3,
    this.gameData = const {},
    this.feedbackMessage,
    this.isCorrectFeedback,
    this.hintAvailable = true,
  });

  final MemoryGameConfig? config;
  final MemoryPhase phase;
  final int score;
  final int combo;
  final int longestCombo;
  final int mistakes;
  final int round;
  final int streak;
  final int elapsedSeconds;
  final int countdown;
  final Map<String, dynamic> gameData;
  final String? feedbackMessage;
  final bool? isCorrectFeedback;
  final bool hintAvailable;

  double get accuracy {
    final total = round + mistakes;
    if (total == 0) return 1;
    return round / total;
  }

  MemorySessionState copyWith({
    MemoryGameConfig? config,
    MemoryPhase? phase,
    int? score,
    int? combo,
    int? longestCombo,
    int? mistakes,
    int? round,
    int? streak,
    int? elapsedSeconds,
    int? countdown,
    Map<String, dynamic>? gameData,
    String? feedbackMessage,
    bool? isCorrectFeedback,
    bool? hintAvailable,
    bool clearFeedback = false,
  }) =>
      MemorySessionState(
        config: config ?? this.config,
        phase: phase ?? this.phase,
        score: score ?? this.score,
        combo: combo ?? this.combo,
        longestCombo: longestCombo ?? this.longestCombo,
        mistakes: mistakes ?? this.mistakes,
        round: round ?? this.round,
        streak: streak ?? this.streak,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        countdown: countdown ?? this.countdown,
        gameData: gameData ?? this.gameData,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        isCorrectFeedback: clearFeedback
            ? null
            : (isCorrectFeedback ?? this.isCorrectFeedback),
        hintAvailable: hintAvailable ?? this.hintAvailable,
      );

  @override
  List<Object?> get props => [
        config,
        phase,
        score,
        combo,
        longestCombo,
        mistakes,
        round,
        streak,
        elapsedSeconds,
        countdown,
        gameData,
        feedbackMessage,
        isCorrectFeedback,
        hintAvailable,
      ];
}

class MemoryGameResult extends Equatable {
  const MemoryGameResult({
    required this.gameType,
    required this.score,
    required this.stars,
    required this.coins,
    required this.xp,
    required this.accuracy,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.longestCombo,
    required this.roundsCompleted,
    required this.isPerfect,
    required this.isNewBest,
  });

  final MemoryMiniGameType gameType;
  final int score;
  final int stars;
  final int coins;
  final int xp;
  final double accuracy;
  final int mistakes;
  final int elapsedSeconds;
  final int longestCombo;
  final int roundsCompleted;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props => [
        gameType,
        score,
        stars,
        coins,
        xp,
        accuracy,
        mistakes,
        elapsedSeconds,
        longestCombo,
        roundsCompleted,
        isPerfect,
        isNewBest,
      ];
}

class MiniGameStats extends Equatable {
  const MiniGameStats({
    required this.gameType,
    this.timesPlayed = 0,
    this.bestScore = 0,
    this.starsEarned = 0,
    this.perfectGames = 0,
    this.highestCombo = 0,
    this.totalCorrect = 0,
    this.totalMistakes = 0,
    this.fastestCompletion = 0,
    this.currentAdaptiveLevel = 0,
    this.isUnlocked = true,
    this.lastPlayed,
  });

  final MemoryMiniGameType gameType;
  final int timesPlayed;
  final int bestScore;
  final int starsEarned;
  final int perfectGames;
  final int highestCombo;
  final int totalCorrect;
  final int totalMistakes;
  final int fastestCompletion;
  final int currentAdaptiveLevel;
  final bool isUnlocked;
  final DateTime? lastPlayed;

  double get averageAccuracy {
    final total = totalCorrect + totalMistakes;
    if (total == 0) return 0;
    return totalCorrect / total;
  }

  MiniGameStats copyWith({
    int? timesPlayed,
    int? bestScore,
    int? starsEarned,
    int? perfectGames,
    int? highestCombo,
    int? totalCorrect,
    int? totalMistakes,
    int? fastestCompletion,
    int? currentAdaptiveLevel,
    bool? isUnlocked,
    DateTime? lastPlayed,
  }) =>
      MiniGameStats(
        gameType: gameType,
        timesPlayed: timesPlayed ?? this.timesPlayed,
        bestScore: bestScore ?? this.bestScore,
        starsEarned: starsEarned ?? this.starsEarned,
        perfectGames: perfectGames ?? this.perfectGames,
        highestCombo: highestCombo ?? this.highestCombo,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalMistakes: totalMistakes ?? this.totalMistakes,
        fastestCompletion: fastestCompletion ?? this.fastestCompletion,
        currentAdaptiveLevel:
            currentAdaptiveLevel ?? this.currentAdaptiveLevel,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        lastPlayed: lastPlayed ?? this.lastPlayed,
      );

  Map<String, dynamic> toJson() => {
        'gameType': gameType.id,
        'timesPlayed': timesPlayed,
        'bestScore': bestScore,
        'starsEarned': starsEarned,
        'perfectGames': perfectGames,
        'highestCombo': highestCombo,
        'totalCorrect': totalCorrect,
        'totalMistakes': totalMistakes,
        'fastestCompletion': fastestCompletion,
        'currentAdaptiveLevel': currentAdaptiveLevel,
        'isUnlocked': isUnlocked,
        'lastPlayed': lastPlayed?.toIso8601String(),
      };

  factory MiniGameStats.fromJson(Map<String, dynamic> json) {
    final type = MemoryMiniGameType.values.firstWhere(
      (g) => g.id == json['gameType'],
      orElse: () => MemoryMiniGameType.classicCard,
    );
    return MiniGameStats(
      gameType: type,
      timesPlayed: json['timesPlayed'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      starsEarned: json['starsEarned'] as int? ?? 0,
      perfectGames: json['perfectGames'] as int? ?? 0,
      highestCombo: json['highestCombo'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      fastestCompletion: json['fastestCompletion'] as int? ?? 0,
      currentAdaptiveLevel: json['currentAdaptiveLevel'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        gameType,
        timesPlayed,
        bestScore,
        starsEarned,
        perfectGames,
        highestCombo,
        totalCorrect,
        totalMistakes,
        fastestCompletion,
        currentAdaptiveLevel,
        isUnlocked,
        lastPlayed,
      ];
}

class MemoryHubStatistics extends Equatable {
  const MemoryHubStatistics({
    this.gamesPlayed = 0,
    this.perfectGames = 0,
    this.highestCombo = 0,
    this.totalStars = 0,
    this.totalCoins = 0,
    this.dailyStreak = 0,
    this.weeklyStreak = 0,
    this.favoriteGame,
    this.unlockedThemes = const ['animals'],
    this.unlockedBadges = const [],
    this.miniGameStats = const {},
  });

  final int gamesPlayed;
  final int perfectGames;
  final int highestCombo;
  final int totalStars;
  final int totalCoins;
  final int dailyStreak;
  final int weeklyStreak;
  final MemoryMiniGameType? favoriteGame;
  final List<String> unlockedThemes;
  final List<String> unlockedBadges;
  final Map<String, MiniGameStats> miniGameStats;

  MemoryHubStatistics copyWith({
    int? gamesPlayed,
    int? perfectGames,
    int? highestCombo,
    int? totalStars,
    int? totalCoins,
    int? dailyStreak,
    int? weeklyStreak,
    MemoryMiniGameType? favoriteGame,
    List<String>? unlockedThemes,
    List<String>? unlockedBadges,
    Map<String, MiniGameStats>? miniGameStats,
  }) =>
      MemoryHubStatistics(
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        perfectGames: perfectGames ?? this.perfectGames,
        highestCombo: highestCombo ?? this.highestCombo,
        totalStars: totalStars ?? this.totalStars,
        totalCoins: totalCoins ?? this.totalCoins,
        dailyStreak: dailyStreak ?? this.dailyStreak,
        weeklyStreak: weeklyStreak ?? this.weeklyStreak,
        favoriteGame: favoriteGame ?? this.favoriteGame,
        unlockedThemes: unlockedThemes ?? this.unlockedThemes,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        miniGameStats: miniGameStats ?? this.miniGameStats,
      );

  MiniGameStats statsFor(MemoryMiniGameType type) =>
      miniGameStats[type.id] ?? MiniGameStats(gameType: type);

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'perfectGames': perfectGames,
        'highestCombo': highestCombo,
        'totalStars': totalStars,
        'totalCoins': totalCoins,
        'dailyStreak': dailyStreak,
        'weeklyStreak': weeklyStreak,
        'favoriteGame': favoriteGame?.id,
        'unlockedThemes': unlockedThemes,
        'unlockedBadges': unlockedBadges,
        'miniGameStats': miniGameStats.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
      };

  factory MemoryHubStatistics.fromJson(Map<String, dynamic> json) {
    final statsMap = <String, MiniGameStats>{};
    final raw = json['miniGameStats'] as Map<String, dynamic>?;
    if (raw != null) {
      for (final entry in raw.entries) {
        statsMap[entry.key] =
            MiniGameStats.fromJson(entry.value as Map<String, dynamic>);
      }
    }
    for (final type in MemoryMiniGameType.values) {
      statsMap.putIfAbsent(type.id, () => MiniGameStats(
            gameType: type,
            isUnlocked: type.unlockCost == 0,
          ));
    }
    return MemoryHubStatistics(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      perfectGames: json['perfectGames'] as int? ?? 0,
      highestCombo: json['highestCombo'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      totalCoins: json['totalCoins'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      weeklyStreak: json['weeklyStreak'] as int? ?? 0,
      favoriteGame: json['favoriteGame'] != null
          ? MemoryMiniGameType.values.firstWhere(
              (g) => g.id == json['favoriteGame'],
              orElse: () => MemoryMiniGameType.classicCard,
            )
          : null,
      unlockedThemes: (json['unlockedThemes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['animals'],
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      miniGameStats: statsMap,
    );
  }

  @override
  List<Object?> get props => [
        gamesPlayed,
        perfectGames,
        highestCombo,
        totalStars,
        totalCoins,
        dailyStreak,
        weeklyStreak,
        favoriteGame,
        unlockedThemes,
        unlockedBadges,
        miniGameStats,
      ];
}
