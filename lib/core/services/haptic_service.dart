import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';

enum HapticType { light, medium, heavy, selection, success, error }

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService(ref);
});

class HapticService {
  HapticService(this._ref);

  final Ref _ref;

  bool get _enabled => _ref.read(settingsProvider).hapticsEnabled;

  Future<void> trigger(HapticType type) async {
    if (!_enabled) return;
    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
      case HapticType.selection:
        await HapticFeedback.selectionClick();
      case HapticType.success:
        await HapticFeedback.mediumImpact();
      case HapticType.error:
        await HapticFeedback.heavyImpact();
    }
  }
}
