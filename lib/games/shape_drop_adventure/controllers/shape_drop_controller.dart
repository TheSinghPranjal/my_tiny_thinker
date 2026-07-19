import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/logic/shape_drop_logic.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

final shapeDropControllerProvider =
    StateNotifierProvider<ShapeDropController, ShapeDropState>((ref) {
  return ShapeDropController(ref);
});

class ShapeDropController extends StateNotifier<ShapeDropState> {
  ShapeDropController(this._ref) : super(const ShapeDropState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  final Map<ShapeKind, int> _matchCounts = {};

  void startGame(ShapeDropSettings settings) {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _matchCounts.clear();
    final round = ShapeDropLogic.generateRound(settings, sequentialIndex: 0);
    state = ShapeDropState(
      phase: ShapeDropPhase.playing,
      settings: settings,
      target: round.target,
      options: round.options,
      remainingSeconds: settings.sessionSeconds,
      sequentialIndex: round.nextSequentialIndex,
    );
    _startTimer();
  }

  void tickEnv(double delta) {
    if (state.phase != ShapeDropPhase.playing &&
        state.phase != ShapeDropPhase.celebrating) {
      return;
    }
    state = state.copyWith(envPhase: state.envPhase + delta);
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != ShapeDropPhase.playing &&
          state.phase != ShapeDropPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _requestEnd();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _requestEnd() {
    if (state.pendingEnd) return;
    if (state.phase == ShapeDropPhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void _loadNextRound() {
    if (state.phase == ShapeDropPhase.finished) return;
    final round = ShapeDropLogic.generateRound(
      state.settings,
      sequentialIndex: state.sequentialIndex,
    );
    state = state.copyWith(
      target: round.target,
      options: round.options,
      sequentialIndex: round.nextSequentialIndex,
      phase: ShapeDropPhase.playing,
      filled: false,
      outlineGlow: false,
      wrongOnCurrent: 0,
      showSparkles: false,
    );
    if (state.pendingEnd) _endSession();
  }

  /// Returns true on correct match.
  bool tryDrop(String optionId) {
    if (state.phase != ShapeDropPhase.playing || state.target == null) {
      return false;
    }
    final option = state.options.where((o) => o.id == optionId).firstOrNull;
    if (option == null || option.matched) return false;

    final attempts = state.attempts + 1;
    final correct = option.def.kind == state.target!.kind;

    if (!correct) {
      final wrong = state.wrongOnCurrent + 1;
      final options = state.options
          .map((o) => o.id == optionId ? o.copyWith(shake: true) : o)
          .toList();
      state = state.copyWith(
        options: options,
        attempts: attempts,
        wrongOnCurrent: wrong,
        streak: 0,
        outlineGlow: wrong >= 2,
        feedbackMessage: kShapeDropWrong[attempts % kShapeDropWrong.length],
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        state = state.copyWith(
          options: state.options
              .map((o) => o.id == optionId ? o.copyWith(shake: false) : o)
              .toList(),
        );
      });
      return false;
    }

    final streak = state.streak + 1;
    final reward = ShapeDropLogic.matchReward(state.settings, streak);
    final learned = {...state.learnedShapes, option.def.kind};
    _matchCounts[option.def.kind] = (_matchCounts[option.def.kind] ?? 0) + 1;
    final name = state.settings.uppercaseLabels
        ? option.def.name.toUpperCase()
        : option.def.name;

    state = state.copyWith(
      options: state.options
          .map((o) => o.id == optionId ? o.copyWith(matched: true) : o)
          .toList(),
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      filled: true,
      outlineGlow: true,
      wrongOnCurrent: 0,
      learnedShapes: learned,
      favoriteShape: ShapeDropLogic.favoriteFrom(_matchCounts),
      feedbackMessage:
          '$name!  ${kShapeDropRight[state.correctMatches % kShapeDropRight.length]}',
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP',
      showMascot: streak % 3 == 0,
      showSparkles: true,
      phase: ShapeDropPhase.celebrating,
    );
    _scheduleFeedbackClear(showMascot: state.showMascot);

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _loadNextRound();
    });
    return true;
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
    if (state.phase == ShapeDropPhase.playing ||
        state.phase == ShapeDropPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: ShapeDropPhase.paused);
    }
  }

  void resume() {
    if (state.phase == ShapeDropPhase.paused) {
      state = state.copyWith(phase: ShapeDropPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _celebrateTimer?.cancel();
    state = state.copyWith(phase: ShapeDropPhase.finished);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _matchCounts.clear();
    state = const ShapeDropState();
  }

  ShapeDropResult getResult() =>
      ShapeDropLogic.calculate(state, matchCounts: _matchCounts);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.shapeDropAdventure,
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
          ShapeDropLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.shapeDropAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    super.dispose();
  }
}
