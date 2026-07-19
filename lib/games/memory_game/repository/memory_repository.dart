import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(ref.watch(storageServiceProvider));
});

class MemoryRepository {
  MemoryRepository(this._storage);

  final StorageService _storage;
  static const _hubStatsKey = 'memory_hub_statistics';

  MemoryHubStatistics loadStatistics() {
    final json = _storage.getJson(_hubStatsKey);
    if (json != null) return MemoryHubStatistics.fromJson(json);
    return _defaultStatistics();
  }

  MemoryHubStatistics _defaultStatistics() {
    final stats = <String, MiniGameStats>{};
    for (final type in MemoryMiniGameType.values) {
      stats[type.id] = MiniGameStats(
        gameType: type,
        isUnlocked: type.unlockCost == 0,
      );
    }
    return MemoryHubStatistics(miniGameStats: stats);
  }

  Future<void> saveStatistics(MemoryHubStatistics stats) async {
    await _storage.saveJson(_hubStatsKey, stats.toJson());
  }

  Future<void> recordGameResult({
    required MemoryGameResult result,
    required MemorySessionState session,
  }) async {
    var stats = loadStatistics();
    final type = result.gameType;
    final existing = stats.statsFor(type);

    final updated = existing.copyWith(
      timesPlayed: existing.timesPlayed + 1,
      bestScore: result.score > existing.bestScore ? result.score : existing.bestScore,
      starsEarned: existing.starsEarned + result.stars,
      perfectGames: existing.perfectGames + (result.isPerfect ? 1 : 0),
      highestCombo: result.longestCombo > existing.highestCombo
          ? result.longestCombo
          : existing.highestCombo,
      totalCorrect: existing.totalCorrect + session.round,
      totalMistakes: existing.totalMistakes + session.mistakes,
      fastestCompletion: existing.fastestCompletion == 0 ||
              result.elapsedSeconds < existing.fastestCompletion
          ? result.elapsedSeconds
          : existing.fastestCompletion,
      lastPlayed: DateTime.now(),
    );

    final miniStats = Map<String, MiniGameStats>.from(stats.miniGameStats);
    miniStats[type.id] = updated;

    stats = stats.copyWith(
      gamesPlayed: stats.gamesPlayed + 1,
      perfectGames: stats.perfectGames + (result.isPerfect ? 1 : 0),
      highestCombo: result.longestCombo > stats.highestCombo
          ? result.longestCombo
          : stats.highestCombo,
      totalStars: stats.totalStars + result.stars,
      totalCoins: stats.totalCoins + result.coins,
      favoriteGame: type,
      miniGameStats: miniStats,
    );

    await saveStatistics(stats);
  }

  Future<bool> unlockGame(MemoryMiniGameType type, int playerCoins) async {
    if (type.unlockCost == 0) return true;
    var stats = loadStatistics();
    final existing = stats.statsFor(type);
    if (existing.isUnlocked) return true;
    if (playerCoins < type.unlockCost) return false;

    final miniStats = Map<String, MiniGameStats>.from(stats.miniGameStats);
    miniStats[type.id] = existing.copyWith(isUnlocked: true);
    await saveStatistics(stats.copyWith(miniGameStats: miniStats));
    return true;
  }

  Future<bool> unlockTheme(String themeId, int cost, int playerCoins) async {
    if (playerCoins < cost) return false;
    var stats = loadStatistics();
    if (stats.unlockedThemes.contains(themeId)) return true;
    await saveStatistics(
      stats.copyWith(unlockedThemes: [...stats.unlockedThemes, themeId]),
    );
    return true;
  }

  Future<void> updateAdaptiveLevel(
    MemoryMiniGameType type,
    int level,
  ) async {
    var stats = loadStatistics();
    final existing = stats.statsFor(type);
    final miniStats = Map<String, MiniGameStats>.from(stats.miniGameStats);
    miniStats[type.id] = existing.copyWith(currentAdaptiveLevel: level);
    await saveStatistics(stats.copyWith(miniGameStats: miniStats));
  }
}
