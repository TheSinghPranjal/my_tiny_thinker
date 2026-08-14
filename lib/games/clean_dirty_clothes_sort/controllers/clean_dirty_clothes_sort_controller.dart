import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/logic/clean_dirty_clothes_sort_logic.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

final cleanDirtyClothesSortControllerProvider =
    StateNotifierProvider<CleanDirtyClothesSortController, LaundrySortState>(
        (ref) {
  return CleanDirtyClothesSortController(ref);
});

class CleanDirtyClothesSortController extends StateNotifier<LaundrySortState> {
  CleanDirtyClothesSortController(this._ref) : super(const LaundrySortState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _wrongTimer;
  Timer? _spawnTimer;

  void startGame(LaundrySortSettings settings) {
    _cancelTimers();
    final count = settings.visibleItemCount;
    state = LaundrySortState(
      phase: LaundrySortPhase.playing,
      settings: settings,
      items: CleanDirtyClothesSortLogic.spawnItems(count: count),
      targets: CleanDirtyClothesSortLogic.defaultTargets(
        leftHanded: settings.leftHandedLayout,
      ),
      remainingSeconds:
          settings.unlimitedTime ? settings.sessionSeconds : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != LaundrySortPhase.playing &&
        state.phase != LaundrySortPhase.celebrating) {
      return;
    }
    final anim = CleanDirtyClothesSortLogic.tickAnimations(
      state.items,
      state.targets,
      delta,
      floating: state.settings.floatingAnimation,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      items: anim.items,
      targets: anim.targets,
      roomGlow: (state.roomGlow + delta * 0.15).clamp(0, 1),
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != LaundrySortPhase.playing &&
          state.phase != LaundrySortPhase.celebrating) {
        return;
      }
      if (state.settings.unlimitedTime) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _requestEnd();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEnd() {
    if (state.pendingEnd) return;
    if (state.phase == LaundrySortPhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void setHoverTarget(String? targetId) {
    if (state.hoverTargetId == targetId) return;
    state = state.copyWith(
      hoverTargetId: targetId,
      clearHover: targetId == null,
    );
  }

  bool tryDrop({required String itemId, required String targetId}) {
    if (state.phase != LaundrySortPhase.playing &&
        state.phase != LaundrySortPhase.celebrating) {
      return false;
    }

    final itemIdx = state.items.indexWhere((i) => i.id == itemId);
    if (itemIdx < 0) return false;
    final item = state.items[itemIdx];
    if (item.hidden) return false;

    final targetIdx = state.targets.indexWhere((t) => t.id == targetId);
    if (targetIdx < 0) return false;

    final target = state.targets[targetIdx];
    final attempts = state.attempts + 1;

    if (item.cleanliness != target.accepts) {
      _handleWrongDrop(item: item, targetId: targetId, attempts: attempts);
      return false;
    }

    _handleCorrectDrop(
      item: item,
      itemIdx: itemIdx,
      target: target,
      targetIdx: targetIdx,
      attempts: attempts,
    );
    return true;
  }

  void _handleWrongDrop({
    required ClothesItem item,
    required String targetId,
    required int attempts,
  }) {
    state = state.copyWith(
      items: [
        for (final i in state.items)
          i.id == item.id ? i.copyWith(shake: true) : i,
      ],
      targets: [
        for (final t in state.targets)
          t.copyWith(
            wobble: t.id == targetId,
            glow: t.accepts == item.cleanliness,
          ),
      ],
      attempts: attempts,
      streak: 0,
      clearHover: true,
    );

    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      state = state.copyWith(
        items: [
          for (final i in state.items)
            i.id == item.id ? i.copyWith(shake: false) : i,
        ],
        targets: [
          for (final t in state.targets)
            t.copyWith(wobble: false, glow: false),
        ],
      );
    });
  }

  void _handleCorrectDrop({
    required ClothesItem item,
    required int itemIdx,
    required LaundryTarget target,
    required int targetIdx,
    required int attempts,
  }) {
    final streak = state.streak + 1;
    final reward = CleanDirtyClothesSortLogic.matchReward(state.settings, streak);
    final milestone = (state.correctSorts + 1) % 5 == 0;
    final isDirty = item.cleanliness == ClothesCleanliness.dirty;

    final items = [...state.items];
    items[itemIdx] = item.copyWith(hidden: true);

    final targets = [...state.targets];
    targets[targetIdx] = target.copyWith(
      happy: true,
      glow: true,
      washing: isDirty,
      wobble: false,
    );

    state = state.copyWith(
      items: items,
      targets: targets,
      pendingSpawns: state.pendingSpawns + 1,
      round: state.round + 1,
      attempts: attempts,
      correctSorts: state.correctSorts + 1,
      cleanStored: state.cleanStored + (item.isClean ? 1 : 0),
      dirtyWashed: state.dirtyWashed + (isDirty ? 1 : 0),
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: LaundrySortPhase.celebrating,
      feedbackMessage: state.settings.narrationEnabled
          ? CleanDirtyClothesSortLogic.encouragement()
          : null,
      lastRewardText: '+${reward.stars} Stars',
      showSparkles: state.settings.celebrationsEnabled,
      showMilestone: milestone && state.settings.celebrationsEnabled,
      roomGlow: math.min(1.0, state.roomGlow + 0.12),
      clearHover: true,
    );
    _scheduleFeedbackClear();
    _scheduleReplacement();

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(
      Duration(milliseconds: isDirty ? 1400 : 1100),
      () {
        if (!mounted) return;
        state = state.copyWith(
          targets: [
            for (final t in state.targets)
              t.copyWith(happy: false, glow: false, washing: false),
          ],
        );
        if (state.pendingEnd) {
          _endSession();
          return;
        }
        state = state.copyWith(
          phase: LaundrySortPhase.playing,
          showSparkles: false,
          showMilestone: false,
        );
      },
    );
  }

  void _scheduleReplacement() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      final visible = state.items.where((i) => !i.hidden).toList();
      final require = CleanDirtyClothesSortLogic.requiredCleanlinessFor(visible);
      final replacement = CleanDirtyClothesSortLogic.spawnItem(
        existing: visible,
        requireCleanliness: require,
      );
      state = state.copyWith(
        items: [...state.items, replacement],
        pendingSpawns: math.max(0, state.pendingSpawns - 1),
      );
    });
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, clearReward: true);
      }
    });
  }

  void pause() {
    if (state.phase == LaundrySortPhase.playing ||
        state.phase == LaundrySortPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: LaundrySortPhase.paused);
    }
  }

  void resume() {
    if (state.phase == LaundrySortPhase.paused) {
      state = state.copyWith(phase: LaundrySortPhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: LaundrySortPhase.finished);
  }

  void reset() {
    _cancelTimers();
    state = const LaundrySortState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _wrongTimer?.cancel();
    _spawnTimer?.cancel();
  }

  LaundrySortResult getResult() => CleanDirtyClothesSortLogic.calculate(state);

  String getVictoryTitle() => CleanDirtyClothesSortLogic.victoryTitle();

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctSorts == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.cleanDirtyClothesSort,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctSorts,
        totalMistakes: s.totalMistakes + (result.attempts - result.correctSorts),
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          CleanDirtyClothesSortLogic.toReward(result),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.cleanDirtyClothesSort);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
