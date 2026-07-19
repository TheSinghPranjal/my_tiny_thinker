import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

enum ColorBalloonSessionPhase { ready, playing, paused, finished }

enum ColorBalloonRoundPhase {
  instructing,
  rising,
  waiting,
  celebrating,
  clearing,
}

class ColorBalloonPopSettings extends Equatable {
  const ColorBalloonPopSettings({
    this.sessionSeconds = 60,
    this.rewardMultiplier = 1.0,
    this.animationSpeed = 1.0,
    this.musicVolume = 1.0,
    this.voiceEnabled = true,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final double rewardMultiplier;
  final double animationSpeed;
  final double musicVolume;
  final bool voiceEnabled;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  ColorBalloonPopSettings copyWith({
    int? sessionSeconds,
    double? rewardMultiplier,
    double? animationSpeed,
    double? musicVolume,
    bool? voiceEnabled,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      ColorBalloonPopSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationSpeed: animationSpeed ?? this.animationSpeed,
        musicVolume: musicVolume ?? this.musicVolume,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'rewardMultiplier': rewardMultiplier,
        'animationSpeed': animationSpeed,
        'musicVolume': musicVolume,
        'voiceEnabled': voiceEnabled,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory ColorBalloonPopSettings.fromJson(Map<String, dynamic> json) {
    return ColorBalloonPopSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationSpeed:
          (json['animationSpeed'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      musicVolume:
          (json['musicVolume'] as num? ?? 1.0).toDouble().clamp(0.0, 1.0),
      voiceEnabled: json['voiceEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        rewardMultiplier,
        animationSpeed,
        musicVolume,
        voiceEnabled,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class ColorBalloonPopState extends Equatable {
  const ColorBalloonPopState({
    this.sessionPhase = ColorBalloonSessionPhase.ready,
    this.roundPhase = ColorBalloonRoundPhase.instructing,
    this.settings = const ColorBalloonPopSettings(),
    this.balloons = const [],
    this.targetHue = BalloonHue.red,
    this.instructionText = 'Pop the Red Balloon!',
    this.remainingSeconds = 60,
    this.balloonsPopped = 0,
    this.roundsCompleted = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.roundTimer = 0,
    this.colorsMastered = const {},
    this.showMascot = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.playAreaReady = false,
    this.pendingEnd = false,
  });

  final ColorBalloonSessionPhase sessionPhase;
  final ColorBalloonRoundPhase roundPhase;
  final ColorBalloonPopSettings settings;
  final List<BalloonEntity> balloons;
  final BalloonHue targetHue;
  final String instructionText;
  final int remainingSeconds;
  final int balloonsPopped;
  final int roundsCompleted;
  final int currentStreak;
  final int maxStreak;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final double roundTimer;
  final Set<BalloonHue> colorsMastered;
  final bool showMascot;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool playAreaReady;
  final bool pendingEnd;

  ColorBalloonPopState copyWith({
    ColorBalloonSessionPhase? sessionPhase,
    ColorBalloonRoundPhase? roundPhase,
    ColorBalloonPopSettings? settings,
    List<BalloonEntity>? balloons,
    BalloonHue? targetHue,
    String? instructionText,
    int? remainingSeconds,
    int? balloonsPopped,
    int? roundsCompleted,
    int? currentStreak,
    int? maxStreak,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    double? roundTimer,
    Set<BalloonHue>? colorsMastered,
    bool? showMascot,
    String? feedbackMessage,
    String? lastRewardText,
    bool? playAreaReady,
    bool? pendingEnd,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      ColorBalloonPopState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        roundPhase: roundPhase ?? this.roundPhase,
        settings: settings ?? this.settings,
        balloons: balloons ?? this.balloons,
        targetHue: targetHue ?? this.targetHue,
        instructionText: instructionText ?? this.instructionText,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        balloonsPopped: balloonsPopped ?? this.balloonsPopped,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
        currentStreak: currentStreak ?? this.currentStreak,
        maxStreak: maxStreak ?? this.maxStreak,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        roundTimer: roundTimer ?? this.roundTimer,
        colorsMastered: colorsMastered ?? this.colorsMastered,
        showMascot: showMascot ?? this.showMascot,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        roundPhase,
        settings,
        balloons,
        targetHue,
        instructionText,
        remainingSeconds,
        balloonsPopped,
        roundsCompleted,
        currentStreak,
        maxStreak,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        roundTimer,
        colorsMastered,
        showMascot,
        feedbackMessage,
        lastRewardText,
        playAreaReady,
        pendingEnd,
      ];
}

class ColorBalloonPopResult extends Equatable {
  const ColorBalloonPopResult({
    required this.balloonsPopped,
    required this.roundsCompleted,
    required this.maxStreak,
    required this.colorsMastered,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int balloonsPopped;
  final int roundsCompleted;
  final int maxStreak;
  final int colorsMastered;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props => [
        balloonsPopped,
        roundsCompleted,
        maxStreak,
        colorsMastered,
        points,
        coins,
        xp,
        stars,
        sessionSeconds,
      ];
}

const kColorBalloonSkills = [
  'Color Recognition',
  'Visual Attention',
  'Concentration',
  'Decision Making',
  'Hand-Eye Coordination',
];
