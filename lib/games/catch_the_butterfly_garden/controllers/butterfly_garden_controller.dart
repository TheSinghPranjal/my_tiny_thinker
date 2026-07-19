import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/logic/butterfly_garden_logic.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

final butterflyGardenControllerProvider =
    StateNotifierProvider<ButterflyGardenController, ButterflyGardenState>((ref) {
  return ButterflyGardenController(ref);
});

class ButterflyGardenController extends StateNotifier<ButterflyGardenState> {
  ButterflyGardenController(this._ref) : super(const ButterflyGardenState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.butterflies.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, ButterflyGardenSettings settings) {
    final (bx, by) = ButterflyGardenLogic.basketAnchor(area);
    final butterflies =
        ButterflyGardenLogic.spawnButterflies(area, settings.effectiveButterflyCount);
    state = state.copyWith(
      butterflies: butterflies,
      basket: BasketEntity(x: bx, y: by),
      playAreaReady: true,
      nextGoldenAt: settings.goldenInterval,
      nextBeeSpawnIn: ButterflyGardenLogic.beeSpawnDelay(settings),
    );
  }

  void startGame(ButterflyGardenSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = ButterflyGardenState(
      sessionPhase: ButterflyGardenSessionPhase.playing,
      settings: settings,
      butterflies: state.butterflies,
      basket: state.basket,
      remainingSeconds: settings.sessionSeconds,
      nextGoldenAt: settings.goldenInterval,
      nextBeeSpawnIn: ButterflyGardenLogic.beeSpawnDelay(settings),
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != ButterflyGardenSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      var goldenDue = state.goldenDue;
      if (ButterflyGardenLogic.shouldMarkGoldenDue(elapsed, state.nextGoldenAt)) {
        goldenDue = true;
      }
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0, elapsedSeconds: elapsed, goldenDue: goldenDue);
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
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != ButterflyGardenSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var butterflies = [...state.butterflies];
    var bees = [...state.bees];
    var basket = ButterflyGardenLogic.updateBasket(state.basket, delta);
    var pendingSpawns = [...state.pendingSpawns];
    var nextBeeSpawnIn = state.nextBeeSpawnIn - delta;
    var goldenDue = state.goldenDue;
    var nextGoldenAt = state.nextGoldenAt;
    var showSparkles = state.showSparkles;
    var showGolden = state.showGoldenCelebration;
    final envPhase = state.envPhase + delta * 0.35;

    for (var i = 0; i < butterflies.length; i++) {
      final prev = butterflies[i];
      butterflies[i] = ButterflyGardenLogic.updateButterfly(
        prev,
        _playArea,
        delta,
        state.settings,
        basket,
      );
      if (prev.phase != ButterflyPhase.gone &&
          butterflies[i].phase == ButterflyPhase.gone) {
        basket = basket.copyWith(
          lidOpen: 1,
          totalCollected: basket.totalCollected + 1,
        );
        pendingSpawns.add(
          PendingButterflySpawn(
            timer: state.settings.replacementDelay,
            isGolden: !prev.isGolden && goldenDue,
          ),
        );
        butterflies.removeAt(i);
        i--;
      }
    }

    for (var i = 0; i < bees.length; i++) {
      bees[i] = ButterflyGardenLogic.updateBee(bees[i], _playArea, delta, state.settings);
      if (bees[i].phase == BeePhase.gone) {
        bees.removeAt(i);
        i--;
      }
    }

    pendingSpawns = pendingSpawns.where((p) {
      final remaining = p.timer - delta;
      if (remaining <= 0) {
        butterflies.add(
          ButterflyGardenLogic.spawnFromEdge(_playArea, isGolden: p.isGolden),
        );
        if (p.isGolden) {
          goldenDue = false;
          nextGoldenAt += state.settings.goldenInterval;
        }
        return false;
      }
      return true;
    }).map((p) => p.copyWith(timer: p.timer - delta)).toList();

    if (nextBeeSpawnIn <= 0) {
      final batch = ButterflyGardenLogic.beeBatchCount();
      bees.addAll(ButterflyGardenLogic.spawnBees(_playArea, batch));
      nextBeeSpawnIn = ButterflyGardenLogic.beeSpawnDelay(state.settings);
    }

    if (showSparkles) showSparkles = false;
    if (showGolden) showGolden = false;

    final hasActive = butterflies.any(
          (b) =>
              b.phase == ButterflyPhase.tapped ||
              b.phase == ButterflyPhase.collecting ||
              b.phase == ButterflyPhase.entering,
        ) ||
        basket.lidOpen > 0.05;

    if (state.pendingEnd && !hasActive) {
      _endSession();
      return;
    }

    state = state.copyWith(
      butterflies: butterflies,
      bees: bees,
      basket: basket,
      pendingSpawns: pendingSpawns,
      nextBeeSpawnIn: nextBeeSpawnIn,
      goldenDue: goldenDue,
      nextGoldenAt: nextGoldenAt,
      envPhase: envPhase,
      showSparkles: showSparkles,
      showGoldenCelebration: showGolden,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool tapButterfly(String id) {
    if (state.sessionPhase != ButterflyGardenSessionPhase.playing) return false;

    final idx = state.butterflies.indexWhere((b) => b.id == id);
    if (idx == -1) return false;
    final butterfly = state.butterflies[idx];
    if (!butterfly.canTap) return false;

    final butterflies = [...state.butterflies];
    butterflies[idx] = butterfly.copyWith(
      phase: ButterflyPhase.tapped,
      collectProgress: 0,
      glow: 1,
      highlight: 1,
    );

    final reward = ButterflyGardenLogic.catchReward(
      state.settings,
      isGolden: butterfly.isGolden,
      caught: state.butterfliesCaught + 1,
    );
    final caught = state.butterfliesCaught + 1;
    final golden = state.goldenCaught + (butterfly.isGolden ? 1 : 0);
    final streak = state.currentStreak + 1;

    state = state.copyWith(
      butterflies: butterflies,
      butterfliesCaught: caught,
      goldenCaught: golden,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: ButterflyGardenLogic.pickEncouragement(
        caught,
        isGolden: butterfly.isGolden,
      ),
      lastRewardText: butterfly.isGolden
          ? 'Golden!  +${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP  +${reward.stars} Stars'
          : '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: caught % 3 == 0 || butterfly.isGolden,
      showSparkles: true,
      showGoldenCelebration: butterfly.isGolden,
      inactivityTimer: 0,
    );
    _scheduleFeedbackClear(long: butterfly.isGolden);
    return true;
  }

  bool tapBee(String id) {
    if (state.sessionPhase != ButterflyGardenSessionPhase.playing) return false;

    final idx = state.bees.indexWhere((b) => b.id == id);
    if (idx == -1) return false;
    final bee = state.bees[idx];
    if (!bee.canTap || bee.wasTapped) return false;

    final bees = [...state.bees];
    bees[idx] = bee.copyWith(phase: BeePhase.buzzed, wasTapped: true);
    final tapped = state.beesTapped + 1;

    state = state.copyWith(
      bees: bees,
      beesTapped: tapped,
      feedbackMessage: ButterflyGardenLogic.pickBeeMessage(tapped),
      showMascot: tapped % 2 == 0,
      showSparkles: false,
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
    if (state.sessionPhase == ButterflyGardenSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: ButterflyGardenSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == ButterflyGardenSessionPhase.paused) {
      state = state.copyWith(sessionPhase: ButterflyGardenSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: ButterflyGardenSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Butterfly Garden!',
    );
  }

  ButterflyGardenResult getResult() => ButterflyGardenLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.butterfliesCaught == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.catchTheButterflyGarden,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.butterfliesCaught),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.butterfliesCaught,
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
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.catchTheButterflyGarden);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const ButterflyGardenState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
