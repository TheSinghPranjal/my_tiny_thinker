import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';

const _settingsKey = 'ocean_fish_settings';

final oceanFishSettingsProvider =
    StateNotifierProvider<OceanFishSettingsNotifier, OceanFishSettings>((ref) {
  return OceanFishSettingsNotifier(ref.watch(storageServiceProvider));
});

class OceanFishSettingsNotifier extends StateNotifier<OceanFishSettings> {
  OceanFishSettingsNotifier(this._storage) : super(const OceanFishSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = OceanFishSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> update(OceanFishSettings settings) async {
    state = settings;
    await _save();
  }

  Future<void> patch(OceanFishSettings Function(OceanFishSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
