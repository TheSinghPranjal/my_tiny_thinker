import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';

const _settingsKey = 'frog_pond_adventure_settings';

final frogPondSettingsProvider =
    StateNotifierProvider<FrogPondSettingsNotifier, FrogPondSettings>((ref) {
  return FrogPondSettingsNotifier(ref.watch(storageServiceProvider));
});

class FrogPondSettingsNotifier extends StateNotifier<FrogPondSettings> {
  FrogPondSettingsNotifier(this._storage) : super(const FrogPondSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = FrogPondSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(FrogPondSettings Function(FrogPondSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(FrogPondDifficulty difficulty) async {
    final next = switch (difficulty) {
      FrogPondDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 2,
          frogMoveSpeed: FrogMoveSpeed.slow,
          replacementDelayMin: 2.5,
          replacementDelayMax: 5.0,
        ),
      FrogPondDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 4,
          frogMoveSpeed: FrogMoveSpeed.slow,
          replacementDelayMin: 2.0,
          replacementDelayMax: 4.5,
        ),
      FrogPondDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 6,
          frogMoveSpeed: FrogMoveSpeed.normal,
          replacementDelayMin: 1.5,
          replacementDelayMax: 3.5,
        ),
    };
    state = next;
    await _save();
  }
}
