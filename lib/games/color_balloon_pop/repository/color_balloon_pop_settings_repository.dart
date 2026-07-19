import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';

const _settingsKey = 'color_balloon_pop_settings';

final colorBalloonPopSettingsProvider = StateNotifierProvider<
    ColorBalloonPopSettingsNotifier, ColorBalloonPopSettings>((ref) {
  return ColorBalloonPopSettingsNotifier(ref.watch(storageServiceProvider));
});

class ColorBalloonPopSettingsNotifier
    extends StateNotifier<ColorBalloonPopSettings> {
  ColorBalloonPopSettingsNotifier(this._storage)
      : super(const ColorBalloonPopSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ColorBalloonPopSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    ColorBalloonPopSettings Function(ColorBalloonPopSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
