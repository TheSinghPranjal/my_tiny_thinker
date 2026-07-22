import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';

const _settingsKey = 'recall_picture_adventure_settings';

final recallPictureSettingsProvider = StateNotifierProvider<
    RecallPictureSettingsNotifier, RecallPictureSettings>((ref) {
  return RecallPictureSettingsNotifier(ref.watch(storageServiceProvider));
});

class RecallPictureSettingsNotifier
    extends StateNotifier<RecallPictureSettings> {
  RecallPictureSettingsNotifier(this._storage)
      : super(const RecallPictureSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = RecallPictureSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    RecallPictureSettings Function(RecallPictureSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
