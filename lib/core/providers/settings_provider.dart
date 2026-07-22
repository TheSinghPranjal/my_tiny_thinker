import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/app_settings.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _load();
  }

  final StorageService _storage;

  Future<void> _load() async {
    final json = _storage.getSettings();
    if (json != null) {
      state = AppSettings.fromJson(json);
    }
  }

  Future<void> _save() async {
    await _storage.saveSettings(state.toJson());
  }

  Future<void> toggleMusic() async {
    state = state.copyWith(musicEnabled: !state.musicEnabled);
    await _save();
  }

  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    await _save();
  }

  Future<void> toggleHaptics() async {
    state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
    await _save();
  }

  Future<void> toggleHighContrast() async {
    state = state.copyWith(highContrast: !state.highContrast);
    await _save();
  }

  Future<void> toggleHints() async {
    state = state.copyWith(hintsEnabled: !state.hintsEnabled);
    await _save();
  }

  Future<void> setDifficulty(String difficulty) async {
    state = state.copyWith(difficulty: difficulty);
    await _save();
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _save();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, PlayerProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProfileNotifier(storage);
});

class ProfileNotifier extends StateNotifier<PlayerProfile> {
  ProfileNotifier(this._storage) : super(const PlayerProfile()) {
    _load();
  }

  final StorageService _storage;

  Future<void> _load() async {
    final json = _storage.getProfile();
    if (json != null) {
      state = PlayerProfile.fromJson(json);
    }
  }

  Future<void> _save() async {
    await _storage.saveProfile(state.toJson());
  }

  Future<void> applyReward(GameRewardResult reward) async {
    state = state.applyReward(reward);
    await _save();
  }

  /// Accumulates minutes shown as Play Time on the Parent Dashboard.
  Future<void> addPlayTimeMinutes(int minutes) async {
    if (minutes <= 0) return;
    state = state.copyWith(
      totalPlayTimeMinutes: state.totalPlayTimeMinutes + minutes,
    );
    await _save();
  }

  Future<void> addCoins(int amount) async {
    state = state.copyWith(coins: state.coins + amount);
    await _save();
  }

  Future<void> applyChestReward({
    required int coins,
    required int xp,
    required int stars,
    required int streakDays,
    String? stickerId,
  }) async {
    final unlocked = List<String>.from(state.unlockedStickers);
    if (stickerId != null && !unlocked.contains(stickerId)) {
      unlocked.add(stickerId);
    }
    final newXp = state.xp + xp;
    var newLevel = state.level;
    while (newXp >= newLevel * 100) {
      newLevel++;
    }
    state = state.copyWith(
      coins: state.coins + coins,
      stars: state.stars + stars,
      xp: newXp,
      level: newLevel,
      dailyStreak: streakDays,
      unlockedStickers: unlocked,
    );
    await _save();
  }

  Future<void> resetProgress() async {
    state = const PlayerProfile();
    await _save();
    await _storage.clearAll();
    state = const PlayerProfile();
    await _save();
  }
}

final dailyRewardProvider =
    StateNotifierProvider<DailyRewardNotifier, DailyRewardState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DailyRewardNotifier(storage);
});

class DailyRewardNotifier extends StateNotifier<DailyRewardState> {
  DailyRewardNotifier(this._storage) : super(const DailyRewardState()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getDailyReward();
    if (json != null) {
      final lastClaim = json['lastClaimDate'] != null
          ? DateTime.parse(json['lastClaimDate'] as String)
          : null;
      var streak = json['streakDays'] as int? ?? 0;
      final today = DateTime.now();
      final canClaim =
          lastClaim == null || !_isSameDay(lastClaim, today);
      // Gracefully reset streak if a calendar day was missed.
      if (lastClaim != null && canClaim) {
        final dayGap = DateTime(today.year, today.month, today.day)
            .difference(
              DateTime(lastClaim.year, lastClaim.month, lastClaim.day),
            )
            .inDays;
        if (dayGap > 1) streak = 0;
      }
      state = DailyRewardState(
        lastClaimDate: lastClaim,
        streakDays: streak,
        canClaim: canClaim,
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<DailyRewardState> claim() async {
    final today = DateTime.now();
    var streak = state.streakDays;
    if (state.lastClaimDate != null) {
      final diff = today.difference(state.lastClaimDate!).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }
    state = DailyRewardState(
      lastClaimDate: today,
      streakDays: streak,
      canClaim: false,
    );
    await _storage.saveDailyReward({
      'lastClaimDate': today.toIso8601String(),
      'streakDays': streak,
    });
    return state;
  }
}
