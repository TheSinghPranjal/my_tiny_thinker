import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';

class PlayerProfile extends Equatable {
  const PlayerProfile({
    this.displayName = 'Explorer',
    this.coins = 0,
    this.stars = 0,
    this.xp = 0,
    this.level = 1,
    this.dailyStreak = 0,
    this.totalPlayTimeMinutes = 0,
    this.avatarId = 'default',
    this.unlockedAvatars = const ['default'],
    this.unlockedStickers = const [],
    this.unlockedBackgrounds = const ['default'],
    this.unlockedBubbleSkins = const ['default'],
    this.lastPlayedDate,
  });

  final String displayName;
  final int coins;
  final int stars;
  final int xp;
  final int level;
  final int dailyStreak;
  final int totalPlayTimeMinutes;
  final String avatarId;
  final List<String> unlockedAvatars;
  final List<String> unlockedStickers;
  final List<String> unlockedBackgrounds;
  final List<String> unlockedBubbleSkins;
  final DateTime? lastPlayedDate;

  int get xpForNextLevel => level * 100;
  double get levelProgress => xpForNextLevel > 0 ? (xp % xpForNextLevel) / xpForNextLevel : 0;

  PlayerProfile copyWith({
    String? displayName,
    int? coins,
    int? stars,
    int? xp,
    int? level,
    int? dailyStreak,
    int? totalPlayTimeMinutes,
    String? avatarId,
    List<String>? unlockedAvatars,
    List<String>? unlockedStickers,
    List<String>? unlockedBackgrounds,
    List<String>? unlockedBubbleSkins,
    DateTime? lastPlayedDate,
  }) =>
      PlayerProfile(
        displayName: displayName ?? this.displayName,
        coins: coins ?? this.coins,
        stars: stars ?? this.stars,
        xp: xp ?? this.xp,
        level: level ?? this.level,
        dailyStreak: dailyStreak ?? this.dailyStreak,
        totalPlayTimeMinutes:
            totalPlayTimeMinutes ?? this.totalPlayTimeMinutes,
        avatarId: avatarId ?? this.avatarId,
        unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
        unlockedStickers: unlockedStickers ?? this.unlockedStickers,
        unlockedBackgrounds:
            unlockedBackgrounds ?? this.unlockedBackgrounds,
        unlockedBubbleSkins:
            unlockedBubbleSkins ?? this.unlockedBubbleSkins,
        lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      );

  PlayerProfile applyReward(GameRewardResult reward) {
    final newXp = xp + reward.xp;
    var newLevel = level;
    while (newXp >= newLevel * 100) {
      newLevel++;
    }
    return copyWith(
      coins: coins + reward.coins,
      stars: stars + reward.stars,
      xp: newXp,
      level: newLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'coins': coins,
        'stars': stars,
        'xp': xp,
        'level': level,
        'dailyStreak': dailyStreak,
        'totalPlayTimeMinutes': totalPlayTimeMinutes,
        'avatarId': avatarId,
        'unlockedAvatars': unlockedAvatars,
        'unlockedStickers': unlockedStickers,
        'unlockedBackgrounds': unlockedBackgrounds,
        'unlockedBubbleSkins': unlockedBubbleSkins,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        displayName: json['displayName'] as String? ?? 'Explorer',
        coins: json['coins'] as int? ?? 0,
        stars: json['stars'] as int? ?? 0,
        xp: json['xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        dailyStreak: json['dailyStreak'] as int? ?? 0,
        totalPlayTimeMinutes: json['totalPlayTimeMinutes'] as int? ?? 0,
        avatarId: json['avatarId'] as String? ?? 'default',
        unlockedAvatars: (json['unlockedAvatars'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['default'],
        unlockedStickers: (json['unlockedStickers'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        unlockedBackgrounds: (json['unlockedBackgrounds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['default'],
        unlockedBubbleSkins: (json['unlockedBubbleSkins'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['default'],
        lastPlayedDate: json['lastPlayedDate'] != null
            ? DateTime.parse(json['lastPlayedDate'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        displayName,
        coins,
        stars,
        xp,
        level,
        dailyStreak,
        totalPlayTimeMinutes,
        avatarId,
        unlockedAvatars,
        unlockedStickers,
        unlockedBackgrounds,
        unlockedBubbleSkins,
        lastPlayedDate,
      ];
}

class GameStats extends Equatable {
  const GameStats({
    required this.gameId,
    this.bestScore = 0,
    this.starsEarned = 0,
    this.timesPlayed = 0,
    this.totalCorrect = 0,
    this.totalMistakes = 0,
    this.longestCombo = 0,
    this.lastPlayed,
  });

  final GameId gameId;
  final int bestScore;
  final int starsEarned;
  final int timesPlayed;
  final int totalCorrect;
  final int totalMistakes;
  final int longestCombo;
  final DateTime? lastPlayed;

  GameStats copyWith({
    int? bestScore,
    int? starsEarned,
    int? timesPlayed,
    int? totalCorrect,
    int? totalMistakes,
    int? longestCombo,
    DateTime? lastPlayed,
  }) =>
      GameStats(
        gameId: gameId,
        bestScore: bestScore ?? this.bestScore,
        starsEarned: starsEarned ?? this.starsEarned,
        timesPlayed: timesPlayed ?? this.timesPlayed,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalMistakes: totalMistakes ?? this.totalMistakes,
        longestCombo: longestCombo ?? this.longestCombo,
        lastPlayed: lastPlayed ?? this.lastPlayed,
      );

  Map<String, dynamic> toJson() => {
        'gameId': gameId.id,
        'bestScore': bestScore,
        'starsEarned': starsEarned,
        'timesPlayed': timesPlayed,
        'totalCorrect': totalCorrect,
        'totalMistakes': totalMistakes,
        'longestCombo': longestCombo,
        'lastPlayed': lastPlayed?.toIso8601String(),
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final id = GameId.values.firstWhere(
      (g) => g.id == json['gameId'],
      orElse: () => GameId.bubbleNumberPop,
    );
    return GameStats(
      gameId: id,
      bestScore: json['bestScore'] as int? ?? 0,
      starsEarned: json['starsEarned'] as int? ?? 0,
      timesPlayed: json['timesPlayed'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      longestCombo: json['longestCombo'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        gameId,
        bestScore,
        starsEarned,
        timesPlayed,
        totalCorrect,
        totalMistakes,
        longestCombo,
        lastPlayed,
      ];
}
