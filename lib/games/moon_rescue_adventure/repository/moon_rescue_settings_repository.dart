import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

const _settingsKey = 'moon_rescue_adventure_settings';

final moonRescueSettingsProvider =
    StateNotifierProvider<MoonRescueSettingsNotifier, MoonRescueSettings>((ref) {
  return MoonRescueSettingsNotifier(ref.watch(storageServiceProvider));
});

class MoonRescueSettingsNotifier extends StateNotifier<MoonRescueSettings> {
  MoonRescueSettingsNotifier(this._storage) : super(const MoonRescueSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = MoonRescueSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(MoonRescueSettings Function(MoonRescueSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
