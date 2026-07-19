import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

const _settingsKey = 'pattern_match_settings';

final patternMatchSettingsProvider =
    StateNotifierProvider<PatternMatchSettingsNotifier, PatternMatchSettings>(
        (ref) {
  return PatternMatchSettingsNotifier(ref.watch(storageServiceProvider));
});

class PatternMatchSettingsNotifier extends StateNotifier<PatternMatchSettings> {
  PatternMatchSettingsNotifier(this._storage)
      : super(const PatternMatchSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = PatternMatchSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(PatternMatchSettings Function(PatternMatchSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
