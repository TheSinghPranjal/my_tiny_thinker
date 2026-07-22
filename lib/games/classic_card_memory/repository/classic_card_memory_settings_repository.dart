import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';

const _settingsKey = 'classic_card_memory_settings';

final classicCardMemorySettingsProvider = StateNotifierProvider<
    ClassicCardMemorySettingsNotifier, ClassicCardMemorySettings>((ref) {
  return ClassicCardMemorySettingsNotifier(ref.watch(storageServiceProvider));
});

class ClassicCardMemorySettingsNotifier
    extends StateNotifier<ClassicCardMemorySettings> {
  ClassicCardMemorySettingsNotifier(this._storage)
      : super(const ClassicCardMemorySettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ClassicCardMemorySettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    ClassicCardMemorySettings Function(ClassicCardMemorySettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
