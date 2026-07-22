import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/models/complete_word_models.dart';

const _settingsKey = 'complete_the_word_adventure_settings';

final completeWordSettingsProvider =
    StateNotifierProvider<CompleteWordSettingsNotifier, CompleteWordSettings>(
        (ref) {
  return CompleteWordSettingsNotifier(ref.watch(storageServiceProvider));
});

class CompleteWordSettingsNotifier extends StateNotifier<CompleteWordSettings> {
  CompleteWordSettingsNotifier(this._storage)
      : super(const CompleteWordSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = CompleteWordSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(CompleteWordSettings Function(CompleteWordSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
