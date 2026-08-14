import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/logic/butterfly_web_matching_logic.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';

final butterflyWebMatchingControllerProvider = StateNotifierProvider<
    ButterflyWebMatchingController, ButterflyWebMatchingState>((ref) {
  return ButterflyWebMatchingController(ref);
});

class ButterflyWebMatchingController
    extends StateNotifier<ButterflyWebMatchingState> {
  ButterflyWebMatchingController(this._ref)
      : super(const ButterflyWebMatchingState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _rainbowTimer;
  Size _playArea = Size.zero;
  double _boardRefreshDelay = 0;

  void setPlayArea(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final changed = (size.width - _playArea.width).abs() > 1 ||
        (size.height - _playArea.height).abs() > 1;
    _playArea = size;
    if (!state.playAreaReady ||
        (changed &&
            state.butterflies.isEmpty &&
            state.sessionPhase != WebMatchSessionPhase.playing)) {
      _seedBoard(size, state.settings);
    }
  }

  void _seedBoard(Size area, ButterflyWebMatchingSettings settings) {
    final butterflies =
        ButterflyWebMatchingLogic.spawnBoard(area, settings);
    state = state.copyWith(
      butterflies: butterflies,
      playAreaReady: true,
      clearSelected: true,
      inputLocked: false,
    );
  }

  void startGame(ButterflyWebMatchingSettings settings) {
    _sessionTimer?.cancel();
    _boardRefreshDelay = 0;
    final butterflies = _playArea != Size.zero
        ? ButterflyWebMatchingLogic.spawnBoard(_playArea, settings)
        : <WebButterflyEntity>[];
    state = ButterflyWebMatchingState(
      sessionPhase: WebMatchSessionPhase.playing,
      settings: settings,
      butterflies: butterflies,
      remainingSeconds: settings.sessionSeconds,
      playAreaReady: _playArea != Size.zero,
      gardenBloom: 0,
    );
    if (!settings.practiceMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.sessionPhase != WebMatchSessionPhase.playing) return;
      if (state.settings.practiceMode) return;
      final rem = state.remainingSeconds - 1;
      if (rem <= 0) {
        state = state.copyWith(remainingSeconds: 0);
        _endSession();
        return;
      }
      state = state.copyWith(remainingSeconds: rem);
    });
  }

  void tick(double delta) {
    if (state.sessionPhase != WebMatchSessionPhase.playing ||
        _playArea == Size.zero) {
      return;
    }

    var butterflies = state.butterflies
        .map(
          (b) => ButterflyWebMatchingLogic.updateButterfly(
            b,
            _playArea,
            delta,
            state.settings,
          ),
        )
        .where((b) => b.phase != WebButterflyPhase.gone)
        .toList();

    var sparkles = state.sparkles
        .map((s) => ButterflyWebMatchingLogic.updateSparkle(s, delta))
        .where((s) => s.progress < 1)
        .toList();

    // Unlock once settle / release / dance transitions finish.
    var inputLocked = state.inputLocked;
    if (inputLocked) {
      final busy = butterflies.any(
        (b) =>
            b.phase == WebButterflyPhase.flyingToWeb ||
            b.phase == WebButterflyPhase.mismatchRelease ||
            b.phase == WebButterflyPhase.matchedDance,
      );
      if (!busy) inputLocked = false;
    }

    var boardsCleared = state.boardsCleared;
    if (_boardRefreshDelay > 0) {
      _boardRefreshDelay -= delta;
      if (_boardRefreshDelay <= 0 && butterflies.isEmpty) {
        butterflies = ButterflyWebMatchingLogic.spawnBoard(
          _playArea,
          state.settings,
        );
        boardsCleared += 1;
        inputLocked = false;
      }
    } else if (butterflies.isEmpty && state.pairsMatched > 0) {
      // Board cleared — brief pause then new butterflies.
      _boardRefreshDelay = 0.8;
    }

    state = state.copyWith(
      butterflies: butterflies,
      sparkles: sparkles,
      envPhase: state.envPhase + delta,
      inputLocked: inputLocked,
      boardsCleared: boardsCleared,
      gardenBloom: math.min(1.0, state.gardenBloom),
    );
  }

  /// Returns: 'selected' | 'match' | 'mismatch' | 'ignored'
  String tapButterfly(String id) {
    if (state.sessionPhase != WebMatchSessionPhase.playing) return 'ignored';
    if (state.inputLocked) return 'ignored';

    final index = state.butterflies.indexWhere((b) => b.id == id);
    if (index < 0) return 'ignored';
    final tapped = state.butterflies[index];
    if (!tapped.canTap) return 'ignored';

    final selectedId = state.selectedId;

    // Deselect if tapping the same butterfly on the web — free it to flutter.
    if (selectedId == id) {
      final updated = [...state.butterflies];
      updated[index] = tapped.copyWith(
        phase: WebButterflyPhase.mismatchRelease,
        animProgress: 0,
      );
      state = state.copyWith(
        butterflies: updated,
        clearSelected: true,
        inputLocked: true,
      );
      return 'mismatch';
    }

    // First selection — halt mid-flight onto a magical web.
    if (selectedId == null) {
      final updated = [...state.butterflies];
      updated[index] = tapped.copyWith(
        phase: WebButterflyPhase.flyingToWeb,
        animProgress: 0,
        webX: tapped.x,
        webY: tapped.y,
      );
      state = state.copyWith(
        butterflies: updated,
        selectedId: id,
        inputLocked: true,
      );
      return 'selected';
    }

    // Second selection — compare pairs.
    final firstIndex = state.butterflies.indexWhere((b) => b.id == selectedId);
    if (firstIndex < 0) {
      state = state.copyWith(clearSelected: true);
      return 'ignored';
    }
    final first = state.butterflies[firstIndex];

    if (first.pairId == tapped.pairId) {
      return _onMatch(firstIndex, index);
    }
    return _onMismatch(firstIndex, index);
  }

  String _onMatch(int firstIndex, int secondIndex) {
    final first = state.butterflies[firstIndex];
    final second = state.butterflies[secondIndex];
    final centerX = (first.x + second.x) / 2;
    final centerY = (first.y + second.y) / 2;
    final updated = [...state.butterflies];
    updated[firstIndex] = first.copyWith(
      phase: WebButterflyPhase.matchedDance,
      animProgress: 0,
      danceCenterX: centerX,
      danceCenterY: centerY,
      webOpacity: 0,
    );
    updated[secondIndex] = second.copyWith(
      phase: WebButterflyPhase.matchedDance,
      animProgress: 0,
      danceCenterX: centerX,
      danceCenterY: centerY,
    );

    final streak = state.currentStreak + 1;
    final pairs = state.pairsMatched + 1;
    final reward =
        ButterflyWebMatchingLogic.matchReward(state.settings, streak);

    state = state.copyWith(
      butterflies: updated,
      clearSelected: true,
      inputLocked: true,
      pairsMatched: pairs,
      currentStreak: streak,
      longestStreak: math.max(state.longestStreak, streak),
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      rewardPoints: state.rewardPoints + reward.rewardPoints,
      rainbowTokens: state.rainbowTokens + reward.rainbow,
      gardenBloom: (state.gardenBloom + 0.12).clamp(0.0, 1.0),
      showRainbow: true,
      showSparkles: state.settings.celebrationsEnabled,
      showMascot: state.settings.celebrationsEnabled && pairs % 3 == 0,
      feedbackMessage: state.settings.narrationEnabled
          ? ButterflyWebMatchingLogic.pickEncouragement(pairs)
          : null,
      lastRewardText: state.settings.celebrationsEnabled
          ? '+${reward.coins > 0 ? '${reward.coins} Coins  ' : ''}'
              '+${reward.xp} XP'
              '${reward.stars > 0 ? '  +${reward.stars} Star' : ''}'
          : null,
    );
    _scheduleFeedbackClear();
    _rainbowTimer?.cancel();
    _rainbowTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) state = state.copyWith(showRainbow: false);
    });
    return 'match';
  }

  String _onMismatch(int firstIndex, int secondIndex) {
    final updated = [...state.butterflies];
    // Free the webbed butterfly — it resumes fluttering. Second keeps flying.
    updated[firstIndex] = updated[firstIndex].copyWith(
      phase: WebButterflyPhase.mismatchRelease,
      animProgress: 0,
    );

    state = state.copyWith(
      butterflies: updated,
      clearSelected: true,
      inputLocked: true,
      currentStreak: 0,
      showSparkles: true,
    );
    _scheduleFeedbackClear();
    return 'mismatch';
  }

  void tapMiss(Offset local) {
    if (state.sessionPhase != WebMatchSessionPhase.playing) return;
    final sparkle = TapSparkle(
      id: 'spark_${DateTime.now().microsecondsSinceEpoch}',
      x: local.dx,
      y: local.dy,
    );
    state = state.copyWith(sparkles: [...state.sparkles, sparkle]);
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(clearFeedback: true, showSparkles: false);
      }
    });
  }

  void pause() {
    if (state.sessionPhase == WebMatchSessionPhase.playing) {
      _sessionTimer?.cancel();
      state = state.copyWith(sessionPhase: WebMatchSessionPhase.paused);
    }
  }

  void resume() {
    if (state.sessionPhase == WebMatchSessionPhase.paused) {
      state = state.copyWith(sessionPhase: WebMatchSessionPhase.playing);
      if (!state.settings.practiceMode) {
        _startTimer();
      }
    }
  }

  void endPractice() {
    if (state.settings.practiceMode &&
        state.sessionPhase == WebMatchSessionPhase.playing) {
      _endSession();
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      sessionPhase: WebMatchSessionPhase.finished,
      showSparkles: true,
      showMascot: true,
      showRainbow: true,
      feedbackMessage:
          ButterflyWebMatchingLogic.pickEndMessage(state.pairsMatched),
    );
  }

  ButterflyWebMatchingResult getResult() =>
      ButterflyWebMatchingLogic.buildResult(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.pairsMatched == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.butterflyWebMatching,
      (s) => s.copyWith(
        bestScore: math.max(s.bestScore, result.pairsMatched),
        starsEarned: s.starsEarned + result.stars,
        timesPlayed: s.timesPlayed + 1,
        totalCorrect: s.totalCorrect + result.pairsMatched,
        lastPlayed: DateTime.now(),
      ),
    );

    await _ref
        .read(profileProvider.notifier)
        .applyReward(ButterflyWebMatchingLogic.toReward(result));
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.butterflyWebMatching);
    _ref.invalidate(allGameStatsProvider);
  }

  void reset() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _rainbowTimer?.cancel();
    _boardRefreshDelay = 0;
    state = const ButterflyWebMatchingState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _rainbowTimer?.cancel();
    super.dispose();
  }
}
