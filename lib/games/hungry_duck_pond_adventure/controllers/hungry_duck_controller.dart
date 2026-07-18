import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/logic/hungry_duck_logic.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

final hungryDuckControllerProvider =
    StateNotifierProvider<HungryDuckController, HungryDuckState>((ref) {
  return HungryDuckController(ref);
});

class HungryDuckController extends StateNotifier<HungryDuckState> {
  HungryDuckController(this._ref) : super(const HungryDuckState());

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

  void _initLevel(Size area, HungryDuckSettings settings) {
    final fish = HungryDuckLogic.spawnFish(area, settings.effectiveFishCount);
    final duckPos = HungryDuckLogic.duckPath(area, 0, 0);
    state = state.copyWith(
      fish: fish,
      duck: DuckEntity(
        x: duckPos.$1,
        y: duckPos.$2,
        pathSeed: 0,
      ),
      playAreaReady: true,
      nextGoldenAt: settings.goldenInterval,
      nextVisitorSpawnIn: HungryDuckLogic.visitorSpawnDelay(settings),
    );
  }

  void startGame(HungryDuckSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = HungryDuckState(
      sessionPhase: HungryDuckSessionPhase.playing,
      settings: settings,
      fish: state.fish,
      duck: state.duck,
      remainingSeconds: settings.sessionSeconds,
      nextGoldenAt: settings.goldenInterval,
      nextVisitorSpawnIn: HungryDuckLogic.visitorSpawnDelay(settings),
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != HungryDuckSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      var goldenDue = state.goldenDue;
      if (HungryDuckLogic.shouldMarkGoldenDue(elapsed, state.nextGoldenAt)) {
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

  void tick(double delta) {
    if (state.sessionPhase != HungryDuckSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var fish = [...state.fish];
    var visitors = [...state.visitors];
    var pendingSpawns = [...state.pendingSpawns];
    var duck = state.duck;
    var goldenDue = state.goldenDue;
    var nextGoldenAt = state.nextGoldenAt;
    var nextVisitorSpawnIn = state.nextVisitorSpawnIn - delta;
    var showSparkles = state.showSparkles;
    var showGolden = state.showGoldenCelebration;
    final sunset = HungryDuckLogic.computeSunsetFactor(
      state.elapsedSeconds,
      state.settings.sessionSeconds,
    );
    final envPhase = state.envPhase + delta * 0.3;

    final prevDuckPhase = duck.phase;
    PondFishEntity? targetFish;
    if (duck.targetFishId != null) {
      targetFish = fish.where((f) => f.id == duck.targetFishId).firstOrNull;
    }

    for (var i = 0; i < fish.length; i++) {
      fish[i] = HungryDuckLogic.updateFish(fish[i], _playArea, delta, state.settings);
    }

    duck = HungryDuckLogic.updateDuck(
      duck,
      _playArea,
      delta,
      state.settings,
      targetFish,
    );

    if (prevDuckPhase == DuckPhase.chasing && duck.phase == DuckPhase.eating) {
      final targetId = duck.targetFishId;
      if (targetId != null) {
        final idx = fish.indexWhere((f) => f.id == targetId);
        if (idx != -1) {
          final caught = fish[idx];
          fish[idx] = caught.copyWith(phase: FishPhase.sinking, sinkProgress: 0);
          _applyCatchReward(caught.isGolden);
        }
      }
    }

    for (var i = 0; i < fish.length; i++) {
      if (fish[i].phase == FishPhase.gone) {
        final wasGolden = fish[i].isGolden;
        pendingSpawns.add(
          PendingFishSpawn(
            timer: state.settings.replacementDelay,
            isGolden: !wasGolden && goldenDue,
          ),
        );
        fish.removeAt(i);
        i--;
      }
    }

    pendingSpawns = pendingSpawns.where((p) {
      final remaining = p.timer - delta;
      if (remaining <= 0) {
        fish.add(HungryDuckLogic.spawnFromEdge(_playArea, isGolden: p.isGolden));
        if (p.isGolden) {
          goldenDue = false;
          nextGoldenAt += state.settings.goldenInterval;
        }
        return false;
      }
      return true;
    }).map((p) => p.copyWith(timer: p.timer - delta)).toList();

    for (var i = 0; i < visitors.length; i++) {
      visitors[i] =
          HungryDuckLogic.updateVisitor(visitors[i], _playArea, delta, state.settings);
      if (visitors[i].phase == PondVisitorPhase.gone) {
        visitors.removeAt(i);
        i--;
      }
    }

    if (nextVisitorSpawnIn <= 0) {
      visitors.add(HungryDuckLogic.spawnVisitor(_playArea));
      nextVisitorSpawnIn = HungryDuckLogic.visitorSpawnDelay(state.settings);
    }

    if (showSparkles) showSparkles = false;
    if (showGolden) showGolden = false;

    final hasActive = duck.phase != DuckPhase.idleSwim ||
        fish.any(
          (f) =>
              f.phase == FishPhase.selected ||
              f.phase == FishPhase.sinking ||
              f.phase == FishPhase.entering,
        );

    if (state.pendingEnd && !hasActive) {
      _endSession();
      return;
    }

    var duckSwims = state.duckSwims;
    if (prevDuckPhase == DuckPhase.celebrating && duck.phase == DuckPhase.idleSwim) {
      duckSwims++;
    }

    state = state.copyWith(
      fish: fish,
      duck: duck,
      visitors: visitors,
      pendingSpawns: pendingSpawns,
      goldenDue: goldenDue,
      nextGoldenAt: nextGoldenAt,
      nextVisitorSpawnIn: nextVisitorSpawnIn,
      sunsetFactor: sunset,
      envPhase: envPhase,
      showSparkles: showSparkles,
      showGoldenCelebration: showGolden,
      duckSwims: duckSwims,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  void _applyCatchReward(bool isGolden) {
    final caught = state.fishCaught + 1;
    final golden = state.goldenCaught + (isGolden ? 1 : 0);
    final streak = state.currentStreak + 1;
    final reward = HungryDuckLogic.catchReward(
      state.settings,
      isGolden: isGolden,
      caught: caught,
    );

    state = state.copyWith(
      fishCaught: caught,
      goldenCaught: golden,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: HungryDuckLogic.pickEncouragement(caught, isGolden: isGolden),
      lastRewardText: isGolden
          ? 'Golden!  +${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP  +${reward.stars} Stars'
          : '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: caught % 3 == 0 || isGolden,
      showSparkles: true,
      showGoldenCelebration: isGolden,
      inactivityTimer: 0,
    );
    _scheduleFeedbackClear(long: isGolden);
  }

  bool tapFish(String fishId) {
    if (state.sessionPhase != HungryDuckSessionPhase.playing) return false;
    if (state.duck.phase != DuckPhase.idleSwim) return false;

    final idx = state.fish.indexWhere((f) => f.id == fishId);
    if (idx == -1) return false;
    final f = state.fish[idx];
    if (!f.canTap) return false;

    final fish = [...state.fish];
    fish[idx] = f.copyWith(phase: FishPhase.selected, glow: 1, highlight: 1);

    state = state.copyWith(
      fish: fish,
      duck: state.duck.copyWith(
        phase: DuckPhase.chasing,
        targetFishId: fishId,
        chaseProgress: 0,
        x: state.duck.restX ?? state.duck.x,
        y: state.duck.restY ?? state.duck.y,
      ),
      inactivityTimer: 0,
    );
    return true;
  }

  bool tapVisitor(String visitorId) {
    if (state.sessionPhase != HungryDuckSessionPhase.playing) return false;

    final idx = state.visitors.indexWhere((v) => v.id == visitorId);
    if (idx == -1) return false;
    final visitor = state.visitors[idx];
    if (!visitor.canTap || visitor.wasTapped) return false;

    final visitors = [...state.visitors];
    visitors[idx] = visitor.copyWith(wasTapped: true);
    final tapped = state.visitorsTapped + 1;

    state = state.copyWith(
      visitors: visitors,
      visitorsTapped: tapped,
      feedbackMessage: HungryDuckLogic.pickVisitorMessage(tapped),
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
    if (state.sessionPhase == HungryDuckSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: HungryDuckSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == HungryDuckSessionPhase.paused) {
      state = state.copyWith(sessionPhase: HungryDuckSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: HungryDuckSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Pond Adventure!',
    );
  }

  HungryDuckResult getResult() => HungryDuckLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.fishCaught == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.hungryDuckPondAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.fishCaught),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.fishCaught,
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
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.hungryDuckPondAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const HungryDuckState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
