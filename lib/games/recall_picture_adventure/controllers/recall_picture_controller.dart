import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/logic/recall_picture_logic.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';

final recallPictureControllerProvider =
    StateNotifierProvider<RecallPictureController, RecallPictureState>((ref) {
  return RecallPictureController(ref);
});

class RecallPictureController extends StateNotifier<RecallPictureState> {
  RecallPictureController(this._ref) : super(const RecallPictureState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  Timer? _showTimer;
  Timer? _celebrateTimer;
  RecallPicturePhase? _pausedFrom;

  static const _showDuration = Duration(milliseconds: 3000);
  static const _celebrateCorrect = Duration(milliseconds: 1100);
  static const _celebrateWrong = Duration(milliseconds: 900);

  void startGame(RecallPictureSettings settings) {
    _cancelAll();
    final scene = RecallPictureLogic.generateScene();
    final question = RecallPictureLogic.generateQuestion(scene);
    state = RecallPictureState(
      phase: RecallPicturePhase.countdown,
      settings: settings,
      scene: scene,
      question: question,
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
          phase: RecallPicturePhase.showing,
          countdown: 0,
        );
        _startSessionTimer();
        _startShowPhase();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != RecallPicturePhase.showing &&
          state.phase != RecallPicturePhase.input &&
          state.phase != RecallPicturePhase.celebrating) {
        return;
      }
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        if (state.phase == RecallPicturePhase.celebrating) {
          state = state.copyWith(pendingEnd: true);
        } else {
          _endGame();
        }
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void _startShowPhase() {
    _showTimer?.cancel();
    state = state.copyWith(
      phase: RecallPicturePhase.showing,
      lockInput: true,
      clearSelected: true,
      clearWrong: true,
      clearFeedback: true,
      clearReward: true,
      bounceCorrect: false,
    );
    _showTimer = Timer(_showDuration, () {
      if (!mounted) return;
      if (state.phase != RecallPicturePhase.showing) return;
      if (state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      state = state.copyWith(
        phase: RecallPicturePhase.input,
        lockInput: false,
      );
    });
  }

  /// Returns true if the answer was correct.
  bool answer(String optionId) {
    if (state.phase != RecallPicturePhase.input) return false;
    if (state.lockInput) return false;
    final question = state.question;
    if (question == null) return false;

    RecallOption? option;
    for (final o in question.options) {
      if (o.id == optionId) {
        option = o;
        break;
      }
    }
    if (option == null) return false;

    final correct = option.valueKey == question.correctKey;
    if (correct) {
      _onCorrect(optionId);
    } else {
      _onWrong(optionId);
    }
    return correct;
  }

  void _onCorrect(String optionId) {
    final combo = state.combo + 1;
    final reward = RecallPictureLogic.correctReward(combo);
    final praise = kRecallPraise[state.correctCount % kRecallPraise.length];

    state = state.copyWith(
      phase: RecallPicturePhase.celebrating,
      lockInput: true,
      selectedOptionId: optionId,
      clearWrong: true,
      correctCount: state.correctCount + 1,
      roundsCompleted: state.roundsCompleted + 1,
      combo: combo,
      maxCombo: math.max(state.maxCombo, combo),
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      score: state.score + reward.points,
      feedbackMessage: praise,
      lastRewardText: '+${reward.coins} Coins  +${reward.xp} XP',
      bounceCorrect: true,
    );
    _scheduleNextRound(_celebrateCorrect);
  }

  void _onWrong(String optionId) {
    state = state.copyWith(
      phase: RecallPicturePhase.celebrating,
      lockInput: true,
      wrongOptionId: optionId,
      clearSelected: true,
      wrongCount: state.wrongCount + 1,
      roundsCompleted: state.roundsCompleted + 1,
      combo: 0,
      feedbackMessage: 'Try again!',
      clearReward: true,
      bounceCorrect: false,
    );
    _scheduleNextRound(_celebrateWrong);
  }

  void _scheduleNextRound(Duration delay) {
    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(delay, () {
      if (!mounted) return;
      if (state.pendingEnd || state.remainingSeconds <= 0) {
        _endGame();
        return;
      }
      _loadNextRound();
    });
  }

  void _loadNextRound() {
    final scene = RecallPictureLogic.generateScene(exclude: state.scene);
    final question = RecallPictureLogic.generateQuestion(scene);
    state = state.copyWith(
      scene: scene,
      question: question,
      clearSelected: true,
      clearWrong: true,
      clearFeedback: true,
      clearReward: true,
      bounceCorrect: false,
      lockInput: true,
    );
    _startShowPhase();
  }

  void pause() {
    if (state.phase == RecallPicturePhase.showing ||
        state.phase == RecallPicturePhase.input ||
        state.phase == RecallPicturePhase.celebrating) {
      _pausedFrom = state.phase;
      _sessionTimer?.cancel();
      _showTimer?.cancel();
      _celebrateTimer?.cancel();
      state = state.copyWith(phase: RecallPicturePhase.paused);
    }
  }

  void resume() {
    if (state.phase != RecallPicturePhase.paused) return;
    final from = _pausedFrom ?? RecallPicturePhase.input;
    _pausedFrom = null;
    if (state.remainingSeconds <= 0) {
      _endGame();
      return;
    }
    _startSessionTimer();
    if (from == RecallPicturePhase.showing) {
      _startShowPhase();
    } else if (from == RecallPicturePhase.celebrating) {
      _scheduleNextRound(const Duration(milliseconds: 400));
    } else {
      state = state.copyWith(
        phase: RecallPicturePhase.input,
        lockInput: false,
      );
    }
  }

  void _endGame() {
    _cancelAll();
    state = state.copyWith(phase: RecallPicturePhase.finished);
  }

  void reset() {
    _cancelAll();
    state = const RecallPictureState();
  }

  RecallPictureResult getResult() => RecallPictureLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    final storage = _ref.read(storageServiceProvider);
    final existing = storage.getGameStats(GameId.recallPictureAdventure.id);
    var stats = existing != null
        ? GameStats.fromJson(existing)
        : const GameStats(gameId: GameId.recallPictureAdventure);

    stats = stats.copyWith(
      bestScore: math.max(stats.bestScore, result.score),
      starsEarned: stats.starsEarned + result.stars,
      timesPlayed: stats.timesPlayed + 1,
      totalCorrect: stats.totalCorrect + result.correctCount,
      totalMistakes: stats.totalMistakes + result.wrongCount,
      longestCombo: math.max(stats.longestCombo, result.maxCombo),
      lastPlayed: DateTime.now(),
    );

    await storage.saveGameStats(
      GameId.recallPictureAdventure.id,
      stats.toJson(),
    );
    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
            isPerfect: result.wrongCount == 0 && result.correctCount > 0,
            isNewBest: result.score >
                (existing != null
                    ? GameStats.fromJson(existing).bestScore
                    : 0),
          ),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.recallPictureAdventure);
  }

  void _cancelAll() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    _showTimer?.cancel();
    _celebrateTimer?.cancel();
    _pausedFrom = null;
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }
}
