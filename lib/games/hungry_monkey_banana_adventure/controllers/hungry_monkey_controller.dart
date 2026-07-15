import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/logic/hungry_monkey_logic.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

final hungryMonkeyControllerProvider =
    StateNotifierProvider<HungryMonkeyController, HungryMonkeyState>((ref) {
  return HungryMonkeyController(ref);
});

class HungryMonkeyController extends StateNotifier<HungryMonkeyState> {
  HungryMonkeyController(this._ref) : super(const HungryMonkeyState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Size _playArea = Size.zero;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _playArea = size;
    if (!state.playAreaReady && state.bananas.isEmpty) {
      _initLevel(size, state.settings);
    }
  }

  void _initLevel(Size area, HungryMonkeySettings settings) {
    final (mx, my) = HungryMonkeyLogic.monkeyAnchor(area);
    final bananas = HungryMonkeyLogic.spawnBananas(area, settings.effectiveBananaCount);
    state = state.copyWith(
      bananas: bananas,
      monkey: MonkeyEntity(x: mx, y: my),
      playAreaReady: true,
      nextAppleSpawnIn: HungryMonkeyLogic.randomAppleSpawnDelay(settings),
    );
  }

  void startGame(HungryMonkeySettings settings) {
    _sessionTimer?.cancel();
    if (_playArea != Size.zero) {
      _initLevel(_playArea, settings);
    }
    state = HungryMonkeyState(
      sessionPhase: HungryMonkeySessionPhase.playing,
      settings: settings,
      bananas: state.bananas,
      monkey: state.monkey,
      remainingSeconds: settings.sessionSeconds,
      nextAppleSpawnIn: HungryMonkeyLogic.randomAppleSpawnDelay(settings),
      playAreaReady: _playArea != Size.zero,
    );
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != HungryMonkeySessionPhase.playing) return;
      final rem = state.remainingSeconds - 1;
      final elapsed = state.elapsedSeconds + 1;
      if (rem <= 0) {
        state = state.copyWith(elapsedSeconds: elapsed);
        _requestEndSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem, elapsedSeconds: elapsed);
    });
  }

  void _requestEndSession() {
    if (state.pendingEnd) return;
    if (state.hasActiveAnimation) {
      state = state.copyWith(pendingEnd: true);
      return;
    }
    _endSession();
  }

  void tick(double delta) {
    if (state.sessionPhase != HungryMonkeySessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var bananas = [...state.bananas];
    var apples = [...state.apples];
    var monkey = state.monkey;
    var pendingRegrows = [...state.pendingRegrows];
    var nextAppleSpawnIn = state.nextAppleSpawnIn - delta;
    var showSparkles = state.showSparkles;
    var envPhase = state.envPhase + delta * 0.4;

    monkey = HungryMonkeyLogic.updateMonkey(monkey, delta, state.settings);

    for (var i = 0; i < bananas.length; i++) {
      final prev = bananas[i];
      bananas[i] = HungryMonkeyLogic.updateBanana(
        prev,
        _playArea,
        delta,
        state.settings,
        monkey,
      );
      final updated = bananas[i];

      if (prev.phase != BananaPhase.gone && updated.phase == BananaPhase.gone) {
        pendingRegrows.add(
          PendingBananaRegrow(
            slotIndex: updated.slotIndex,
            timer: state.settings.bananaRegrowDelay,
          ),
        );
        bananas.removeAt(i);
        i--;
      }
    }

    for (var i = 0; i < apples.length; i++) {
      apples[i] = HungryMonkeyLogic.updateApple(apples[i], delta, state.settings);
      if (apples[i].phase == ApplePhase.gone) {
        apples.removeAt(i);
        i--;
      }
    }

    pendingRegrows = pendingRegrows
        .map((p) => p.copyWith(timer: p.timer - delta))
        .where((p) {
          if (p.timer <= 0) {
            final slot = HungryMonkeyLogic.pickRegrowSlot(_playArea, bananas);
            bananas.add(HungryMonkeyLogic.spawnGrowingBanana(_playArea, slot));
            return false;
          }
          return true;
        })
        .toList();

    if (state.settings.maxApples > 0 && nextAppleSpawnIn <= 0) {
      final batch = HungryMonkeyLogic.randomAppleBatchCount(
        state.settings,
        apples.length,
      );
      if (batch > 0) {
        apples.addAll(
          HungryMonkeyLogic.spawnApples(_playArea, bananas, batch),
        );
      }
      nextAppleSpawnIn = HungryMonkeyLogic.randomAppleSpawnDelay(state.settings);
    }

    final hasActive = bananas.any(
          (b) =>
              b.phase == BananaPhase.tapped ||
              b.phase == BananaPhase.falling ||
              b.phase == BananaPhase.growing,
        ) ||
        monkey.phase == MonkeyPhase.reaching ||
        monkey.phase == MonkeyPhase.catching ||
        monkey.phase == MonkeyPhase.eating ||
        monkey.phase == MonkeyPhase.clapping;

    if (state.pendingEnd && !hasActive) {
      _endSession();
      return;
    }

    state = state.copyWith(
      bananas: bananas,
      apples: apples,
      monkey: monkey,
      pendingRegrows: pendingRegrows,
      nextAppleSpawnIn: nextAppleSpawnIn,
      envPhase: envPhase,
      showSparkles: showSparkles,
      inactivityTimer: state.inactivityTimer + delta,
    );
  }

  bool tapBanana(String bananaId) {
    if (state.sessionPhase != HungryMonkeySessionPhase.playing) return false;
    if (state.monkey.phase != MonkeyPhase.idle &&
        state.monkey.phase != MonkeyPhase.clapping) {
      return false;
    }

    final idx = state.bananas.indexWhere((b) => b.id == bananaId);
    if (idx == -1) return false;
    final banana = state.bananas[idx];
    if (!banana.canTap) return false;

    final bananas = [...state.bananas];
    bananas[idx] = banana.copyWith(
      phase: BananaPhase.tapped,
      tapProgress: 0,
      glow: 1,
    );

    final (mx, my) = HungryMonkeyLogic.monkeyAnchor(_playArea);
    final reward = HungryMonkeyLogic.feedReward(
      state.settings,
      fedCount: state.bananasFed + 1,
    );
    final fed = state.bananasFed + 1;
    final streak = state.currentStreak + 1;

    state = state.copyWith(
      bananas: bananas,
      monkey: state.monkey.copyWith(
        phase: MonkeyPhase.reaching,
        reachProgress: 0,
        x: mx,
        y: my,
      ),
      bananasFed: fed,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      pointsEarned: state.pointsEarned + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      feedbackMessage: HungryMonkeyLogic.pickBananaEncouragement(fed),
      lastRewardText:
          '+${reward.points} Points  +${reward.coins} Coins  +${reward.xp} XP${reward.stars > 0 ? '  +${reward.stars} Star' : ''}',
      showMascot: fed % 3 == 0,
      showSparkles: true,
      inactivityTimer: 0,
    );
    _scheduleFeedbackClear();
    return true;
  }

  bool tapApple(String appleId) {
    if (state.sessionPhase != HungryMonkeySessionPhase.playing) return false;

    final idx = state.apples.indexWhere((a) => a.id == appleId);
    if (idx == -1) return false;
    final apple = state.apples[idx];
    if (!apple.canTap || apple.wasTapped) return false;

    final apples = [...state.apples];
    apples[idx] = apple.copyWith(
      phase: ApplePhase.wobble,
      wasTapped: true,
      wobblePhase: 0,
    );

    final tapped = state.applesTapped + 1;

    state = state.copyWith(
      apples: apples,
      applesTapped: tapped,
      currentStreak: 0,
      monkey: state.monkey.copyWith(
        phase: MonkeyPhase.sad,
        sadProgress: 0,
        earDroop: 0.5,
      ),
      feedbackMessage: HungryMonkeyLogic.pickAppleMessage(tapped),
      showMascot: tapped % 2 == 0,
      showSparkles: false,
      inactivityTimer: 0,
    );
    _scheduleFeedbackClear(short: true);
    return true;
  }

  void _scheduleFeedbackClear({bool short = false}) {
    _feedbackTimer?.cancel();
    final ms = short ? 1400 : 1600;
    _feedbackTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) state = state.copyWith(clearFeedback: true);
    });
  }

  void pause() {
    if (state.sessionPhase == HungryMonkeySessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: HungryMonkeySessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == HungryMonkeySessionPhase.paused) {
      state = state.copyWith(sessionPhase: HungryMonkeySessionPhase.playing);
      _startTimer();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: HungryMonkeySessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      feedbackMessage: 'Amazing Jungle Adventure!',
    );
  }

  HungryMonkeyResult getResult() => HungryMonkeyLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.bananasFed == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.hungryMonkeyBananaAdventure,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.bananasFed),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.bananasFed,
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
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    state = const HungryMonkeyState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
