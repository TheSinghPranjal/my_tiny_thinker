import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

/// Congratulatory headlines for the universal celebration dialog.
const kCelebrationMessages = [
  'Hurrah!',
  'Great Job!',
  'Fantastic Learning!',
  'You Did It!',
  'Super Star!',
  'Amazing Work!',
];

class SessionRewardSummary extends Equatable {
  const SessionRewardSummary({
    required this.gameId,
    required this.message,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.achievementPoints,
    required this.bonusCoins,
    required this.totalScore,
    this.unlockedAchievements = const [],
    this.isPerfect = false,
    this.isNewBest = false,
  });

  final GameId gameId;
  final String message;
  final int coins;
  final int xp;
  final int stars;
  final int achievementPoints;
  final int bonusCoins;
  final int totalScore;
  final List<String> unlockedAchievements;
  final bool isPerfect;
  final bool isNewBest;

  GameRewardResult get asGameReward => GameRewardResult(
        coins: coins + bonusCoins,
        stars: stars,
        xp: xp,
        unlockedItems: unlockedAchievements,
        isPerfect: isPerfect,
        isNewBest: isNewBest,
      );

  @override
  List<Object?> get props => [
        gameId,
        message,
        coins,
        xp,
        stars,
        achievementPoints,
        bonusCoins,
        totalScore,
        unlockedAchievements,
        isPerfect,
        isNewBest,
      ];
}

class ChestReward extends Equatable {
  const ChestReward({
    required this.coins,
    required this.xp,
    required this.stars,
    this.stickerId,
    this.bonusLabel,
  });

  final int coins;
  final int xp;
  final int stars;
  final String? stickerId;
  final String? bonusLabel;

  @override
  List<Object?> get props => [coins, xp, stars, stickerId, bonusLabel];
}

/// Centralized reward engine used by every game.
class RewardEngine {
  RewardEngine(this._ref);

  final Ref _ref;
  final _rng = Random();

  String pickCelebrationMessage() =>
      kCelebrationMessages[_rng.nextInt(kCelebrationMessages.length)];

  /// Build a normalized reward from raw gameplay stats.
  SessionRewardSummary buildSessionReward({
    required GameId gameId,
    required int score,
    required int correctActions,
    int mistakes = 0,
    int combo = 0,
    double rewardMultiplier = 1.0,
    bool isPerfect = false,
    List<String> unlockedAchievements = const [],
  }) {
    final baseCoins = (8 + correctActions * 2 + (combo ~/ 3)).clamp(5, 120);
    final baseXp = (12 + correctActions * 3 + score ~/ 10).clamp(8, 200);
    final baseStars = isPerfect
        ? 3
        : correctActions >= 10
            ? 2
            : 1;
    final bonus = isPerfect ? (baseCoins * 0.35).round() : (combo >= 5 ? 5 : 0);
    final achievementPoints =
        (correctActions + (isPerfect ? 10 : 0) + unlockedAchievements.length * 15)
            .clamp(0, 500);

    final mult = rewardMultiplier.clamp(0.5, 3.0);
    final coins = (baseCoins * mult).round();
    final xp = (baseXp * mult).round();
    final stars = baseStars;
    final bonusCoins = (bonus * mult).round();

    return SessionRewardSummary(
      gameId: gameId,
      message: pickCelebrationMessage(),
      coins: coins,
      xp: xp,
      stars: stars,
      achievementPoints: achievementPoints,
      bonusCoins: bonusCoins,
      totalScore: score,
      unlockedAchievements: unlockedAchievements,
      isPerfect: isPerfect,
      isNewBest: false,
    );
  }

  /// Persist rewards, update stats, and record a daily play.
  Future<SessionRewardSummary> commitSession({
    required SessionRewardSummary summary,
    required GameStats Function(GameStats previous) updateStats,
  }) async {
    final storage = _ref.read(storageServiceProvider);
    final previousJson = storage.getGameStats(summary.gameId.id);
    final previous = previousJson != null
        ? GameStats.fromJson(previousJson)
        : GameStats(gameId: summary.gameId);
    final next = updateStats(previous);
    final isNewBest = next.bestScore > previous.bestScore;
    await saveGameStatsResult(storage, summary.gameId, (_) => next);

    final finalSummary = SessionRewardSummary(
      gameId: summary.gameId,
      message: summary.message,
      coins: summary.coins,
      xp: summary.xp,
      stars: summary.stars,
      achievementPoints: summary.achievementPoints,
      bonusCoins: summary.bonusCoins,
      totalScore: summary.totalScore,
      unlockedAchievements: summary.unlockedAchievements,
      isPerfect: summary.isPerfect,
      isNewBest: isNewBest || summary.isNewBest,
    );

    await _ref.read(profileProvider.notifier).applyReward(finalSummary.asGameReward);
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(summary.gameId);
    return finalSummary;
  }

  /// Apply an existing [GameRewardResult] (for games that already compute rewards).
  Future<SessionRewardSummary> commitGameRewardResult({
    required GameId gameId,
    required GameRewardResult result,
    int totalScore = 0,
  }) async {
    final summary = SessionRewardSummary(
      gameId: gameId,
      message: pickCelebrationMessage(),
      coins: result.coins,
      xp: result.xp,
      stars: result.stars,
      achievementPoints: result.isPerfect ? 25 : 10,
      bonusCoins: result.isPerfect ? 8 : 0,
      totalScore: totalScore,
      unlockedAchievements: result.unlockedItems,
      isPerfect: result.isPerfect,
      isNewBest: result.isNewBest,
    );
    await _ref.read(profileProvider.notifier).applyReward(summary.asGameReward);
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(gameId);
    return summary;
  }

  ChestReward rollDailyChest({required int streakDays}) {
    final coins = 10 + streakDays * 2 + _rng.nextInt(12);
    final xp = 15 + streakDays + _rng.nextInt(20);
    final stars = 1 + _rng.nextInt(3);
    final stickers = ['sticker_star', 'sticker_rainbow', 'sticker_rocket', 'sticker_heart'];
    final sticker = _rng.nextDouble() < 0.45
        ? stickers[_rng.nextInt(stickers.length)]
        : null;
    final bonus = _rng.nextDouble() < 0.25 ? 'Bonus Sparkles!' : null;
    return ChestReward(
      coins: coins,
      xp: xp,
      stars: stars,
      stickerId: sticker,
      bonusLabel: bonus,
    );
  }
}

final rewardEngineProvider = Provider<RewardEngine>((ref) => RewardEngine(ref));
