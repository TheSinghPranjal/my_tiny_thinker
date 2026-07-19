import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

const _settingsKey = 'odd_one_out_settings';

final oddOneOutSettingsProvider =
    StateNotifierProvider<OddOneOutSettingsNotifier, OddOneOutSettings>((ref) {
  return OddOneOutSettingsNotifier(ref.watch(storageServiceProvider));
});

class OddOneOutSettingsNotifier extends StateNotifier<OddOneOutSettings> {
  OddOneOutSettingsNotifier(this._storage) : super(const OddOneOutSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = OddOneOutSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(OddOneOutSettings Function(OddOneOutSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
