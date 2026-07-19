import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/logic/picture_bridge_logic.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

final pictureBridgeControllerProvider =
    StateNotifierProvider<PictureBridgeController, PictureBridgeState>((ref) {
  return PictureBridgeController(ref);
});

class PictureBridgeController extends StateNotifier<PictureBridgeState> {
  PictureBridgeController(this._ref) : super(const PictureBridgeState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _roundTimer;

  void startGame(PictureBridgeSettings settings) {
    _cancelTimers();
    final round = PictureBridgeLogic.generateRound(
      settings: settings,
      recentVocabIds: const [],
      sequentialCursor: 0,
      round: 1,
    );
    state = PictureBridgeState(
      phase: PictureBridgePhase.playing,
      settings: settings,
      pictureCards: round.pictureCards,
      wordCards: round.wordCards,
      recentVocabIds: round.chosenIds,
      round: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != PictureBridgePhase.playing &&
        state.phase != PictureBridgePhase.celebrating) {
      return;
    }
    final anim = PictureBridgeLogic.tickAnimations(
      state.pictureCards,
      state.wordCards,
      delta,
      state.settings.reducedMotion,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      pictureCards: anim.pictureCards,
      wordCards: anim.wordCards,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != PictureBridgePhase.playing &&
          state.phase != PictureBridgePhase.celebrating) {
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
    if (state.phase == PictureBridgePhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  bool tryConnect({required String pictureId, required String wordId}) {
    if (state.phase != PictureBridgePhase.playing) return false;

    final pictureIdx =
        state.pictureCards.indexWhere((c) => c.id == pictureId && !c.matched);
    final wordIdx =
        state.wordCards.indexWhere((c) => c.id == wordId && !c.matched);
    if (pictureIdx < 0 || wordIdx < 0) return false;

    final picture = state.pictureCards[pictureIdx];
    final word = state.wordCards[wordIdx];
    final attempts = state.attempts + 1;
    final correct = picture.vocabId == word.vocabId;

    if (!correct) {
      final pictures = [...state.pictureCards];
      pictures[pictureIdx] = picture.copyWith(shake: true, selected: false);
      final words = [
        for (final c in state.wordCards)
          c.copyWith(
            shake: c.id == wordId,
            hintPulse: c.vocabId == picture.vocabId && !c.matched,
            selected: false,
          ),
      ];
      state = state.copyWith(
        pictureCards: pictures,
        wordCards: words,
        attempts: attempts,
        streak: 0,
        feedbackMessage: PictureBridgeLogic.encouragePhrase(),
        spokenPhrase: PictureBridgeLogic.encouragePhrase(),
        showMascot: true,
      );
      _scheduleFeedbackClear();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        state = state.copyWith(
          pictureCards: state.pictureCards
              .map((c) => c.copyWith(shake: false, selected: false))
              .toList(),
          wordCards: state.wordCards
              .map(
                (c) => c.copyWith(
                  shake: false,
                  hintPulse: false,
                  selected: false,
                ),
              )
              .toList(),
        );
      });
      return false;
    }

    final streak = state.streak + 1;
    final reward = PictureBridgeLogic.matchReward(state.settings, streak);
    final phrase = PictureBridgeLogic.successPhrase(picture.vocabId);

    final pictures = [...state.pictureCards];
    pictures[pictureIdx] =
        picture.copyWith(matched: true, celebrate: true, selected: false);
    final words = [...state.wordCards];
    words[wordIdx] =
        word.copyWith(matched: true, celebrate: true, selected: false);

    final connections = [
      ...state.connections,
      PictureBridgeConnection(
        pictureId: pictureId,
        wordId: wordId,
        vocabId: picture.vocabId,
      ),
    ];

    state = state.copyWith(
      pictureCards: pictures,
      wordCards: words,
      connections: connections,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: PictureBridgePhase.celebrating,
      feedbackMessage: phrase,
      spokenPhrase: phrase,
      lastRewardText:
          '+${reward.points} Pts  +${reward.coins} Coins  +${reward.xp} XP',
      showSparkles: true,
      showMascot: true,
    );
    _scheduleFeedbackClear();

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      state = state.copyWith(
        pictureCards: state.pictureCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
        wordCards: state.wordCards
            .map((c) => c.copyWith(celebrate: false))
            .toList(),
      );

      if (state.roundComplete) {
        _completeRound();
      } else {
        state = state.copyWith(
          phase: PictureBridgePhase.playing,
          showSparkles: false,
        );
        if (state.pendingEnd) _endSession();
      }
    });

    return true;
  }

  void _completeRound() {
    final bonus = PictureBridgeLogic.roundBonus(state.settings);
    state = state.copyWith(
      roundsCompleted: state.roundsCompleted + 1,
      score: state.score + bonus.points,
      coinsEarned: state.coinsEarned + bonus.coins,
      xpEarned: state.xpEarned + bonus.xp,
      starsEarned: state.starsEarned + bonus.stars,
      feedbackMessage: 'Round Complete!',
      lastRewardText:
          '+${bonus.points} Bonus  +${bonus.coins} Coins  +${bonus.xp} XP',
      showRoundBonus: true,
      showSparkles: true,
      showMascot: true,
    );
    _scheduleFeedbackClear();

    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (state.pendingEnd) {
        _endSession();
        return;
      }
      _loadNextRound();
    });
  }

  void _loadNextRound() {
    if (state.phase == PictureBridgePhase.finished) return;
    final nextRound = state.round + 1;
    final pairCount = state.settings.pairCount.clamp(3, 7);
    final poolSize = EducationVocabulary.items.length;
    final sequentialCursor = ((nextRound - 1) * pairCount) % poolSize;
    final generated = PictureBridgeLogic.generateRound(
      settings: state.settings,
      recentVocabIds: state.recentVocabIds,
      sequentialCursor: sequentialCursor,
      round: nextRound,
    );
    state = state.copyWith(
      pictureCards: generated.pictureCards,
      wordCards: generated.wordCards,
      connections: const [],
      recentVocabIds: PictureBridgeLogic.mergeRecent(
        state.recentVocabIds,
        generated.chosenIds,
      ),
      round: nextRound,
      phase: PictureBridgePhase.playing,
      showSparkles: false,
      showRoundBonus: false,
    );
    if (state.pendingEnd) _endSession();
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearSpoken: true,
          showMascot: false,
          showRoundBonus: false,
        );
      }
    });
  }

  void pause() {
    if (state.phase == PictureBridgePhase.playing ||
        state.phase == PictureBridgePhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: PictureBridgePhase.paused);
    }
  }

  void resume() {
    if (state.phase == PictureBridgePhase.paused) {
      state = state.copyWith(phase: PictureBridgePhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: PictureBridgePhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const PictureBridgeState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _roundTimer?.cancel();
  }

  PictureBridgeResult getResult() => PictureBridgeLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.pictureBridgeAdventure,
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
          PictureBridgeLogic.toReward(result),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.pictureBridgeAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
