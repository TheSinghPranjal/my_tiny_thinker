import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

const _settingsKey = 'catch_the_falling_stars_settings';

final catchTheFallingStarsSettingsProvider = StateNotifierProvider<
    CatchTheFallingStarsSettingsNotifier, CatchTheFallingStarsSettings>((ref) {
  return CatchTheFallingStarsSettingsNotifier(ref.watch(storageServiceProvider));
});

class CatchTheFallingStarsSettingsNotifier
    extends StateNotifier<CatchTheFallingStarsSettings> {
  CatchTheFallingStarsSettingsNotifier(this._storage)
      : super(const CatchTheFallingStarsSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = CatchTheFallingStarsSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    CatchTheFallingStarsSettings Function(CatchTheFallingStarsSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyFallSpeed(StarFallSpeed speed) async {
    state = state.copyWith(fallSpeed: speed);
    await _save();
  }
}
