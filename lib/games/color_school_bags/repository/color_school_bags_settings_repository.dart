import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

const _settingsKey = 'color_school_bags_settings';

final colorSchoolBagsSettingsProvider =
    StateNotifierProvider<ColorSchoolBagsSettingsNotifier, SortBagsSettings>(
        (ref) {
  return ColorSchoolBagsSettingsNotifier(ref.watch(storageServiceProvider));
});

class ColorSchoolBagsSettingsNotifier extends StateNotifier<SortBagsSettings> {
  ColorSchoolBagsSettingsNotifier(this._storage)
      : super(const SortBagsSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = SortBagsSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(SortBagsSettings Function(SortBagsSettings) fn) async {
    state = fn(state);
    await _save();
  }

  /// Returns false if selection would drop below 2 colors.
  Future<bool> toggleColor(BagColorKind kind) async {
    final next = [...state.enabledColors];
    if (next.contains(kind)) {
      if (next.length <= 2) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledColors: next);
    await _save();
    return true;
  }
}
