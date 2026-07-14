import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/logic/flower_garden_logic.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

final flowerGardenControllerProvider =
    StateNotifierProvider<FlowerGardenController, FlowerGardenState>((ref) {
  return FlowerGardenController(ref);
});

class FlowerGardenController extends StateNotifier<FlowerGardenState> {
  FlowerGardenController(this._ref) : super(const FlowerGardenState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  final _rewardedBeeIds = <String>{};

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.flowers.isEmpty) {
      final count = state.settings.maxFlowersOnScreen.clamp(4, 5);
      state = state.copyWith(
        flowers: FlowerGardenLogic.spawnFlowers(size, count),
        playAreaReady: true,
      );
    }
  }

  void startGame(FlowerGardenSettings settings) {
    _sessionTimer?.cancel();
    _rewardedBeeIds.clear();
    final count = settings.maxFlowersOnScreen.clamp(4, 5);
    final flowers = _playArea == Size.zero
        ? <FlowerEntity>[]
        : FlowerGardenLogic.spawnFlowers(_playArea, count);

    state = FlowerGardenState(
      sessionPhase: GardenSessionPhase.playing,
      settings: settings,
      flowers: flowers,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != GardenSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        _endSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void tick(double delta) {
    if (state.sessionPhase != GardenSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    final intensity = state.settings.animationIntensity;
    final moveMult = state.settings.flowerMoveMult;
    var flowers = [...state.flowers];
    var bees = [...state.bees];
    var showRainbow = false;
    var showSunbeam = false;
    var showSparkles = false;
    var coinsEarned = state.coinsEarned;
    var xpEarned = state.xpEarned;
    var starsEarned = state.starsEarned;
    String? rewardText = state.lastRewardText;

    // Update flowers and spawn bees when bloom completes
    flowers = flowers.asMap().entries.map((entry) {
      var f = FlowerGardenLogic.updateFlower(
        entry.value,
        delta,
        intensity,
        moveMult,
      );

      if (entry.value.phase == FlowerPhase.blooming &&
          f.phase == FlowerPhase.open) {
        final hasActiveBee = bees.any(
          (b) =>
              b.flowerId == f.id &&
              (b.phase == PollinatorPhase.entering ||
                  b.phase == PollinatorPhase.collecting),
        );
        if (!hasActiveBee) {
          bees.add(FlowerGardenLogic.spawnBee(_playArea, f.id, f.x, f.y));
          showSparkles = true;
          showSunbeam = true;
        }
      }

      return f;
    }).toList();

    // Update bees — apply rewards and cooldown in-place (no mid-tick state overwrite)
    bees = bees.map((bee) {
      if (bee.phase == PollinatorPhase.gone) return bee;

      final flowerIdx = flowers.indexWhere((f) => f.id == bee.flowerId);
      if (flowerIdx == -1) return bee;

      final flower = flowers[flowerIdx];
      return FlowerGardenLogic.updateBee(
        bee: bee,
        flowerX: flower.x,
        flowerY: flower.y,
        delta: delta,
        intensity: intensity,
        onNectarCollected: (collectedBee) {
          if (_rewardedBeeIds.contains(collectedBee.id)) return;
          _rewardedBeeIds.add(collectedBee.id);

          final reward = FlowerGardenLogic.beeReward(
            state.settings,
            state.bloomsCount,
          );
          coinsEarned += reward.coins;
          xpEarned += reward.xp;
          starsEarned += reward.stars;
          rewardText =
              '+${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}';
          showSparkles = true;

          if (flowers[flowerIdx].phase == FlowerPhase.open) {
            flowers[flowerIdx] = flowers[flowerIdx].copyWith(
              phase: FlowerPhase.cooldown,
              phaseTimer: 0,
            );
          }
        },
      );
    }).toList();

    bees = bees.where((b) => b.phase != PollinatorPhase.gone).toList();

    // Drop bees once a flower is ready to bloom again.
    bees = bees.where((b) {
      final flower = flowers.where((f) => f.id == b.flowerId).firstOrNull;
      if (flower == null) return false;
      if (flower.phase == FlowerPhase.bud) return false;
      if (flower.phase == FlowerPhase.blooming) {
        return b.phase == PollinatorPhase.entering ||
            b.phase == PollinatorPhase.collecting;
      }
      return b.phase == PollinatorPhase.entering ||
          b.phase == PollinatorPhase.collecting;
    }).toList();

    showRainbow = flowers.any((f) => f.phase == FlowerPhase.open);
    showSparkles = showSparkles ||
        flowers.any((f) => f.phase == FlowerPhase.blooming || f.phase == FlowerPhase.open);

    state = state.copyWith(
      flowers: flowers,
      bees: bees,
      showRainbow: showRainbow,
      showSunbeam: showSunbeam,
      showSparkles: showSparkles,
      coinsEarned: coinsEarned,
      xpEarned: xpEarned,
      starsEarned: starsEarned,
      lastRewardText: rewardText,
    );
  }

  bool tapFlower(String flowerId) {
    if (state.sessionPhase != GardenSessionPhase.playing) return false;

    final idx = state.flowers.indexWhere((f) => f.id == flowerId);
    if (idx == -1) return false;

    final flower = state.flowers[idx];
    if (!flower.canTap) return false;

    final palette = FlowerGardenLogic.pickPalette(state.bloomsCount);
    final reward = FlowerGardenLogic.bloomReward(state.settings);
    final blooms = state.bloomsCount + 1;
    final msg = kGardenEncouragements[blooms % kGardenEncouragements.length];

    final updated = [...state.flowers];
    updated[idx] = flower.copyWith(
      phase: FlowerPhase.blooming,
      bloomProgress: 0,
      paletteIndex: FlowerGardenLogic.paletteIndexFor(palette),
      petalCount: 5 + FlowerGardenLogic.random.nextInt(4),
      petalSpread: 0.85 + FlowerGardenLogic.random.nextDouble() * 0.35,
    );

    state = state.copyWith(
      flowers: updated,
      bees: state.bees
          .where((b) => b.flowerId != flowerId)
          .toList(growable: false),
      bloomsCount: blooms,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + (blooms % 4 == 0 ? 1 : 0),
      showSunbeam: true,
      showSparkles: true,
      feedbackMessage: msg,
      lastRewardText: '+${reward.coins} Coins  +${reward.xp} XP',
      showMascot: blooms % 3 == 0,
    );

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascot: false);
      }
    });

    return true;
  }

  void pause() {
    if (state.sessionPhase == GardenSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: GardenSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == GardenSessionPhase.paused) {
      state = state.copyWith(sessionPhase: GardenSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: GardenSessionPhase.finished,
      showRainbow: true,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Garden Adventure!',
    );
  }

  FlowerGardenResult getResult() => FlowerGardenLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.bloomsCount == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.magicalFlowerGarden,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.bloomsCount),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.bloomsCount,
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
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _rewardedBeeIds.clear();
    _playArea = Size.zero;
    state = const FlowerGardenState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
