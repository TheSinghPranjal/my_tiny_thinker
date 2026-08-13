import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

const _settingsKey = 'learn_to_sort_food_settings';

final learnToSortFoodSettingsProvider =
    StateNotifierProvider<LearnToSortFoodSettingsNotifier, FoodSortSettings>(
        (ref) {
  return LearnToSortFoodSettingsNotifier(ref.watch(storageServiceProvider));
});

class LearnToSortFoodSettingsNotifier extends StateNotifier<FoodSortSettings> {
  LearnToSortFoodSettingsNotifier(this._storage)
      : super(const FoodSortSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json == null) return;

    final rawSeconds = json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds;
    var settings = FoodSortSettings.fromJson(json);
    var migrated = false;

    // Legacy installs defaulted to unlimited time and beginner difficulty,
    // which locked gameplay to apple/banana/burger/pizza only.
    if (rawSeconds <= 0) {
      settings = settings.copyWith(
        sessionSeconds: GameDuration.defaultSeconds,
        maxDifficulty: FoodSortDifficulty.advanced,
      );
      migrated = true;
    }

    state = settings;
    if (migrated) _save();
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(FoodSortSettings Function(FoodSortSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<bool> toggleHealthy(FoodKind kind) async {
    final next = [...state.enabledHealthy];
    if (next.contains(kind)) {
      if (next.length <= 4) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledHealthy: next);
    await _save();
    return true;
  }

  Future<bool> toggleJunk(FoodKind kind) async {
    final next = [...state.enabledJunk];
    if (next.contains(kind)) {
      if (next.length <= 4) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledJunk: next);
    await _save();
    return true;
  }
}
