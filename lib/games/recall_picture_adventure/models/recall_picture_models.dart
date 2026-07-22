import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum RecallPicturePhase {
  ready,
  countdown,
  showing,
  input,
  celebrating,
  paused,
  finished,
}

enum RecallSceneColor {
  red('red', 'Red', Color(0xFFEF5350)),
  blue('blue', 'Blue', Color(0xFF42A5F5)),
  green('green', 'Green', Color(0xFF66BB6A)),
  yellow('yellow', 'Yellow', Color(0xFFFFCA28)),
  purple('purple', 'Purple', Color(0xFFAB47BC));

  const RecallSceneColor(this.key, this.label, this.color);
  final String key;
  final String label;
  final Color color;
}

enum RecallSceneShape {
  circle,
  square,
  triangle,
  star,
  heart,
}

enum RecallQuestionType {
  balloonCount,
  animal,
  color,
  shape,
}

class RecallPictureSettings extends Equatable {
  const RecallPictureSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
  });

  final int sessionSeconds;

  RecallPictureSettings copyWith({int? sessionSeconds}) =>
      RecallPictureSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
      };

  factory RecallPictureSettings.fromJson(Map<String, dynamic> json) {
    return RecallPictureSettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
    );
  }

  @override
  List<Object?> get props => [sessionSeconds];
}

class RecallScene extends Equatable {
  const RecallScene({
    required this.balloonCount,
    required this.animal,
    required this.color,
    required this.shape,
    required this.shapeAccent,
  });

  final int balloonCount;
  final String animal;
  final RecallSceneColor color;
  final RecallSceneShape shape;
  /// Secondary fill for the shape (same family or accent).
  final Color shapeAccent;

  @override
  List<Object?> get props =>
      [balloonCount, animal, color, shape, shapeAccent];
}

class RecallOption extends Equatable {
  const RecallOption({
    required this.id,
    required this.valueKey,
    this.label,
    this.emoji,
    this.color,
    this.shape,
  });

  final String id;
  /// Internal answer key (number string, animal emoji, color key, shape name).
  final String valueKey;
  final String? label;
  final String? emoji;
  final Color? color;
  final RecallSceneShape? shape;

  @override
  List<Object?> get props => [id, valueKey, label, emoji, color, shape];
}

class RecallQuestion extends Equatable {
  const RecallQuestion({
    required this.type,
    required this.prompt,
    required this.correctKey,
    required this.options,
  });

  final RecallQuestionType type;
  final String prompt;
  final String correctKey;
  final List<RecallOption> options;

  @override
  List<Object?> get props => [type, prompt, correctKey, options];
}

class RecallPictureState extends Equatable {
  const RecallPictureState({
    this.phase = RecallPicturePhase.ready,
    this.settings = const RecallPictureSettings(),
    this.scene,
    this.question,
    this.remainingSeconds = 60,
    this.countdown = 3,
    this.score = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.roundsCompleted = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.selectedOptionId,
    this.wrongOptionId,
    this.lockInput = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.pendingEnd = false,
    this.bounceCorrect = false,
  });

  final RecallPicturePhase phase;
  final RecallPictureSettings settings;
  final RecallScene? scene;
  final RecallQuestion? question;
  final int remainingSeconds;
  final int countdown;
  final int score;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int correctCount;
  final int wrongCount;
  final int roundsCompleted;
  final int combo;
  final int maxCombo;
  final String? selectedOptionId;
  final String? wrongOptionId;
  final bool lockInput;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool pendingEnd;
  final bool bounceCorrect;

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 1;
    return correctCount / total;
  }

  RecallPictureState copyWith({
    RecallPicturePhase? phase,
    RecallPictureSettings? settings,
    RecallScene? scene,
    RecallQuestion? question,
    int? remainingSeconds,
    int? countdown,
    int? score,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? correctCount,
    int? wrongCount,
    int? roundsCompleted,
    int? combo,
    int? maxCombo,
    String? selectedOptionId,
    String? wrongOptionId,
    bool? lockInput,
    String? feedbackMessage,
    String? lastRewardText,
    bool? pendingEnd,
    bool? bounceCorrect,
    bool clearScene = false,
    bool clearQuestion = false,
    bool clearSelected = false,
    bool clearWrong = false,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      RecallPictureState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        scene: clearScene ? null : (scene ?? this.scene),
        question: clearQuestion ? null : (question ?? this.question),
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        countdown: countdown ?? this.countdown,
        score: score ?? this.score,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        correctCount: correctCount ?? this.correctCount,
        wrongCount: wrongCount ?? this.wrongCount,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
        combo: combo ?? this.combo,
        maxCombo: maxCombo ?? this.maxCombo,
        selectedOptionId:
            clearSelected ? null : (selectedOptionId ?? this.selectedOptionId),
        wrongOptionId:
            clearWrong ? null : (wrongOptionId ?? this.wrongOptionId),
        lockInput: lockInput ?? this.lockInput,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        pendingEnd: pendingEnd ?? this.pendingEnd,
        bounceCorrect: bounceCorrect ?? this.bounceCorrect,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        scene,
        question,
        remainingSeconds,
        countdown,
        score,
        coinsEarned,
        xpEarned,
        starsEarned,
        correctCount,
        wrongCount,
        roundsCompleted,
        combo,
        maxCombo,
        selectedOptionId,
        wrongOptionId,
        lockInput,
        feedbackMessage,
        lastRewardText,
        pendingEnd,
        bounceCorrect,
      ];
}

class RecallPictureResult extends Equatable {
  const RecallPictureResult({
    required this.roundsCompleted,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.score,
    required this.maxCombo,
    required this.encouragement,
  });

  final int roundsCompleted;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final int coins;
  final int xp;
  final int stars;
  final int score;
  final int maxCombo;
  final String encouragement;

  @override
  List<Object?> get props => [
        roundsCompleted,
        correctCount,
        wrongCount,
        accuracy,
        coins,
        xp,
        stars,
        score,
        maxCombo,
        encouragement,
      ];
}

const kRecallPictureSkills = [
  'Visual Memory',
  'Attention',
  'Observation',
  'Recall',
  'Focus',
];

const kRecallPraise = [
  'Great!',
  'Awesome!',
  'Excellent!',
  'Nice Job!',
  'Super!',
  'Brilliant!',
];

const kRecallEndPraise = [
  'Memory Superstar!',
  'Picture Master!',
  'Sharp Eyes!',
  'Keep Remembering!',
  'Fantastic Focus!',
];
