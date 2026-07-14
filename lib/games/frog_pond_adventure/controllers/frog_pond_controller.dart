import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/logic/frog_pond_logic.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';

final frogPondControllerProvider =
    StateNotifierProvider<FrogPondController, FrogPondState>((ref) {
  return FrogPondController(ref);
});

class FrogPondController extends StateNotifier<FrogPondState> {
  FrogPondController(this._ref) : super(const FrogPondState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  final _pendingSpawns = <String>{};

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.pads.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, FrogPondSettings settings) {
    final pads = FrogPondLogic.spawnPads(area, settings.effectivePadCount);
    final frogs = FrogPondLogic.spawnFrogsForPads(pads);
    state = state.copyWith(pads: pads, frogs: frogs, playAreaReady: true);
  }

  void startGame(FrogPondSettings settings) {
    _sessionTimer?.cancel();
    _pendingSpawns.clear();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = FrogPondState(
      sessionPhase: FrogPondSessionPhase.playing,
      settings: settings,
      pads: state.pads,
      frogs: state.frogs,
      remainingSeconds: settings.sessionSeconds,
      nextKingAt: settings.kingFrogInterval,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != FrogPondSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      var kingDue = state.kingDue;

      if (state.settings.kingFrogEnabled &&
          FrogPondLogic.shouldMarkKingDue(elapsed, state.nextKingAt)) {
        kingDue = true;
      }

      if (rem <= 0) {
        state = state.copyWith(elapsedSeconds: elapsed, kingDue: kingDue);
        _requestEndSession();
        return;
      }
      state = state.copyWith(
        remainingSeconds: rem,
        elapsedSeconds: elapsed,
        kingDue: kingDue,
      );
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.hasActiveAnimation ||
        state.frogs.any((f) => f.phase == FrogPhase.jumping)) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != FrogPondSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var pads = state.pads
        .map((p) => FrogPondLogic.updatePad(p, delta, state.settings))
        .toList();
    var frogs = [...state.frogs];
    var showSparkles = state.showSparkles;
    var kingDue = state.kingDue;
    var nextKingAt = state.nextKingAt;

    for (var i = 0; i < frogs.length; i++) {
      final pad = pads.where((p) => p.id == frogs[i].padId).firstOrNull;
      frogs[i] = FrogPondLogic.updateFrog(frogs[i], pad, delta, state.settings);
    }

    for (var i = 0; i < pads.length; i++) {
      final pad = pads[i];
      final frog = frogs.where((f) => f.padId == pad.id).firstOrNull;

      if (frog != null && frog.phase == FrogPhase.gone) {
        frogs.removeWhere((f) => f.id == frog.id);
        pads[i] = pad.copyWith(
          state: PadState.waiting,
          emptyTimer: FrogPondLogic.randomReplacementDelay(state.settings),
          showSplash: true,
          splashProgress: 0.01,
        );
        _pendingSpawns.add(pad.id);
        showSparkles = true;
      }

      if (pad.state == PadState.empty &&
          !frogs.any((f) => f.padId == pad.id) &&
          _pendingSpawns.contains(pad.id)) {
        final spawnKing = state.settings.kingFrogEnabled &&
            kingDue &&
            !frogs.any((f) => f.isKing && f.phase != FrogPhase.gone);
        final newFrog = FrogPondLogic.createFrog(
          pad,
          isKing: spawnKing,
          area: _playArea,
        );
        frogs.add(newFrog);
        pads[i] = pad.copyWith(state: PadState.occupied);
        _pendingSpawns.remove(pad.id);

        if (spawnKing) {
          kingDue = false;
          nextKingAt += state.settings.kingFrogInterval;
        }
      }
    }

    if (state.pendingEnd && !state.hasActiveAnimation) {
      _endSession();
      return;
    }

    state = state.copyWith(
      pads: pads,
      frogs: frogs,
      showSparkles: showSparkles,
      kingDue: kingDue,
      nextKingAt: nextKingAt,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool tapFrog(String frogId) {
    if (state.sessionPhase != FrogPondSessionPhase.playing) return false;

    final idx = state.frogs.indexWhere((f) => f.id == frogId);
    if (idx == -1) return false;
    final frog = state.frogs[idx];
    if (frog.phase != FrogPhase.idle && frog.phase != FrogPhase.reacting) {
      return false;
    }

    state = state.copyWith(inactivityTimer: 0);

    if (frog.isKing) {
      return _tapKingFrog(idx, frog);
    }
    return _tapNormalFrog(idx, frog);
  }

  bool _tapNormalFrog(int idx, FrogEntity frog) {
    final frogs = [...state.frogs];
    frogs[idx] = frog.copyWith(phase: FrogPhase.jumping, jumpProgress: 0);

    final reward = FrogPondLogic.tapReward(state.settings, isKing: false, tapCount: 1);
    final tapped = state.frogsTapped + 1;
    final streak = state.currentStreak + 1;

    state = state.copyWith(
      frogs: frogs,
      frogsTapped: tapped,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: FrogPondLogic.pickEncouragement(tapped),
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: tapped % 3 == 0,
      showSparkles: true,
    );
    _scheduleFeedbackClear();
    return true;
  }

  bool _tapKingFrog(int idx, FrogEntity frog) {
    final gems = frog.crownGems - 1;
    final frogs = [...state.frogs];

    if (gems > 0) {
      frogs[idx] = frog.copyWith(
        phase: FrogPhase.reacting,
        reactProgress: 0,
        crownGems: gems,
      );
      state = state.copyWith(
        frogs: frogs,
        feedbackMessage: 'Tap Tap!',
        showSparkles: true,
      );
      _scheduleFeedbackClear(short: true);
      return true;
    }

    frogs[idx] = frog.copyWith(
      phase: FrogPhase.jumping,
      jumpProgress: 0,
      crownGems: 0,
    );
    final reward = FrogPondLogic.tapReward(
      state.settings,
      isKing: true,
      tapCount: FrogEntity.kingTapRequired,
    );
    final tapped = state.frogsTapped + 1;
    final kings = state.kingFrogsRemoved + 1;
    final streak = state.currentStreak + 1;

    state = state.copyWith(
      frogs: frogs,
      frogsTapped: tapped,
      kingFrogsRemoved: kings,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: FrogPondLogic.pickKingMessage(kings),
      lastRewardText:
          'Double Reward!  +${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP  +${reward.stars} Stars',
      showMascot: true,
      showSparkles: true,
    );
    _scheduleFeedbackClear(long: true);
    return true;
  }

  void _scheduleFeedbackClear({bool short = false, bool long = false}) {
    _feedbackTimer?.cancel();
    final ms = long ? 2200 : (short ? 900 : 1500);
    _feedbackTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });
  }

  void pause() {
    if (state.sessionPhase == FrogPondSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: FrogPondSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == FrogPondSessionPhase.paused) {
      state = state.copyWith(sessionPhase: FrogPondSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: FrogPondSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Pond Adventure!',
    );
  }

  FrogPondResult getResult() => FrogPondLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.frogsTapped == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.frogPondAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.frogsTapped),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.frogsTapped,
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
    _pendingSpawns.clear();
    state = const FrogPondState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
