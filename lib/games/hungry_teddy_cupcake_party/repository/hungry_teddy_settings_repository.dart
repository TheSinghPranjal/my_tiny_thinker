import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

const _settingsKey = 'hungry_teddy_cupcake_party_settings';

final hungryTeddySettingsProvider =
    StateNotifierProvider<HungryTeddySettingsNotifier, HungryTeddySettings>((ref) {
  return HungryTeddySettingsNotifier(ref.watch(storageServiceProvider));
});

class HungryTeddySettingsNotifier extends StateNotifier<HungryTeddySettings> {
  HungryTeddySettingsNotifier(this._storage) : super(const HungryTeddySettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = HungryTeddySettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(HungryTeddySettings Function(HungryTeddySettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(HungryTeddyDifficulty difficulty) async {
    final next = switch (difficulty) {
      HungryTeddyDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          cupcakeCount: 4,
          dragSensitivity: TeddyDragSensitivity.veryLow,
          goldenInterval: 25,
        ),
      HungryTeddyDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          cupcakeCount: 6,
          dragSensitivity: TeddyDragSensitivity.normal,
          goldenInterval: 20,
        ),
      HungryTeddyDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          cupcakeCount: 8,
          dragSensitivity: TeddyDragSensitivity.low,
          goldenInterval: 15,
        ),
    };
    state = next;
    await _save();
  }
}
