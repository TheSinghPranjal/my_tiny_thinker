import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';

const _settingsKey = 'alphabet_bridge_adventure_settings';

final alphabetBridgeSettingsProvider = StateNotifierProvider<
    AlphabetBridgeSettingsNotifier, AlphabetBridgeSettings>((ref) {
  return AlphabetBridgeSettingsNotifier(ref.watch(storageServiceProvider));
});

class AlphabetBridgeSettingsNotifier
    extends StateNotifier<AlphabetBridgeSettings> {
  AlphabetBridgeSettingsNotifier(this._storage)
      : super(const AlphabetBridgeSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = AlphabetBridgeSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    AlphabetBridgeSettings Function(AlphabetBridgeSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
