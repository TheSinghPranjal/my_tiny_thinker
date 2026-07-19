import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_school_bags/logic/color_school_bags_logic.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

final colorSchoolBagsControllerProvider =
    StateNotifierProvider<ColorSchoolBagsController, SortBagsState>((ref) {
  return ColorSchoolBagsController(ref);
});

class ColorSchoolBagsController extends StateNotifier<SortBagsState> {
  ColorSchoolBagsController(this._ref) : super(const SortBagsState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;

  void startGame(SortBagsSettings settings) {
    _cancelTimers();
    final round = ColorSchoolBagsLogic.generateRound(
      settings: settings,
      level: 1,
    );
    state = SortBagsState(
      phase: SortBagsPhase.playing,
      settings: settings,
      books: round.books,
      backpacks: round.backpacks,
      level: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != SortBagsPhase.playing &&
        state.phase != SortBagsPhase.celebrating) {
      return;
    }
    final anim = ColorSchoolBagsLogic.tickAnimations(
      state.books,
      state.backpacks,
      delta,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      books: anim.books,
      backpacks: anim.backpacks,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != SortBagsPhase.playing &&
          state.phase != SortBagsPhase.celebrating) {
        return;
      }
      if (state.settings.unlimitedTime) return;
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
    if (state.phase == SortBagsPhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void setHoverBag(String? bagId) {
    if (state.hoverBagId == bagId) return;
    state = state.copyWith(
      hoverBagId: bagId,
      clearHover: bagId == null,
    );
  }

  /// Returns true on correct match.
  bool tryDrop({required String bookId, required String bagId}) {
    if (state.phase != SortBagsPhase.playing) return false;

    final bookIdx = state.books.indexWhere((b) => b.id == bookId && !b.matched);
    final bagIdx = state.backpacks.indexWhere((b) => b.id == bagId);
    if (bookIdx < 0 || bagIdx < 0) return false;

    final book = state.books[bookIdx];
    final bag = state.backpacks[bagIdx];
    if (bag.filled) return false;

    final attempts = state.attempts + 1;
    final correct = book.colorKind == bag.colorKind;

    if (!correct) {
      final books = [...state.books];
      books[bookIdx] = book.copyWith(shake: true);
      final bags = [
        for (final b in state.backpacks)
          b.copyWith(
            hintPulse: b.colorKind == book.colorKind && !b.filled,
            smiling: b.id == bagId,
          ),
      ];
      state = state.copyWith(
        books: books,
        backpacks: bags,
        attempts: attempts,
        streak: 0,
        clearHover: true,
      );
      Future.delayed(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        state = state.copyWith(
          books: state.books
              .map((b) => b.id == bookId ? b.copyWith(shake: false) : b)
              .toList(),
          backpacks: state.backpacks
              .map(
                (b) => b.copyWith(hintPulse: false, smiling: false),
              )
              .toList(),
        );
      });
      return false;
    }

    final streak = state.streak + 1;
    final reward = ColorSchoolBagsLogic.matchReward(state.settings, streak);
    final name = book.colorDef.name;
    final milestone = (state.correctMatches + 1) % 5 == 0;

    final books = [...state.books];
    books[bookIdx] = book.copyWith(matched: true);
    final bags = [...state.backpacks];
    bags[bagIdx] = bag.copyWith(
      open: true,
      filled: true,
      glow: true,
      smiling: true,
      hintPulse: false,
    );

    state = state.copyWith(
      books: books,
      backpacks: bags,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: SortBagsPhase.celebrating,
      feedbackMessage: name.toUpperCase(),
      spokenColorName: name,
      lastRewardText: '+${reward.stars} Stars',
      showSparkles: true,
      showMascot: milestone,
      showMilestone: milestone,
      clearHover: true,
    );
    _scheduleFeedbackClear();

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      // Close bag smile after celebrate
      state = state.copyWith(
        backpacks: state.backpacks
            .map(
              (b) => b.id == bagId
                  ? b.copyWith(open: false, glow: false)
                  : b,
            )
            .toList(),
      );

      if (state.roundComplete) {
        Timer(const Duration(milliseconds: 400), () {
          if (mounted) _loadNextRound();
        });
      } else {
        state = state.copyWith(
          phase: SortBagsPhase.playing,
          showSparkles: false,
          showMilestone: false,
        );
        if (state.pendingEnd) _endSession();
      }
    });

    return true;
  }

  void _loadNextRound() {
    if (state.phase == SortBagsPhase.finished) return;
    final nextLevel = state.level + 1;
    final round = ColorSchoolBagsLogic.generateRound(
      settings: state.settings,
      level: nextLevel,
    );
    state = state.copyWith(
      books: round.books,
      backpacks: round.backpacks,
      level: nextLevel,
      phase: SortBagsPhase.playing,
      showSparkles: false,
      showMilestone: false,
    );
    if (state.pendingEnd) _endSession();
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
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
    if (state.phase == SortBagsPhase.playing ||
        state.phase == SortBagsPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: SortBagsPhase.paused);
    }
  }

  void resume() {
    if (state.phase == SortBagsPhase.paused) {
      state = state.copyWith(phase: SortBagsPhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: SortBagsPhase.finished);
  }

  /// Parent/home end for unlimited mode.
  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const SortBagsState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
  }

  SortBagsResult getResult() => ColorSchoolBagsLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.colorSchoolBags,
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
          ColorSchoolBagsLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.colorSchoolBags);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
