import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

const _settingsKey = 'hungry_monkey_banana_adventure_settings';

final hungryMonkeySettingsProvider =
    StateNotifierProvider<HungryMonkeySettingsNotifier, HungryMonkeySettings>((ref) {
  return HungryMonkeySettingsNotifier(ref.watch(storageServiceProvider));
});

class HungryMonkeySettingsNotifier extends StateNotifier<HungryMonkeySettings> {
  HungryMonkeySettingsNotifier(this._storage) : super(const HungryMonkeySettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = HungryMonkeySettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(HungryMonkeySettings Function(HungryMonkeySettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(HungryMonkeyDifficulty difficulty) async {
    final next = switch (difficulty) {
      HungryMonkeyDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          bananaCount: 5,
          maxApples: 2,
          appleSpawnMin: 5.0,
          appleSpawnMax: 8.0,
        ),
      HungryMonkeyDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          bananaCount: 7,
          maxApples: 3,
          appleSpawnMin: 4.0,
          appleSpawnMax: 7.0,
        ),
      HungryMonkeyDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          bananaCount: 9,
          maxApples: 4,
          appleSpawnMin: 3.0,
          appleSpawnMax: 5.0,
        ),
    };
    state = next;
    await _save();
  }
}
