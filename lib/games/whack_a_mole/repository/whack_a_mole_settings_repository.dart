import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

const _settingsKey = 'whack_a_mole_settings';

final whackAMoleSettingsProvider =
    StateNotifierProvider<WhackAMoleSettingsNotifier, WhackAMoleSettings>((ref) {
  return WhackAMoleSettingsNotifier(ref.watch(storageServiceProvider));
});

class WhackAMoleSettingsNotifier extends StateNotifier<WhackAMoleSettings> {
  WhackAMoleSettingsNotifier(this._storage) : super(const WhackAMoleSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = WhackAMoleSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(WhackAMoleSettings Function(WhackAMoleSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyVisibility(MoleVisibility visibility) async {
    state = state.copyWith(visibility: visibility);
    await _save();
  }

  Future<void> applyAppearSpeed(MoleAppearSpeed speed) async {
    state = state.copyWith(appearSpeed: speed);
    await _save();
  }
}
