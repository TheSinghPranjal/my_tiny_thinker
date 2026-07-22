import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum NumberMemoryPhase {
  ready,
  countdown,
  showing,
  input,
  celebrating,
  paused,
  finished,
}

class NumberMemorySettings extends Equatable {
  const NumberMemorySettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.digitCount = 4,
  });

  final int sessionSeconds;
  /// How many digits to memorize (1–10). Default 4 → numbers 0–9999.
  final int digitCount;

  NumberMemorySettings copyWith({
    int? sessionSeconds,
    int? digitCount,
  }) =>
      NumberMemorySettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        digitCount: (digitCount ?? this.digitCount).clamp(1, 10),
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'digitCount': digitCount,
      };

  factory NumberMemorySettings.fromJson(Map<String, dynamic> json) {
    return NumberMemorySettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
      digitCount: (json['digitCount'] as int? ?? 4).clamp(1, 10),
    );
  }

  @override
  List<Object?> get props => [sessionSeconds, digitCount];
}

class NumberMemoryState extends Equatable {
  const NumberMemoryState({
    this.phase = NumberMemoryPhase.ready,
    this.settings = const NumberMemorySettings(),
    this.targetNumber = '',
    this.input = '',
    this.remainingSeconds = 60,
    this.countdown = 3,
    this.score = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.attemptsLeft = 2,
    this.showShake = false,
    this.showErrorBorder = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.pendingEnd = false,
    this.phaseBeforePause,
  });

  final NumberMemoryPhase phase;
  final NumberMemorySettings settings;
  /// Zero-padded digit string of length [settings.digitCount].
  final String targetNumber;
  final String input;
  final int remainingSeconds;
  final int countdown;
  final int score;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int correctCount;
  final int wrongCount;
  final int combo;
  final int maxCombo;
  /// Starts at 2 per number; first miss → 1; second miss → next number.
  final int attemptsLeft;
  final bool showShake;
  final bool showErrorBorder;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool pendingEnd;
  final NumberMemoryPhase? phaseBeforePause;

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 1;
    return correctCount / total;
  }

  NumberMemoryState copyWith({
    NumberMemoryPhase? phase,
    NumberMemorySettings? settings,
    String? targetNumber,
    String? input,
    int? remainingSeconds,
    int? countdown,
    int? score,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? correctCount,
    int? wrongCount,
    int? combo,
    int? maxCombo,
    int? attemptsLeft,
    bool? showShake,
    bool? showErrorBorder,
    String? feedbackMessage,
    String? lastRewardText,
    bool? pendingEnd,
    NumberMemoryPhase? phaseBeforePause,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearPhaseBeforePause = false,
  }) =>
      NumberMemoryState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        targetNumber: targetNumber ?? this.targetNumber,
        input: input ?? this.input,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        countdown: countdown ?? this.countdown,
        score: score ?? this.score,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        correctCount: correctCount ?? this.correctCount,
        wrongCount: wrongCount ?? this.wrongCount,
        combo: combo ?? this.combo,
        maxCombo: maxCombo ?? this.maxCombo,
        attemptsLeft: attemptsLeft ?? this.attemptsLeft,
        showShake: showShake ?? this.showShake,
        showErrorBorder: showErrorBorder ?? this.showErrorBorder,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        pendingEnd: pendingEnd ?? this.pendingEnd,
        phaseBeforePause: clearPhaseBeforePause
            ? null
            : (phaseBeforePause ?? this.phaseBeforePause),
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        targetNumber,
        input,
        remainingSeconds,
        countdown,
        score,
        coinsEarned,
        xpEarned,
        starsEarned,
        correctCount,
        wrongCount,
        combo,
        maxCombo,
        attemptsLeft,
        showShake,
        showErrorBorder,
        feedbackMessage,
        lastRewardText,
        pendingEnd,
        phaseBeforePause,
      ];
}

class NumberMemoryResult extends Equatable {
  const NumberMemoryResult({
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.maxCombo,
    required this.encouragement,
  });

  final int score;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final int coins;
  final int xp;
  final int stars;
  final int maxCombo;
  final String encouragement;

  @override
  List<Object?> get props => [
        score,
        correctCount,
        wrongCount,
        accuracy,
        coins,
        xp,
        stars,
        maxCombo,
        encouragement,
      ];
}

const kNumberMemorySkills = [
  'Working Memory',
  'Number Sense',
  'Concentration',
  'Focus',
  'Recall',
];

const kNumberPraise = [
  'Great!',
  'Awesome!',
  'You got it!',
  'Excellent!',
  'Super Memory!',
  'Brilliant!',
];

const kEndPraise = [
  'Memory Master!',
  'Number Champ!',
  'Brain Star!',
  'Keep Thinking!',
  'Fantastic Focus!',
];
