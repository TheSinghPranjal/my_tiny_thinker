import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/game_config/game_catalog.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

class LearningPathPrefs extends Equatable {
  const LearningPathPrefs({
    this.includedGameIds = const {},
  });

  /// Games opted into Learning Path. Empty means "all catalog games for category".
  final Set<String> includedGameIds;

  bool isIncluded(GameId gameId) {
    if (includedGameIds.isEmpty) {
      // Default: every game with parent controls is included.
      final entry = GameCatalog.entryFor(gameId);
      return entry?.hasParentControls ?? false;
    }
    return includedGameIds.contains(gameId.id);
  }

  LearningPathPrefs copyWith({Set<String>? includedGameIds}) =>
      LearningPathPrefs(includedGameIds: includedGameIds ?? this.includedGameIds);

  Map<String, dynamic> toJson() => {
        'includedGameIds': includedGameIds.toList(),
      };

  factory LearningPathPrefs.fromJson(Map<String, dynamic> json) {
    final raw = json['includedGameIds'];
    final set = <String>{};
    if (raw is List) {
      for (final e in raw) {
        set.add(e.toString());
      }
    }
    return LearningPathPrefs(includedGameIds: set);
  }

  @override
  List<Object?> get props => [includedGameIds];
}

final learningPathPrefsProvider =
    StateNotifierProvider<LearningPathPrefsNotifier, LearningPathPrefs>((ref) {
  return LearningPathPrefsNotifier(ref.watch(storageServiceProvider));
});

class LearningPathPrefsNotifier extends StateNotifier<LearningPathPrefs> {
  LearningPathPrefsNotifier(this._storage) : super(const LearningPathPrefs()) {
    _load();
  }

  static const _key = 'learning_path_prefs_v1';
  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_key);
    if (json != null) {
      state = LearningPathPrefs.fromJson(json);
    } else {
      // Seed defaults: all parent-controlled games included.
      state = LearningPathPrefs(
        includedGameIds: {
          for (final e in GameCatalog.withParentControls) e.gameId.id,
        },
      );
      _save();
    }
  }

  Future<void> _save() async {
    await _storage.saveJson(_key, state.toJson());
  }

  Future<void> setIncluded(GameId gameId, bool included) async {
    final next = Set<String>.from(state.includedGameIds);
    if (included) {
      next.add(gameId.id);
    } else {
      next.remove(gameId.id);
    }
    state = state.copyWith(includedGameIds: next);
    await _save();
  }
}

class LearningPathSession extends Equatable {
  const LearningPathSession({
    this.active = false,
    this.category,
    this.queue = const [],
    this.currentIndex = 0,
    this.totalCoins = 0,
    this.totalXp = 0,
    this.totalStars = 0,
    this.gamesCompleted = 0,
    this.totalPlaySeconds = 0,
    this.achievements = const [],
  });

  final bool active;
  final LearningCategory? category;
  final List<GameId> queue;
  final int currentIndex;
  final int totalCoins;
  final int totalXp;
  final int totalStars;
  final int gamesCompleted;
  final int totalPlaySeconds;
  final List<String> achievements;

  GameId? get currentGame =>
      currentIndex >= 0 && currentIndex < queue.length ? queue[currentIndex] : null;

  bool get hasNext => currentIndex + 1 < queue.length;

  LearningPathSession copyWith({
    bool? active,
    LearningCategory? category,
    List<GameId>? queue,
    int? currentIndex,
    int? totalCoins,
    int? totalXp,
    int? totalStars,
    int? gamesCompleted,
    int? totalPlaySeconds,
    List<String>? achievements,
  }) =>
      LearningPathSession(
        active: active ?? this.active,
        category: category ?? this.category,
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        totalCoins: totalCoins ?? this.totalCoins,
        totalXp: totalXp ?? this.totalXp,
        totalStars: totalStars ?? this.totalStars,
        gamesCompleted: gamesCompleted ?? this.gamesCompleted,
        totalPlaySeconds: totalPlaySeconds ?? this.totalPlaySeconds,
        achievements: achievements ?? this.achievements,
      );

  @override
  List<Object?> get props => [
        active,
        category,
        queue,
        currentIndex,
        totalCoins,
        totalXp,
        totalStars,
        gamesCompleted,
        totalPlaySeconds,
        achievements,
      ];
}

final learningPathSessionProvider =
    StateNotifierProvider<LearningPathSessionNotifier, LearningPathSession>((ref) {
  return LearningPathSessionNotifier(ref);
});

class LearningPathSessionNotifier extends StateNotifier<LearningPathSession> {
  LearningPathSessionNotifier(this._ref) : super(const LearningPathSession());

  final Ref _ref;

  List<GameId> buildQueue(LearningCategory category) {
    final prefs = _ref.read(learningPathPrefsProvider);
    return GameCatalog.forCategory(category)
        .where((e) => prefs.isIncluded(e.gameId))
        .map((e) => e.gameId)
        .toList(growable: false);
  }

  bool start(LearningCategory category) {
    final queue = buildQueue(category);
    if (queue.isEmpty) return false;
    state = LearningPathSession(
      active: true,
      category: category,
      queue: queue,
      currentIndex: 0,
    );
    return true;
  }

  void recordGameResult({
    required GameRewardResult reward,
    int playSeconds = 0,
    List<String> achievements = const [],
  }) {
    if (!state.active) return;
    state = state.copyWith(
      totalCoins: state.totalCoins + reward.coins,
      totalXp: state.totalXp + reward.xp,
      totalStars: state.totalStars + reward.stars,
      gamesCompleted: state.gamesCompleted + 1,
      totalPlaySeconds: state.totalPlaySeconds + playSeconds,
      achievements: [...state.achievements, ...achievements],
    );
  }

  /// Advance to next game. Returns next GameId, or null if journey complete.
  GameId? advance() {
    if (!state.active) return null;
    if (!state.hasNext) {
      return null;
    }
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    return state.currentGame;
  }

  void end() {
    state = const LearningPathSession();
  }

  LearningPathSession takeSummaryAndEnd() {
    final summary = state;
    state = const LearningPathSession();
    return summary;
  }
}
