import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

const _settingsKey = 'catch_the_butterfly_garden_settings';

final butterflyGardenSettingsProvider =
    StateNotifierProvider<ButterflyGardenSettingsNotifier, ButterflyGardenSettings>(
        (ref) {
  return ButterflyGardenSettingsNotifier(ref.watch(storageServiceProvider));
});

class ButterflyGardenSettingsNotifier extends StateNotifier<ButterflyGardenSettings> {
  ButterflyGardenSettingsNotifier(this._storage)
      : super(const ButterflyGardenSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ButterflyGardenSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(ButterflyGardenSettings Function(ButterflyGardenSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(ButterflyGardenDifficulty difficulty) async {
    final next = switch (difficulty) {
      ButterflyGardenDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          butterflyCount: 3,
          flightSpeed: ButterflyFlightSpeed.verySlow,
          goldenInterval: 25,
          beeSpawnMin: 8.0,
          beeSpawnMax: 12.0,
        ),
      ButterflyGardenDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          butterflyCount: 5,
          flightSpeed: ButterflyFlightSpeed.slow,
          goldenInterval: 20,
          beeSpawnMin: 6.0,
          beeSpawnMax: 10.0,
        ),
      ButterflyGardenDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          butterflyCount: 8,
          flightSpeed: ButterflyFlightSpeed.normal,
          goldenInterval: 15,
          beeSpawnMin: 4.0,
          beeSpawnMax: 7.0,
        ),
    };
    state = next;
    await _save();
  }
}
