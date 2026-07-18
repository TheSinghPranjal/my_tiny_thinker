import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

/// Free-tier daily play cap per game.
const kFreeDailyPlayLimit = 5;

class DailyPlayLimitsState extends Equatable {
  const DailyPlayLimitsState({
    this.dayKey = '',
    this.counts = const {},
  });

  final String dayKey;
  final Map<String, int> counts;

  int playsFor(GameId gameId) => counts[gameId.id] ?? 0;

  bool canPlay(GameId gameId, {required bool isPremium}) {
    if (isPremium) return true;
    return playsFor(gameId) < kFreeDailyPlayLimit;
  }

  int remaining(GameId gameId, {required bool isPremium}) {
    if (isPremium) return kFreeDailyPlayLimit; // unused when premium
    return (kFreeDailyPlayLimit - playsFor(gameId)).clamp(0, kFreeDailyPlayLimit);
  }

  DailyPlayLimitsState copyWith({
    String? dayKey,
    Map<String, int>? counts,
  }) =>
      DailyPlayLimitsState(
        dayKey: dayKey ?? this.dayKey,
        counts: counts ?? this.counts,
      );

  Map<String, dynamic> toJson() => {
        'dayKey': dayKey,
        'counts': counts,
      };

  factory DailyPlayLimitsState.fromJson(Map<String, dynamic> json) {
    final raw = json['counts'];
    final map = <String, int>{};
    if (raw is Map) {
      for (final e in raw.entries) {
        map[e.key.toString()] = (e.value as num?)?.toInt() ?? 0;
      }
    }
    return DailyPlayLimitsState(
      dayKey: json['dayKey'] as String? ?? '',
      counts: map,
    );
  }

  @override
  List<Object?> get props => [dayKey, counts];
}

final dailyPlayLimitsProvider =
    StateNotifierProvider<DailyPlayLimitsNotifier, DailyPlayLimitsState>((ref) {
  return DailyPlayLimitsNotifier(ref.watch(storageServiceProvider));
});

class DailyPlayLimitsNotifier extends StateNotifier<DailyPlayLimitsState> {
  DailyPlayLimitsNotifier(this._storage) : super(const DailyPlayLimitsState()) {
    _load();
  }

  static const _key = 'daily_play_limits_v1';

  final StorageService _storage;

  static String _todayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  void _load() {
    final json = _storage.getJson(_key);
    final today = _todayKey();
    if (json == null) {
      state = DailyPlayLimitsState(dayKey: today);
      return;
    }
    final loaded = DailyPlayLimitsState.fromJson(json);
    if (loaded.dayKey != today) {
      state = DailyPlayLimitsState(dayKey: today);
      _save();
    } else {
      state = loaded;
    }
  }

  void _ensureToday() {
    final today = _todayKey();
    if (state.dayKey != today) {
      state = DailyPlayLimitsState(dayKey: today);
    }
  }

  Future<void> _save() async {
    await _storage.saveJson(_key, state.toJson());
  }

  /// Call after a completed play session.
  Future<void> recordPlay(GameId gameId) async {
    _ensureToday();
    final next = Map<String, int>.from(state.counts);
    next[gameId.id] = (next[gameId.id] ?? 0) + 1;
    state = state.copyWith(counts: next);
    await _save();
  }

  Future<void> resetAll() async {
    state = DailyPlayLimitsState(dayKey: _todayKey());
    await _save();
  }
}

/// Convenience: whether [gameId] can be started right now.
bool canStartGame(WidgetRef ref, GameId gameId) {
  final isPremium = ref.read(isPremiumProvider);
  return ref.read(dailyPlayLimitsProvider).canPlay(gameId, isPremium: isPremium);
}

String playsLabel(WidgetRef ref, GameId gameId) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return 'Unlimited';
  final plays = ref.watch(dailyPlayLimitsProvider).playsFor(gameId);
  return "Today's Plays: $plays / $kFreeDailyPlayLimit";
}

/// Lightweight checksum helpers for tamper resistance (local soft check).
String playLimitsChecksum(DailyPlayLimitsState state) {
  final payload = jsonEncode(state.toJson());
  return payload.hashCode.toRadixString(16);
}
