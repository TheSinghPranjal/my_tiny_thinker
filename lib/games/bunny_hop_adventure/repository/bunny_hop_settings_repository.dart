import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

const _settingsKey = 'bunny_hop_adventure_settings';

final bunnyHopSettingsProvider =
    StateNotifierProvider<BunnyHopSettingsNotifier, BunnyHopSettings>((ref) {
  return BunnyHopSettingsNotifier(ref.watch(storageServiceProvider));
});

class BunnyHopSettingsNotifier extends StateNotifier<BunnyHopSettings> {
  BunnyHopSettingsNotifier(this._storage) : super(const BunnyHopSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = BunnyHopSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(BunnyHopSettings Function(BunnyHopSettings) fn) async {
    state = fn(state);
    await _save();
  }

  Future<void> applyDifficulty(BunnyHopDifficulty difficulty) async {
    final next = switch (difficulty) {
      BunnyHopDifficulty.easy => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 5,
          hopSpeed: BunnyHopSpeed.slow,
          crackedSinkDelay: 7.0,
        ),
      BunnyHopDifficulty.normal => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 7,
          hopSpeed: BunnyHopSpeed.normal,
          crackedSinkDelay: 5.0,
        ),
      BunnyHopDifficulty.playful => state.copyWith(
          difficulty: difficulty,
          lilyPadCount: 12,
          hopSpeed: BunnyHopSpeed.normal,
          crackedSinkDelay: 4.0,
        ),
    };
    state = next;
    await _save();
  }
}
