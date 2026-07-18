import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';

const _settingsKey = 'picture_bridge_adventure_settings';

final pictureBridgeSettingsProvider = StateNotifierProvider<
    PictureBridgeSettingsNotifier, PictureBridgeSettings>((ref) {
  return PictureBridgeSettingsNotifier(ref.watch(storageServiceProvider));
});

class PictureBridgeSettingsNotifier
    extends StateNotifier<PictureBridgeSettings> {
  PictureBridgeSettingsNotifier(this._storage)
      : super(const PictureBridgeSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = PictureBridgeSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    PictureBridgeSettings Function(PictureBridgeSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
