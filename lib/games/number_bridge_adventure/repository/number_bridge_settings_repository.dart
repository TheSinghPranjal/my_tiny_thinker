import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

const _settingsKey = 'number_bridge_adventure_settings';

final numberBridgeSettingsProvider = StateNotifierProvider<
    NumberBridgeSettingsNotifier, NumberBridgeSettings>((ref) {
  return NumberBridgeSettingsNotifier(ref.watch(storageServiceProvider));
});

class NumberBridgeSettingsNotifier extends StateNotifier<NumberBridgeSettings> {
  NumberBridgeSettingsNotifier(this._storage)
      : super(const NumberBridgeSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = NumberBridgeSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    NumberBridgeSettings Function(NumberBridgeSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
