import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_physics_engine.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

final bubbleGameConfigProvider =
    StateProvider<BubbleGameConfig>((ref) => const BubbleGameConfig());

final bubbleGameControllerProvider =
    StateNotifierProvider<BubbleGameController, BubbleGameState>((ref) {
  return BubbleGameController(ref);
});

class BubbleGameController extends StateNotifier<BubbleGameState> {
  BubbleGameController(this._ref) : super(const BubbleGameState());

  final Ref _ref;
  final BubblePhysicsEngine _physics = BubblePhysicsEngine();
  Timer? _gameTimer;
  Timer? _hintTimer;
  Timer? _countdownTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  DateTime? _lastTick;
  DateTime? _lastCorrectPop;
  int _previousBest = 0;
  bool _countdownComplete = false;

  void updateConfig(BubbleGameConfig config) {
    state = state.copyWith(config: config);
    _ref.read(bubbleGameConfigProvider.notifier).state = config;
  }

  Future<void> loadBestScore() async {
    final storage = _ref.read(storageServiceProvider);
    final json = storage.getGameStats(GameId.bubbleNumberPop.id);
    if (json != null) {
      _previousBest = GameStats.fromJson(json).bestScore;
    }
  }

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    // Ignore tiny layout jitter; only update when size meaningfully changes.
    if (_playArea.width > 0 &&
        (size.width - _playArea.width).abs() < 2 &&
        (size.height - _playArea.height).abs() < 2) {
      return;
    }
    _playArea = size;
    if (_countdownComplete && state.phase == GamePhase.countdown) {
      _tryBeginPlaying();
    }
  }

  Future<void> startGame() async {
    await loadBestScore();
    final config = _ref.read(bubbleGameConfigProvider);
    final numbers = BubbleNumberGenerator.generate(
      count: config.bubbleCount,
      minValue: config.minValue,
      maxValue: config.maxValue,
      difficulty: config.difficulty,
    );
    final sorted = BubbleNumberGenerator.sortNumbers(numbers, config.sortMode);

    state = BubbleGameState(
      phase: GamePhase.countdown,
      config: config,
      sortedNumbers: sorted,
      remainingSeconds: config.timerMode == TimerMode.timed || config.toddlerMode
          ? config.timerSeconds
          : 0,
      countdown: config.toddlerMode ? 2 : 3,
      lastInteraction: DateTime.now(),
    );

    _countdownComplete = false;
    _lastCorrectPop = null;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        timer.cancel();
        _countdownComplete = true;
        _tryBeginPlaying();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _tryBeginPlaying() {
    if (!_countdownComplete) return;
    if (_playArea == Size.zero) return;
    if (state.phase != GamePhase.countdown) return;

    final bubbles = _physics.spawnBubbles(
      numbers: state.sortedNumbers,
      playArea: _playArea,
      difficulty: state.config.difficulty,
      speedMultiplier: state.config.bubbleSpeed,
      toddlerMode: state.config.toddlerMode,
    );

    if (bubbles.length != state.sortedNumbers.length) return;

    state = state.copyWith(
      phase: GamePhase.playing,
      bubbles: bubbles,
      lastInteraction: DateTime.now(),
      clearFeedback: true,
    );

    _startGameTimer();
    _startHintTimer();
    _lastTick = DateTime.now();
    _countdownComplete = false;
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != GamePhase.playing) return;

      final elapsed = state.elapsedSeconds + 1;
      var remaining = state.remainingSeconds;

      if (state.config.timerMode == TimerMode.timed || state.config.toddlerMode) {
        remaining = remaining - 1;
        if (remaining <= 0) {
          state = state.copyWith(remainingSeconds: 0);
          _endGame(victory: false);
          return;
        }
      }

      state = state.copyWith(
        elapsedSeconds: elapsed,
        remainingSeconds: remaining,
      );

      _checkInactivityHint();
    });
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    if (!state.config.hintsEnabled) return;
    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkInactivityHint();
    });
  }

  void _checkInactivityHint() {
    if (state.phase != GamePhase.playing) return;
    final last = state.lastInteraction;
    if (last == null) return;
    final inactive = DateTime.now().difference(last);
    if (inactive >= AppDurations.inactivityHint && !state.showHint) {
      state = state.copyWith(showHint: true);
    }
  }

  void tick() {
    if (state.phase != GamePhase.playing || _playArea == Size.zero) return;

    final now = DateTime.now();
    final delta = _lastTick != null
        ? now.difference(_lastTick!).inMicroseconds / 1000000.0
        : 0.016;
    _lastTick = now;

    final updated = _physics.update(
      bubbles: state.bubbles,
      playArea: _playArea,
      deltaTime: delta.clamp(0.001, 0.05),
    );

    state = state.copyWith(bubbles: updated);
  }

  BubbleTapResult tapBubble(String bubbleId) {
    if (state.phase != GamePhase.playing) return BubbleTapResult.ignored;

    final target = state.targetNumber;
    if (target == null) return BubbleTapResult.ignored;

    final bubbleIndex = state.bubbles.indexWhere((b) => b.id == bubbleId);
    if (bubbleIndex == -1) return BubbleTapResult.ignored;

    final bubble = state.bubbles[bubbleIndex];
    if (bubble.isPopping) return BubbleTapResult.ignored;

    state = state.copyWith(lastInteraction: DateTime.now(), showHint: false);

    if (bubble.number == target) {
      _handleCorrect(bubbleId);
      return BubbleTapResult.correct;
    }
    _handleWrong(bubbleId);
    return BubbleTapResult.wrong;
  }

  void _handleCorrect(String bubbleId) {
    final now = DateTime.now();
    final fastPop = _lastCorrectPop != null &&
        now.difference(_lastCorrectPop!).inMilliseconds < 2000;
    _lastCorrectPop = now;

    final newCombo = state.combo + 1;
    final points =
        BubbleScoring.pointsForCorrect(newCombo, fastPop: fastPop);
    final message =
        BubbleScoring.encouragementFor(newCombo, state.currentIndex);

    final bubbles = state.bubbles
        .map((b) => b.id == bubbleId ? b.copyWith(isPopping: true) : b)
        .toList();
    final newIndex = state.currentIndex + 1;

    state = state.copyWith(
      bubbles: bubbles,
      currentIndex: newIndex,
      score: state.score + points,
      combo: newCombo,
      longestCombo: math.max(state.longestCombo, newCombo),
      feedbackMessage: message,
      lastPointsEarned: points,
    );

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final cleaned = state.bubbles.where((b) => b.id != bubbleId).toList();
      state = state.copyWith(bubbles: cleaned);

      if (newIndex >= state.total) {
        _endGame(victory: true);
      }
    });
  }

  void _handleWrong(String bubbleId) {
    final message = BubbleScoring.wrongMessage(state.mistakes);
    final bubbles = state.bubbles
        .map((b) => b.id == bubbleId ? b.copyWith(isWrong: true) : b)
        .toList();

    state = state.copyWith(
      bubbles: bubbles,
      combo: 0,
      mistakes: state.mistakes + 1,
      feedbackMessage: message,
      lastPointsEarned: 0,
    );

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final updated = state.bubbles
          .map((b) => b.id == bubbleId ? b.copyWith(isWrong: false) : b)
          .toList();
      state = state.copyWith(bubbles: updated);
    });
  }

  void pause() {
    if (state.phase == GamePhase.playing) {
      _gameTimer?.cancel();
      _hintTimer?.cancel();
      state = state.copyWith(phase: GamePhase.paused);
    }
  }

  void resume() {
    if (state.phase == GamePhase.paused) {
      state = state.copyWith(phase: GamePhase.playing);
      _startGameTimer();
      _startHintTimer();
      _lastTick = DateTime.now();
    }
  }

  void _endGame({required bool victory}) {
    _gameTimer?.cancel();
    _hintTimer?.cancel();
    _countdownTimer?.cancel();
    _countdownComplete = false;

    state = state.copyWith(
      phase: victory ? GamePhase.victory : GamePhase.gameOver,
      feedbackMessage: victory ? 'Level Complete!' : null,
    );
  }

  BubbleGameResult getResult() {
    return BubbleScoring.calculateResult(
      state: state,
      previousBest: _previousBest,
    );
  }

  Future<void> saveResult(BubbleGameResult result) async {
    final storage = _ref.read(storageServiceProvider);
    final existing = storage.getGameStats(GameId.bubbleNumberPop.id);
    var stats = existing != null
        ? GameStats.fromJson(existing)
        : const GameStats(gameId: GameId.bubbleNumberPop);

    stats = stats.copyWith(
      bestScore: math.max(stats.bestScore, result.score),
      starsEarned: stats.starsEarned + result.stars,
      timesPlayed: stats.timesPlayed + 1,
      totalCorrect: stats.totalCorrect + state.currentIndex,
      totalMistakes: stats.totalMistakes + state.mistakes,
      longestCombo: math.max(stats.longestCombo, result.longestCombo),
      lastPlayed: DateTime.now(),
    );

    await storage.saveGameStats(GameId.bubbleNumberPop.id, stats.toJson());
    await _ref
        .read(profileProvider.notifier)
        .applyReward(BubbleRewardCalculator.toGameReward(result));
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.bubbleNumberPop);
  }

  void reset() {
    _gameTimer?.cancel();
    _hintTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    _countdownComplete = false;
    _playArea = Size.zero;
    state = const BubbleGameState();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _hintTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
