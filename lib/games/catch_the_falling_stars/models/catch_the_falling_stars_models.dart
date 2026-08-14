import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum StarSessionPhase { ready, playing, paused, finished }

enum StarLifePhase {
  appearing,
  stationary,
  falling,
  collected,
  driftedOff,
  gone,
}

enum StarFallSpeed { slow, normal, fast }

enum StarVariant {
  golden,
  rainbow,
  blueCrystal,
  pinkGlitter,
  purpleMagic,
  greenEmerald,
  orangeSunset,
  silverMoon,
  diamond,
  goldenCrown,
}

enum StarAccessory {
  none,
  crown,
  partyHat,
  bow,
  glasses,
  scarf,
  halo,
  sleepingCap,
  butterflyWings,
  ribbon,
}

enum StarIdleAnim {
  twinkle,
  bounce,
  rotate,
  blink,
  smile,
  wave,
  jump,
  glowPulse,
  shimmer,
  sparkle,
}

enum ConstellationShape {
  teddy,
  rabbit,
  elephant,
  panda,
  unicorn,
  rocket,
  rainbow,
  castle,
  heart,
  butterfly,
  smilingMoon,
}

class CatchTheFallingStarsSettings extends Equatable {
  const CatchTheFallingStarsSettings({
    this.sessionSeconds = 60,
    this.practiceMode = false,
    this.starCount = 5,
    this.fallSpeed = StarFallSpeed.slow,
    this.stationarySeconds = 4.0,
    this.replacementDelaySeconds = 1.0,
    this.twinkleIntensity = 0.7,
    this.constellationEnabled = true,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.narrationEnabled = true,
    this.celebrationsEnabled = true,
    this.coinRewardsEnabled = true,
    this.hapticsEnabled = true,
    this.leftHandedLayout = false,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final bool practiceMode;
  final int starCount;
  final StarFallSpeed fallSpeed;
  final double stationarySeconds;
  final double replacementDelaySeconds;
  final double twinkleIntensity;
  final bool constellationEnabled;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool narrationEnabled;
  final bool celebrationsEnabled;
  final bool coinRewardsEnabled;
  final bool hapticsEnabled;
  final bool leftHandedLayout;
  final bool reducedMotion;
  final bool largerTouchTargets;

  int get effectiveStarCount => starCount.clamp(3, 8);

  double get fallSpeedPxPerSec => switch (fallSpeed) {
        StarFallSpeed.slow => 38,
        StarFallSpeed.normal => 58,
        StarFallSpeed.fast => 82,
      };

  CatchTheFallingStarsSettings copyWith({
    int? sessionSeconds,
    bool? practiceMode,
    int? starCount,
    StarFallSpeed? fallSpeed,
    double? stationarySeconds,
    double? replacementDelaySeconds,
    double? twinkleIntensity,
    bool? constellationEnabled,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? narrationEnabled,
    bool? celebrationsEnabled,
    bool? coinRewardsEnabled,
    bool? hapticsEnabled,
    bool? leftHandedLayout,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      CatchTheFallingStarsSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        practiceMode: practiceMode ?? this.practiceMode,
        starCount: starCount ?? this.starCount,
        fallSpeed: fallSpeed ?? this.fallSpeed,
        stationarySeconds: stationarySeconds ?? this.stationarySeconds,
        replacementDelaySeconds:
            replacementDelaySeconds ?? this.replacementDelaySeconds,
        twinkleIntensity: twinkleIntensity ?? this.twinkleIntensity,
        constellationEnabled:
            constellationEnabled ?? this.constellationEnabled,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        celebrationsEnabled: celebrationsEnabled ?? this.celebrationsEnabled,
        coinRewardsEnabled: coinRewardsEnabled ?? this.coinRewardsEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        leftHandedLayout: leftHandedLayout ?? this.leftHandedLayout,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'practiceMode': practiceMode,
        'starCount': starCount,
        'fallSpeed': fallSpeed.name,
        'stationarySeconds': stationarySeconds,
        'replacementDelaySeconds': replacementDelaySeconds,
        'twinkleIntensity': twinkleIntensity,
        'constellationEnabled': constellationEnabled,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'narrationEnabled': narrationEnabled,
        'celebrationsEnabled': celebrationsEnabled,
        'coinRewardsEnabled': coinRewardsEnabled,
        'hapticsEnabled': hapticsEnabled,
        'leftHandedLayout': leftHandedLayout,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory CatchTheFallingStarsSettings.fromJson(Map<String, dynamic> json) {
    return CatchTheFallingStarsSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      practiceMode: json['practiceMode'] as bool? ?? false,
      starCount: (json['starCount'] as int? ?? 5).clamp(3, 8),
      fallSpeed: StarFallSpeed.values.firstWhere(
        (s) => s.name == json['fallSpeed'],
        orElse: () => StarFallSpeed.slow,
      ),
      stationarySeconds:
          (json['stationarySeconds'] as num? ?? 4.0).toDouble().clamp(2.0, 6.0),
      replacementDelaySeconds:
          (json['replacementDelaySeconds'] as num? ?? 1.0)
              .toDouble()
              .clamp(0.3, 3.0),
      twinkleIntensity:
          (json['twinkleIntensity'] as num? ?? 0.7).toDouble().clamp(0.2, 1.0),
      constellationEnabled: json['constellationEnabled'] as bool? ?? true,
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      celebrationsEnabled: json['celebrationsEnabled'] as bool? ?? true,
      coinRewardsEnabled: json['coinRewardsEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      leftHandedLayout: json['leftHandedLayout'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        practiceMode,
        starCount,
        fallSpeed,
        stationarySeconds,
        replacementDelaySeconds,
        twinkleIntensity,
        constellationEnabled,
        rewardMultiplier,
        soundEnabled,
        musicEnabled,
        narrationEnabled,
        celebrationsEnabled,
        coinRewardsEnabled,
        hapticsEnabled,
        leftHandedLayout,
        reducedMotion,
        largerTouchTargets,
      ];
}

class FallingStarEntity extends Equatable {
  const FallingStarEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    this.phase = StarLifePhase.appearing,
    this.variant = StarVariant.golden,
    this.accessory = StarAccessory.none,
    this.idleAnim = StarIdleAnim.twinkle,
    this.appearProgress = 0,
    this.stationaryTimer = 0,
    this.collectProgress = 0,
    this.driftProgress = 0,
    this.animPhase = 0,
    this.swayPhase = 0,
    this.glowPulse = 0,
  });

  final String id;
  final double x;
  final double y;
  final double radius;
  final StarLifePhase phase;
  final StarVariant variant;
  final StarAccessory accessory;
  final StarIdleAnim idleAnim;
  final double appearProgress;
  final double stationaryTimer;
  final double collectProgress;
  final double driftProgress;
  final double animPhase;
  final double swayPhase;
  final double glowPulse;

  bool get isTappable =>
      phase == StarLifePhase.appearing ||
      phase == StarLifePhase.stationary ||
      phase == StarLifePhase.falling;

  bool get isVisible =>
      phase != StarLifePhase.gone && phase != StarLifePhase.driftedOff;

  FallingStarEntity copyWith({
    double? x,
    double? y,
    double? radius,
    StarLifePhase? phase,
    StarVariant? variant,
    StarAccessory? accessory,
    StarIdleAnim? idleAnim,
    double? appearProgress,
    double? stationaryTimer,
    double? collectProgress,
    double? driftProgress,
    double? animPhase,
    double? swayPhase,
    double? glowPulse,
  }) =>
      FallingStarEntity(
        id: id,
        x: x ?? this.x,
        y: y ?? this.y,
        radius: radius ?? this.radius,
        phase: phase ?? this.phase,
        variant: variant ?? this.variant,
        accessory: accessory ?? this.accessory,
        idleAnim: idleAnim ?? this.idleAnim,
        appearProgress: appearProgress ?? this.appearProgress,
        stationaryTimer: stationaryTimer ?? this.stationaryTimer,
        collectProgress: collectProgress ?? this.collectProgress,
        driftProgress: driftProgress ?? this.driftProgress,
        animPhase: animPhase ?? this.animPhase,
        swayPhase: swayPhase ?? this.swayPhase,
        glowPulse: glowPulse ?? this.glowPulse,
      );

  @override
  List<Object?> get props => [
        id,
        x,
        y,
        radius,
        phase,
        variant,
        accessory,
        idleAnim,
        appearProgress,
        stationaryTimer,
        collectProgress,
        driftProgress,
        animPhase,
        swayPhase,
        glowPulse,
      ];
}

class PendingStarSpawn extends Equatable {
  const PendingStarSpawn({required this.delay});

  final double delay;

  PendingStarSpawn copyWith({double? delay}) =>
      PendingStarSpawn(delay: delay ?? this.delay);

  @override
  List<Object?> get props => [delay];
}

class TapSparkle extends Equatable {
  const TapSparkle({
    required this.id,
    required this.x,
    required this.y,
    this.progress = 0,
  });

  final String id;
  final double x;
  final double y;
  final double progress;

  TapSparkle copyWith({double? progress}) => TapSparkle(
        id: id,
        x: x,
        y: y,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props => [id, x, y, progress];
}

class CatchTheFallingStarsState extends Equatable {
  const CatchTheFallingStarsState({
    this.sessionPhase = StarSessionPhase.ready,
    this.settings = const CatchTheFallingStarsSettings(),
    this.stars = const [],
    this.pendingSpawns = const [],
    this.sparkles = const [],
    this.remainingSeconds = 60,
    this.starsCollected = 0,
    this.starsAppeared = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.rewardPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.progressMeter = 0,
    this.constellationPieces = 0,
    this.activeConstellation = ConstellationShape.teddy,
    this.longestConstellation = 0,
    this.moonCheer = 0,
    this.envPhase = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
  });

  final StarSessionPhase sessionPhase;
  final CatchTheFallingStarsSettings settings;
  final List<FallingStarEntity> stars;
  final List<PendingStarSpawn> pendingSpawns;
  final List<TapSparkle> sparkles;
  final int remainingSeconds;
  final int starsCollected;
  final int starsAppeared;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int rewardPoints;
  final int currentStreak;
  final int longestStreak;
  final double progressMeter;
  final int constellationPieces;
  final ConstellationShape activeConstellation;
  final int longestConstellation;
  final double moonCheer;
  final double envPhase;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;

  int get visibleStarCount =>
      stars.where((s) => s.isTappable || s.phase == StarLifePhase.collected).length;

  CatchTheFallingStarsState copyWith({
    StarSessionPhase? sessionPhase,
    CatchTheFallingStarsSettings? settings,
    List<FallingStarEntity>? stars,
    List<PendingStarSpawn>? pendingSpawns,
    List<TapSparkle>? sparkles,
    int? remainingSeconds,
    int? starsCollected,
    int? starsAppeared,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? rewardPoints,
    int? currentStreak,
    int? longestStreak,
    double? progressMeter,
    int? constellationPieces,
    ConstellationShape? activeConstellation,
    int? longestConstellation,
    double? moonCheer,
    double? envPhase,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool clearFeedback = false,
  }) =>
      CatchTheFallingStarsState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        stars: stars ?? this.stars,
        pendingSpawns: pendingSpawns ?? this.pendingSpawns,
        sparkles: sparkles ?? this.sparkles,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        starsCollected: starsCollected ?? this.starsCollected,
        starsAppeared: starsAppeared ?? this.starsAppeared,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        progressMeter: progressMeter ?? this.progressMeter,
        constellationPieces: constellationPieces ?? this.constellationPieces,
        activeConstellation: activeConstellation ?? this.activeConstellation,
        longestConstellation: longestConstellation ?? this.longestConstellation,
        moonCheer: moonCheer ?? this.moonCheer,
        envPhase: envPhase ?? this.envPhase,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        stars,
        pendingSpawns,
        sparkles,
        remainingSeconds,
        starsCollected,
        starsAppeared,
        coinsEarned,
        xpEarned,
        starsEarned,
        rewardPoints,
        currentStreak,
        longestStreak,
        progressMeter,
        constellationPieces,
        activeConstellation,
        longestConstellation,
        moonCheer,
        envPhase,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
      ];
}

class CatchTheFallingStarsResult extends Equatable {
  const CatchTheFallingStarsResult({
    required this.starsCollected,
    required this.coins,
    required this.stars,
    required this.xp,
    required this.rewardPoints,
    required this.longestStreak,
    required this.longestConstellation,
    required this.constellationPieces,
    required this.sessionSeconds,
    required this.encouragement,
  });

  final int starsCollected;
  final int coins;
  final int stars;
  final int xp;
  final int rewardPoints;
  final int longestStreak;
  final int longestConstellation;
  final int constellationPieces;
  final int sessionSeconds;
  final String encouragement;

  @override
  List<Object?> get props => [
        starsCollected,
        coins,
        stars,
        xp,
        rewardPoints,
        longestStreak,
        longestConstellation,
        constellationPieces,
        sessionSeconds,
        encouragement,
      ];
}

const kCatchStarsSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Reaction Time',
  'Attention Span',
  'Finger Control',
  'Focus',
  'Visual Perception',
];

const kCatchStarsEncouragements = [
  'Great Job!',
  'Wonderful!',
  'Fantastic!',
  'Amazing!',
  'Excellent!',
  'You Caught It!',
  'Brilliant!',
  'Super Star!',
  'Keep Shining!',
  "You're Amazing!",
  'Beautiful Catch!',
  'Nice Tap!',
  'Awesome!',
  "You're a Star Collector!",
];

const kCatchStarsEndMessages = [
  "You're a Super Star!",
  'Fantastic Star Catcher!',
  'The Moon Is Proud of You!',
  'Amazing Twinkle Hunter!',
  'Wonderful Collecting!',
  'You Made the Sky Shine!',
  'Keep Reaching for the Stars!',
  "You're Getting Better Every Time!",
  'Magical Job!',
  "Let's Catch More Stars!",
];

const kConstellationEmojis = {
  ConstellationShape.teddy: '🧸',
  ConstellationShape.rabbit: '🐰',
  ConstellationShape.elephant: '🐘',
  ConstellationShape.panda: '🐼',
  ConstellationShape.unicorn: '🦄',
  ConstellationShape.rocket: '🚀',
  ConstellationShape.rainbow: '🌈',
  ConstellationShape.castle: '🏰',
  ConstellationShape.heart: '💖',
  ConstellationShape.butterfly: '🦋',
  ConstellationShape.smilingMoon: '🌙',
};

const kStarVariantColors = {
  StarVariant.golden: Color(0xFFFFD54F),
  StarVariant.rainbow: Color(0xFFFF80AB),
  StarVariant.blueCrystal: Color(0xFF4FC3F7),
  StarVariant.pinkGlitter: Color(0xFFF48FB1),
  StarVariant.purpleMagic: Color(0xFFCE93D8),
  StarVariant.greenEmerald: Color(0xFF81C784),
  StarVariant.orangeSunset: Color(0xFFFFB74D),
  StarVariant.silverMoon: Color(0xFFE0E0E0),
  StarVariant.diamond: Color(0xFFB3E5FC),
  StarVariant.goldenCrown: Color(0xFFFFC107),
};
