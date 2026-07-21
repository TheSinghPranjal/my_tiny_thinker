import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';

const _settingsKey = 'animal_sounds_settings';

final animalSoundsSettingsProvider =
    StateNotifierProvider<AnimalSoundsSettingsNotifier, AnimalSoundsSettings>(
        (ref) {
  return AnimalSoundsSettingsNotifier(ref.watch(storageServiceProvider));
});

class AnimalSoundsSettingsNotifier extends StateNotifier<AnimalSoundsSettings> {
  AnimalSoundsSettingsNotifier(this._storage)
      : super(const AnimalSoundsSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = AnimalSoundsSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    AnimalSoundsSettings Function(AnimalSoundsSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
