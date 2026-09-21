import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/kid_profiles.dart';
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
  ProfileNotifier(this._storage) : super(_defaultFor(KidProfilePresets.all.first)) {
    _load();
  }

  static const _kidProfilesKey = 'kid_profiles';

  final StorageService _storage;

  /// All five kid profiles by id. The active one lives in [state] too.
  final Map<String, PlayerProfile> _profiles = {};
  String _activeId = KidProfilePresets.defaultId;

  String get activeProfileId => _activeId;

  /// The five profiles in preset order (the active one is always current).
  List<PlayerProfile> get allProfiles => [
        for (final p in KidProfilePresets.all)
          p.id == _activeId ? state : (_profiles[p.id] ?? _defaultFor(p)),
      ];

  static PlayerProfile _defaultFor(KidProfilePreset preset) => PlayerProfile(
        displayName: preset.defaultName,
        avatarId: preset.id,
        unlockedAvatars: [preset.id],
      );

  Future<void> _load() async {
    final saved = _storage.getJson(_kidProfilesKey);
    if (saved != null) {
      final map = (saved['profiles'] as Map<String, dynamic>?) ?? const {};
      map.forEach((id, json) {
        _profiles[id] = PlayerProfile.fromJson(json as Map<String, dynamic>)
            .copyWith(avatarId: id);
      });
      final active = saved['active'] as String?;
      if (active != null && KidProfilePresets.all.any((p) => p.id == active)) {
        _activeId = active;
      }
    } else {
      // First run with profiles: existing progress becomes the Bunny profile.
      final legacy = _storage.getProfile();
      if (legacy != null) {
        final old = PlayerProfile.fromJson(legacy);
        _profiles[KidProfilePresets.defaultId] = old.copyWith(
          avatarId: KidProfilePresets.defaultId,
          displayName: old.displayName == 'Explorer'
              ? KidProfilePresets.all.first.defaultName
              : old.displayName,
        );
      }
    }
    for (final preset in KidProfilePresets.all) {
      _profiles.putIfAbsent(preset.id, () => _defaultFor(preset));
    }
    state = _profiles[_activeId]!;
  }

  Future<void> _save() async {
    _profiles[_activeId] = state;
    await _storage.saveProfile(state.toJson());
    await _storage.saveJson(_kidProfilesKey, {
      'active': _activeId,
      'profiles': {for (final e in _profiles.entries) e.key: e.value.toJson()},
    });
  }

  /// Switches to another kid profile, keeping each one's own progress.
  Future<void> switchProfile(String id) async {
    if (id == _activeId || !KidProfilePresets.all.any((p) => p.id == id)) {
      return;
    }
    _profiles[_activeId] = state;
    _activeId = id;
    state = _profiles[id] ?? _defaultFor(KidProfilePresets.byId(id));
    await _save();
  }

  /// Changes the active profile's display name.
  Future<void> renameActive(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(displayName: trimmed);
    await _save();
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
    await _storage.clearAll();
    _profiles.clear();
    _activeId = KidProfilePresets.defaultId;
    for (final preset in KidProfilePresets.all) {
      _profiles[preset.id] = _defaultFor(preset);
    }
    state = _profiles[_activeId]!;
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
