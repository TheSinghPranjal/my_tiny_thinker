import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/logic/bunny_hop_logic.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

final bunnyHopControllerProvider =
    StateNotifierProvider<BunnyHopController, BunnyHopState>((ref) {
  return BunnyHopController(ref);
});

class BunnyHopController extends StateNotifier<BunnyHopState> {
  BunnyHopController(this._ref) : super(const BunnyHopState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.lilyPads.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, BunnyHopSettings settings) {
    final padCount = settings.effectiveLilyPadCount;
    final cracked = BunnyHopLogic.pickCrackedIndices(padCount).toSet();
    final pads = BunnyHopLogic.buildLilyPads(area, padCount, cracked);
    final (bx, by) = BunnyHopLogic.positionForStep(area, -1, padCount);
    state = state.copyWith(
      lilyPads: pads,
      bunny: BunnyEntity(x: bx, y: by, facingRight: true),
      carrot: BunnyHopLogic.buildCarrot(area, CarrotSide.sideB),
      travelDirection: TravelDirection.towardB,
      stepIndex: -1,
      originBankForCrossing: -1,
      playAreaReady: true,
    );
  }

  void startGame(BunnyHopSettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    final s = state;
    state = BunnyHopState(
      sessionPhase: BunnyHopSessionPhase.playing,
      settings: settings,
      lilyPads: s.lilyPads,
      bunny: s.bunny,
      carrot: s.carrot,
      travelDirection: TravelDirection.towardB,
      stepIndex: -1,
      originBankForCrossing: -1,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != BunnyHopSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      if (rem <= 0) {
        state = state.copyWith(elapsedSeconds: elapsed);
        _requestEndSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem, elapsedSeconds: elapsed);
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
    if (state.sessionPhase != BunnyHopSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var bunny = state.bunny;
    var lilyPads = [...state.lilyPads];
    var carrot = state.carrot;
    var stepIndex = state.stepIndex;
    var crackedStandTimer = state.crackedStandTimer;
    var showSparkles = state.showSparkles;
    var showCarrot = state.showCarrotCelebration;
    var travelDirection = state.travelDirection;
    final envPhase = state.envPhase + delta * 0.35;
    final padCount = state.padCount;

    final prevPhase = bunny.phase;

    for (var i = 0; i < lilyPads.length; i++) {
      lilyPads[i] = BunnyHopLogic.updateLilyPad(lilyPads[i], delta, state.settings);
    }

    bunny = BunnyHopLogic.updateBunny(bunny, delta, state.settings);
    carrot = BunnyHopLogic.updateCarrot(carrot, delta, state.settings);

    if (prevPhase == BunnyPhase.hopping && bunny.phase == BunnyPhase.landed) {
      stepIndex = BunnyHopLogic.nextStep(stepIndex, travelDirection);
      bunny = bunny.copyWith(
        phase: BunnyPhase.idle,
        x: bunny.hopToX,
        y: bunny.hopToY,
      );

      final hops = state.totalHops + 1;
      final streak = state.currentStreak + 1;
      final hopReward = BunnyHopLogic.hopReward(state.settings, hopCount: hops);

      var points = state.pointsEarned + hopReward.points;
      var coins = state.coinsEarned + hopReward.coins;
      var xp = state.xpEarned + hopReward.xp;
      var stars = state.starsEarned + hopReward.stars;
      var carrots = state.carrotsCollected;
      var feedback = BunnyHopLogic.pickHopMessage(hops);
      var rewardText =
          '+${hopReward.points} Points  +${hopReward.coins} Coins  +${hopReward.xp} XP${hopReward.stars > 0 ? '  +${hopReward.stars} Star' : ''}';
      var mascot = hops % 4 == 0;
      showSparkles = true;
      var celebrating = false;

      if (BunnyHopLogic.reachedCarrot(stepIndex, padCount, carrot.side)) {
        carrots += 1;
        final cReward = BunnyHopLogic.carrotReward(state.settings, carrotCount: carrots);
        points += cReward.points;
        coins += cReward.coins;
        xp += cReward.xp;
        stars += cReward.stars;
        feedback = BunnyHopLogic.pickCarrotMessage(carrots);
        rewardText =
            'Carrot!  +${cReward.points} Points  +${cReward.coins} Coins  +${cReward.xp} XP  +${cReward.stars} Stars';
        bunny = bunny.copyWith(phase: BunnyPhase.celebrating, actionTimer: 0, celebrateProgress: 0);
        mascot = true;
        showCarrot = true;
        celebrating = true;
      } else if (BunnyHopLogic.isOnCrackedPad(stepIndex, padCount, lilyPads)) {
        crackedStandTimer = 0;
      } else {
        crackedStandTimer = 0;
      }

      state = state.copyWith(
        totalHops: hops,
        currentStreak: celebrating ? streak + 1 : streak,
        longestStreak: math.max(state.longestStreak, celebrating ? streak + 1 : streak),
        pointsEarned: points,
        coinsEarned: coins,
        xpEarned: xp,
        starsEarned: stars,
        carrotsCollected: carrots,
        feedbackMessage: feedback,
        lastRewardText: rewardText,
        showMascot: mascot,
        showSparkles: true,
        showCarrotCelebration: showCarrot,
        stepIndex: stepIndex,
        bunny: bunny,
        resetCrackedTimer: !BunnyHopLogic.isOnCrackedPad(stepIndex, padCount, lilyPads),
        crackedStandTimer: BunnyHopLogic.isOnCrackedPad(stepIndex, padCount, lilyPads) ? 0 : 0,
      );
      if (celebrating) {
        _scheduleFeedbackClear(long: true);
      } else {
        _scheduleFeedbackClear();
      }
    }

    if (prevPhase == BunnyPhase.celebrating && bunny.phase == BunnyPhase.idle) {
      final newSide =
          carrot.side == CarrotSide.sideB ? CarrotSide.sideA : CarrotSide.sideB;
      travelDirection =
          newSide == CarrotSide.sideB ? TravelDirection.towardB : TravelDirection.towardA;
      carrot = BunnyHopLogic.buildCarrot(_playArea, newSide);
      crackedStandTimer = 0;
    }

    if (prevPhase == BunnyPhase.recovering && bunny.phase == BunnyPhase.idle) {
      state = state.copyWith(
        fallsRecovered: state.fallsRecovered + 1,
        currentStreak: 0,
        feedbackMessage: BunnyHopLogic.pickFallMessage(state.fallsRecovered + 1),
        showMascot: true,
        resetCrackedTimer: true,
      );
      _scheduleFeedbackClear(short: true);
    }

    if (bunny.phase == BunnyPhase.idle || bunny.phase == BunnyPhase.landed) {
      if (stepIndex >= 0 && stepIndex < padCount) {
        final pad = lilyPads[stepIndex];
        if (pad.isCracked && pad.phase == LilyPadPhase.floating) {
          crackedStandTimer += delta;
          if (crackedStandTimer >= state.settings.crackedSinkDelay) {
            lilyPads[stepIndex] = pad.copyWith(phase: LilyPadPhase.sinking, sinkProgress: 0);
            final recoveryStep = state.originBankForCrossing;
            final (tx, ty) =
                BunnyHopLogic.positionForStep(_playArea, recoveryStep, padCount);
            bunny = bunny.copyWith(
              phase: BunnyPhase.falling,
              fallProgress: 0,
              hopFromX: bunny.x,
              hopToX: tx,
              hopToY: ty,
            );
            crackedStandTimer = 0;
          }
        } else {
          crackedStandTimer = 0;
        }
      } else {
        crackedStandTimer = 0;
      }
    }

    if (prevPhase == BunnyPhase.falling && bunny.phase == BunnyPhase.swimming) {
      // swim target = recovery bank
    }

    if (prevPhase == BunnyPhase.swimming && bunny.phase == BunnyPhase.recovering) {
      final recoveryStep = state.originBankForCrossing;
      final (rx, ry) = BunnyHopLogic.positionForStep(_playArea, recoveryStep, padCount);
      bunny = bunny.copyWith(x: rx, y: ry);
      stepIndex = recoveryStep;
      if (state.stepIndex >= 0 && state.stepIndex < padCount) {
        final idx = state.stepIndex;
        lilyPads[idx] = lilyPads[idx].copyWith(
          phase: LilyPadPhase.floating,
          sinkProgress: 0,
          y: BunnyHopLogic.riverY(_playArea),
        );
      }
    }

    if (showSparkles) showSparkles = false;
    if (showCarrot) showCarrot = false;

    final hasActive = bunny.phase == BunnyPhase.hopping ||
        bunny.phase == BunnyPhase.celebrating ||
        bunny.phase == BunnyPhase.falling ||
        bunny.phase == BunnyPhase.swimming ||
        bunny.phase == BunnyPhase.recovering;

    if (state.pendingEnd && !hasActive) {
      _endSession();
      return;
    }

    state = state.copyWith(
      bunny: bunny,
      lilyPads: lilyPads,
      carrot: carrot,
      stepIndex: stepIndex,
      crackedStandTimer: crackedStandTimer,
      travelDirection: travelDirection,
      envPhase: envPhase,
      showSparkles: showSparkles,
      showCarrotCelebration: showCarrot,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool tapHop() {
    if (!state.canTap || _playArea == Size.zero) return false;

    final padCount = state.padCount;
    final next = BunnyHopLogic.nextStep(state.stepIndex, state.travelDirection);
    if (state.travelDirection == TravelDirection.towardB && next > padCount) return false;
    if (state.travelDirection == TravelDirection.towardA && next < -1) return false;

    if (state.stepIndex >= 0 &&
        state.stepIndex < padCount &&
        state.lilyPads[state.stepIndex].phase == LilyPadPhase.sunk) {
      return false;
    }

    final (fromX, fromY) =
        BunnyHopLogic.positionForStep(_playArea, state.stepIndex, padCount);
    final (toX, toY) = BunnyHopLogic.positionForStep(_playArea, next, padCount);

    final newOrigin = (state.stepIndex == -1 || state.stepIndex == padCount)
        ? state.stepIndex
        : state.originBankForCrossing;

    state = state.copyWith(
      bunny: state.bunny.copyWith(
        phase: BunnyPhase.hopping,
        hopProgress: 0,
        hopFromX: fromX,
        hopFromY: fromY,
        hopToX: toX,
        hopToY: toY,
        x: fromX,
        y: fromY,
        facingRight: state.travelDirection == TravelDirection.towardB,
      ),
      originBankForCrossing: newOrigin,
      resetCrackedTimer: true,
      inactivityTimer: 0,
    );
    return true;
  }

  void _scheduleFeedbackClear({bool short = false, bool long = false}) {
    _feedbackTimer?.cancel();
    final ms = long ? 2200 : (short ? 1400 : 1600);
    _feedbackTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });
  }

  void pause() {
    if (state.sessionPhase == BunnyHopSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: BunnyHopSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == BunnyHopSessionPhase.paused) {
      state = state.copyWith(sessionPhase: BunnyHopSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: BunnyHopSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Bunny Adventure!',
    );
  }

  BunnyHopResult getResult() => BunnyHopLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.totalHops == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.bunnyHopAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.carrotsCollected),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.totalHops,
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
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const BunnyHopState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
