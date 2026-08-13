import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/play_limits/daily_play_limits.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/logic/learn_to_sort_food_logic.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

final learnToSortFoodControllerProvider =
    StateNotifierProvider<LearnToSortFoodController, FoodSortState>((ref) {
  return LearnToSortFoodController(ref);
});

class LearnToSortFoodController extends StateNotifier<FoodSortState> {
  LearnToSortFoodController(this._ref) : super(const FoodSortState());

  final Ref _ref;
  Timer? _sessionTimer;
  Timer? _feedbackTimer;
  Timer? _celebrateTimer;
  Timer? _wrongTimer;

  void startGame(FoodSortSettings settings) {
    _cancelTimers();
    final bubbleCount = LearnToSortFoodLogic.bubbleCountForDifficulty(
      LearnToSortFoodLogic.effectiveDifficulty(settings, 1),
    );
    state = FoodSortState(
      phase: FoodSortPhase.playing,
      settings: settings,
      foods: LearnToSortFoodLogic.spawnFoods(
        settings: settings,
        round: 1,
        count: bubbleCount,
      ),
      baskets: LearnToSortFoodLogic.defaultBaskets(),
      round: 1,
      remainingSeconds: settings.unlimitedTime ? 0 : settings.sessionSeconds,
    );
    if (!settings.unlimitedTime) _startTimer();
  }

  void tick(double delta) {
    if (state.phase != FoodSortPhase.playing &&
        state.phase != FoodSortPhase.celebrating) {
      return;
    }
    final anim = LearnToSortFoodLogic.tickAnimations(
      state.foods,
      state.baskets,
      delta,
    );
    state = state.copyWith(
      envPhase: state.envPhase + delta,
      foods: anim.foods,
      baskets: anim.baskets,
    );
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != FoodSortPhase.playing &&
          state.phase != FoodSortPhase.celebrating) {
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
    if (state.phase == FoodSortPhase.celebrating) {
      state = state.copyWith(pendingEnd: true, remainingSeconds: 0);
      return;
    }
    _endSession();
  }

  void setHoverBasket(String? basketId) {
    if (state.hoverBasketId == basketId) return;
    state = state.copyWith(
      hoverBasketId: basketId,
      clearHover: basketId == null,
    );
  }

  bool tryDrop({required String foodId, required String basketId}) {
    if (state.phase != FoodSortPhase.playing &&
        state.phase != FoodSortPhase.celebrating) {
      return false;
    }

    final foodIdx = state.foods.indexWhere((f) => f.id == foodId);
    if (foodIdx < 0) return false;
    final food = state.foods[foodIdx];
    if (food.hidden) return false;

    final basketIdx = state.baskets.indexWhere((b) => b.id == basketId);
    if (basketIdx < 0) return false;

    final basket = state.baskets[basketIdx];
    final attempts = state.attempts + 1;

    if (food.category != basket.category) {
      _handleWrongDrop(food: food, basketId: basketId, attempts: attempts);
      return false;
    }

    _handleCorrectDrop(
      food: food,
      foodIdx: foodIdx,
      basket: basket,
      basketIdx: basketIdx,
      attempts: attempts,
    );
    return true;
  }

  /// The food bounces back into the sky, the wrong basket wobbles and the
  /// correct one glows as a hint. Nothing is taken away from the child.
  void _handleWrongDrop({
    required FloatingFood food,
    required String basketId,
    required int attempts,
  }) {
    state = state.copyWith(
      foods: [
        for (final f in state.foods)
          f.id == food.id ? f.copyWith(shake: true) : f,
      ],
      baskets: [
        for (final b in state.baskets)
          b.copyWith(
            wobble: b.id == basketId,
            hintPulse: b.category == food.category,
            glow: b.category == food.category,
          ),
      ],
      attempts: attempts,
      streak: 0,
      wrongHintText: 'Not this one!',
      clearHover: true,
    );

    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      state = state.copyWith(
        foods: [
          for (final f in state.foods)
            f.id == food.id ? f.copyWith(shake: false) : f,
        ],
        baskets: [
          for (final b in state.baskets)
            b.copyWith(wobble: false, hintPulse: false, glow: false),
        ],
        clearHint: true,
      );
    });
  }

  void _handleCorrectDrop({
    required FloatingFood food,
    required int foodIdx,
    required SortBasket basket,
    required int basketIdx,
    required int attempts,
  }) {
    final streak = state.streak + 1;
    final reward = LearnToSortFoodLogic.matchReward(state.settings, streak);
    final isHealthy = food.category == FoodCategory.healthy;
    final milestone = (state.correctMatches + 1) % 5 == 0;
    final round = state.round + 1;

    // Refill the sky, growing the bubble count as the difficulty ramps up. The
    // lower bound keeps at least one replacement so the count never shrinks.
    final remaining = [...state.foods]..removeAt(foodIdx);
    final targetCount = math.max(
      LearnToSortFoodLogic.bubbleCountForDifficulty(
        LearnToSortFoodLogic.effectiveDifficulty(state.settings, round),
      ),
      remaining.length + 1,
    );
    final nextFoods = [...remaining];
    while (nextFoods.length < targetCount) {
      nextFoods.add(
        LearnToSortFoodLogic.spawnFood(
          settings: state.settings,
          round: round,
          existing: nextFoods,
          requireCategory: LearnToSortFoodLogic.requiredCategoryFor(nextFoods),
        ),
      );
    }

    final baskets = [...state.baskets];
    baskets[basketIdx] = basket.copyWith(
      happy: true,
      glow: true,
      hintPulse: false,
      wobble: false,
    );

    state = state.copyWith(
      foods: nextFoods,
      baskets: baskets,
      round: round,
      attempts: attempts,
      correctMatches: state.correctMatches + 1,
      streak: streak,
      maxStreak: math.max(state.maxStreak, streak),
      score: state.score + reward.points,
      coinsEarned: state.coinsEarned + reward.coins,
      xpEarned: state.xpEarned + reward.xp,
      starsEarned: state.starsEarned + reward.stars,
      phase: FoodSortPhase.celebrating,
      feedbackMessage: isHealthy ? 'HEALTHY!' : 'JUNK FOOD',
      subFeedbackMessage: isHealthy ? 'Healthy Food!' : 'Junk Food!',
      spokenFoodName: food.foodDef.name,
      lastRewardText: '+${reward.stars} Stars',
      showSparkles: true,
      showMascot: milestone,
      showMilestone: milestone,
      clearHover: true,
      clearHint: true,
    );
    _scheduleFeedbackClear();

    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      state = state.copyWith(
        baskets: [
          for (final b in state.baskets) b.copyWith(happy: false, glow: false),
        ],
      );

      if (state.pendingEnd) {
        _endSession();
        return;
      }

      state = state.copyWith(
        phase: FoodSortPhase.playing,
        showSparkles: false,
        showMilestone: false,
      );
    });
  }

  void _scheduleFeedbackClear() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        state = state.copyWith(
          clearFeedback: true,
          clearReward: true,
          clearSpoken: true,
          showMascot: false,
        );
      }
    });
  }

  void pause() {
    if (state.phase == FoodSortPhase.playing ||
        state.phase == FoodSortPhase.celebrating) {
      _sessionTimer?.cancel();
      state = state.copyWith(phase: FoodSortPhase.paused);
    }
  }

  void resume() {
    if (state.phase == FoodSortPhase.paused) {
      state = state.copyWith(phase: FoodSortPhase.playing);
      if (!state.settings.unlimitedTime) _startTimer();
    }
  }

  void _endSession() {
    _cancelTimers();
    state = state.copyWith(phase: FoodSortPhase.finished);
  }

  void finishNow() => _endSession();

  void reset() {
    _cancelTimers();
    state = const FoodSortState();
  }

  void _cancelTimers() {
    _sessionTimer?.cancel();
    _feedbackTimer?.cancel();
    _celebrateTimer?.cancel();
    _wrongTimer?.cancel();
  }

  FoodSortResult getResult() => LearnToSortFoodLogic.calculate(state);

  Future<void> saveResult() async {
    final result = getResult();
    if (result.correctMatches == 0 && result.coins == 0) return;

    final storage = _ref.read(storageServiceProvider);
    await saveGameStatsResult(
      storage,
      GameId.learnToSortFood,
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
          LearnToSortFoodLogic.toReward(result),
        );
    await _ref
        .read(dailyPlayLimitsProvider.notifier)
        .recordPlay(GameId.learnToSortFood);
    _ref.invalidate(allGameStatsProvider);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
