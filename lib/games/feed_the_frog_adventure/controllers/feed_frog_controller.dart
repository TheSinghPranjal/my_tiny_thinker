import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/logic/feed_frog_logic.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/shared/flying_insects.dart';

final feedFrogControllerProvider =
    StateNotifierProvider<FeedFrogController, FeedFrogState>((ref) {
  return FeedFrogController(ref);
});

class FeedFrogController extends StateNotifier<FeedFrogState> {
  FeedFrogController(this._ref) : super(const FeedFrogState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;
  final _kindCounts = <InsectKind, int>{};

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    final anchor = FeedFrogLogic.frogAnchor(size);
    if (!state.playAreaReady && state.insects.isEmpty) {
      state = state.copyWith(
        frogX: anchor.$1,
        frogY: anchor.$2,
        insects: FeedFrogLogic.spawnInsects(
          size,
          state.settings.effectiveInsectCount,
          0,
        ),
        playAreaReady: true,
      );
    } else if (state.frogX == 0) {
      state = state.copyWith(frogX: anchor.$1, frogY: anchor.$2);
    }
  }

  void startGame(FeedFrogSettings settings) {
    _sessionTimer?.cancel();
    _kindCounts.clear();
    final anchor = _playArea == Size.zero
        ? (0.0, 0.0, 0.0)
        : FeedFrogLogic.frogAnchor(_playArea);
    final insects = _playArea == Size.zero
        ? <InsectEntity>[]
        : FeedFrogLogic.spawnInsects(
            _playArea,
            settings.effectiveInsectCount,
            0,
          );

    state = FeedFrogState(
      sessionPhase: FeedFrogSessionPhase.playing,
      settings: settings,
      insects: insects,
      remainingSeconds: settings.sessionSeconds,
      frogX: anchor.$1,
      frogY: anchor.$2,
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != FeedFrogSessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      final night = FeedFrogLogic.computeNightFactor(elapsed, state.settings);
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0, elapsedSeconds: elapsed, nightFactor: night);
        _requestEndSession();
        return;
      }
      state = state.copyWith(
        remainingSeconds: rem,
        elapsedSeconds: elapsed,
        nightFactor: night,
      );
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.isFeeding) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != FeedFrogSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    final night = FeedFrogLogic.computeNightFactor(
      state.elapsedSeconds,
      state.settings,
    );
    var insects = [...state.insects];
    var frogPhase = state.frogPhase;
    var tongueProgress = state.tongueProgress;
    var tongueTipX = state.tongueTipX;
    var tongueTipY = state.tongueTipY;
    var targetId = state.targetInsectId;
    var showSparkles = state.showSparkles;

    if (frogPhase == FrogFeedPhase.idle || frogPhase == FrogFeedPhase.chewing) {
      for (var i = 0; i < insects.length; i++) {
        if (insects[i].phase == InsectPhase.flying ||
            insects[i].phase == InsectPhase.entering) {
          insects[i] = FeedFrogLogic.updateInsect(
            insects[i],
            _playArea,
            delta,
            state.settings,
            night,
          );
        }
      }
    }

    if (frogPhase == FrogFeedPhase.tongueExtend) {
      tongueProgress = (tongueProgress + delta * 2.2 * state.settings.animationIntensity)
          .clamp(0.0, 1.0);
      final target = insects.where((i) => i.id == targetId).firstOrNull;
      if (target != null) {
        final tip = FeedFrogLogic.tongueTip(
          state.frogX,
          state.frogY,
          target.x,
          target.y,
          tongueProgress,
        );
        tongueTipX = tip.tipX;
        tongueTipY = tip.tipY;
        if (tongueProgress >= 1) {
          final idx = insects.indexWhere((i) => i.id == targetId);
          if (idx != -1) {
            insects[idx] = insects[idx].copyWith(phase: InsectPhase.caught);
          }
          frogPhase = FrogFeedPhase.tongueRetract;
          tongueProgress = 0;
        }
      }
    } else if (frogPhase == FrogFeedPhase.tongueRetract) {
      tongueProgress = (tongueProgress + delta * 2.8 * state.settings.animationIntensity)
          .clamp(0.0, 1.0);
      final tip = FeedFrogLogic.tongueTip(
        state.frogX,
        state.frogY,
        state.frogX,
        state.frogY - 60,
        1 - tongueProgress,
      );
      tongueTipX = tip.tipX;
      tongueTipY = tip.tipY;
      if (tongueProgress >= 1) {
        frogPhase = FrogFeedPhase.chewing;
        tongueProgress = 0;
        showSparkles = true;
      }
    } else if (frogPhase == FrogFeedPhase.chewing) {
      tongueProgress = (tongueProgress + delta * 1.5).clamp(0.0, 1.0);
      if (tongueProgress >= 1) {
        frogPhase = FrogFeedPhase.idle;
        tongueProgress = 0;
        if (targetId != null) {
          insects.removeWhere((i) => i.id == targetId);
          insects.add(FeedFrogLogic.spawnReplacement(_playArea, night));
        }
        targetId = null;
      }
    }

    if (state.pendingEnd &&
        frogPhase == FrogFeedPhase.idle &&
        !state.isFeeding) {
      _endSession();
      return;
    }

    state = state.copyWith(
      insects: insects,
      nightFactor: night,
      frogPhase: frogPhase,
      frogAnimPhase: state.frogAnimPhase + delta * 2.5,
      frogBlinkTimer: state.frogBlinkTimer + delta,
      tongueProgress: tongueProgress,
      targetInsectId: targetId,
      clearTarget: targetId == null,
      tongueTipX: tongueTipX,
      tongueTipY: tongueTipY,
      showSparkles: showSparkles,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool tapInsect(String insectId) {
    if (state.sessionPhase != FeedFrogSessionPhase.playing) return false;
    if (state.isFeeding) return false;

    final idx = state.insects.indexWhere((i) => i.id == insectId);
    if (idx == -1) return false;
    final insect = state.insects[idx];
    if (!insect.canTap) return false;

    final insects = [...state.insects];
    insects[idx] = insect.copyWith(phase: InsectPhase.selected, highlight: 1);

    final tip = FeedFrogLogic.tongueTip(
      state.frogX,
      state.frogY,
      insect.x,
      insect.y,
      0,
    );

    final reward = FeedFrogLogic.feedReward(
      state.settings,
      isFirefly: insect.isFirefly,
      eaten: state.insectsEaten + 1,
    );
    final eaten = state.insectsEaten + 1;
    final fireflies = state.firefliesCaught + (insect.isFirefly ? 1 : 0);
    final streak = state.currentStreak + 1;
    _kindCounts[insect.def.kind] = (_kindCounts[insect.def.kind] ?? 0) + 1;
    final favorite = _kindCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    state = state.copyWith(
      insects: insects,
      frogPhase: FrogFeedPhase.tongueExtend,
      tongueProgress: 0,
      targetInsectId: insectId,
      tongueTipX: tip.tipX,
      tongueTipY: tip.tipY,
      insectsEaten: eaten,
      firefliesCaught: fireflies,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: FeedFrogLogic.encouragement(eaten),
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: eaten % 3 == 0,
      showSparkles: true,
      inactivityTimer: 0,
      favoriteKind: favorite,
    );
    _scheduleFeedbackClear();
    return true;
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });
  }

  void pause() {
    if (state.sessionPhase == FeedFrogSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: FeedFrogSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == FeedFrogSessionPhase.paused) {
      state = state.copyWith(sessionPhase: FeedFrogSessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: FeedFrogSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Happy Feeding Time!',
    );
  }

  FeedFrogResult getResult() => FeedFrogLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.insectsEaten == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.feedTheFrogAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.insectsEaten),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.insectsEaten,
        longestCombo: math.max(s.longestCombo, result.longestStreak),
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref.read(profileProvider.notifier).applyReward(
          GameRewardResult(
            coins: result.coins,
            stars: result.stars,
            xp: result.xp,
          ),
        );
    await _ref.read(dailyPlayLimitsProvider.notifier).recordPlay(GameId.feedTheFrogAdventure);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _kindCounts.clear();
    state = const FeedFrogState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
