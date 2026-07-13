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

class BubbleGameConfig extends Equatable {
  const BubbleGameConfig({
    this.sortMode = SortMode.ascending,
    this.difficulty = Difficulty.easy,
    this.timerMode = TimerMode.relaxed,
    this.timerSeconds = 60,
    this.bubbleCount = 10,
    this.minValue = 1,
    this.maxValue = 20,
    this.hintsEnabled = true,
    this.bubbleSpeed = 1.0,
    this.theme = BubbleTheme.defaultTheme,
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

  bool get isValid => minValue <= maxValue;

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

  int? get targetNumber =>
      currentIndex < sortedNumbers.length ? sortedNumbers[currentIndex] : null;

  int get total => sortedNumbers.length;

  bool get isComplete => currentIndex >= sortedNumbers.length && total > 0;

  double get accuracy {
    final totalAttempts = currentIndex + mistakes;
    if (totalAttempts == 0) return 1;
    return currentIndex / totalAttempts;
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
    required this.longestCombo,
    required this.isPerfect,
    required this.isNewBest,
  });

  final int score;
  final int stars;
  final int coins;
  final int xp;
  final double accuracy;
  final int mistakes;
  final int elapsedSeconds;
  final int longestCombo;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props => [
        score,
        stars,
        coins,
        xp,
        accuracy,
        mistakes,
        elapsedSeconds,
        longestCombo,
        isPerfect,
        isNewBest,
      ];
}
