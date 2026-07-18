import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

/// Global Premium entitlement. Defaults to `true` for development.
final isPremiumProvider =
    StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier(ref.watch(storageServiceProvider));
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier(this._storage) : super(true) {
    _load();
  }

  static const _key = 'is_premium';

  final StorageService _storage;

  void _load() {
    final raw = _storage.getString(_key);
    if (raw == null) {
      state = true;
      return;
    }
    state = raw == 'true';
  }

  Future<void> setPremium(bool value) async {
    if (state == value) return;
    state = value;
    await _storage.saveString(_key, value.toString());
  }

  Future<void> toggle() => setPremium(!state);
}
