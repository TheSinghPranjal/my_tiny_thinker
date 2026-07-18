import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/logic/moon_rescue_logic.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

final moonRescueControllerProvider =
    StateNotifierProvider<MoonRescueController, MoonRescueState>((ref) {
  return MoonRescueController(ref);
});

class MoonRescueController extends StateNotifier<MoonRescueState> {
  MoonRescueController(this._ref) : super(const MoonRescueState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _launchTimer;
  Timer? _earthTimer;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (state.playArea == size) return;
    state = state.copyWith(playArea: size);
    if (state.phase == MoonRescuePhase.playing && state.astronauts.isEmpty) {
      _spawnCrew(state.settings);
    }
  }

  void startGame(MoonRescueSettings settings) {
    _cancelTimers();
    final area = state.playArea;
    final astronauts = area != Size.zero
        ? MoonRescueLogic.spawnInitial(area, settings)
        : <MoonAstronaut>[];
    state = MoonRescueState(
      phase: MoonRescuePhase.playing,
      settings: settings,
      astronauts: astronauts,
      rocket: const MoonRocket(),
      playArea: area,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
      spawnCounter: astronauts.length,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void _spawnCrew(MoonRescueSettings settings) {
    if (!state.playAreaReady) return;
    final astronauts =
        MoonRescueLogic.spawnInitial(state.playArea, settings);
    state = state.copyWith(
      astronauts: astronauts,
      spawnCounter: astronauts.length,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != MoonRescuePhase.playing &&
          state.phase != MoonRescuePhase.celebrating) {
        return;
      }
      if (state.settings.unlimitedTime) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        _requestEnd();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEnd() {
    if (state.pendingEnd) return;
    if (state.hasActiveRescue || state.hasActiveLaunch) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.phase != MoonRescuePhase.playing &&
        state.phase != MoonRescuePhase.celebrating) {
      return;
    }
    if (!state.playAreaReady) return;

    final tick = MoonRescueLogic.tick(
      astronauts: state.astronauts,
      rocket: state.rocket,
      settings: state.settings,
      delta: delta,
      area: state.playArea,
    );

    var astronauts = tick.astronauts;
    var rocket = tick.rocket;
    var score = state.score;
    var coins = state.coinsEarned;
    var xp = state.xpEarned;
    var stars = state.starsEarned;
    var rescued = state.astronautsRescued;
    var streak = state.streak;
    var maxStreak = state.maxStreak;
    var spawnCounter = state.spawnCounter;
    var feedback = state.feedbackMessage;
    var rewardText = state.lastRewardText;
    var spoken = state.spokenPhrase;
    var showSparkles = state.showSparkles;
    var showMascot = state.showMascot;
    var phase = state.phase;

    if (tick.boardedIds.isNotEmpty) {
      final reward = MoonRescueLogic.rescueReward(state.settings);
      final n = tick.boardedIds.length;
      for (var i = 0; i < n; i++) {
        rescued += 1;
        streak += 1;
        maxStreak = math.max(maxStreak, streak);
        score += reward.points;
        coins += reward.coins;
        xp += reward.xp;
        stars += reward.stars;
      }
      feedback = n == 1 ? 'Astronaut Rescued!' : '$n Astronauts Rescued!';
      rewardText =
          '+${reward.points * n} Pts  +${reward.coins * n} Coins  +${reward.xp * n} XP';
      spoken = 'Great rescue!';
      showSparkles = true;
      showMascot = true;
      phase = MoonRescuePhase.celebrating;
      _scheduleFeedbackClear();

      // Smoothly bring replacements in from the edges.
      final need = state.settings.astronautCount - astronauts.length;
      for (var i = 0; i < need; i++) {
        spawnCounter += 1;
        astronauts = [
          ...astronauts,
          MoonRescueLogic.spawnAstronaut(
            state.playArea,
            state.settings,
            idSuffix: spawnCounter,
            smoothEntrance: true,
          ),
        ];
      }

      Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (state.phase == MoonRescuePhase.celebrating &&
            state.rocket.phase != RocketPhase.launching) {
          state = state.copyWith(
            phase: MoonRescuePhase.playing,
            showSparkles: false,
          );
          if (state.pendingEnd &&
              !state.hasActiveRescue &&
              !state.hasActiveLaunch) {
            _endSession();
          }
        }
      });
    }

    if (tick.becameReady) {
      // Keep rescue reward text if this frame also boarded the last seat.
      feedback = 'Tap to Launch!';
      spoken = 'Tap to Launch!';
      showMascot = true;
      _scheduleFeedbackClear();
    }

    // Finish launch when progress complete
    if (rocket.phase == RocketPhase.launching && rocket.launchProgress >= 1) {
      _completeLaunch();
      return;
    }

    state = state.copyWith(
      astronauts: astronauts,
      rocket: rocket,
      score: score,
      coinsEarned: coins,
      xpEarned: xp,
      starsEarned: stars,
      astronautsRescued: rescued,
      streak: streak,
      maxStreak: maxStreak,
      spawnCounter: spawnCounter,
      feedbackMessage: feedback,
      lastRewardText: rewardText,
      spokenPhrase: spoken,
      showSparkles: showSparkles,
      showMascot: showMascot,
      phase: phase,
      envPhase: state.envPhase + delta,
    );
  }

  bool get _canInteractAstronauts =>
      (state.phase == MoonRescuePhase.playing ||
          state.phase == MoonRescuePhase.celebrating) &&
      state.rocket.phase != RocketPhase.launching;

  void pushAstronaut(String id, Offset localDelta) {
    if (!_canInteractAstronauts) return;
    state = state.copyWith(
      astronauts: [
        for (final a in state.astronauts)
          if (a.id == id)
            MoonRescueLogic.pushAstronaut(a, localDelta, state.settings)
          else
            a,
      ],
    );
  }

  void tapAstronaut(String id) {
    if (!_canInteractAstronauts) return;
    state = state.copyWith(
      astronauts: [
        for (final a in state.astronauts)
          if (a.id == id)
            MoonRescueLogic.tapPush(a, state.settings)
          else
            a,
      ],
    );
  }

  void tapRocket() {
    if (state.phase != MoonRescuePhase.playing &&
        state.phase != MoonRescuePhase.celebrating) {
      return;
    }
    if (state.rocket.phase != RocketPhase.ready) return;
    if (state.rocket.passengers < state.settings.rocketCapacity) return;

    final bonus = MoonRescueLogic.launchBonus(state.settings);
    state = state.copyWith(
      rocket: state.rocket.copyWith(
        phase: RocketPhase.launching,
        launchProgress: 0,
      ),
      // Show launch rewards immediately on tap.
      score: state.score + bonus.points,
      coinsEarned: state.coinsEarned + bonus.coins,
      xpEarned: state.xpEarned + bonus.xp,
      starsEarned: state.starsEarned + bonus.stars,
      feedbackMessage: 'Liftoff! +${bonus.points} Pts',
      lastRewardText:
          '+${bonus.points} Pts  +${bonus.coins} Coins  +${bonus.xp} XP',
      spokenPhrase: 'Liftoff!',
      showSparkles: true,
      showMascot: true,
      phase: MoonRescuePhase.celebrating,
    );
    _scheduleFeedbackClear();
  }

  void _completeLaunch() {
    state = state.copyWith(
      rocketsLaunched: state.rocketsLaunched + 1,
      streak: 0,
      feedbackMessage: 'Mission Complete!',
      spokenPhrase: 'Mission Complete!',
      showEarthCelebration: true,
      showSparkles: true,
      showMascot: true,
      rocket: state.rocket.copyWith(
        phase: RocketPhase.arriving,
        arriveProgress: 0,
        passengers: 0,
        launchProgress: 0,
        x: 1.15,
        y: MoonRescueLogic.rocketPadY,
      ),
    );
    _scheduleFeedbackClear();

    _earthTimer?.cancel();
    _earthTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      state = state.copyWith(
        showEarthCelebration: false,
        showSparkles: false,
        phase: MoonRescuePhase.playing,
      );
      if (state.pendingEnd && !state.hasActiveLaunch && !state.hasActiveRescue) {
        _endSession();
      }
    });
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearSpoken: true,
          showMascot: false,
        );
      }
    });
  }

  void pause() {
    if (state.phase == MoonRescuePhase.playing ||
        state.phase == MoonRescuePhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: MoonRescuePhase.paused);
    }
  }

  void resume() {
    if (state.phase == MoonRescuePhase.paused) {
      state = state.copyWith(phase: MoonRescuePhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: MoonRescuePhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    final area = state.playArea;
    state = MoonRescueState(playArea: area);
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _launchTimer?.cancel();
    _earthTimer?.cancel();
  }

  MoonRescueResult getResult() => MoonRescueLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.astronautsRescued == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.moonRescueAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.astronautsRescued,
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          MoonRescueLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.moonRescueAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
