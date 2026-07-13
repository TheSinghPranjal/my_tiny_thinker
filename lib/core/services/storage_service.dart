import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden');
});

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _profileKey = 'player_profile';
  static const _settingsKey = 'app_settings';
  static const _gameStatsPrefix = 'game_stats_';
  static const _dailyRewardKey = 'daily_reward';

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    await _prefs.setString(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveProfile(Map<String, dynamic> json) =>
      saveJson(_profileKey, json);

  Map<String, dynamic>? getProfile() => getJson(_profileKey);

  Future<void> saveSettings(Map<String, dynamic> json) =>
      saveJson(_settingsKey, json);

  Map<String, dynamic>? getSettings() => getJson(_settingsKey);

  Future<void> saveGameStats(String gameId, Map<String, dynamic> json) =>
      saveJson('$_gameStatsPrefix$gameId', json);

  Map<String, dynamic>? getGameStats(String gameId) =>
      getJson('$_gameStatsPrefix$gameId');

  Future<void> saveDailyReward(Map<String, dynamic> json) =>
      saveJson(_dailyRewardKey, json);

  Map<String, dynamic>? getDailyReward() => getJson(_dailyRewardKey);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
