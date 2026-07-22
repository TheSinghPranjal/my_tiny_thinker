import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
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
  final _rewardedPollinatorIds = <String>{};
  double _birdSpawnTimer = 18;
  bool _pollinatorsSpawnedForBloom = false;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.flower == null) {
      state = state.copyWith(
        flower: FlowerGardenLogic.spawnSingleFlower(size),
        playAreaReady: true,
      );
    }
  }

  void startGame(FlowerGardenSettings settings) {
    _sessionTimer?.cancel();
    _rewardedPollinatorIds.clear();
    _birdSpawnTimer = 14 + FlowerGardenLogic.random.nextDouble() * 10;
    _pollinatorsSpawnedForBloom = false;

    final flower = _playArea == Size.zero
        ? null
        : FlowerGardenLogic.spawnSingleFlower(_playArea);

    state = FlowerGardenState(
      sessionPhase: GardenSessionPhase.playing,
      settings: settings,
      flower: flower,
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
        state = state.copyWith(remainingSeconds: 0);
        _endSession(reason: 'timer');
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void tick(double delta) {
    if (state.sessionPhase != GardenSessionPhase.playing ||
        _playArea == Size.zero ||
        state.flower == null) {
      return;
    }

    final intensity = state.settings.animationIntensity;
    final moveMult = state.settings.flowerMoveMult;
    var flower = state.flower!;
    var pollinators = [...state.pollinators];
    var bird = state.bird;
    var showRainbow = false;
    var showSunbeam = false;
    var showSparkles = false;
    var coinsEarned = state.coinsEarned;
    var xpEarned = state.xpEarned;
    var starsEarned = state.starsEarned;
    String? rewardText = state.lastRewardText;

    final prevPhase = flower.phase;
    flower = FlowerGardenLogic.updateFlower(
      flower,
      delta,
      intensity,
      moveMult,
      _playArea,
      state.settings,
    );

    if (prevPhase == FlowerPhase.blooming && flower.phase == FlowerPhase.open) {
      if (!_pollinatorsSpawnedForBloom) {
        pollinators = FlowerGardenLogic.spawnPollinators(
          _playArea,
          flower.id,
          flower.x,
          flower.y,
        );
        _pollinatorsSpawnedForBloom = true;
        showSparkles = true;
        showSunbeam = true;
      }
    }

    String? feedbackMessage;
    var showMascot = state.showMascot;

    if (flower.phase == FlowerPhase.bud &&
        prevPhase == FlowerPhase.relocating) {
      _pollinatorsSpawnedForBloom = false;
      feedbackMessage = 'Tap the flower!';
      showMascot = false;
    }

    pollinators = pollinators.map((p) {
      if (p.phase == PollinatorPhase.gone) return p;
      return FlowerGardenLogic.updatePollinator(
        p: p,
        flowerX: flower.x,
        flowerY: flower.y,
        delta: delta,
        intensity: intensity,
        onNectarCollected: (collected) {
          if (_rewardedPollinatorIds.contains(collected.id)) return;
          _rewardedPollinatorIds.add(collected.id);

          final reward = FlowerGardenLogic.pollinatorReward(
            state.settings,
            state.bloomsCount,
          );
          coinsEarned += reward.coins;
          xpEarned += reward.xp;
          starsEarned += reward.stars;
          rewardText =
              '+${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}';
          showSparkles = true;
        },
      );
    }).toList();

    pollinators =
        pollinators.where((p) => p.phase != PollinatorPhase.gone).toList();

    // Unbloom once nectar is done (butterflies leaving / gone).
    // Failsafe: if open too long, close anyway so the cycle never stalls.
    if (flower.phase == FlowerPhase.open && _pollinatorsSpawnedForBloom) {
      final waitingForNectar = pollinators.any(
        (p) =>
            p.phase == PollinatorPhase.entering ||
            p.phase == PollinatorPhase.collecting,
      );
      // Butterflies finished drinking and are flying away.
      final finishedNectar = pollinators.isNotEmpty && !waitingForNectar;
      // All butterflies already gone after visiting.
      final allGoneAfterVisit =
          pollinators.isEmpty && flower.phaseTimer >= 0.35;
      final stuckOpen = flower.phaseTimer >= 8.0;
      if (finishedNectar || allGoneAfterVisit || stuckOpen) {
        flower = flower.copyWith(
          phase: FlowerPhase.cooldown,
          phaseTimer: 0,
          clearMorph: true,
        );
        _pollinatorsSpawnedForBloom = false;
      }
    }

    // Decorative birds only — never end the session. Only the timer does.
    if (bird != null && bird.phase != BirdPhase.gone) {
      bird = FlowerGardenLogic.updateBird(
        bird: bird,
        delta: delta,
        speedMult: state.settings.birdSpeedMult,
        intensity: intensity,
      );
      if (bird.phase == BirdPhase.landing) {
        // Fly away instead of ending the game.
        bird = FlowerGardenLogic.scareBird(bird);
      }
      if (bird.phase == BirdPhase.gone) {
        bird = null;
      }
    }

    if (bird == null &&
        (flower.phase == FlowerPhase.bud ||
            flower.phase == FlowerPhase.relocating)) {
      _birdSpawnTimer -= delta;
      if (_birdSpawnTimer <= 0) {
        bird = FlowerGardenLogic.spawnBird(_playArea, flower.x, flower.y);
        _birdSpawnTimer = 28 + FlowerGardenLogic.random.nextDouble() * 18;
      }
    }

    showRainbow = flower.phase == FlowerPhase.open ||
        flower.phase == FlowerPhase.blooming;
    showSparkles = showSparkles ||
        flower.phase == FlowerPhase.blooming ||
        flower.phase == FlowerPhase.open;

    state = state.copyWith(
      flower: flower,
      pollinators: pollinators,
      bird: bird,
      clearBird: bird == null,
      showRainbow: showRainbow,
      showSunbeam: showSunbeam,
      showSparkles: showSparkles,
      coinsEarned: coinsEarned,
      xpEarned: xpEarned,
      starsEarned: starsEarned,
      lastRewardText: rewardText,
      feedbackMessage: feedbackMessage,
      showMascot: feedbackMessage != null ? false : showMascot,
    );
    if (feedbackMessage != null) {
      _scheduleFeedbackClear();
    }
  }

  bool tapFlower(String flowerId) {
    if (state.sessionPhase != GardenSessionPhase.playing) return false;
    final flower = state.flower;
    if (flower == null || flower.id != flowerId || !flower.canTap) return false;

    // Retap while butterfly is coming / drinking → slow colour change.
    if (flower.phase == FlowerPhase.blooming ||
        flower.phase == FlowerPhase.open) {
      final next = FlowerGardenLogic.pickDifferentPaletteIndex(
        flower.morphPaletteIndex ?? flower.paletteIndex,
      );
      state = state.copyWith(
        flower: flower.copyWith(
          morphPaletteIndex: next,
          colorMorph: 0,
        ),
        showSparkles: true,
        feedbackMessage: 'Pretty colours!',
      );
      _scheduleFeedbackClear();
      return true;
    }

    final palette = FlowerGardenLogic.pickPalette(state.bloomsCount);
    final reward = FlowerGardenLogic.bloomReward(state.settings);
    final blooms = state.bloomsCount + 1;
    final msg = kGardenEncouragements[blooms % kGardenEncouragements.length];

    state = state.copyWith(
      flower: flower.copyWith(
        phase: FlowerPhase.blooming,
        bloomProgress: 0,
        clearMorph: true,
        paletteIndex: FlowerGardenLogic.paletteIndexFor(palette),
        petalCount: 5 + FlowerGardenLogic.random.nextInt(4),
        petalSpread: 0.85 + FlowerGardenLogic.random.nextDouble() * 0.35,
      ),
      pollinators: [],
      clearBird: true,
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
    _pollinatorsSpawnedForBloom = false;
    _birdSpawnTimer = 16 + FlowerGardenLogic.random.nextDouble() * 12;

    _scheduleFeedbackClear();
    return true;
  }

  bool tapBird() {
    if (state.sessionPhase != GardenSessionPhase.playing) return false;
    final bird = state.bird;
    if (bird == null || !bird.isTappable) return false;

    state = state.copyWith(
      bird: FlowerGardenLogic.scareBird(bird),
      feedbackMessage:
          kBirdScareMessages[FlowerGardenLogic.random.nextInt(kBirdScareMessages.length)],
      showSparkles: true,
      showMascot: true,
    );
    _birdSpawnTimer = 22 + FlowerGardenLogic.random.nextDouble() * 14;
    _scheduleFeedbackClear();
    return true;
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true,
          clearReward: true, showMascot: false);
      }
    });
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

  void _endSession({required String reason}) {
    _sessionTimer?.cancel();
    // Session always ends on the timer for this toddler tap game.
    final message = reason == 'timer'
        ? 'Amazing Garden Adventure!'
        : kBirdLandMessages[
            FlowerGardenLogic.random.nextInt(kBirdLandMessages.length)];
    state = state.copyWith(
      sessionPhase: GardenSessionPhase.finished,
      remainingSeconds: reason == 'timer' ? 0 : state.remainingSeconds,
      showRainbow: true,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: message,
      endReason: reason,
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
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.magicalFlowerGarden);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _rewardedPollinatorIds.clear();
    _birdSpawnTimer = 18;
    _pollinatorsSpawnedForBloom = false;
    state = const FlowerGardenState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
