import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/logic/number_bridge_logic.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

final numberBridgeControllerProvider =
    StateNotifierProvider<NumberBridgeController, NumberBridgeState>((ref) {
  return NumberBridgeController(ref);
});

class NumberBridgeController extends StateNotifier<NumberBridgeState> {
  NumberBridgeController(this._ref) : super(const NumberBridgeState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _roundTimer;

  void startGame(NumberBridgeSettings settings) {
    _cancelTimers();
    final round = NumberBridgeLogic.generateRound(
      settings: settings,
      recentValues: const [],
      sequentialCursor: 0,
      round: 1,
    );
    state = NumberBridgeState(
      phase: NumberBridgePhase.playing,
      settings: settings,
      digitCards: round.digitCards,
      wordCards: round.wordCards,
      recentValues: round.chosenValues,
      round: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != NumberBridgePhase.playing &&
        state.phase != NumberBridgePhase.celebrating) {
      return;
    }
    final anim = NumberBridgeLogic.tickAnimations(
      state.digitCards,
      state.wordCards,
      delta,
      state.settings.reducedMotion,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      digitCards: anim.digitCards,
      wordCards: anim.wordCards,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != NumberBridgePhase.playing &&
          state.phase != NumberBridgePhase.celebrating) {
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
    if (state.phase == NumberBridgePhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  bool tryConnect({required String digitId, required String wordId}) {
    if (state.phase != NumberBridgePhase.playing) return false;

    final digitIdx =
        state.digitCards.indexWhere((c) => c.id == digitId && !c.matched);
    final wordIdx =
        state.wordCards.indexWhere((c) => c.id == wordId && !c.matched);
    if (digitIdx < 0 || wordIdx < 0) return false;

    final digit = state.digitCards[digitIdx];
    final word = state.wordCards[wordIdx];
    final attempts = state.attempts + 1;
    final correct = digit.value == word.value;

    if (!correct) {
      final digits = [...state.digitCards];
      digits[digitIdx] = digit.copyWith(shake: true, selected: false);
      final words = [
        for (final c in state.wordCards)
          c.copyWith(
            shake: c.id == wordId,
            hintPulse: c.value == digit.value && !c.matched,
            selected: false,
          ),
      ];
      state = state.copyWith(
        digitCards: digits,
        wordCards: words,
        attempts: attempts,
        streak: 0,
        feedbackMessage: NumberBridgeLogic.encouragePhrase(),
        spokenPhrase: NumberBridgeLogic.encouragePhrase(),
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(
          digitCards: state.digitCards
              .map((c) => c.copyWith(shake: false, selected: false))
              .toList(),
          wordCards: state.wordCards
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
    final reward = NumberBridgeLogic.matchReward(state.settings, streak);
    final phrase = NumberBridgeLogic.successPhrase(digit.value);

    final digits = [...state.digitCards];
    digits[digitIdx] =
        digit.copyWith(matched: true, celebrate: true, selected: false);
    final words = [...state.wordCards];
    words[wordIdx] =
        word.copyWith(matched: true, celebrate: true, selected: false);

    final connections = [
      ...state.connections,
      NumberBridgeConnection(
        digitId: digitId,
        wordId: wordId,
        value: digit.value,
      ),
    ];

    state = state.copyWith(
      digitCards: digits,
      wordCards: words,
      connections: connections,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: NumberBridgePhase.celebrating,
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
        digitCards: state.digitCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
        wordCards: state.wordCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
      );

      if (state.roundComplete) {
        _completeRound();
      } else {
        state = state.copyWith(
          phase: NumberBridgePhase.playing,
          showSparkles: false,
        );
        if (state.pendingEnd) _endSession();
      }
    });

    return true;
  }

  void _completeRound() {
    final bonus = NumberBridgeLogic.roundBonus(state.settings);
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
    if (state.phase == NumberBridgePhase.finished) return;
    final nextRound = state.round + 1;
    final pairCount = state.settings.pairCount.clamp(3, 7);
    final maxNumber = state.settings.maxNumber.clamp(20, 100);
    final sequentialCursor = ((nextRound - 1) * pairCount) % maxNumber;
    final generated = NumberBridgeLogic.generateRound(
      settings: state.settings,
      recentValues: state.recentValues,
      sequentialCursor: sequentialCursor,
      round: nextRound,
    );
    state = state.copyWith(
      digitCards: generated.digitCards,
      wordCards: generated.wordCards,
      connections: const [],
      recentValues: NumberBridgeLogic.mergeRecent(
        state.recentValues,
        generated.chosenValues,
      ),
      round: nextRound,
      phase: NumberBridgePhase.playing,
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
    if (state.phase == NumberBridgePhase.playing ||
        state.phase == NumberBridgePhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: NumberBridgePhase.paused);
    }
  }

  void resume() {
    if (state.phase == NumberBridgePhase.paused) {
      state = state.copyWith(phase: NumberBridgePhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: NumberBridgePhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const NumberBridgeState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _roundTimer?.cancel();
  }

  NumberBridgeResult getResult() => NumberBridgeLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.numberBridgeAdventure,
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
          NumberBridgeLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.numberBridgeAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
