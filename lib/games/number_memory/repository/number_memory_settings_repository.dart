import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';

const _settingsKey = 'number_memory_settings';

final numberMemorySettingsProvider =
    StateNotifierProvider<NumberMemorySettingsNotifier, NumberMemorySettings>(
        (ref) {
  return NumberMemorySettingsNotifier(ref.watch(storageServiceProvider));
});

class NumberMemorySettingsNotifier
    extends StateNotifier<NumberMemorySettings> {
  NumberMemorySettingsNotifier(this._storage)
      : super(const NumberMemorySettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = NumberMemorySettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    NumberMemorySettings Function(NumberMemorySettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
