import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

final allGameStatsProvider = Provider<Map<GameId, GameStats>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final stats = <GameId, GameStats>{};
  for (final gameId in GameId.values) {
    final json = storage.getGameStats(gameId.id);
    stats[gameId] =
        json != null ? GameStats.fromJson(json) : GameStats(gameId: gameId);
  }
  return stats;
});

GameStats statsForGame(WidgetRef ref, GameId gameId) {
  return ref.watch(allGameStatsProvider)[gameId] ??
      GameStats(gameId: gameId);
}

Future<void> saveGameStatsResult(
  StorageService storage,
  GameId gameId,
  GameStats Function(GameStats current) update,
) async {
  final json = storage.getGameStats(gameId.id);
  var stats = json != null
      ? GameStats.fromJson(json)
      : GameStats(gameId: gameId);
  stats = update(stats);
  await storage.saveGameStats(gameId.id, stats.toJson());
}
