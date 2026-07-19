import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/balloon_parade/models/balloon_parade_models.dart';

const _settingsKey = 'balloon_parade_settings';

final balloonParadeSettingsProvider =
    StateNotifierProvider<BalloonParadeSettingsNotifier, BalloonParadeSettings>(
        (ref) {
  return BalloonParadeSettingsNotifier(ref.watch(storageServiceProvider));
});

class BalloonParadeSettingsNotifier
    extends StateNotifier<BalloonParadeSettings> {
  BalloonParadeSettingsNotifier(this._storage)
      : super(const BalloonParadeSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = BalloonParadeSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    BalloonParadeSettings Function(BalloonParadeSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
