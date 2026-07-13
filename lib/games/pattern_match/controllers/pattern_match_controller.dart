import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/pattern_match/logic/pattern_match_logic.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

final patternMatchConfigProvider =
    StateProvider<PatternMatchConfig>((ref) => const PatternMatchConfig());

final patternMatchControllerProvider =
    StateNotifierProvider<PatternMatchController, PatternMatchState>((ref) {
  return PatternMatchController(ref);
});

class PatternMatchController extends StateNotifier<PatternMatchState> {
  PatternMatchController(this._ref) : super(const PatternMatchState());

  final Ref _ref;
  Timer? _timer;
  int _previousBest = 0;

  void start(PatternMatchConfig config) {
    _previousBest =
        _ref.read(allGameStatsProvider)[GameId.patternMatch]?.bestScore ?? 0;
    final rounds = PatternMatchGenerator.roundsFor(config.difficulty);
    state = PatternMatchState(
      config: config,
      phase: PatternPhase.playing,
      roundsTarget: rounds,
    );
    _loadPuzzle();
    _startTimer();
  }

  void _loadPuzzle() {
    final puzzle = PatternMatchGenerator.generate(state.config.difficulty);
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void selectOption(int optionId) {
    if (state.phase != PatternPhase.playing) return;
    if (optionId == state.correctOptionId) {
      final newStreak = state.streak + 1;
      state = state.copyWith(
        score: state.score + PatternMatchScoring.pointsForCorrect(newStreak),
        streak: newStreak,
        longestStreak: math.max(state.longestStreak, newStreak),
        phase: PatternPhase.feedback,
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _nextRound();
      });
    } else {
      state = state.copyWith(
        mistakes: state.mistakes + 1,
        streak: 0,
        wrongOptionId: optionId,
        phase: PatternPhase.feedback,
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        state = state.copyWith(clearWrong: true, phase: PatternPhase.playing);
      });
    }
  }

  void _nextRound() {
    if (state.round >= state.roundsTarget) {
      _timer?.cancel();
      state = state.copyWith(phase: PatternPhase.victory);
      return;
    }
    state = state.copyWith(round: state.round + 1, phase: PatternPhase.playing);
    _loadPuzzle();
  }

  PatternMatchResult getResult() =>
      PatternMatchScoring.calculate(state, _previousBest);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(storage, GameId.patternMatch, (s) => s.copyWith(
          bestScore: math.max(s.bestScore, result.score),
          starsEarned: s.starsEarned + result.stars,
          timesPlayed: s.timesPlayed + 1,
          totalCorrect: s.totalCorrect + state.round,
          totalMistakes: s.totalMistakes + state.mistakes,
          longestCombo: math.max(s.longestCombo, result.longestStreak),
          lastPlayed: DateTime.now(),
        ));
    await _ref
        .read(profileProvider.notifier)
        .applyReward(PatternMatchScoring.toReward(result));
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _timer?.cancel();
    state = const PatternMatchState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
