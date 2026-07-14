import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';

const _settingsKey = 'alphabet_quiz_settings';

final alphabetQuizSettingsProvider =
    StateNotifierProvider<AlphabetQuizSettingsNotifier, AlphabetQuizSettings>(
        (ref) {
  return AlphabetQuizSettingsNotifier(ref.watch(storageServiceProvider));
});

class AlphabetQuizSettingsNotifier extends StateNotifier<AlphabetQuizSettings> {
  AlphabetQuizSettingsNotifier(this._storage)
      : super(const AlphabetQuizSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = AlphabetQuizSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(AlphabetQuizSettings Function(AlphabetQuizSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
