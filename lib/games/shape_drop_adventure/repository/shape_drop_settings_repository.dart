import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

const _settingsKey = 'shape_drop_adventure_settings';

final shapeDropSettingsProvider =
    StateNotifierProvider<ShapeDropSettingsNotifier, ShapeDropSettings>((ref) {
  return ShapeDropSettingsNotifier(ref.watch(storageServiceProvider));
});

class ShapeDropSettingsNotifier extends StateNotifier<ShapeDropSettings> {
  ShapeDropSettingsNotifier(this._storage) : super(const ShapeDropSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ShapeDropSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(ShapeDropSettings Function(ShapeDropSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
