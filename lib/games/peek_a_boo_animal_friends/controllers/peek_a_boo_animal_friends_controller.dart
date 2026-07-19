import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/logic/peek_a_boo_animal_friends_logic.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';

final peekABooControllerProvider =
    StateNotifierProvider<PeekABooController, PeekABooState>((ref) {
  return PeekABooController(ref);
});

class PeekABooController extends StateNotifier<PeekABooState> {
  PeekABooController(this._ref) : super(const PeekABooState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.bushes.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, PeekABooSettings settings) {
    final bushes = PeekABooLogic.spawnBushes(area, settings.effectiveBushCount);
    final animals = PeekABooLogic.assignHiddenAnimals(
      bushes: bushes,
      animalCount: settings.effectiveHiddenAnimals,
    );
    final synced = PeekABooLogic.syncBushAnimalFlags(bushes, animals);
    state = state.copyWith(
      bushes: synced,
      animals: animals,
      playAreaReady: true,
    );
  }

  void startGame(PeekABooSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = PeekABooState(
      sessionPhase: PeekABooSessionPhase.playing,
      settings: settings,
      bushes: state.bushes,
      animals: state.animals,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != PeekABooSessionPhase.playing) return;
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
    if (state.hasActiveReveal) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != PeekABooSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var bushes = state.bushes
        .map((b) => PeekABooLogic.updateBush(b, delta, state.settings))
        .toList();
    var animals = [...state.animals];

    for (var i = 0; i < animals.length; i++) {
      final bush = bushes.where((b) => b.id == animals[i].bushId).firstOrNull;
      animals[i] = PeekABooLogic.updateAnimal(
        animals[i],
        bush,
        delta,
        _playArea,
        state.settings,
      );
    }

    final gone = animals.where((a) => a.phase == AnimalPhase.gone).toList();
    if (gone.isNotEmpty) {
      animals.removeWhere((a) => a.phase == AnimalPhase.gone);
      bushes = bushes
          .map((b) => b.copyWith(
                hasAnimal: false,
                visualPhase: BushVisualPhase.swaying,
                openProgress: 0,
              ))
          .toList();

      final needed = state.settings.effectiveHiddenAnimals -
          animals.where((a) => a.phase == AnimalPhase.hidden).length;
      if (needed > 0) {
        final recentIds = animals.map((a) => a.animalId).toSet();
        final spawned = PeekABooLogic.assignHiddenAnimals(
          bushes: bushes,
          animalCount: needed,
          excludeAnimalIds: recentIds,
        );
        animals.addAll(spawned);
      }
      bushes = PeekABooLogic.syncBushAnimalFlags(bushes, animals);
    }

    if (state.pendingEnd && !state.hasActiveReveal) {
      _endSession();
      return;
    }

    state = state.copyWith(bushes: bushes, animals: animals);
  }

  bool tapBush(String bushId) {
    if (state.sessionPhase != PeekABooSessionPhase.playing) return false;

    final bushIdx = state.bushes.indexWhere((b) => b.id == bushId);
    if (bushIdx == -1) return false;
    final bush = state.bushes[bushIdx];
    if (!bush.canTap) return false;

    final animalIdx = state.animals.indexWhere(
      (a) => a.bushId == bushId && a.phase == AnimalPhase.hidden,
    );

    var bushes = [...state.bushes];
    var bushesExplored = state.bushesExplored + 1;

    if (animalIdx == -1) {
      bushes[bushIdx] = bush.copyWith(
        visualPhase: BushVisualPhase.bouncing,
        bounceProgress: 1,
      );
      bushes = _hintAnimalBushes(bushes);
      final missed = state.missedAttempts + 1;
      state = state.copyWith(
        bushes: bushes,
        bushesExplored: bushesExplored,
        missedAttempts: missed,
        feedbackMessage: PeekABooLogic.pickMissMessage(missed),
        showMascot: missed >= 3,
      );
      _scheduleFeedbackClear();
      return true;
    }

    final animal = state.animals[animalIdx];
    final def = animal.def;
    final reward = PeekABooLogic.discoveryReward(
      state.settings,
      state.discoveriesCount + 1,
    );
    final discoveries = state.discoveriesCount + 1;

    bushes[bushIdx] = bush.copyWith(
      visualPhase: BushVisualPhase.opening,
      openProgress: 0.01,
      hasAnimal: true,
    );

    final animals = [...state.animals];
    animals[animalIdx] = animal.copyWith(
      phase: AnimalPhase.popping,
      popProgress: 0,
    );

    state = state.copyWith(
      bushes: bushes,
      animals: animals,
      discoveriesCount: discoveries,
      bushesExplored: bushesExplored,
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: PeekABooLogic.pickEncouragement(discoveries),
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      lastAnnouncement: def?.announcement,
      showMascot: discoveries % 3 == 0,
      showSparkles: true,
      missedAttempts: 0,
    );
    _scheduleFeedbackClear();
    return true;
  }

  List<BushEntity> _hintAnimalBushes(List<BushEntity> bushes) {
    return bushes.map((b) {
      if (!b.hasAnimal) return b;
      return b.copyWith(
        visualPhase: BushVisualPhase.hintShaking,
        shakeIntensity: 1.6,
        shakeTimer: 2.5,
      );
    }).toList();
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == PeekABooSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: PeekABooSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == PeekABooSessionPhase.paused) {
      state = state.copyWith(sessionPhase: PeekABooSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: PeekABooSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Peek-a-Boo Adventure!',
    );
  }

  PeekABooResult getResult() => PeekABooLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.discoveriesCount == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.peekABooAnimalFriends,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.discoveriesCount),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.discoveriesCount,
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
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.peekABooAnimalFriends);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const PeekABooState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
