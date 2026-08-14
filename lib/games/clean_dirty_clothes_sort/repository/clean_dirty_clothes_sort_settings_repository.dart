import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

const _settingsKey = 'clean_dirty_clothes_sort_settings';

final cleanDirtyClothesSortSettingsProvider =
    StateNotifierProvider<CleanDirtyClothesSortSettingsNotifier, LaundrySortSettings>(
        (ref) {
  return CleanDirtyClothesSortSettingsNotifier(ref.watch(storageServiceProvider));
});

class CleanDirtyClothesSortSettingsNotifier
    extends StateNotifier<LaundrySortSettings> {
  CleanDirtyClothesSortSettingsNotifier(this._storage)
      : super(const LaundrySortSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = LaundrySortSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(LaundrySortSettings Function(LaundrySortSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
