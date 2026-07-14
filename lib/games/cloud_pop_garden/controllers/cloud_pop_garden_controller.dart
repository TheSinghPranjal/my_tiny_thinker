import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/logic/cloud_pop_garden_logic.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';

final cloudPopGardenControllerProvider =
    StateNotifierProvider<CloudPopGardenController, CloudPopGardenState>((ref) {
  return CloudPopGardenController(ref);
});

class CloudPopGardenController extends StateNotifier<CloudPopGardenState> {
  CloudPopGardenController(this._ref) : super(const CloudPopGardenState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  final _pendingSpawns = <String>{};

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.flowers.isEmpty) {
      final count = state.settings.pairCount.clamp(1, 5);
      final spawned = CloudPopGardenLogic.spawnPairs(size, count);
      state = state.copyWith(
        flowers: spawned.flowers,
        clouds: spawned.clouds,
        playAreaReady: true,
      );
    }
  }

  void startGame(CloudPopGardenSettings settings) {
    _sessionTimer?.cancel();
    _pendingSpawns.clear();
    final count = settings.pairCount.clamp(1, 5);
    final spawned = _playArea == Size.zero
        ? (flowers: <GardenFlowerEntity>[], clouds: <CloudEntity>[])
        : CloudPopGardenLogic.spawnPairs(_playArea, count);

    state = CloudPopGardenState(
      sessionPhase: CloudPopSessionPhase.playing,
      settings: settings,
      flowers: spawned.flowers,
      clouds: spawned.clouds,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != CloudPopSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        _requestEndSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    final activeRain = state.clouds.any((c) => c.phase == CloudPhase.raining);
    if (activeRain) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != CloudPopSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var flowers = [...state.flowers];
    var clouds = [...state.clouds];
    var showSparkles = false;
    var showRainbow = state.showRainbow;
    var rainbowProgress = state.rainbowProgress;
    var showMascot = state.showMascot;

    clouds = clouds.map((cloud) {
      final flowerIdx = flowers.indexWhere((f) => f.id == cloud.flowerId);
      if (flowerIdx == -1) return cloud;
      return CloudPopGardenLogic.updateCloud(
        cloud: cloud,
        flower: flowers[flowerIdx],
        area: _playArea,
        delta: delta,
        settings: state.settings,
      );
    }).toList();

    for (var i = 0; i < flowers.length; i++) {
      final cloud = clouds
          .where((c) => c.flowerId == flowers[i].id && c.phase != CloudPhase.gone)
          .firstOrNull;
      flowers[i] = CloudPopGardenLogic.updateFlower(
        flower: flowers[i],
        cloud: cloud,
        delta: delta,
        settings: state.settings,
      );
      if (flowers[i].phase == GardenFlowerPhase.open ||
          flowers[i].phase == GardenFlowerPhase.blooming) {
        showSparkles = true;
      }
    }

    for (final flower in flowers) {
      final pairClouds = clouds.where((c) => c.pairId == flower.pairId).toList();
      final active = pairClouds.where((c) => c.phase != CloudPhase.gone).toList();
      final leaving = active.where((c) => c.phase == CloudPhase.leaving).toList();
      final needsSpawn = active.isEmpty ||
          (leaving.isNotEmpty && !_hasIncomingCloud(clouds, flower.pairId));

      if (needsSpawn && !_pendingSpawns.contains(flower.pairId)) {
        _pendingSpawns.add(flower.pairId);
        clouds.add(
          CloudPopGardenLogic.spawnReplacementCloud(
            _playArea,
            flower,
            leaving.isNotEmpty ? 0.2 : 0,
          ),
        );
      }
    }

    clouds = clouds.where((c) => c.phase != CloudPhase.gone).toList();
    _pendingSpawns.removeWhere(
      (pairId) => clouds.any((c) => c.pairId == pairId && c.spawnDelay <= 0),
    );

    if (state.pendingEnd &&
        !clouds.any((c) => c.phase == CloudPhase.raining)) {
      _endSession();
      return;
    }

    state = state.copyWith(
      flowers: flowers,
      clouds: clouds,
      showSparkles: showSparkles,
      showRainbow: showRainbow,
      rainbowProgress: rainbowProgress,
      showMascot: showMascot,
    );
  }

  bool _hasIncomingCloud(List<CloudEntity> clouds, String pairId) {
    return clouds.any(
      (c) =>
          c.pairId == pairId &&
          (c.phase == CloudPhase.approaching ||
              c.phase == CloudPhase.hovering ||
              c.spawnDelay > 0),
    );
  }

  CloudTapResult? tapCloud(String cloudId) {
    if (state.sessionPhase != CloudPopSessionPhase.playing) return null;

    final cloudIdx = state.clouds.indexWhere((c) => c.id == cloudId);
    if (cloudIdx == -1) return null;

    final cloud = state.clouds[cloudIdx];
    if (!cloud.isTappable || cloud.spawnDelay > 0) return null;

    final flowerIdx = state.flowers.indexWhere((f) => f.id == cloud.flowerId);
    if (flowerIdx == -1) return null;

    final flower = state.flowers[flowerIdx];
    final result = CloudPopGardenLogic.classifyTap(cloud, flower, _playArea);
    if (result == CloudTapResult.ignored) return result;

    var clouds = [...state.clouds];
    var cloudsTapped = state.cloudsTapped + 1;
    var successfulRains = state.successfulRains;
    var flowersWatered = state.flowersWatered;
    var wateringStreak = state.wateringStreak;
    var maxWateringStreak = state.maxWateringStreak;
    var rainbowsCreated = state.rainbowsCreated;
    var coinsEarned = state.coinsEarned;
    var xpEarned = state.xpEarned;
    var starsEarned = state.starsEarned;
    var rainbowProgress = state.rainbowProgress;
    var showRainbow = state.showRainbow;
    var showMascot = state.showMascot;
    String? feedback;
    String? rewardText;

    switch (result) {
      case CloudTapResult.successRain:
        clouds[cloudIdx] = cloud.copyWith(
          phase: CloudPhase.raining,
          phaseTimer: 0,
          blueLevel: 1,
          rainDrops: const [],
        );
        successfulRains += 1;
        flowersWatered += 1;
        wateringStreak += 1;
        maxWateringStreak = math.max(maxWateringStreak, wateringStreak);
        final reward = CloudPopGardenLogic.rainReward(
          state.settings,
          wateringStreak,
        );
        coinsEarned += reward.coins;
        xpEarned += reward.xp;
        starsEarned += reward.stars;
        rainbowProgress += 1 / state.settings.rainsForRainbow;
        if (rainbowProgress >= 1) {
          rainbowProgress = 0;
          rainbowsCreated += 1;
          showRainbow = true;
          showMascot = true;
        }
        feedback = kCloudPopEncouragements[successfulRains % kCloudPopEncouragements.length];
        rewardText =
            '+${reward.coins} Coin${reward.coins == 1 ? '' : 's'}  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}';
        _scheduleFeedbackClear(showMascot: showMascot);
      case CloudTapResult.earlyThunder:
        wateringStreak = 0;
        clouds[cloudIdx] = cloud.copyWith(
          thunderTimer: CloudPopGardenLogic.thunderDuration,
          blueLevel: 0.05,
        );
        feedback = 'Wait for the flower!';
        _scheduleFeedbackClear();
      case CloudTapResult.lateBounce:
        clouds[cloudIdx] = cloud.copyWith(
          bounceTimer: CloudPopGardenLogic.bounceDuration,
          showSmile: true,
        );
        feedback = 'Nice cloud!';
        _scheduleFeedbackClear();
      case CloudTapResult.ignored:
        break;
    }

    state = state.copyWith(
      clouds: clouds,
      cloudsTapped: cloudsTapped,
      successfulRains: successfulRains,
      flowersWatered: flowersWatered,
      wateringStreak: wateringStreak,
      maxWateringStreak: maxWateringStreak,
      rainbowsCreated: rainbowsCreated,
      coinsEarned: coinsEarned,
      xpEarned: xpEarned,
      starsEarned: starsEarned,
      rainbowProgress: rainbowProgress,
      showRainbow: showRainbow,
      showMascot: showMascot,
      showSparkles: result == CloudTapResult.successRain,
      feedbackMessage: feedback,
      lastRewardText: rewardText,
    );

    return result;
  }

  void _scheduleFeedbackClear({bool showMascot = false}) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascot: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == CloudPopSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: CloudPopSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == CloudPopSessionPhase.paused) {
      state = state.copyWith(sessionPhase: CloudPopSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: CloudPopSessionPhase.finished,
      feedbackMessage: 'Amazing Cloud Pop Garden!',
      showMascot: true,
    );
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _pendingSpawns.clear();
    state = const CloudPopGardenState();
  }

  CloudPopGardenResult getResult() => CloudPopGardenResult(
        cloudsTapped: state.cloudsTapped,
        successfulRains: state.successfulRains,
        flowersWatered: state.flowersWatered,
        rainbowsCreated: state.rainbowsCreated,
        maxWateringStreak: state.maxWateringStreak,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds,
      );

  Future<void> saveResult() async {
    final result = getResult();
    if (result.successfulRains == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.cloudPopGarden,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.flowersWatered),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.successfulRains,
        longestCombo: math.max(s.longestCombo, result.maxWateringStreak),
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
}
