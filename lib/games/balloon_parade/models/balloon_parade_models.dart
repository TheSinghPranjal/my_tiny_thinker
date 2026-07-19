import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

enum BalloonParadeSessionPhase { ready, playing, paused, finished }

class BalloonParadeSettings extends Equatable {
  const BalloonParadeSettings({
    this.sessionSeconds = 60,
    this.spawnIntervalSeconds = 1,
    this.balloonsPerSpawn = 1,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.narrationEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final int spawnIntervalSeconds;
  final int balloonsPerSpawn;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool narrationEnabled;
  final bool reducedMotion;

  BalloonParadeSettings copyWith({
    int? sessionSeconds,
    int? spawnIntervalSeconds,
    int? balloonsPerSpawn,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? narrationEnabled,
    bool? reducedMotion,
  }) =>
      BalloonParadeSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        spawnIntervalSeconds:
            spawnIntervalSeconds ?? this.spawnIntervalSeconds,
        balloonsPerSpawn: balloonsPerSpawn ?? this.balloonsPerSpawn,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'spawnIntervalSeconds': spawnIntervalSeconds,
        'balloonsPerSpawn': balloonsPerSpawn,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'narrationEnabled': narrationEnabled,
        'reducedMotion': reducedMotion,
      };

  factory BalloonParadeSettings.fromJson(Map<String, dynamic> json) {
    return BalloonParadeSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      spawnIntervalSeconds:
          (json['spawnIntervalSeconds'] as int? ?? 1).clamp(1, 5),
      balloonsPerSpawn: (json['balloonsPerSpawn'] as int? ?? 1).clamp(1, 5),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        spawnIntervalSeconds,
        balloonsPerSpawn,
        rewardMultiplier,
        animationIntensity,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        narrationEnabled,
        reducedMotion,
      ];
}

class BalloonParadeState extends Equatable {
  const BalloonParadeState({
    this.sessionPhase = BalloonParadeSessionPhase.ready,
    this.settings = const BalloonParadeSettings(),
    this.balloons = const [],
    this.remainingSeconds = 60,
    this.balloonsPopped = 0,
    this.balloonsGenerated = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.spawnCooldown = 0,
    this.inactivitySeconds = 0,
    this.showMascot = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.playAreaReady = false,
    this.pendingEnd = false,
  });

  final BalloonParadeSessionPhase sessionPhase;
  final BalloonParadeSettings settings;
  final List<BalloonEntity> balloons;
  final int remainingSeconds;
  final int balloonsPopped;
  final int balloonsGenerated;
  final int currentStreak;
  final int maxStreak;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final double spawnCooldown;
  final double inactivitySeconds;
  final bool showMascot;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool playAreaReady;
  final bool pendingEnd;

  BalloonParadeState copyWith({
    BalloonParadeSessionPhase? sessionPhase,
    BalloonParadeSettings? settings,
    List<BalloonEntity>? balloons,
    int? remainingSeconds,
    int? balloonsPopped,
    int? balloonsGenerated,
    int? currentStreak,
    int? maxStreak,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    double? spawnCooldown,
    double? inactivitySeconds,
    bool? showMascot,
    String? feedbackMessage,
    String? lastRewardText,
    bool? playAreaReady,
    bool? pendingEnd,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      BalloonParadeState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        balloons: balloons ?? this.balloons,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        balloonsPopped: balloonsPopped ?? this.balloonsPopped,
        balloonsGenerated: balloonsGenerated ?? this.balloonsGenerated,
        currentStreak: currentStreak ?? this.currentStreak,
        maxStreak: maxStreak ?? this.maxStreak,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        spawnCooldown: spawnCooldown ?? this.spawnCooldown,
        inactivitySeconds: inactivitySeconds ?? this.inactivitySeconds,
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
        settings,
        balloons,
        remainingSeconds,
        balloonsPopped,
        balloonsGenerated,
        currentStreak,
        maxStreak,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        spawnCooldown,
        inactivitySeconds,
        showMascot,
        feedbackMessage,
        lastRewardText,
        playAreaReady,
        pendingEnd,
      ];
}

class BalloonParadeResult extends Equatable {
  const BalloonParadeResult({
    required this.balloonsPopped,
    required this.balloonsGenerated,
    required this.maxStreak,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int balloonsPopped;
  final int balloonsGenerated;
  final int maxStreak;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props => [
        balloonsPopped,
        balloonsGenerated,
        maxStreak,
        points,
        coins,
        xp,
        stars,
        sessionSeconds,
      ];
}

const kBalloonParadeSkills = [
  'Visual Tracking',
  'Hand-Eye Coordination',
  'Finger Accuracy',
  'Attention',
  'Cause & Effect',
];
