import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/color_memory/logic/color_memory_logic.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

final colorMemoryConfigProvider =
    StateProvider<ColorMemoryConfig>((ref) => const ColorMemoryConfig());

final colorMemoryControllerProvider =
    StateNotifierProvider<ColorMemoryController, ColorMemoryState>((ref) {
  return ColorMemoryController(ref);
});

class ColorMemoryController extends StateNotifier<ColorMemoryState> {
  ColorMemoryController(this._ref) : super(const ColorMemoryState());

  final Ref _ref;
  Timer? _timer;
  Timer? _showTimer;
  int _previousBest = 0;

  void start(ColorMemoryConfig config) {
    _previousBest =
        _ref.read(allGameStatsProvider)[GameId.colorMemory]?.bestScore ?? 0;
    final grid = ColorMemoryLogic.gridSize(config.difficulty);
    final rounds = ColorMemoryLogic.roundsTarget(config.difficulty);
    state = ColorMemoryState(
      config: config,
      gridSize: grid,
      roundsTarget: rounds,
      hintsRemaining: config.hintsEnabled ? 1 : 0,
      phase: ColorMemoryPhase.showing,
    );
    _startLevel();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _startLevel() {
    final len =
        ColorMemoryLogic.sequenceLength(state.config.difficulty, state.level);
    final seq = ColorMemoryLogic.generateSequence(len, state.tileCount);
    state = state.copyWith(
      sequence: seq,
      playerInput: const [],
      showIndex: 0,
      clearActive: true,
      clearFeedback: true,
      phase: ColorMemoryPhase.showing,
    );
    _playSequence();
  }

  void _playSequence({List<int>? subset, int startIndex = 0}) {
    _showTimer?.cancel();
    final seq = subset ?? state.sequence;
    var index = startIndex;

    void showNext() {
      if (!mounted) return;
      if (index >= seq.length) {
        state = state.copyWith(clearActive: true, phase: ColorMemoryPhase.input);
        return;
      }
      state = state.copyWith(activeTile: seq[index]);
      final delay = ColorMemoryLogic.showDelayMs(state.config.difficulty);
      _showTimer = Timer(Duration(milliseconds: delay ~/ 2), () {
        if (!mounted) return;
        state = state.copyWith(clearActive: true);
        _showTimer = Timer(Duration(milliseconds: delay ~/ 2), () {
          index++;
          showNext();
        });
      });
    }

    showNext();
  }

  void onTileTap(int tileIndex) {
    if (state.phase != ColorMemoryPhase.input) return;

    final input = [...state.playerInput, tileIndex];
    final expected = state.sequence[input.length - 1];

    if (tileIndex != expected) {
      final msg = ColorMemoryLogic.encouragingMessages[
          state.mistakes % ColorMemoryLogic.encouragingMessages.length];
      state = state.copyWith(
        playerInput: input,
        mistakes: state.mistakes + 1,
        streak: 0,
        feedbackMessage: msg,
        phase: ColorMemoryPhase.feedback,
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _startLevel();
      });
      return;
    }

    if (input.length == state.sequence.length) {
      final newStreak = state.streak + 1;
      final pts = ColorMemoryLogic.pointsForLevel(state.level, newStreak);
      state = state.copyWith(
        playerInput: input,
        score: state.score + pts,
        streak: newStreak,
        longestStreak: math.max(state.longestStreak, newStreak),
        feedbackMessage: 'Awesome!',
        phase: ColorMemoryPhase.feedback,
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (state.level >= state.roundsTarget) {
          _timer?.cancel();
          state = state.copyWith(phase: ColorMemoryPhase.victory);
          return;
        }
        state = state.copyWith(level: state.level + 1);
        _startLevel();
      });
    } else {
      state = state.copyWith(playerInput: input, activeTile: tileIndex);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) state = state.copyWith(clearActive: true);
      });
    }
  }

  void useHintReplayAll() {
    if (state.hintsRemaining <= 0 || state.phase != ColorMemoryPhase.input) {
      return;
    }
    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      hintsRemaining: state.hintsRemaining - 1,
      playerInput: const [],
      phase: ColorMemoryPhase.showing,
    );
    _playSequence();
  }

  void useHintReplayLast3() {
    if (state.hintsRemaining <= 0 || state.phase != ColorMemoryPhase.input) {
      return;
    }
    final start = math.max(0, state.sequence.length - 3);
    final subset = state.sequence.sublist(start);
    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      hintsRemaining: state.hintsRemaining - 1,
      playerInput: const [],
      phase: ColorMemoryPhase.showing,
    );
    _playSequence(subset: subset);
  }

  void useHintHighlightFirst() {
    if (state.hintsRemaining <= 0 || state.phase != ColorMemoryPhase.input) {
      return;
    }
    if (state.sequence.isEmpty) return;
    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      hintsRemaining: state.hintsRemaining - 1,
      activeTile: state.sequence.first,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) state = state.copyWith(clearActive: true);
    });
  }

  ColorMemoryResult getResult() =>
      ColorMemoryLogic.calculate(state, _previousBest);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(storage, GameId.colorMemory, (s) => s.copyWith(
          bestScore: math.max(s.bestScore, result.score),
          starsEarned: s.starsEarned + result.stars,
          timesPlayed: s.timesPlayed + 1,
          totalCorrect: s.totalCorrect + state.level,
          totalMistakes: s.totalMistakes + state.mistakes,
          longestCombo: math.max(s.longestCombo, result.longestStreak),
          lastPlayed: DateTime.now(),
        ));
    await _ref
        .read(profileProvider.notifier)
        .applyReward(ColorMemoryLogic.toReward(result));
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _timer?.cancel();
    _showTimer?.cancel();
    state = const ColorMemoryState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _showTimer?.cancel();
    super.dispose();
  }
}
