import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';

enum BubbleTheme {
  defaultTheme('default', 'Default'),
  ocean('ocean', 'Ocean'),
  space('space', 'Space'),
  candy('candy', 'Candy'),
  jungle('jungle', 'Jungle'),
  rainbow('rainbow', 'Rainbow'),
  galaxy('galaxy', 'Galaxy');

  const BubbleTheme(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum GamePhase { setup, countdown, playing, paused, gameOver, victory }

enum BubbleTapResult { ignored, correct, wrong }

class BubbleGameConfig extends Equatable {
  const BubbleGameConfig({
    this.sortMode = SortMode.ascending,
    this.difficulty = Difficulty.easy,
    this.timerMode = TimerMode.timed,
    this.timerSeconds = 60,
    this.bubbleCount = 8,
    this.minValue = 0,
    this.maxValue = 20,
    this.hintsEnabled = true,
    this.bubbleSpeed = 1.0,
    this.theme = BubbleTheme.defaultTheme,
    this.toddlerMode = false,
    this.randomNumbers = false,
    this.wordMatchMode = false,
    this.gameId = GameId.ascendingBubbleNumberPop,
  });

  final SortMode sortMode;
  final Difficulty difficulty;
  final TimerMode timerMode;
  final int timerSeconds;
  final int bubbleCount;
  final int minValue;
  final int maxValue;
  final bool hintsEnabled;
  final double bubbleSpeed;
  final BubbleTheme theme;
  final bool toddlerMode;
  final bool randomNumbers;
  /// When true, show a number word and pop the matching digit bubble.
  final bool wordMatchMode;
  final GameId gameId;

  bool get isValid => minValue <= maxValue;

  /// Little Explorers: huge bubbles, slow motion, 0–10 range.
  factory BubbleGameConfig.littleExplorers({int timerSeconds = 60}) =>
      BubbleGameConfig(
        sortMode: SortMode.ascending,
        difficulty: Difficulty.easy,
        timerMode: TimerMode.timed,
        timerSeconds: timerSeconds,
        bubbleCount: 8,
        minValue: 0,
        maxValue: 10,
        hintsEnabled: true,
        bubbleSpeed: 0.35,
        toddlerMode: true,
        randomNumbers: false,
        wordMatchMode: false,
        gameId: GameId.bubbleNumberPop,
      );

  factory BubbleGameConfig.ascending({
    int timerSeconds = 60,
    int minValue = 0,
    int maxValue = 20,
    int bubbleCount = 8,
    bool randomNumbers = false,
  }) =>
      BubbleGameConfig(
        sortMode: SortMode.ascending,
        difficulty: Difficulty.easy,
        timerMode: TimerMode.timed,
        timerSeconds: timerSeconds,
        bubbleCount: bubbleCount.clamp(5, 10),
        minValue: minValue,
        maxValue: maxValue,
        hintsEnabled: true,
        bubbleSpeed: 0.6,
        toddlerMode: false,
        randomNumbers: randomNumbers,
        wordMatchMode: false,
        gameId: GameId.ascendingBubbleNumberPop,
      );

  factory BubbleGameConfig.descending({
    int timerSeconds = 60,
    int minValue = 0,
    int maxValue = 20,
    int bubbleCount = 8,
    bool randomNumbers = false,
  }) =>
      BubbleGameConfig(
        sortMode: SortMode.descending,
        difficulty: Difficulty.easy,
        timerMode: TimerMode.timed,
        timerSeconds: timerSeconds,
        bubbleCount: bubbleCount.clamp(5, 10),
        minValue: minValue,
        maxValue: maxValue,
        hintsEnabled: true,
        bubbleSpeed: 0.6,
        toddlerMode: false,
        randomNumbers: randomNumbers,
        wordMatchMode: false,
        gameId: GameId.descendingNumberPop,
      );

  factory BubbleGameConfig.numberWord({
    int timerSeconds = 60,
    int minValue = 0,
    int maxValue = 50,
    int bubbleCount = 8,
    bool randomNumbers = true,
  }) =>
      BubbleGameConfig(
        sortMode: SortMode.ascending,
        difficulty: Difficulty.easy,
        timerMode: TimerMode.timed,
        timerSeconds: timerSeconds,
        bubbleCount: bubbleCount.clamp(5, 10),
        minValue: minValue.clamp(0, 9999),
        maxValue: maxValue.clamp(0, 9999),
        hintsEnabled: true,
        bubbleSpeed: 0.6,
        toddlerMode: false,
        randomNumbers: randomNumbers,
        wordMatchMode: true,
        gameId: GameId.numberWordPop,
      );

  BubbleGameConfig copyWith({
    SortMode? sortMode,
    Difficulty? difficulty,
    TimerMode? timerMode,
    int? timerSeconds,
    int? bubbleCount,
    int? minValue,
    int? maxValue,
    bool? hintsEnabled,
    double? bubbleSpeed,
    BubbleTheme? theme,
    bool? toddlerMode,
    bool? randomNumbers,
    bool? wordMatchMode,
    GameId? gameId,
  }) =>
      BubbleGameConfig(
        sortMode: sortMode ?? this.sortMode,
        difficulty: difficulty ?? this.difficulty,
        timerMode: timerMode ?? this.timerMode,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        bubbleCount: bubbleCount ?? this.bubbleCount,
        minValue: minValue ?? this.minValue,
        maxValue: maxValue ?? this.maxValue,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
        bubbleSpeed: bubbleSpeed ?? this.bubbleSpeed,
        theme: theme ?? this.theme,
        toddlerMode: toddlerMode ?? this.toddlerMode,
        randomNumbers: randomNumbers ?? this.randomNumbers,
        wordMatchMode: wordMatchMode ?? this.wordMatchMode,
        gameId: gameId ?? this.gameId,
      );

  @override
  List<Object?> get props => [
        sortMode,
        difficulty,
        timerMode,
        timerSeconds,
        bubbleCount,
        minValue,
        maxValue,
        hintsEnabled,
        bubbleSpeed,
        theme,
        toddlerMode,
        randomNumbers,
        wordMatchMode,
        gameId,
      ];
}

class BubbleEntity extends Equatable {
  const BubbleEntity({
    required this.id,
    required this.number,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.colorIndex,
    this.isPopping = false,
    this.isWrong = false,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });

  final String id;
  final int number;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double radius;
  final int colorIndex;
  final bool isPopping;
  final bool isWrong;
  final double rotation;
  final double rotationSpeed;

  BubbleEntity copyWith({
    int? number,
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? radius,
    int? colorIndex,
    bool? isPopping,
    bool? isWrong,
    double? rotation,
    double? rotationSpeed,
  }) =>
      BubbleEntity(
        id: id,
        number: number ?? this.number,
        x: x ?? this.x,
        y: y ?? this.y,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
        radius: radius ?? this.radius,
        colorIndex: colorIndex ?? this.colorIndex,
        isPopping: isPopping ?? this.isPopping,
        isWrong: isWrong ?? this.isWrong,
        rotation: rotation ?? this.rotation,
        rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      );

  @override
  List<Object?> get props => [
        id,
        number,
        x,
        y,
        vx,
        vy,
        radius,
        colorIndex,
        isPopping,
        isWrong,
        rotation,
        rotationSpeed,
      ];
}

class BubbleGameState extends Equatable {
  const BubbleGameState({
    this.phase = GamePhase.setup,
    this.config = const BubbleGameConfig(),
    this.bubbles = const [],
    this.sortedNumbers = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.combo = 0,
    this.longestCombo = 0,
    this.mistakes = 0,
    this.elapsedSeconds = 0,
    this.remainingSeconds = 0,
    this.showHint = false,
    this.lastInteraction,
    this.countdown = 3,
    this.feedbackMessage,
    this.lastPointsEarned = 0,
    this.totalCorrectPops = 0,
    this.wordTarget,
  });

  final GamePhase phase;
  final BubbleGameConfig config;
  final List<BubbleEntity> bubbles;
  final List<int> sortedNumbers;
  final int currentIndex;
  final int score;
  final int combo;
  final int longestCombo;
  final int mistakes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool showHint;
  final DateTime? lastInteraction;
  final int countdown;
  final String? feedbackMessage;
  final int lastPointsEarned;
  final int totalCorrectPops;
  /// Explicit target for word-match mode (number matching the shown word).
  final int? wordTarget;

  int? get targetNumber {
    if (config.wordMatchMode) return wordTarget;
    return currentIndex < sortedNumbers.length
        ? sortedNumbers[currentIndex]
        : null;
  }

  int get total => sortedNumbers.length;

  bool get isComplete => currentIndex >= sortedNumbers.length && total > 0;

  double get accuracy {
    final totalAttempts = totalCorrectPops + mistakes;
    if (totalAttempts == 0) return 1;
    return totalCorrectPops / totalAttempts;
  }

  BubbleGameState copyWith({
    GamePhase? phase,
    BubbleGameConfig? config,
    List<BubbleEntity>? bubbles,
    List<int>? sortedNumbers,
    int? currentIndex,
    int? score,
    int? combo,
    int? longestCombo,
    int? mistakes,
    int? elapsedSeconds,
    int? remainingSeconds,
    bool? showHint,
    DateTime? lastInteraction,
    int? countdown,
    String? feedbackMessage,
    int? lastPointsEarned,
    int? totalCorrectPops,
    int? wordTarget,
    bool clearFeedback = false,
    bool clearWordTarget = false,
  }) =>
      BubbleGameState(
        phase: phase ?? this.phase,
        config: config ?? this.config,
        bubbles: bubbles ?? this.bubbles,
        sortedNumbers: sortedNumbers ?? this.sortedNumbers,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        combo: combo ?? this.combo,
        longestCombo: longestCombo ?? this.longestCombo,
        mistakes: mistakes ?? this.mistakes,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        showHint: showHint ?? this.showHint,
        lastInteraction: lastInteraction ?? this.lastInteraction,
        countdown: countdown ?? this.countdown,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastPointsEarned: lastPointsEarned ?? this.lastPointsEarned,
        totalCorrectPops: totalCorrectPops ?? this.totalCorrectPops,
        wordTarget: clearWordTarget ? null : (wordTarget ?? this.wordTarget),
      );

  @override
  List<Object?> get props => [
        phase,
        config,
        bubbles,
        sortedNumbers,
        currentIndex,
        score,
        combo,
        longestCombo,
        mistakes,
        elapsedSeconds,
        remainingSeconds,
        showHint,
        lastInteraction,
        countdown,
        feedbackMessage,
        lastPointsEarned,
        totalCorrectPops,
        wordTarget,
      ];
}

class BubbleGameResult extends Equatable {
  const BubbleGameResult({
    required this.score,
    required this.stars,
    required this.coins,
    required this.xp,
    required this.accuracy,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.longestCombo,
    required this.isPerfect,
    required this.isNewBest,
    required this.isVictory,
  });

  final int score;
  final int stars;
  final int coins;
  final int xp;
  final double accuracy;
  final int mistakes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final int longestCombo;
  final bool isPerfect;
  final bool isNewBest;
  final bool isVictory;

  @override
  List<Object?> get props => [
        score,
        stars,
        coins,
        xp,
        accuracy,
        mistakes,
        elapsedSeconds,
        remainingSeconds,
        longestCombo,
        isPerfect,
        isNewBest,
        isVictory,
      ];
}
