import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/logic/complete_word_logic.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/models/complete_word_models.dart';

final completeWordControllerProvider =
    StateNotifierProvider<CompleteWordController, CompleteWordState>((ref) {
  return CompleteWordController(ref);
});

class CompleteWordController extends StateNotifier<CompleteWordState> {
  CompleteWordController(this._ref) : super(const CompleteWordState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  Timer? _celebrateTimer;
  Timer? _feedbackTimer;
  Timer? _hintTimer;
  Timer? _wrongTimer;

  void startGame(CompleteWordSettings settings) {
    _cancelAll();
    final word = CompleteWordLogic.pickWord(settings.wordLength);
    state = CompleteWordState(
      phase: CompleteWordPhase.countdown,
      settings: settings,
      currentWord: word,
      filled: CompleteWordLogic.emptySlots(word.length),
      tiles: CompleteWordLogic.scrambleTiles(word.word),
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
        state = state.copyWith(phase: CompleteWordPhase.playing, countdown: 0);
        _startSessionTimer();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != CompleteWordPhase.playing &&
          state.phase != CompleteWordPhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        if (state.phase == CompleteWordPhase.celebrating) {
          state = state.copyWith(pendingEnd: true);
        } else {
          _endGame();
        }
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  /// Returns true if the letter was correct.
  bool tapTile(String tileId) {
    if (state.phase != CompleteWordPhase.playing) return false;
    if (state.currentWord == null) return false;
    if (state.nextIndex >= state.currentWord!.word.length) return false;

    final tileIndex = state.tiles.indexWhere((t) => t.id == tileId);
    if (tileIndex < 0) return false;
    final tile = state.tiles[tileIndex];
    if (tile.used) return false;

    final expected = state.currentWord!.word[state.nextIndex];
    if (tile.letter != expected) {
      _onWrong(tileId, expected);
      return false;
    }

    _onCorrect(tileIndex, tile.letter);
    return true;
  }

  void _onCorrect(int tileIndex, String letter) {
    final reward = CompleteWordLogic.letterReward();
    final combo = state.combo + 1;
    final filled = [...state.filled];
    filled[state.nextIndex] = letter;
    final tiles = [...state.tiles];
    tiles[tileIndex] = tiles[tileIndex].copyWith(used: true);
    final nextIndex = state.nextIndex + 1;
    final praise = kLetterPraise[state.lettersCorrect % kLetterPraise.length];

    state = state.copyWith(
      filled: filled,
      tiles: tiles,
      nextIndex: nextIndex,
      lettersCorrect: state.lettersCorrect + 1,
      combo: combo,
      maxCombo: math.max(state.maxCombo, combo),
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      score: state.score + reward.points,
      flyingLetter: letter,
      feedbackMessage: praise,
      lastRewardText: '+${reward.coins} Coins  +${reward.xp} XP',
      clearHint: true,
      clearWrong: true,
    );
    _scheduleFeedbackClear();

    if (nextIndex >= state.currentWord!.word.length) {
      _onWordComplete();
    }
  }

  void _onWrong(String tileId, String expectedLetter) {
    String? hintId;
    for (final t in state.tiles) {
      if (!t.used && t.letter == expectedLetter) {
        hintId = t.id;
        break;
      }
    }
    state = state.copyWith(
      lettersWrong: state.lettersWrong + 1,
      combo: 0,
      wrongTileId: tileId,
      hintTileId: hintId,
      feedbackMessage: 'Try again!',
      clearReward: true,
    );

    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(milliseconds: 550), () {
      if (mounted) state = state.copyWith(clearWrong: true);
    });
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) state = state.copyWith(clearHint: true);
    });
    _scheduleFeedbackClear();
  }

  void _onWordComplete() {
    final bonus = CompleteWordLogic.wordBonus(state.combo);
    final praise = kWordPraise[state.wordsCompleted % kWordPraise.length];
    state = state.copyWith(
      phase: CompleteWordPhase.celebrating,
      wordsCompleted: state.wordsCompleted + 1,
      coinsEarned: state.coinsEarned + bonus.coins,
      xpEarned: state.xpEarned + bonus.xp,
      starsEarned: state.starsEarned + bonus.stars,
      score: state.score + bonus.points,
      feedbackMessage: praise,
      lastRewardText:
          '+${bonus.coins} Coins  +${bonus.xp} XP  +${bonus.stars}⭐',
    );

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (state.pendingEnd || state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      _loadNextWord();
    });
  }

  void _loadNextWord() {
    final word = CompleteWordLogic.pickWord(
      state.settings.wordLength,
      exclude: state.currentWord?.word,
    );
    state = state.copyWith(
      phase: CompleteWordPhase.playing,
      currentWord: word,
      filled: CompleteWordLogic.emptySlots(word.length),
      tiles: CompleteWordLogic.scrambleTiles(word.word),
      nextIndex: 0,
      clearHint: true,
      clearWrong: true,
      clearFlying: true,
      clearFeedback: true,
      clearReward: true,
    );
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearReward: true,
          clearFlying: true,
        );
      }
    });
  }

  void pause() {
    if (state.phase == CompleteWordPhase.playing ||
        state.phase == CompleteWordPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: CompleteWordPhase.paused);
    }
  }

  void resume() {
    if (state.phase == CompleteWordPhase.paused) {
      state = state.copyWith(phase: CompleteWordPhase.playing);
      _startSessionTimer();
    }
  }

  void _endGame() {
    _cancelAll();
    state = state.copyWith(phase: CompleteWordPhase.finished);
  }

  void reset() {
    _cancelAll();
    state = const CompleteWordState();
  }

  CompleteWordResult getResult() => CompleteWordLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    final existing = storage.getGameStats(GameId.completeTheWordAdventure.id);
    var stats = existing != null
        ? GameStats.fromJson(existing)
        : const GameStats(gameId: GameId.completeTheWordAdventure);

    stats = stats.copyWith(
      bestScore: math.max(stats.bestScore, result.score),
      starsEarned: stats.starsEarned + result.stars,
      timesPlayed: stats.timesPlayed + 1,
      totalCorrect: stats.totalCorrect + result.lettersCorrect,
      totalMistakes: stats.totalMistakes + result.lettersWrong,
      longestCombo: math.max(stats.longestCombo, result.maxCombo),
      lastPlayed: DateTime.now(),
    );

    await storage.saveGameStats(
      GameId.completeTheWordAdventure.id,
      stats.toJson(),
    );
    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
            isPerfect: result.lettersWrong == 0 && result.lettersCorrect > 0,
            isNewBest: result.score >
                (existing != null
                    ? GameStats.fromJson(existing).bestScore
                    : 0),
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.completeTheWordAdventure);
  }

  void _cancelAll() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _celebrateTimer?.cancel();
    _feedbackTimer?.cancel();
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}
