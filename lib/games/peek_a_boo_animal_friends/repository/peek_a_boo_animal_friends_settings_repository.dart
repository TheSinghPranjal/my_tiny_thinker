import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';

const _settingsKey = 'peek_a_boo_animal_friends_settings';

final peekABooSettingsProvider =
    StateNotifierProvider<PeekABooSettingsNotifier, PeekABooSettings>((ref) {
  return PeekABooSettingsNotifier(ref.watch(storageServiceProvider));
});

class PeekABooSettingsNotifier extends StateNotifier<PeekABooSettings> {
  PeekABooSettingsNotifier(this._storage) : super(const PeekABooSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = PeekABooSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(PeekABooSettings Function(PeekABooSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyPreset(PeekDifficultyPreset preset) async {
    final next = switch (preset) {
      PeekDifficultyPreset.easy => state.copyWith(
          difficultyPreset: preset,
          bushCount: 2,
          hiddenAnimalCount: 1,
          shakeFrequency: BushShakeFrequency.slow,
          animationSpeed: PeekAnimationSpeed.slow,
        ),
      PeekDifficultyPreset.normal => state.copyWith(
          difficultyPreset: preset,
          bushCount: 4,
          hiddenAnimalCount: 1,
          shakeFrequency: BushShakeFrequency.normal,
          animationSpeed: PeekAnimationSpeed.normal,
        ),
      PeekDifficultyPreset.challenge => state.copyWith(
          difficultyPreset: preset,
          bushCount: 6,
          hiddenAnimalCount: 2,
          shakeFrequency: BushShakeFrequency.fast,
          animationSpeed: PeekAnimationSpeed.fast,
        ),
    };
    state = next;
    await _save();
  }
}
