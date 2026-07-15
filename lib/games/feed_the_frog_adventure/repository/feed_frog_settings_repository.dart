import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';

const _settingsKey = 'feed_the_frog_adventure_settings';

final feedFrogSettingsProvider =
    StateNotifierProvider<FeedFrogSettingsNotifier, FeedFrogSettings>((ref) {
  return FeedFrogSettingsNotifier(ref.watch(storageServiceProvider));
});

class FeedFrogSettingsNotifier extends StateNotifier<FeedFrogSettings> {
  FeedFrogSettingsNotifier(this._storage) : super(const FeedFrogSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_settingsKey);
    if (json != null) state = FeedFrogSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_settingsKey, state.toJson());
  }

  Future<void> patch(FeedFrogSettings Function(FeedFrogSettings) fn) async {
    state = fn(state);
    await _save();
  }
}
