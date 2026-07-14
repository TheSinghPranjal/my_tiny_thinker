import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

const _settingsKey = 'flower_garden_settings';

final flowerGardenSettingsProvider =
    StateNotifierProvider<FlowerGardenSettingsNotifier, FlowerGardenSettings>(
        (ref) {
  return FlowerGardenSettingsNotifier(ref.watch(storageServiceProvider));
});

class FlowerGardenSettingsNotifier extends StateNotifier<FlowerGardenSettings> {
  FlowerGardenSettingsNotifier(this._storage)
      : super(const FlowerGardenSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = FlowerGardenSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(FlowerGardenSettings Function(FlowerGardenSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
