import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/logic/hungry_teddy_logic.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

final hungryTeddyControllerProvider =
    StateNotifierProvider<HungryTeddyController, HungryTeddyState>((ref) {
  return HungryTeddyController(ref);
});

class HungryTeddyController extends StateNotifier<HungryTeddyState> {
  HungryTeddyController(this._ref) : super(const HungryTeddyState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.cupcakes.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, HungryTeddySettings settings) {
    final (tx, ty) = HungryTeddyLogic.teddyAnchor(area);
    final cupcakes = HungryTeddyLogic.spawnCupcakes(area, settings.effectiveCupcakeCount);
    state = state.copyWith(
      cupcakes: cupcakes,
      teddy: TeddyEntity(x: tx, y: ty),
      playAreaReady: true,
      nextGoldenAt: settings.goldenInterval,
      nextVisitorSpawnIn: HungryTeddyLogic.visitorSpawnDelay(settings),
    );
  }

  void startGame(HungryTeddySettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = HungryTeddyState(
      sessionPhase: HungryTeddySessionPhase.playing,
      settings: settings,
      cupcakes: state.cupcakes,
      teddy: state.teddy,
      remainingSeconds: settings.sessionSeconds,
      nextGoldenAt: settings.goldenInterval,
      nextVisitorSpawnIn: HungryTeddyLogic.visitorSpawnDelay(settings),
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != HungryTeddySessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      var goldenDue = state.goldenDue;
      if (HungryTeddyLogic.shouldMarkGoldenDue(elapsed, state.nextGoldenAt)) {
        goldenDue = true;
      }
      if (rem <= 0) {
        state = state.copyWith(elapsedSeconds: elapsed, goldenDue: goldenDue);
        _requestEndSession();
        return;
      }
      state = state.copyWith(
        remainingSeconds: rem,
        elapsedSeconds: elapsed,
        goldenDue: goldenDue,
      );
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.hasActiveAnimation) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  Offset? _dragPosition() {
    final id = state.draggingCupcakeId;
    if (id == null) return null;
    final c = state.cupcakes.where((x) => x.id == id).firstOrNull;
    if (c == null || c.phase != CupcakePhase.dragging) return null;
    return Offset(c.dragX, c.dragY);
  }

  void tick(double delta) {
    if (state.sessionPhase != HungryTeddySessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var cupcakes = [...state.cupcakes];
    var visitors = [...state.visitors];
    var pendingRegrows = [...state.pendingRegrows];
    var teddy = state.teddy;
    var goldenDue = state.goldenDue;
    var nextGoldenAt = state.nextGoldenAt;
    var nextVisitorSpawnIn = state.nextVisitorSpawnIn - delta;
    var showSparkles = state.showSparkles;
    var showGolden = state.showGoldenCelebration;
    final evening = HungryTeddyLogic.computeEveningFactor(
      state.elapsedSeconds,
      state.settings.sessionSeconds,
    );
    final envPhase = state.envPhase + delta * 0.35;
    final dragPos = _dragPosition();

    teddy = HungryTeddyLogic.updateTeddy(
      teddy,
      _playArea,
      delta,
      state.settings,
      dragPosition: dragPos,
    );

    for (var i = 0; i < cupcakes.length; i++) {
      final prev = cupcakes[i];
      cupcakes[i] = HungryTeddyLogic.updateCupcake(
        prev,
        _playArea,
        delta,
        state.settings,
        teddy,
      );
      final updated = cupcakes[i];

      if (prev.phase == CupcakePhase.snapping && updated.phase == CupcakePhase.gone) {
        teddy = teddy.copyWith(
          phase: TeddyPhase.eating,
          eatProgress: 0,
          actionTimer: 0,
          targetCupcakeId: updated.id,
          feedWasGolden: updated.isGolden,
        );
      }

      if (updated.phase == CupcakePhase.gone && prev.phase != CupcakePhase.gone) {
        pendingRegrows.add(
          PendingCupcakeRegrow(
            slotIndex: updated.slotIndex,
            timer: state.settings.regrowDelay,
            isGolden: !updated.isGolden && goldenDue,
          ),
        );
        cupcakes.removeAt(i);
        i--;
      }
    }

    pendingRegrows = pendingRegrows.where((p) {
      final remaining = p.timer - delta;
      if (remaining <= 0) {
        final slot = p.slotIndex;
        cupcakes.add(
          HungryTeddyLogic.spawnBakingCupcake(_playArea, slot, isGolden: p.isGolden),
        );
        if (p.isGolden) {
          goldenDue = false;
          nextGoldenAt += state.settings.goldenInterval;
        }
        return false;
      }
      return true;
    }).map((p) => p.copyWith(timer: p.timer - delta)).toList();

    if (dragPos != null &&
        HungryTeddyLogic.isNearTeddy(
          _playArea,
          dragPos.dx,
          dragPos.dy,
          state.settings,
        )) {
      _triggerSnap(dragPos);
      cupcakes = [...state.cupcakes];
      teddy = state.teddy;
    }

    for (var i = 0; i < visitors.length; i++) {
      visitors[i] =
          HungryTeddyLogic.updateVisitor(visitors[i], _playArea, delta, state.settings);
      if (visitors[i].phase == PartyVisitorPhase.gone) {
        visitors.removeAt(i);
        i--;
      }
    }

    if (nextVisitorSpawnIn <= 0) {
      visitors.add(HungryTeddyLogic.spawnVisitor(_playArea));
      nextVisitorSpawnIn = HungryTeddyLogic.visitorSpawnDelay(state.settings);
    }

    if (showSparkles) showSparkles = false;
    if (showGolden) showGolden = false;

    final hasActive = state.hasActiveAnimation ||
        cupcakes.any(
          (c) =>
              c.phase == CupcakePhase.snapping ||
              c.phase == CupcakePhase.baking ||
              c.phase == CupcakePhase.dragging,
        ) ||
        teddy.phase == TeddyPhase.receiving ||
        teddy.phase == TeddyPhase.eating ||
        teddy.phase == TeddyPhase.celebrating ||
        teddy.phase == TeddyPhase.goldenCelebration;

    if (state.pendingEnd && !hasActive) {
      _endSession();
      return;
    }

    state = state.copyWith(
      cupcakes: cupcakes,
      teddy: teddy,
      visitors: visitors,
      pendingRegrows: pendingRegrows,
      goldenDue: goldenDue,
      nextGoldenAt: nextGoldenAt,
      nextVisitorSpawnIn: nextVisitorSpawnIn,
      eveningFactor: evening,
      envPhase: envPhase,
      showSparkles: showSparkles,
      showGoldenCelebration: showGolden,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool startDrag(String cupcakeId, Offset localPosition) {
    if (state.sessionPhase != HungryTeddySessionPhase.playing) return false;
    if (state.draggingCupcakeId != null) return false;

    final idx = state.cupcakes.indexWhere((c) => c.id == cupcakeId);
    if (idx == -1) return false;
    final cupcake = state.cupcakes[idx];
    if (!cupcake.canDrag) return false;

    final cupcakes = [...state.cupcakes];
    cupcakes[idx] = cupcake.copyWith(
      phase: CupcakePhase.dragging,
      dragX: localPosition.dx,
      dragY: localPosition.dy,
      glow: 1,
      scale: 1.12,
    );

    state = state.copyWith(
      cupcakes: cupcakes,
      draggingCupcakeId: cupcakeId,
      inactivityTimer: 0,
    );
    return true;
  }

  void updateDrag(String cupcakeId, Offset localPosition) {
    if (state.draggingCupcakeId != cupcakeId) return;
    final idx = state.cupcakes.indexWhere((c) => c.id == cupcakeId);
    if (idx == -1) return;

    final cupcakes = [...state.cupcakes];
    cupcakes[idx] = cupcakes[idx].copyWith(
      dragX: localPosition.dx,
      dragY: localPosition.dy,
    );
    state = state.copyWith(cupcakes: cupcakes, inactivityTimer: 0);
  }

  void endDrag(String cupcakeId) {
    if (state.draggingCupcakeId != cupcakeId) return;
    final idx = state.cupcakes.indexWhere((c) => c.id == cupcakeId);
    if (idx == -1) return;
    final cupcake = state.cupcakes[idx];

    if (HungryTeddyLogic.isNearTeddy(
      _playArea,
      cupcake.dragX,
      cupcake.dragY,
      state.settings,
    )) {
      _triggerSnap(Offset(cupcake.dragX, cupcake.dragY));
      return;
    }

    final cupcakes = [...state.cupcakes];
    cupcakes[idx] = cupcake.copyWith(
      phase: CupcakePhase.onTable,
      x: cupcake.homeX,
      y: cupcake.homeY,
      dragX: cupcake.homeX,
      dragY: cupcake.homeY,
      glow: 0,
      scale: cupcake.scale.clamp(0.85, 1.05),
    );
    state = state.copyWith(
      cupcakes: cupcakes,
      clearDrag: true,
      teddy: state.teddy.copyWith(phase: TeddyPhase.idle, headAngle: 0, excitedLevel: 0),
    );
  }

  void _triggerSnap(Offset position) {
    final id = state.draggingCupcakeId;
    if (id == null) return;
    final idx = state.cupcakes.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final cupcake = state.cupcakes[idx];
    if (cupcake.phase != CupcakePhase.dragging) return;

    final cupcakes = [...state.cupcakes];
    cupcakes[idx] = cupcake.copyWith(
      phase: CupcakePhase.snapping,
      snapProgress: 0,
      homeX: cupcake.dragX,
      homeY: cupcake.dragY,
      glow: 1,
    );

    state = state.copyWith(
      cupcakes: cupcakes,
      clearDrag: true,
      teddy: state.teddy.copyWith(
        phase: TeddyPhase.receiving,
        targetCupcakeId: id,
        actionTimer: 0,
        mouthOpen: 0.8,
        headAngle: HungryTeddyLogic.headAngleToward(
          _playArea,
          state.teddy.x,
          state.teddy.y,
          position.dx,
          position.dy,
        ),
      ),
      inactivityTimer: 0,
    );

    _applyFeedReward(cupcake);
  }

  void _applyFeedReward(CupcakeEntity cupcake) {
    final fed = state.cupcakesFed + 1;
    final golden = state.goldenFed + (cupcake.isGolden ? 1 : 0);
    final streak = state.currentStreak + 1;
    final reward = HungryTeddyLogic.feedReward(
      state.settings,
      isGolden: cupcake.isGolden,
      fedCount: fed,
    );

    final flavorCounts = Map<int, int>.from(state.flavorCounts);
    flavorCounts[cupcake.varietyIndex] = (flavorCounts[cupcake.varietyIndex] ?? 0) + 1;
    var favoriteIndex = state.favoriteFlavorIndex;
    var maxCount = 0;
    flavorCounts.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        favoriteIndex = k;
      }
    });

    state = state.copyWith(
      cupcakesFed: fed,
      goldenFed: golden,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      flavorCounts: flavorCounts,
      favoriteFlavorIndex: favoriteIndex,
      feedbackMessage: HungryTeddyLogic.pickEncouragement(fed, isGolden: cupcake.isGolden),
      lastRewardText: cupcake.isGolden
          ? 'Golden!  +${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP  +${reward.stars} Stars'
          : '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: fed % 3 == 0 || cupcake.isGolden,
      showSparkles: true,
      showGoldenCelebration: cupcake.isGolden,
      teddy: state.teddy.copyWith(
        phase: TeddyPhase.receiving,
        targetCupcakeId: cupcake.id,
        feedWasGolden: cupcake.isGolden,
      ),
    );
    _scheduleFeedbackClear(long: cupcake.isGolden);
  }

  bool tapVisitor(String visitorId) {
    if (state.sessionPhase != HungryTeddySessionPhase.playing) return false;

    final idx = state.visitors.indexWhere((v) => v.id == visitorId);
    if (idx == -1) return false;
    final visitor = state.visitors[idx];
    if (!visitor.canTap) return false;

    final visitors = [...state.visitors];
    visitors[idx] = visitor.copyWith(wasTapped: true, reactProgress: 0);
    final tapped = state.visitorsTapped + 1;

    state = state.copyWith(
      visitors: visitors,
      visitorsTapped: tapped,
      feedbackMessage: HungryTeddyLogic.pickVisitorMessage(tapped),
      showMascot: tapped % 2 == 0,
      inactivityTimer: 0,
    );
    _scheduleFeedbackClear(short: true);
    return true;
  }

  void _scheduleFeedbackClear({bool short = false, bool long = false}) {
    _feedbackTimer?.cancel();
    final ms = long ? 2200 : (short ? 1300 : 1600);
    _feedbackTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });
  }

  void pause() {
    if (state.sessionPhase == HungryTeddySessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: HungryTeddySessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == HungryTeddySessionPhase.paused) {
      state = state.copyWith(sessionPhase: HungryTeddySessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: HungryTeddySessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Cupcake Party!',
    );
  }

  HungryTeddyResult getResult() => HungryTeddyLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.cupcakesFed == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.hungryTeddyCupcakeParty,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.cupcakesFed),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.cupcakesFed,
        longestCombo: math.max(s.longestCombo, result.longestStreak),
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
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.hungryTeddyCupcakeParty);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const HungryTeddyState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
