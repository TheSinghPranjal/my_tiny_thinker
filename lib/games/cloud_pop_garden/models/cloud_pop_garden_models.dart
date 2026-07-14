import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CloudPopSessionPhase { ready, playing, paused, finished }

enum CloudPhase { approaching, hovering, raining, leaving, gone }

enum GardenFlowerPhase { closed, blooming, open, closing }

enum CloudMoveSpeed { verySlow, slow, normal, fast }

enum BloomSpeed { slow, normal, fast }

enum CloudTapResult { successRain, earlyThunder, lateBounce, ignored }

class CloudPopGardenSettings extends Equatable {
  const CloudPopGardenSettings({
    this.sessionSeconds = 60,
    this.pairCount = 4,
    this.cloudMoveSpeed = CloudMoveSpeed.slow,
    this.bloomSpeed = BloomSpeed.normal,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.rainsForRainbow = 3,
    this.soundEnabled = true,
    this.rainSoundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.lightningEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final int pairCount;
  final CloudMoveSpeed cloudMoveSpeed;
  final BloomSpeed bloomSpeed;
  final double rewardMultiplier;
  final double animationIntensity;
  final int rainsForRainbow;
  final bool soundEnabled;
  final bool rainSoundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool lightningEnabled;
  final bool reducedMotion;

  double get cloudSpeedMult => switch (cloudMoveSpeed) {
        CloudMoveSpeed.verySlow => 0.55,
        CloudMoveSpeed.slow => 0.8,
        CloudMoveSpeed.normal => 1.0,
        CloudMoveSpeed.fast => 1.35,
      };

  double get bloomSpeedMult => switch (bloomSpeed) {
        BloomSpeed.slow => 0.7,
        BloomSpeed.normal => 1.0,
        BloomSpeed.fast => 1.4,
      };

  CloudPopGardenSettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    CloudMoveSpeed? cloudMoveSpeed,
    BloomSpeed? bloomSpeed,
    double? rewardMultiplier,
    double? animationIntensity,
    int? rainsForRainbow,
    bool? soundEnabled,
    bool? rainSoundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? lightningEnabled,
    bool? reducedMotion,
  }) =>
      CloudPopGardenSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: pairCount ?? this.pairCount,
        cloudMoveSpeed: cloudMoveSpeed ?? this.cloudMoveSpeed,
        bloomSpeed: bloomSpeed ?? this.bloomSpeed,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        rainsForRainbow: rainsForRainbow ?? this.rainsForRainbow,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        rainSoundEnabled: rainSoundEnabled ?? this.rainSoundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        lightningEnabled: lightningEnabled ?? this.lightningEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'pairCount': pairCount,
        'cloudMoveSpeed': cloudMoveSpeed.name,
        'bloomSpeed': bloomSpeed.name,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'rainsForRainbow': rainsForRainbow,
        'soundEnabled': soundEnabled,
        'rainSoundEnabled': rainSoundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'lightningEnabled': lightningEnabled,
        'reducedMotion': reducedMotion,
      };

  factory CloudPopGardenSettings.fromJson(Map<String, dynamic> json) {
    return CloudPopGardenSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      pairCount: (json['pairCount'] as int? ?? 4).clamp(1, 5),
      cloudMoveSpeed: CloudMoveSpeed.values.firstWhere(
        (s) => s.name == json['cloudMoveSpeed'],
        orElse: () => CloudMoveSpeed.slow,
      ),
      bloomSpeed: BloomSpeed.values.firstWhere(
        (s) => s.name == json['bloomSpeed'],
        orElse: () => BloomSpeed.normal,
      ),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      rainsForRainbow: (json['rainsForRainbow'] as int? ?? 3).clamp(2, 8),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      rainSoundEnabled: json['rainSoundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      lightningEnabled: json['lightningEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        pairCount,
        cloudMoveSpeed,
        bloomSpeed,
        rewardMultiplier,
        animationIntensity,
        rainsForRainbow,
        soundEnabled,
        rainSoundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        lightningEnabled,
        reducedMotion,
      ];
}

class GardenFlowerEntity extends Equatable {
  const GardenFlowerEntity({
    required this.id,
    required this.pairId,
    required this.anchorX,
    required this.anchorY,
    this.phase = GardenFlowerPhase.closed,
    this.bloomProgress = 0,
    this.swayPhase = 0,
    this.breathePhase = 0,
    this.blinkTimer = 0,
    this.petalCount = 5,
    this.paletteIndex = 0,
    this.petalSpread = 1,
  });

  final String id;
  final String pairId;
  final double anchorX;
  final double anchorY;
  final GardenFlowerPhase phase;
  final double bloomProgress;
  final double swayPhase;
  final double breathePhase;
  final double blinkTimer;
  final int petalCount;
  final int paletteIndex;
  final double petalSpread;

  GardenFlowerEntity copyWith({
    GardenFlowerPhase? phase,
    double? bloomProgress,
    double? swayPhase,
    double? breathePhase,
    double? blinkTimer,
    int? petalCount,
    int? paletteIndex,
    double? petalSpread,
  }) =>
      GardenFlowerEntity(
        id: id,
        pairId: pairId,
        anchorX: anchorX,
        anchorY: anchorY,
        phase: phase ?? this.phase,
        bloomProgress: bloomProgress ?? this.bloomProgress,
        swayPhase: swayPhase ?? this.swayPhase,
        breathePhase: breathePhase ?? this.breathePhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        petalCount: petalCount ?? this.petalCount,
        paletteIndex: paletteIndex ?? this.paletteIndex,
        petalSpread: petalSpread ?? this.petalSpread,
      );

  @override
  List<Object?> get props => [
        id,
        pairId,
        anchorX,
        anchorY,
        phase,
        bloomProgress,
        swayPhase,
        breathePhase,
        blinkTimer,
        petalCount,
        paletteIndex,
        petalSpread,
      ];
}

class RainDropEntity extends Equatable {
  const RainDropEntity({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });

  final double x;
  final double y;
  final double speed;
  final double size;

  RainDropEntity copyWith({double? x, double? y}) =>
      RainDropEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        speed: speed,
        size: size,
      );

  @override
  List<Object?> get props => [x, y, speed, size];
}

class CloudEntity extends Equatable {
  const CloudEntity({
    required this.id,
    required this.pairId,
    required this.flowerId,
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    this.phase = CloudPhase.approaching,
    this.blueLevel = 1,
    this.phaseTimer = 0,
    this.bobPhase = 0,
    this.rotation = 0,
    this.thunderTimer = 0,
    this.bounceTimer = 0,
    this.showSmile = false,
    this.rainDrops = const [],
    this.spawnDelay = 0,
  });

  final String id;
  final String pairId;
  final String flowerId;
  final double x;
  final double y;
  final double targetX;
  final double targetY;
  final CloudPhase phase;
  final double blueLevel;
  final double phaseTimer;
  final double bobPhase;
  final double rotation;
  final double thunderTimer;
  final double bounceTimer;
  final bool showSmile;
  final List<RainDropEntity> rainDrops;
  final double spawnDelay;

  bool get isTappable =>
      phase != CloudPhase.gone &&
      thunderTimer <= 0 &&
      bounceTimer <= 0;

  CloudEntity copyWith({
    double? x,
    double? y,
    double? targetX,
    double? targetY,
    CloudPhase? phase,
    double? blueLevel,
    double? phaseTimer,
    double? bobPhase,
    double? rotation,
    double? thunderTimer,
    double? bounceTimer,
    bool? showSmile,
    List<RainDropEntity>? rainDrops,
    double? spawnDelay,
  }) =>
      CloudEntity(
        id: id,
        pairId: pairId,
        flowerId: flowerId,
        x: x ?? this.x,
        y: y ?? this.y,
        targetX: targetX ?? this.targetX,
        targetY: targetY ?? this.targetY,
        phase: phase ?? this.phase,
        blueLevel: blueLevel ?? this.blueLevel,
        phaseTimer: phaseTimer ?? this.phaseTimer,
        bobPhase: bobPhase ?? this.bobPhase,
        rotation: rotation ?? this.rotation,
        thunderTimer: thunderTimer ?? this.thunderTimer,
        bounceTimer: bounceTimer ?? this.bounceTimer,
        showSmile: showSmile ?? this.showSmile,
        rainDrops: rainDrops ?? this.rainDrops,
        spawnDelay: spawnDelay ?? this.spawnDelay,
      );

  @override
  List<Object?> get props => [
        id,
        pairId,
        flowerId,
        x,
        y,
        targetX,
        targetY,
        phase,
        blueLevel,
        phaseTimer,
        bobPhase,
        rotation,
        thunderTimer,
        bounceTimer,
        showSmile,
        rainDrops,
        spawnDelay,
      ];
}

class CloudPopReward extends Equatable {
  const CloudPopReward({
    required this.coins,
    required this.xp,
    required this.stars,
  });

  final int coins;
  final int xp;
  final int stars;

  @override
  List<Object?> get props => [coins, xp, stars];
}

class CloudPopGardenState extends Equatable {
  const CloudPopGardenState({
    this.sessionPhase = CloudPopSessionPhase.ready,
    this.settings = const CloudPopGardenSettings(),
    this.flowers = const [],
    this.clouds = const [],
    this.remainingSeconds = 60,
    this.cloudsTapped = 0,
    this.successfulRains = 0,
    this.flowersWatered = 0,
    this.wateringStreak = 0,
    this.maxWateringStreak = 0,
    this.rainbowsCreated = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.rainbowProgress = 0,
    this.showRainbow = false,
    this.showMascot = false,
    this.showSparkles = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.playAreaReady = false,
    this.pendingEnd = false,
  });

  final CloudPopSessionPhase sessionPhase;
  final CloudPopGardenSettings settings;
  final List<GardenFlowerEntity> flowers;
  final List<CloudEntity> clouds;
  final int remainingSeconds;
  final int cloudsTapped;
  final int successfulRains;
  final int flowersWatered;
  final int wateringStreak;
  final int maxWateringStreak;
  final int rainbowsCreated;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final double rainbowProgress;
  final bool showRainbow;
  final bool showMascot;
  final bool showSparkles;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool playAreaReady;
  final bool pendingEnd;

  CloudPopGardenState copyWith({
    CloudPopSessionPhase? sessionPhase,
    CloudPopGardenSettings? settings,
    List<GardenFlowerEntity>? flowers,
    List<CloudEntity>? clouds,
    int? remainingSeconds,
    int? cloudsTapped,
    int? successfulRains,
    int? flowersWatered,
    int? wateringStreak,
    int? maxWateringStreak,
    int? rainbowsCreated,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    double? rainbowProgress,
    bool? showRainbow,
    bool? showMascot,
    bool? showSparkles,
    String? feedbackMessage,
    String? lastRewardText,
    bool? playAreaReady,
    bool? pendingEnd,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      CloudPopGardenState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        flowers: flowers ?? this.flowers,
        clouds: clouds ?? this.clouds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        cloudsTapped: cloudsTapped ?? this.cloudsTapped,
        successfulRains: successfulRains ?? this.successfulRains,
        flowersWatered: flowersWatered ?? this.flowersWatered,
        wateringStreak: wateringStreak ?? this.wateringStreak,
        maxWateringStreak: maxWateringStreak ?? this.maxWateringStreak,
        rainbowsCreated: rainbowsCreated ?? this.rainbowsCreated,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        rainbowProgress: rainbowProgress ?? this.rainbowProgress,
        showRainbow: showRainbow ?? this.showRainbow,
        showMascot: showMascot ?? this.showMascot,
        showSparkles: showSparkles ?? this.showSparkles,
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
        flowers,
        clouds,
        remainingSeconds,
        cloudsTapped,
        successfulRains,
        flowersWatered,
        wateringStreak,
        maxWateringStreak,
        rainbowsCreated,
        coinsEarned,
        xpEarned,
        starsEarned,
        rainbowProgress,
        showRainbow,
        showMascot,
        showSparkles,
        feedbackMessage,
        lastRewardText,
        playAreaReady,
        pendingEnd,
      ];
}

class CloudPopGardenResult extends Equatable {
  const CloudPopGardenResult({
    required this.cloudsTapped,
    required this.successfulRains,
    required this.flowersWatered,
    required this.rainbowsCreated,
    required this.maxWateringStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int cloudsTapped;
  final int successfulRains;
  final int flowersWatered;
  final int rainbowsCreated;
  final int maxWateringStreak;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props => [
        cloudsTapped,
        successfulRains,
        flowersWatered,
        rainbowsCreated,
        maxWateringStreak,
        coins,
        xp,
        stars,
        sessionSeconds,
      ];
}

const kCloudPopEncouragements = [
  'Yay! Rain!',
  'So Pretty!',
  'Great Job!',
  'Happy Flowers!',
  'Wonderful!',
  'So Magical!',
  'Splash Splash!',
];

const kCloudPopSkills = [
  'Cause & Effect',
  'Visual Tracking',
  'Hand-Eye Coordination',
  'Fine Motor Skills',
  'Attention',
  'Observation',
];

const kCloudDarkBlue = Color(0xFF5C6BC0);
const kCloudLightBlue = Color(0xFFB3E5FC);
