import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/logic/color_shape_bridge_logic.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';

final colorShapeBridgeControllerProvider =
    StateNotifierProvider<ColorShapeBridgeController, ColorShapeBridgeState>(
        (ref) {
  return ColorShapeBridgeController(ref);
});

class ColorShapeBridgeController extends StateNotifier<ColorShapeBridgeState> {
  ColorShapeBridgeController(this._ref) : super(const ColorShapeBridgeState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _roundTimer;

  void startGame(ColorShapeBridgeSettings settings) {
    _cancelTimers();
    final round = ColorShapeBridgeLogic.generateRound(
      settings: settings,
      recentKeys: const [],
      round: 1,
    );
    state = ColorShapeBridgeState(
      phase: ColorShapeBridgePhase.playing,
      settings: settings,
      promptCards: round.prompts,
      visualCards: round.visuals,
      recentKeys: round.chosenKeys,
      round: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != ColorShapeBridgePhase.playing &&
        state.phase != ColorShapeBridgePhase.celebrating) {
      return;
    }
    final anim = ColorShapeBridgeLogic.tickAnimations(
      state.promptCards,
      state.visualCards,
      delta,
      state.settings.reducedMotion,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      promptCards: anim.prompts,
      visualCards: anim.visuals,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != ColorShapeBridgePhase.playing &&
          state.phase != ColorShapeBridgePhase.celebrating) {
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
    if (state.phase == ColorShapeBridgePhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  bool tryConnect({required String promptId, required String visualId}) {
    if (state.phase != ColorShapeBridgePhase.playing) return false;

    final promptIdx =
        state.promptCards.indexWhere((c) => c.id == promptId && !c.matched);
    final visualIdx =
        state.visualCards.indexWhere((c) => c.id == visualId && !c.matched);
    if (promptIdx < 0 || visualIdx < 0) return false;

    final prompt = state.promptCards[promptIdx];
    final visual = state.visualCards[visualIdx];
    final attempts = state.attempts + 1;
    final correct = prompt.matchKey == visual.matchKey;

    if (!correct) {
      final prompts = [...state.promptCards];
      prompts[promptIdx] = prompt.copyWith(shake: true, selected: false);
      final visuals = [
        for (final c in state.visualCards)
          c.copyWith(
            shake: c.id == visualId,
            hintPulse: c.matchKey == prompt.matchKey && !c.matched,
            selected: false,
          ),
      ];
      state = state.copyWith(
        promptCards: prompts,
        visualCards: visuals,
        attempts: attempts,
        streak: 0,
        feedbackMessage: ColorShapeBridgeLogic.encouragePhrase(),
        spokenPhrase: ColorShapeBridgeLogic.encouragePhrase(),
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(
          promptCards: state.promptCards
              .map((c) => c.copyWith(shake: false, selected: false))
              .toList(),
          visualCards: state.visualCards
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
    final reward = ColorShapeBridgeLogic.matchReward(state.settings, streak);
    final phrase = ColorShapeBridgeLogic.successPhrase(prompt);

    final prompts = [...state.promptCards];
    prompts[promptIdx] =
        prompt.copyWith(matched: true, celebrate: true, selected: false);
    final visuals = [...state.visualCards];
    visuals[visualIdx] =
        visual.copyWith(matched: true, celebrate: true, selected: false);

    final connections = [
      ...state.connections,
      ColorShapeBridgeConnection(
        promptId: promptId,
        visualId: visualId,
        matchKey: prompt.matchKey,
      ),
    ];

    state = state.copyWith(
      promptCards: prompts,
      visualCards: visuals,
      connections: connections,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: ColorShapeBridgePhase.celebrating,
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
        promptCards: state.promptCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
        visualCards: state.visualCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
      );

      if (state.roundComplete) {
        _completeRound();
      } else {
        state = state.copyWith(
          phase: ColorShapeBridgePhase.playing,
          showSparkles: false,
        );
        if (state.pendingEnd) _endSession();
      }
    });

    return true;
  }

  void _completeRound() {
    final bonus = ColorShapeBridgeLogic.roundBonus(state.settings);
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
    if (state.phase == ColorShapeBridgePhase.finished) return;
    final nextRound = state.round + 1;
    final generated = ColorShapeBridgeLogic.generateRound(
      settings: state.settings,
      recentKeys: state.recentKeys,
      round: nextRound,
    );
    state = state.copyWith(
      promptCards: generated.prompts,
      visualCards: generated.visuals,
      connections: const [],
      recentKeys: ColorShapeBridgeLogic.mergeRecent(
        state.recentKeys,
        generated.chosenKeys,
      ),
      round: nextRound,
      phase: ColorShapeBridgePhase.playing,
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
    if (state.phase == ColorShapeBridgePhase.playing ||
        state.phase == ColorShapeBridgePhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: ColorShapeBridgePhase.paused);
    }
  }

  void resume() {
    if (state.phase == ColorShapeBridgePhase.paused) {
      state = state.copyWith(phase: ColorShapeBridgePhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: ColorShapeBridgePhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const ColorShapeBridgeState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _roundTimer?.cancel();
  }

  ColorShapeBridgeResult getResult() => ColorShapeBridgeLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.colorShapeBridgeAdventure,
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
          ColorShapeBridgeLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.colorShapeBridgeAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
