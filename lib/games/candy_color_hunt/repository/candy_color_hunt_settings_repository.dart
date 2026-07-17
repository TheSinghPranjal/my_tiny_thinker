import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

const _settingsKey = 'candy_color_hunt_settings';

final candyColorHuntSettingsProvider =
    StateNotifierProvider<CandyColorHuntSettingsNotifier, CandyHuntSettings>(
        (ref) {
  return CandyColorHuntSettingsNotifier(ref.watch(storageServiceProvider));
});

class CandyColorHuntSettingsNotifier extends StateNotifier<CandyHuntSettings> {
  CandyColorHuntSettingsNotifier(this._storage)
      : super(const CandyHuntSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = CandyHuntSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(CandyHuntSettings Function(CandyHuntSettings) fn) async {
    state = fn(state);
    await _save();
  }

  /// Returns false if selection would drop below 4 colors.
  Future<bool> toggleColor(CandyColorKind kind) async {
    final next = [...state.enabledColors];
    if (next.contains(kind)) {
      if (next.length <= 4) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledColors: next);
    await _save();
    return true;
  }
}
