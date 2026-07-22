import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/logic/classic_card_memory_logic.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';

final classicCardMemoryControllerProvider = StateNotifierProvider<
    ClassicCardMemoryController, ClassicCardMemoryState>((ref) {
  return ClassicCardMemoryController(ref);
});

class ClassicCardMemoryController
    extends StateNotifier<ClassicCardMemoryState> {
  ClassicCardMemoryController(this._ref) : super(const ClassicCardMemoryState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  Timer? _mismatchTimer;
  Timer? _roundTimer;
  Timer? _feedbackTimer;

  void startGame(ClassicCardMemorySettings settings) {
    _cancelAll();
    final category = ClassicCardMemoryLogic.pickCategory(settings);
    final cards = ClassicCardMemoryLogic.dealRound(
      pairCount: settings.pairCount,
      category: category,
    );
    state = ClassicCardMemoryState(
      phase: ClassicMemoryPhase.countdown,
      settings: settings,
      cards: cards,
      category: category,
      remainingSeconds: settings.sessionSeconds,
      countdown: 3,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        timer.cancel();
        state = state.copyWith(
          phase: ClassicMemoryPhase.playing,
          countdown: 0,
        );
        _startSessionTimer();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != ClassicMemoryPhase.playing &&
          state.phase != ClassicMemoryPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _endGame();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void flipCard(int index) {
    if (state.phase != ClassicMemoryPhase.playing) return;
    if (state.lockInput) return;
    if (index < 0 || index >= state.cards.length) return;

    final card = state.cards[index];
    if (card.isMatched || card.isFlipped) return;

    final cards = [...state.cards];
    cards[index] = card.copyWith(isFlipped: true);

    final first = state.firstFlippedIndex;
    if (first == null) {
      state = state.copyWith(cards: cards, firstFlippedIndex: index);
      return;
    }

    if (first == index) return;

    final a = cards[first];
    final b = cards[index];
    state = state.copyWith(cards: cards, lockInput: true);

    if (a.pairId == b.pairId) {
      _handleMatch(first, index);
    } else {
      _handleMismatch(first, index);
    }
  }

  void _handleMatch(int i, int j) {
    final reward = ClassicCardMemoryLogic.matchReward(state.combo + 1);
    final combo = state.combo + 1;
    final cards = [...state.cards];
    cards[i] = cards[i].copyWith(isMatched: true, isFlipped: true);
    cards[j] = cards[j].copyWith(isMatched: true, isFlipped: true);

    state = state.copyWith(
      cards: cards,
      matches: state.matches + 1,
      combo: combo,
      maxCombo: math.max(state.maxCombo, combo),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: combo >= 3 ? 'Amazing combo!' : 'Match!',
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP',
      clearFirstFlip: true,
      lockInput: false,
    );
    _scheduleFeedbackClear();

    if (state.roundComplete) {
      _completeRound();
    }
  }

  void _handleMismatch(int i, int j) {
    final cards = [...state.cards];
    cards[i] = cards[i].copyWith(isWrong: true);
    cards[j] = cards[j].copyWith(isWrong: true);
    state = state.copyWith(
      cards: cards,
      mistakes: state.mistakes + 1,
      combo: 0,
      feedbackMessage: 'Try again!',
      clearFirstFlip: true,
    );
    _scheduleFeedbackClear();

    _mismatchTimer?.cancel();
    _mismatchTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted || state.phase != ClassicMemoryPhase.playing) return;
      final next = [...state.cards];
      if (i < next.length) {
        next[i] = next[i].copyWith(isFlipped: false, isWrong: false);
      }
      if (j < next.length) {
        next[j] = next[j].copyWith(isFlipped: false, isWrong: false);
      }
      state = state.copyWith(cards: next, lockInput: false);
    });
  }

  void _completeRound() {
    state = state.copyWith(
      phase: ClassicMemoryPhase.celebrating,
      roundsCompleted: state.roundsCompleted + 1,
      feedbackMessage: 'Round complete!',
    );
    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      _dealNextRound();
    });
  }

  void _dealNextRound() {
    final category = ClassicCardMemoryLogic.pickCategory(state.settings);
    final cards = ClassicCardMemoryLogic.dealRound(
      pairCount: state.settings.pairCount,
      category: category,
    );
    state = state.copyWith(
      phase: ClassicMemoryPhase.playing,
      cards: cards,
      category: category,
      clearFirstFlip: true,
      lockInput: false,
      clearFeedback: true,
      clearReward: true,
    );
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, clearReward: true);
      }
    });
  }

  void pause() {
    if (state.phase == ClassicMemoryPhase.playing ||
        state.phase == ClassicMemoryPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: ClassicMemoryPhase.paused);
    }
  }

  void resume() {
    if (state.phase == ClassicMemoryPhase.paused) {
      state = state.copyWith(phase: ClassicMemoryPhase.playing);
      _startSessionTimer();
    }
  }

  void _endGame() {
    _cancelAll();
    state = state.copyWith(phase: ClassicMemoryPhase.finished);
  }

  void reset() {
    _cancelAll();
    state = const ClassicCardMemoryState();
  }

  ClassicCardMemoryResult getResult() =>
      ClassicCardMemoryLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    final existing = storage.getGameStats(GameId.classicCardMemory.id);
    var stats = existing != null
        ? GameStats.fromJson(existing)
        : const GameStats(gameId: GameId.classicCardMemory);

    stats = stats.copyWith(
      bestScore: math.max(stats.bestScore, result.score),
      starsEarned: stats.starsEarned + result.stars,
      timesPlayed: stats.timesPlayed + 1,
      totalCorrect: stats.totalCorrect + result.matches,
      totalMistakes: stats.totalMistakes + result.mistakes,
      longestCombo: math.max(stats.longestCombo, result.maxCombo),
      lastPlayed: DateTime.now(),
    );

    await storage.saveGameStats(GameId.classicCardMemory.id, stats.toJson());
    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
            isPerfect: result.mistakes == 0 && result.matches > 0,
            isNewBest: result.score > (existing != null
                ? GameStats.fromJson(existing).bestScore
                : 0),
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.classicCardMemory);
  }

  void _cancelAll() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _mismatchTimer?.cancel();
    _roundTimer?.cancel();
    _feedbackTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}
