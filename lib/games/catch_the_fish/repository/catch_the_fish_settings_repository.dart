import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';

const _settingsKey = 'catch_the_fish_settings';

final catchTheFishSettingsProvider =
    StateNotifierProvider<CatchTheFishSettingsNotifier, CatchFishSettings>(
        (ref) {
  return CatchTheFishSettingsNotifier(ref.watch(storageServiceProvider));
});

class CatchTheFishSettingsNotifier extends StateNotifier<CatchFishSettings> {
  CatchTheFishSettingsNotifier(this._storage)
      : super(const CatchFishSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = CatchFishSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(CatchFishSettings Function(CatchFishSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
