import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/odd_one_out/logic/odd_one_out_logic.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

final oddOneOutConfigProvider =
    StateProvider<OddOneOutConfig>((ref) => const OddOneOutConfig());

final oddOneOutControllerProvider =
    StateNotifierProvider<OddOneOutController, OddOneOutState>((ref) {
  return OddOneOutController(ref);
});

class OddOneOutController extends StateNotifier<OddOneOutState> {
  OddOneOutController(this._ref) : super(const OddOneOutState());

  final Ref _ref;
  Timer? _timer;
  Timer? _hintTimer;
  int _previousBest = 0;

  void start(OddOneOutConfig config) {
    _previousBest = _ref.read(allGameStatsProvider)[GameId.oddOneOut]?.bestScore ?? 0;
    final rounds = OddOneOutGenerator.roundsFor(config.difficulty);
    final items = OddOneOutGenerator.generatePuzzle(config);
    state = OddOneOutState(
      config: config,
      phase: OddOnePhase.playing,
      items: items,
      gridSize: OddOneOutGenerator.gridSizeFor(config.difficulty),
      roundsTarget: rounds,
    );
    _startTimer();
    _scheduleHint();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _scheduleHint() {
    _hintTimer?.cancel();
    if (!state.config.hintsEnabled) return;
    _hintTimer = Timer(const Duration(seconds: 8), () {
      if (state.phase == OddOnePhase.playing) {
        state = state.copyWith(showHint: true);
      }
    });
  }

  void selectItem(int id) {
    if (state.phase != OddOnePhase.playing) return;
    final item = state.items.firstWhere((e) => e.id == id);
    _hintTimer?.cancel();

    if (item.isOdd) {
      final newStreak = state.streak + 1;
      state = state.copyWith(
        score: state.score + OddOneOutScoring.pointsForCorrect(newStreak),
        streak: newStreak,
        longestStreak: math.max(state.longestStreak, newStreak),
        phase: OddOnePhase.feedback,
        clearHint: true,
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
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
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(clearWrong: true, phase: OddOnePhase.playing);
        _scheduleHint();
      });
    }
  }

  void _nextRound() {
    if (state.round >= state.roundsTarget) {
      _endGame();
      return;
    }
    final items = OddOneOutGenerator.generatePuzzle(state.config);
    state = state.copyWith(
      round: state.round + 1,
      items: items,
      phase: OddOnePhase.playing,
    );
    _scheduleHint();
  }

  void _endGame() {
    _timer?.cancel();
    _hintTimer?.cancel();
    state = state.copyWith(phase: OddOnePhase.victory);
  }

  OddOneOutResult getResult() =>
      OddOneOutScoring.calculate(state, _previousBest);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(storage, GameId.oddOneOut, (s) => s.copyWith(
          bestScore: math.max(s.bestScore, result.score),
          starsEarned: s.starsEarned + result.stars,
          timesPlayed: s.timesPlayed + 1,
          totalCorrect: s.totalCorrect + state.round,
          totalMistakes: s.totalMistakes + state.mistakes,
          longestCombo: math.max(s.longestCombo, result.longestStreak),
          lastPlayed: DateTime.now(),
        ));
    await _ref.read(profileProvider.notifier).applyReward(
          OddOneOutScoring.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.oddOneOut);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _timer?.cancel();
    _hintTimer?.cancel();
    state = const OddOneOutState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }
}
