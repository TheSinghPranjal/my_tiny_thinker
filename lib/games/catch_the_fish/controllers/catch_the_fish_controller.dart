import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/logic/catch_the_fish_logic.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';

final catchTheFishControllerProvider =
    StateNotifierProvider<CatchTheFishController, CatchTheFishState>((ref) {
  return CatchTheFishController(ref);
});

class CatchTheFishController extends StateNotifier<CatchTheFishState> {
  CatchTheFishController(this._ref) : super(const CatchTheFishState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.fish.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, CatchFishSettings settings) {
    final (bx, by) = CatchTheFishLogic.boatAnchor(area);
    final fish =
        CatchTheFishLogic.spawnFish(area, settings.effectiveFishCount);
    state = state.copyWith(
      fish: fish,
      boatX: bx,
      boatY: by,
      playAreaReady: true,
    );
  }

  void startGame(CatchFishSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = CatchTheFishState(
      sessionPhase: CatchFishSessionPhase.playing,
      settings: settings,
      fish: state.fish,
      boatX: state.boatX,
      boatY: state.boatY,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != CatchFishSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _requestEndSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.hasActiveReeling) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession(reason: 'timer');
  }

  void tick(double delta) {
    if (state.sessionPhase != CatchFishSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var fish = [...state.fish];
    var hookProgress = state.hookProgress;
    var hookTargetFishId = state.hookTargetFishId;
    var showSparkles = state.showSparkles;
    final envPhase = state.envPhase + delta * 0.35;
    final targetCount = state.settings.effectiveFishCount;

    for (var i = 0; i < fish.length; i++) {
      final prev = fish[i];
      fish[i] = CatchTheFishLogic.updateFish(
        prev,
        _playArea,
        delta,
        state.settings,
      );
      if (prev.phase != CatchFishPhase.gone &&
          fish[i].phase == CatchFishPhase.gone) {
        if (hookTargetFishId == prev.id) {
          hookTargetFishId = null;
          hookProgress = 0;
        }
        fish.removeAt(i);
        i--;
      }
    }

    while (fish.length < targetCount) {
      fish.add(CatchTheFishLogic.spawnReplacement(_playArea, fish));
    }

    if (hookProgress > 0) {
      hookProgress = (hookProgress + delta).clamp(0.0, 1.0);
      if (hookProgress >= 1 &&
          !fish.any((f) => f.phase == CatchFishPhase.reeling)) {
        hookProgress = 0;
        hookTargetFishId = null;
      }
    }

    if (showSparkles) showSparkles = false;

    if (state.pendingEnd &&
        !fish.any((f) => f.phase == CatchFishPhase.reeling) &&
        hookProgress <= 0) {
      _endSession(reason: 'timer');
      return;
    }

    state = state.copyWith(
      fish: fish,
      hookProgress: hookProgress,
      hookTargetFishId: hookTargetFishId,
      clearHookTarget: hookTargetFishId == null,
      envPhase: envPhase,
      showSparkles: showSparkles,
    );
  }

  bool tapFish(String id) {
    if (state.sessionPhase != CatchFishSessionPhase.playing) return false;
    if (state.pendingEnd) return false;

    final idx = state.fish.indexWhere((f) => f.id == id);
    if (idx == -1) return false;
    final fish = state.fish[idx];
    if (!fish.canTap) return false;

    final list = [...state.fish];
    list[idx] = fish.copyWith(
      phase: CatchFishPhase.reeling,
      catchProgress: 0,
      catchStartX: fish.x,
      catchStartY: fish.y,
      glow: 1,
    );

    final caught = state.fishCaught + 1;
    final reward = CatchTheFishLogic.catchReward(
      state.settings,
      caught: caught,
    );

    state = state.copyWith(
      fish: list,
      fishCaught: caught,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      hookProgress: 0.01,
      hookTargetFishId: id,
      feedbackMessage: CatchTheFishLogic.pickEncouragement(caught),
      lastRewardText:
          '+${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showSparkles: true,
      showCelebration: caught % 5 == 0,
    );
    _scheduleFeedbackClear();
    return true;
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showCelebration: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == CatchFishSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: CatchFishSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == CatchFishSessionPhase.paused) {
      state = state.copyWith(sessionPhase: CatchFishSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession({required String reason}) {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: CatchFishSessionPhase.finished,
      remainingSeconds: reason == 'timer' ? 0 : state.remainingSeconds,
      showSparkles: true,
      showCelebration: true,
      feedbackMessage: CatchTheFishLogic.pickEndMessage(state.fishCaught),
      endReason: reason,
      pendingEnd: false,
      hookProgress: 0,
      clearHookTarget: true,
    );
  }

  CatchTheFishResult getResult() => CatchTheFishLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.fishCaught == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.catchTheFishAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.fishCaught),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.fishCaught,
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.catchTheFishAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _playArea = Size.zero;
    state = const CatchTheFishState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
