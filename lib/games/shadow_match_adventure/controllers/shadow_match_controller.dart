import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/logic/shadow_match_logic.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';

final shadowMatchControllerProvider =
    StateNotifierProvider<ShadowMatchController, ShadowMatchState>((ref) {
  return ShadowMatchController(ref);
});

class ShadowMatchController extends StateNotifier<ShadowMatchState> {
  ShadowMatchController(this._ref) : super(const ShadowMatchState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;

  void startGame(ShadowMatchSettings settings) {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    final round = ShadowMatchLogic.generateRound(settings);
    state = ShadowMatchState(
      phase: ShadowMatchPhase.playing,
      settings: settings,
      shadows: round.shadows,
      items: round.items,
      remainingSeconds: settings.sessionSeconds,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != ShadowMatchPhase.playing &&
          state.phase != ShadowMatchPhase.celebrating) {
        return;
      }
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
    if (state.phase == ShadowMatchPhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void _loadNextRound() {
    if (state.phase == ShadowMatchPhase.finished) return;
    final round = ShadowMatchLogic.generateRound(state.settings);
    state = state.copyWith(
      shadows: round.shadows,
      items: round.items,
      phase: ShadowMatchPhase.playing,
      showSparkles: false,
    );
    if (state.pendingEnd) _endSession();
  }

  /// Returns true on correct match.
  bool tryMatch(String itemId, String shadowItemId) {
    if (state.phase != ShadowMatchPhase.playing) return false;

    final attempts = state.attempts + 1;
    if (itemId != shadowItemId) {
      final items = state.items
          .map(
            (i) => i.itemId == itemId ? i.copyWith(shake: true) : i,
          )
          .toList();
      state = state.copyWith(
        items: items,
        attempts: attempts,
        streak: 0,
        feedbackMessage:
            kShadowEncouragementsWrong[attempts % kShadowEncouragementsWrong.length],
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        state = state.copyWith(
          items: state.items
              .map((i) => i.itemId == itemId ? i.copyWith(shake: false) : i)
              .toList(),
        );
      });
      return false;
    }

    final reward = ShadowMatchLogic.matchReward(state.settings, state.streak + 1);
    final streak = state.streak + 1;
    final item = EducationVocabulary.byId(itemId);

    final shadows = state.shadows
        .map(
          (s) => s.itemId == shadowItemId
              ? s.copyWith(matched: true, glow: true)
              : s,
        )
        .toList();
    final items = state.items
        .map(
          (i) => i.itemId == itemId ? i.copyWith(matched: true) : i,
        )
        .toList();

    state = state.copyWith(
      shadows: shadows,
      items: items,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: item != null
          ? '${item.name}!'
          : kShadowEncouragementsRight[
              state.correctMatches % kShadowEncouragementsRight.length],
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP',
      showMascot: streak % 3 == 0,
      showSparkles: true,
      lastSpokenItemId: itemId,
      phase: ShadowMatchPhase.celebrating,
    );
    _scheduleFeedbackClear(showMascot: state.showMascot);

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (state.roundComplete) {
        _loadNextRound();
      } else {
        state = state.copyWith(phase: ShadowMatchPhase.playing, showSparkles: false);
      }
      if (state.pendingEnd) _endSession();
    });

    return true;
  }

  void _scheduleFeedbackClear({bool showMascot = false}) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showMascot: false);
      }
    });
  }

  void pause() {
    if (state.phase == ShadowMatchPhase.playing ||
        state.phase == ShadowMatchPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: ShadowMatchPhase.paused);
    }
  }

  void resume() {
    if (state.phase == ShadowMatchPhase.paused) {
      state = state.copyWith(phase: ShadowMatchPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _celebrateTimer?.cancel();
    state = state.copyWith(phase: ShadowMatchPhase.finished);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    state = const ShadowMatchState();
  }

  ShadowMatchResult getResult() => ShadowMatchLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.shadowMatchAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.correctMatches,
        totalMistakes: s.totalMistakes + (result.attempts - result.correctMatches),
        longestCombo: math.max(s.longestCombo, result.maxStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          ShadowMatchLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.shadowMatchAdventure);
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
