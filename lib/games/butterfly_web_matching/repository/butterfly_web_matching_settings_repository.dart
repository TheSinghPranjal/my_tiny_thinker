import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';

const _settingsKey = 'butterfly_web_matching_settings';

final butterflyWebMatchingSettingsProvider = StateNotifierProvider<
    ButterflyWebMatchingSettingsNotifier, ButterflyWebMatchingSettings>((ref) {
  return ButterflyWebMatchingSettingsNotifier(ref.watch(storageServiceProvider));
});

class ButterflyWebMatchingSettingsNotifier
    extends StateNotifier<ButterflyWebMatchingSettings> {
  ButterflyWebMatchingSettingsNotifier(this._storage)
      : super(const ButterflyWebMatchingSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = ButterflyWebMatchingSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(
    ButterflyWebMatchingSettings Function(ButterflyWebMatchingSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
