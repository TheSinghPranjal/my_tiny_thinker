import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';

const _settingsKey = 'cloud_pop_garden_settings';

final cloudPopGardenSettingsProvider =
    StateNotifierProvider<CloudPopGardenSettingsNotifier, CloudPopGardenSettings>(
        (ref) {
  return CloudPopGardenSettingsNotifier(ref.watch(storageServiceProvider));
});

class CloudPopGardenSettingsNotifier extends StateNotifier<CloudPopGardenSettings> {
  CloudPopGardenSettingsNotifier(this._storage)
      : super(const CloudPopGardenSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = CloudPopGardenSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    CloudPopGardenSettings Function(CloudPopGardenSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
