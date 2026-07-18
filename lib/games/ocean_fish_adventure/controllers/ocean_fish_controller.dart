import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/logic/ocean_fish_logic.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';

final oceanFishControllerProvider =
    StateNotifierProvider<OceanFishController, OceanFishState>((ref) {
  return OceanFishController(ref);
});

class OceanFishController extends StateNotifier<OceanFishState> {
  OceanFishController(this._ref) : super(const OceanFishState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (state.phase == OceanFishPhase.ready && state.fish.isEmpty) {
      _fillFish();
    }
  }

  void startGame(OceanFishSettings settings) {
    _sessionTimer?.cancel();
    state = OceanFishState(
      phase: OceanFishPhase.playing,
      settings: settings,
      remainingSeconds: settings.sessionSeconds,
    );
    if (_playArea != Size.zero) _fillFish();
    _startTimer();
  }

  void _fillFish() {
    if (_playArea == Size.zero) return;
    final max = state.settings.maxFishOnScreen;
    final current = state.fish.where((f) => f.phase != FishPhase.gone).length;
    var fish = [...state.fish.where((f) => f.phase != FishPhase.gone)];
    for (var i = current; i < max; i++) {
      fish.add(FishSpawner.create(
        playArea: _playArea,
        settings: state.settings,
        slotIndex: i,
        totalSlots: max,
      ));
    }
    state = state.copyWith(fish: fish);
  }

  int _nextFreeSlot() {
    final max = state.settings.maxFishOnScreen;
    final used = state.fish
        .where((f) => f.phase != FishPhase.gone)
        .map((f) => f.slotIndex)
        .toSet();
    for (var i = 0; i < max; i++) {
      if (!used.contains(i)) return i;
    }
    return 0;
  }

  void _spawnOne() {
    if (_playArea == Size.zero) return;
    final active = state.fish.where((f) => f.phase != FishPhase.gone).length;
    if (active >= state.settings.maxFishOnScreen) return;
    final max = state.settings.maxFishOnScreen;
    final fish = [
      ...state.fish.where((f) => f.phase != FishPhase.gone),
      FishSpawner.create(
        playArea: _playArea,
        settings: state.settings,
        slotIndex: _nextFreeSlot(),
        totalSlots: max,
      ),
    ];
    state = state.copyWith(fish: fish);
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != OceanFishPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        _endSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void tick(double delta) {
    if (state.phase != OceanFishPhase.playing || _playArea == Size.zero) return;

    var fish = FishMovement.update(
      fish: state.fish,
      playArea: _playArea,
      delta: delta,
      speedMult: state.settings.speedMultiplier,
    );

    // Auto-spawn when fish exit or gone
    final max = state.settings.maxFishOnScreen;
    if (fish.length < max) {
      final spawning = [...fish];
      while (spawning.length < max) {
        final used = spawning.map((f) => f.slotIndex).toSet();
        var slot = 0;
        for (var i = 0; i < max; i++) {
          if (!used.contains(i)) {
            slot = i;
            break;
          }
        }
        spawning.add(
          FishSpawner.create(
            playArea: _playArea,
            settings: state.settings,
            slotIndex: slot,
            totalSlots: max,
          ),
        );
      }
      fish = spawning;
    }

    state = state.copyWith(fish: fish);
  }

  bool tapFish(String fishId) {
    if (state.phase != OceanFishPhase.playing) return false;

    final idx = state.fish.indexWhere((f) => f.id == fishId);
    if (idx == -1) return false;

    final fish = state.fish[idx];
    if (fish.phase != FishPhase.waiting && fish.phase != FishPhase.entering) {
      return false;
    }

    final exit = FishSpawner.exitAlongHeading(
      fish.x,
      fish.y,
      fish.rotation,
      _playArea,
    );
    final reward = OceanFishScoring.rewardForTap(state.settings);
    final newTapped = state.fishTapped + 1;
    final addStar = OceanFishScoring.fishTappedEveryN(newTapped) ? 1 : 0;
    final msg = kEncouragements[newTapped % kEncouragements.length];
    final showMascot = newTapped % 4 == 0;

    final updated = [...state.fish];
    updated[idx] = FishEntity(
      id: fish.id,
      variantIndex: fish.variantIndex,
      x: fish.x,
      y: fish.y,
      rotation: fish.rotation,
      phase: FishPhase.tapped,
      size: fish.size,
      pathT: fish.pathT,
      waitAngle: fish.waitAngle,
      startX: fish.startX,
      startY: fish.startY,
      controlX: fish.controlX,
      controlY: fish.controlY,
      targetX: fish.targetX,
      targetY: fish.targetY,
      exitX: exit.$1,
      exitY: exit.$2,
      scale: 1,
    );

    state = state.copyWith(
      fish: updated,
      fishTapped: newTapped,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + addStar,
      feedbackMessage: msg,
      showMascotCelebrate: showMascot,
      lastRewardText: '+${reward.coins} Coin  +${reward.xp} XP',
    );

    // Immediately spawn replacement so screen never empties
    _spawnOne();

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascotCelebrate: false);
      }
    });

    // Transition to exiting after brief tap feedback
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final i = state.fish.indexWhere((f) => f.id == fishId);
      if (i == -1) return;
      final f = state.fish[i];
      if (f.phase == FishPhase.tapped) {
        final list = [...state.fish];
        list[i] = f.copyWith(phase: FishPhase.exiting, scale: 1);
        state = state.copyWith(fish: list);
      }
    });

    return true;
  }

  void pause() {
    if (state.phase == OceanFishPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: OceanFishPhase.paused);
    }
  }

  void resume() {
    if (state.phase == OceanFishPhase.paused) {
      state = state.copyWith(phase: OceanFishPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(phase: OceanFishPhase.finished);
  }

  OceanFishResult getResult() => OceanFishScoring.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.fishTapped == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(storage, GameId.oceanFishAdventure, (s) => s.copyWith(
          bestScore: s.bestScore + result.fishTapped,
          starsEarned: s.starsEarned + result.stars,
          timesPlayed: s.timesPlayed + 1,
          totalCorrect: s.totalCorrect + result.fishTapped,
          lastPlayed: DateTime.now(),
        ));

    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
          ),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.oceanFishAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _playArea = Size.zero;
    state = const OceanFishState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
