import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

const _settingsKey = 'hungry_duck_pond_adventure_settings';

final hungryDuckSettingsProvider =
    StateNotifierProvider<HungryDuckSettingsNotifier, HungryDuckSettings>((ref) {
  return HungryDuckSettingsNotifier(ref.watch(storageServiceProvider));
});

class HungryDuckSettingsNotifier extends StateNotifier<HungryDuckSettings> {
  HungryDuckSettingsNotifier(this._storage) : super(const HungryDuckSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = HungryDuckSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(HungryDuckSettings Function(HungryDuckSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(HungryDuckDifficulty difficulty) async {
    final next = switch (difficulty) {
      HungryDuckDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          fishCount: 4,
          fishSpeed: PondFishSwimSpeed.verySlow,
          duckSpeed: DuckSwimSpeed.verySlow,
          goldenInterval: 25,
        ),
      HungryDuckDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          fishCount: 5,
          fishSpeed: PondFishSwimSpeed.slow,
          duckSpeed: DuckSwimSpeed.slow,
          goldenInterval: 20,
        ),
      HungryDuckDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          fishCount: 8,
          fishSpeed: PondFishSwimSpeed.normal,
          duckSpeed: DuckSwimSpeed.normal,
          goldenInterval: 15,
        ),
    };
    state = next;
    await _save();
  }
}
