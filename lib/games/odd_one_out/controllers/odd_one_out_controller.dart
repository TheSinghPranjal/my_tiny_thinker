import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/odd_one_out/logic/odd_one_out_logic.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

final oddOneOutControllerProvider =
    StateNotifierProvider<OddOneOutController, OddOneOutState>((ref) {
  return OddOneOutController(ref);
});

class OddOneOutController extends StateNotifier<OddOneOutState> {
  OddOneOutController(this._ref) : super(const OddOneOutState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _hintTimer;
  Timer? _feedbackTimer;
  int _previousBest = 0;

  void startGame(OddOneOutSettings settings) {
    _cancelTimers();
    _previousBest =
        _ref.read(allGameStatsProvider)[GameId.oddOneOut]?.bestScore ?? 0;
    final config = settings.toConfig();
    final items = OddOneOutGenerator.generatePuzzle(config);
    state = OddOneOutState(
      settings: settings,
      phase: OddOnePhase.playing,
      items: items,
      gridSize: OddOneOutGenerator.gridSizeFor(settings.difficulty),
      remainingSeconds: settings.sessionSeconds,
    );
    _startTimer();
    _scheduleHint();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != OddOnePhase.playing &&
          state.phase != OddOnePhase.feedback &&
          state.phase != OddOnePhase.celebrating) {
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
    if (state.phase == OddOnePhase.finished) return;
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: 0);
    }
    if (state.phase == OddOnePhase.feedback || state.phase == OddOnePhase.celebrating) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void _scheduleHint() {
    _hintTimer?.cancel();
    if (!state.settings.hintsEnabled) return;
    _hintTimer = Timer(const Duration(seconds: 8), () {
      if (state.phase == OddOnePhase.playing) {
        state = state.copyWith(showHint: true);
      }
    });
  }

  void selectItem(int id) {
    if (state.phase != OddOnePhase.playing || state.pendingEnd) return;
    final item = state.items.firstWhere((e) => e.id == id);
    _hintTimer?.cancel();

    if (item.isOdd) {
      final newStreak = state.streak + 1;
      state = state.copyWith(
        score: state.score + OddOneOutScoring.pointsForCorrect(newStreak),
        streak: newStreak,
        longestStreak: math.max(state.longestStreak, newStreak),
        phase: OddOnePhase.feedback,
        showSparkles: true,
        clearHint: true,
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
        wrongItemId: id,
        phase: OddOnePhase.feedback,
        clearHint: true,
      );
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (state.pendingEnd) {
          _endSession();
          return;
        }
        state = state.copyWith(clearWrong: true, phase: OddOnePhase.playing);
        _scheduleHint();
      });
    }
  }

  void _nextRound() {
    if (state.phase == OddOnePhase.finished) return;
    final items = OddOneOutGenerator.generatePuzzle(state.settings.toConfig());
    state = state.copyWith(
      round: state.round + 1,
      items: items,
      phase: OddOnePhase.playing,
      showSparkles: false,
    );
    _scheduleHint();
  }

  void pause() {
    if (state.phase == OddOnePhase.playing ||
        state.phase == OddOnePhase.feedback) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: OddOnePhase.paused);
    }
  }

  void resume() {
    if (state.phase == OddOnePhase.paused) {
      state = state.copyWith(phase: OddOnePhase.playing);
      if (state.pendingEnd || state.remainingSeconds <= 0) {
        _requestEnd();
        return;
      }
      _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: OddOnePhase.finished, remainingSeconds: 0);
  }

  OddOneOutResult getResult() =>
      OddOneOutScoring.calculate(state, _previousBest);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.score == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.oddOneOut,
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
    await _ref.read(profileProvider.notifier).applyReward(
          OddOneOutScoring.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.oddOneOut);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _cancelTimers();
    state = const OddOneOutState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _hintTimer?.cancel();
    _feedbackTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
