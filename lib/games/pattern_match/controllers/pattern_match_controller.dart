import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/pattern_match/logic/pattern_match_logic.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

final patternMatchControllerProvider =
    StateNotifierProvider<PatternMatchController, PatternMatchState>((ref) {
  return PatternMatchController(ref);
});

class PatternMatchController extends StateNotifier<PatternMatchState> {
  PatternMatchController(this._ref) : super(const PatternMatchState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  int _previousBest = 0;

  void startGame(PatternMatchSettings settings) {
    _cancelTimers();
    _previousBest =
        _ref.read(allGameStatsProvider)[GameId.patternMatch]?.bestScore ?? 0;
    state = PatternMatchState(
      settings: settings,
      phase: PatternPhase.playing,
      remainingSeconds: settings.sessionSeconds,
    );
    _loadPuzzle();
    _startTimer();
  }

  void _loadPuzzle() {
    final puzzle =
        PatternMatchGenerator.generate(state.settings.difficulty);
    final options = puzzle.options
        .asMap()
        .entries
        .map((e) => PatternOption(id: e.key, display: e.value))
        .toList();
    final correctId = options.indexWhere((o) => o.display == puzzle.answer);

    state = state.copyWith(
      sequence: puzzle.sequence,
      missingIndex: puzzle.missingIndex,
      options: options,
      correctOptionId: correctId,
      patternType: puzzle.type,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != PatternPhase.playing &&
          state.phase != PatternPhase.feedback) {
        return;
      }
      if (state.remainingSeconds <= 0) {
        _sessionTimer?.cancel();
        _requestEnd();
        return;
      }
      final rem = state.remainingSeconds - 1;
      state = state.copyWith(remainingSeconds: rem);
      if (rem <= 0) {
        _sessionTimer?.cancel();
        _requestEnd();
      }
    });
  }

  void _requestEnd() {
    if (state.phase == PatternPhase.finished) return;
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: 0);
    }
    if (state.phase == PatternPhase.feedback) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void selectOption(int optionId) {
    if (state.phase != PatternPhase.playing || state.pendingEnd) return;
    if (optionId == state.correctOptionId) {
      final newStreak = state.streak + 1;
      state = state.copyWith(
        score: state.score + PatternMatchScoring.pointsForCorrect(newStreak),
        streak: newStreak,
        longestStreak: math.max(state.longestStreak, newStreak),
        phase: PatternPhase.feedback,
        showSparkles: true,
      );
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (state.pendingEnd) {
          _endSession();
          return;
        }
        _nextRound();
      });
    } else {
      state = state.copyWith(
        mistakes: state.mistakes + 1,
        streak: 0,
        wrongOptionId: optionId,
        phase: PatternPhase.feedback,
      );
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (state.pendingEnd) {
          _endSession();
          return;
        }
        state = state.copyWith(clearWrong: true, phase: PatternPhase.playing);
      });
    }
  }

  void _nextRound() {
    if (state.phase == PatternPhase.finished) return;
    state = state.copyWith(
      round: state.round + 1,
      phase: PatternPhase.playing,
      showSparkles: false,
    );
    _loadPuzzle();
  }

  void pause() {
    if (state.phase == PatternPhase.playing ||
        state.phase == PatternPhase.feedback) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: PatternPhase.paused);
    }
  }

  void resume() {
    if (state.phase == PatternPhase.paused) {
      state = state.copyWith(phase: PatternPhase.playing);
      if (state.pendingEnd || state.remainingSeconds <= 0) {
        _requestEnd();
        return;
      }
      _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: PatternPhase.finished, remainingSeconds: 0);
  }

  PatternMatchResult getResult() =>
      PatternMatchScoring.calculate(state, _previousBest);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.score == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.patternMatch,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.score),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.roundsSolved,
        totalMistakes: s.totalMistakes + result.mistakes,
        longestCombo: math.max(s.longestCombo, result.longestStreak),
        lastPlayed: DateTime.now(),
      ),
    );
    await _ref
        .read(profileProvider.notifier)
        .applyReward(PatternMatchScoring.toReward(result));
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.patternMatch);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _cancelTimers();
    state = const PatternMatchState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
