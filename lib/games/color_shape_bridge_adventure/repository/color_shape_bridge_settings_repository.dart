import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';

const _settingsKey = 'color_shape_bridge_settings';

final colorShapeBridgeSettingsProvider = StateNotifierProvider<
    ColorShapeBridgeSettingsNotifier, ColorShapeBridgeSettings>((ref) {
  return ColorShapeBridgeSettingsNotifier(ref.watch(storageServiceProvider));
});

class ColorShapeBridgeSettingsNotifier
    extends StateNotifier<ColorShapeBridgeSettings> {
  ColorShapeBridgeSettingsNotifier(this._storage)
      : super(const ColorShapeBridgeSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ColorShapeBridgeSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    ColorShapeBridgeSettings Function(ColorShapeBridgeSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }

  /// Returns false if selection would drop below 2 colors.
  Future<bool> toggleColor(BridgeColorKind kind) async {
    final next = [...state.enabledColors];
    if (next.contains(kind)) {
      if (next.length <= 2) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledColors: next);
    await _save();
    return true;
  }

  /// Returns false if selection would drop below 2 shapes.
  Future<bool> toggleShape(BridgeShapeKind kind) async {
    final next = [...state.enabledShapes];
    if (next.contains(kind)) {
      if (next.length <= 2) return false;
      next.remove(kind);
    } else {
      next.add(kind);
    }
    state = state.copyWith(enabledShapes: next);
    await _save();
    return true;
  }
}
