import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/logic/alphabet_bridge_logic.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';

final alphabetBridgeControllerProvider =
    StateNotifierProvider<AlphabetBridgeController, AlphabetBridgeState>((ref) {
  return AlphabetBridgeController(ref);
});

class AlphabetBridgeController extends StateNotifier<AlphabetBridgeState> {
  AlphabetBridgeController(this._ref) : super(const AlphabetBridgeState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _roundTimer;

  void startGame(AlphabetBridgeSettings settings) {
    _cancelTimers();
    final round = AlphabetBridgeLogic.generateRound(
      settings: settings,
      recentLetterIndexes: const [],
      sequentialCursor: 0,
      round: 1,
    );
    state = AlphabetBridgeState(
      phase: AlphabetBridgePhase.playing,
      settings: settings,
      lowerCards: round.lower,
      upperCards: round.upper,
      recentLetterIndexes: round.chosenIndexes,
      sequentialCursor: round.nextSequentialCursor,
      round: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != AlphabetBridgePhase.playing &&
        state.phase != AlphabetBridgePhase.celebrating) {
      return;
    }
    final anim = AlphabetBridgeLogic.tickAnimations(
      state.lowerCards,
      state.upperCards,
      delta,
      state.settings.reducedMotion,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      lowerCards: anim.lower,
      upperCards: anim.upper,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != AlphabetBridgePhase.playing &&
          state.phase != AlphabetBridgePhase.celebrating) {
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
    if (state.phase == AlphabetBridgePhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  /// Returns true on correct match.
  bool tryConnect({required String lowerId, required String upperId}) {
    if (state.phase != AlphabetBridgePhase.playing) return false;

    final lowerIdx =
        state.lowerCards.indexWhere((c) => c.id == lowerId && !c.matched);
    final upperIdx =
        state.upperCards.indexWhere((c) => c.id == upperId && !c.matched);
    if (lowerIdx < 0 || upperIdx < 0) return false;

    final lower = state.lowerCards[lowerIdx];
    final upper = state.upperCards[upperIdx];
    final attempts = state.attempts + 1;
    final correct = lower.letterIndex == upper.letterIndex;

    if (!correct) {
      final lowers = [...state.lowerCards];
      lowers[lowerIdx] = lower.copyWith(shake: true, selected: false);
      final uppers = [
        for (final c in state.upperCards)
          c.copyWith(
            shake: c.id == upperId,
            hintPulse: c.letterIndex == lower.letterIndex && !c.matched,
            selected: false,
          ),
      ];
      state = state.copyWith(
        lowerCards: lowers,
        upperCards: uppers,
        attempts: attempts,
        streak: 0,
        feedbackMessage: AlphabetBridgeLogic.encouragePhrase(),
        spokenPhrase: AlphabetBridgeLogic.encouragePhrase(),
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(
          lowerCards: state.lowerCards
              .map((c) => c.copyWith(shake: false, selected: false))
              .toList(),
          upperCards: state.upperCards
              .map(
                (c) => c.copyWith(
                  shake: false,
                  hintPulse: false,
                  selected: false,
                ),
              )
              .toList(),
        );
      });
      return false;
    }

    final streak = state.streak + 1;
    final reward =
        AlphabetBridgeLogic.matchReward(state.settings, streak);
    final phrase = AlphabetBridgeLogic.successPhrase(lower.letterIndex);

    final lowers = [...state.lowerCards];
    lowers[lowerIdx] =
        lower.copyWith(matched: true, celebrate: true, selected: false);
    final uppers = [...state.upperCards];
    uppers[upperIdx] =
        upper.copyWith(matched: true, celebrate: true, selected: false);

    final connections = [
      ...state.connections,
      BridgeConnection(
        lowerId: lowerId,
        upperId: upperId,
        letterIndex: lower.letterIndex,
      ),
    ];

    state = state.copyWith(
      lowerCards: lowers,
      upperCards: uppers,
      connections: connections,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: AlphabetBridgePhase.celebrating,
      feedbackMessage: phrase,
      spokenPhrase: phrase,
      lastRewardText:
          '+${reward.points} Pts  +${reward.coins} Coins  +${reward.xp} XP',
      showSparkles: true,
      showMascot: true,
    );
    _scheduleFeedbackClear();

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      state = state.copyWith(
        lowerCards: state.lowerCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
        upperCards: state.upperCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
      );

      if (state.roundComplete) {
        _completeRound();
      } else {
        state = state.copyWith(
          phase: AlphabetBridgePhase.playing,
          showSparkles: false,
        );
        if (state.pendingEnd) _endSession();
      }
    });

    return true;
  }

  void _completeRound() {
    final bonus = AlphabetBridgeLogic.roundBonus(state.settings);
    state = state.copyWith(
      roundsCompleted: state.roundsCompleted + 1,
      score: state.score + bonus.points,
      coinsEarned: state.coinsEarned + bonus.coins,
      xpEarned: state.xpEarned + bonus.xp,
      starsEarned: state.starsEarned + bonus.stars,
      feedbackMessage: 'Round Complete!',
      lastRewardText:
          '+${bonus.points} Bonus  +${bonus.coins} Coins  +${bonus.xp} XP',
      showRoundBonus: true,
      showSparkles: true,
      showMascot: true,
    );
    _scheduleFeedbackClear();

    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (state.pendingEnd) {
        _endSession();
        return;
      }
      _loadNextRound();
    });
  }

  void _loadNextRound() {
    if (state.phase == AlphabetBridgePhase.finished) return;
    final nextRound = state.round + 1;
    final generated = AlphabetBridgeLogic.generateRound(
      settings: state.settings,
      recentLetterIndexes: state.recentLetterIndexes,
      sequentialCursor: state.sequentialCursor,
      round: nextRound,
    );
    state = state.copyWith(
      lowerCards: generated.lower,
      upperCards: generated.upper,
      connections: const [],
      recentLetterIndexes: AlphabetBridgeLogic.mergeRecent(
        state.recentLetterIndexes,
        generated.chosenIndexes,
      ),
      sequentialCursor: generated.nextSequentialCursor,
      round: nextRound,
      phase: AlphabetBridgePhase.playing,
      showSparkles: false,
      showRoundBonus: false,
    );
    if (state.pendingEnd) _endSession();
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearSpoken: true,
          showMascot: false,
          showRoundBonus: false,
        );
      }
    });
  }

  void pause() {
    if (state.phase == AlphabetBridgePhase.playing ||
        state.phase == AlphabetBridgePhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: AlphabetBridgePhase.paused);
    }
  }

  void resume() {
    if (state.phase == AlphabetBridgePhase.paused) {
      state = state.copyWith(phase: AlphabetBridgePhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: AlphabetBridgePhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const AlphabetBridgeState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _roundTimer?.cancel();
  }

  AlphabetBridgeResult getResult() => AlphabetBridgeLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.alphabetBridgeAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctMatches,
        totalMistakes:
            s.totalMistakes + (result.attempts - result.correctMatches),
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          AlphabetBridgeLogic.toReward(result),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.alphabetBridgeAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
