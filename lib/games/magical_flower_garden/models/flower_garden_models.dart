import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GardenSessionPhase { ready, playing, paused, finished }

enum FlowerPhase { bud, blooming, open, cooldown, relocating }

enum PollinatorPhase { entering, collecting, leaving, gone }

enum PollinatorKind { bee, butterfly }

enum BirdPhase { approaching, scared, landing, gone }

enum FlowerMoveSpeed { verySlow, slow, normal }

enum BirdSpeed { verySlow, slow, normal }

class BloomPalette extends Equatable {
  const BloomPalette({
    required this.name,
    required this.petals,
    required this.center,
    required this.glow,
  });

  final String name;
  final List<Color> petals;
  final Color center;
  final Color glow;

  @override
  List<Object?> get props => [name, petals, center, glow];
}

class FlowerGardenSettings extends Equatable {
  const FlowerGardenSettings({
    this.sessionSeconds = 60,
    this.flowerMoveSpeed = FlowerMoveSpeed.slow,
    this.birdSpeed = BirdSpeed.verySlow,
    this.maxMoveDistance = 0.22,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final FlowerMoveSpeed flowerMoveSpeed;
  final BirdSpeed birdSpeed;
  final double maxMoveDistance;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  double get flowerMoveMult => switch (flowerMoveSpeed) {
        FlowerMoveSpeed.verySlow => 0.6,
        FlowerMoveSpeed.slow => 0.85,
        FlowerMoveSpeed.normal => 1.15,
      };

  double get birdSpeedMult => switch (birdSpeed) {
        BirdSpeed.verySlow => 0.55,
        BirdSpeed.slow => 0.8,
        BirdSpeed.normal => 1.05,
      };

  FlowerGardenSettings copyWith({
    int? sessionSeconds,
    FlowerMoveSpeed? flowerMoveSpeed,
    BirdSpeed? birdSpeed,
    double? maxMoveDistance,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      FlowerGardenSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        flowerMoveSpeed: flowerMoveSpeed ?? this.flowerMoveSpeed,
        birdSpeed: birdSpeed ?? this.birdSpeed,
        maxMoveDistance: maxMoveDistance ?? this.maxMoveDistance,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'flowerMoveSpeed': flowerMoveSpeed.name,
        'birdSpeed': birdSpeed.name,
        'maxMoveDistance': maxMoveDistance,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
      };

  factory FlowerGardenSettings.fromJson(Map<String, dynamic> json) {
    return FlowerGardenSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      flowerMoveSpeed: FlowerMoveSpeed.values.firstWhere(
        (s) => s.name == json['flowerMoveSpeed'],
        orElse: () => FlowerMoveSpeed.slow,
      ),
      birdSpeed: BirdSpeed.values.firstWhere(
        (s) => s.name == json['birdSpeed'],
        orElse: () => BirdSpeed.verySlow,
      ),
      maxMoveDistance:
          (json['maxMoveDistance'] as num? ?? 0.22).toDouble().clamp(0.12, 0.35),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        flowerMoveSpeed,
        birdSpeed,
        maxMoveDistance,
        rewardMultiplier,
        animationIntensity,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
      ];
}

class FlowerEntity extends Equatable {
  const FlowerEntity({
    required this.id,
    required this.anchorX,
    required this.anchorY,
    this.x = 0,
    this.y = 0,
    this.targetAnchorX,
    this.targetAnchorY,
    this.phase = FlowerPhase.bud,
    this.bloomProgress = 0,
    this.opacity = 1,
    this.phaseTimer = 0,
    this.swayPhase = 0,
    this.breathePhase = 0,
    this.blinkTimer = 0,
    this.petalCount = 6,
    this.paletteIndex = 0,
    this.petalSpread = 1,
    this.morphPaletteIndex,
    this.colorMorph = 0,
  });

  final String id;
  final double anchorX;
  final double anchorY;
  final double? targetAnchorX;
  final double? targetAnchorY;
  final double x;
  final double y;
  final FlowerPhase phase;
  final double bloomProgress;
  final double opacity;
  final double phaseTimer;
  final double swayPhase;
  final double breathePhase;
  final double blinkTimer;
  final int petalCount;
  final int paletteIndex;
  final double petalSpread;

  /// While non-null, petals slowly blend toward this palette.
  final int? morphPaletteIndex;
  final double colorMorph;

  bool get isVisible => true;

  /// Bud starts a bloom cycle. While blooming/open, retaps only change colour.
  /// After the butterfly leaves the flower unblooms back to a bud.
  bool get canTap =>
      phase == FlowerPhase.bud ||
      phase == FlowerPhase.blooming ||
      phase == FlowerPhase.open;

  FlowerEntity copyWith({
    double? anchorX,
    double? anchorY,
    double? targetAnchorX,
    double? targetAnchorY,
    bool clearTarget = false,
    double? x,
    double? y,
    FlowerPhase? phase,
    double? bloomProgress,
    double? opacity,
    double? phaseTimer,
    double? swayPhase,
    double? breathePhase,
    double? blinkTimer,
    int? petalCount,
    int? paletteIndex,
    double? petalSpread,
    int? morphPaletteIndex,
    bool clearMorph = false,
    double? colorMorph,
  }) =>
      FlowerEntity(
        id: id,
        anchorX: anchorX ?? this.anchorX,
        anchorY: anchorY ?? this.anchorY,
        targetAnchorX:
            clearTarget ? null : (targetAnchorX ?? this.targetAnchorX),
        targetAnchorY:
            clearTarget ? null : (targetAnchorY ?? this.targetAnchorY),
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        bloomProgress: bloomProgress ?? this.bloomProgress,
        opacity: opacity ?? this.opacity,
        phaseTimer: phaseTimer ?? this.phaseTimer,
        swayPhase: swayPhase ?? this.swayPhase,
        breathePhase: breathePhase ?? this.breathePhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        petalCount: petalCount ?? this.petalCount,
        paletteIndex: paletteIndex ?? this.paletteIndex,
        petalSpread: petalSpread ?? this.petalSpread,
        morphPaletteIndex: clearMorph
            ? null
            : (morphPaletteIndex ?? this.morphPaletteIndex),
        colorMorph: clearMorph ? 0 : (colorMorph ?? this.colorMorph),
      );

  @override
  List<Object?> get props => [
        id,
        anchorX,
        anchorY,
        targetAnchorX,
        targetAnchorY,
        x,
        y,
        phase,
        bloomProgress,
        opacity,
        phaseTimer,
        swayPhase,
        breathePhase,
        blinkTimer,
        petalCount,
        paletteIndex,
        petalSpread,
        morphPaletteIndex,
        colorMorph,
      ];
}

class PollinatorEntity extends Equatable {
  const PollinatorEntity({
    required this.id,
    required this.flowerId,
    required this.kind,
    required this.x,
    required this.y,
    required this.phase,
    this.progress = 0,
    this.wingPhase = 0,
    this.rotation = 0,
    this.varietyIndex = 0,
  });

  final String id;
  final String flowerId;
  final PollinatorKind kind;
  final double x;
  final double y;
  final PollinatorPhase phase;
  final double progress;
  final double wingPhase;
  final double rotation;
  final int varietyIndex;

  PollinatorEntity copyWith({
    double? x,
    double? y,
    PollinatorPhase? phase,
    double? progress,
    double? wingPhase,
    double? rotation,
    int? varietyIndex,
  }) =>
      PollinatorEntity(
        id: id,
        flowerId: flowerId,
        kind: kind,
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        wingPhase: wingPhase ?? this.wingPhase,
        rotation: rotation ?? this.rotation,
        varietyIndex: varietyIndex ?? this.varietyIndex,
      );

  @override
  List<Object?> get props => [
        id,
        flowerId,
        kind,
        x,
        y,
        phase,
        progress,
        wingPhase,
        rotation,
        varietyIndex,
      ];
}

class BirdEntity extends Equatable {
  const BirdEntity({
    required this.id,
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    this.phase = BirdPhase.approaching,
    this.wingPhase = 0,
    this.rotation = 0,
    this.scaredTimer = 0,
  });

  final String id;
  final double x;
  final double y;
  final double targetX;
  final double targetY;
  final BirdPhase phase;
  final double wingPhase;
  final double rotation;
  final double scaredTimer;

  bool get isTappable => phase == BirdPhase.approaching;

  BirdEntity copyWith({
    double? x,
    double? y,
    BirdPhase? phase,
    double? wingPhase,
    double? rotation,
    double? scaredTimer,
  }) =>
      BirdEntity(
        id: id,
        x: x ?? this.x,
        y: y ?? this.y,
        targetX: targetX,
        targetY: targetY,
        phase: phase ?? this.phase,
        wingPhase: wingPhase ?? this.wingPhase,
        rotation: rotation ?? this.rotation,
        scaredTimer: scaredTimer ?? this.scaredTimer,
      );

  @override
  List<Object?> get props =>
      [id, x, y, targetX, targetY, phase, wingPhase, rotation, scaredTimer];
}

class FlowerGardenState extends Equatable {
  const FlowerGardenState({
    this.sessionPhase = GardenSessionPhase.ready,
    this.settings = const FlowerGardenSettings(),
    this.flower,
    this.pollinators = const [],
    this.bird,
    this.remainingSeconds = 60,
    this.bloomsCount = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.showRainbow = false,
    this.showSunbeam = false,
    this.showSparkles = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.playAreaReady = false,
    this.endReason,
  });

  final GardenSessionPhase sessionPhase;
  final FlowerGardenSettings settings;
  final FlowerEntity? flower;
  final List<PollinatorEntity> pollinators;
  final BirdEntity? bird;
  final int remainingSeconds;
  final int bloomsCount;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final bool showRainbow;
  final bool showSunbeam;
  final bool showSparkles;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool playAreaReady;
  final String? endReason;

  FlowerGardenState copyWith({
    GardenSessionPhase? sessionPhase,
    FlowerGardenSettings? settings,
    FlowerEntity? flower,
    List<PollinatorEntity>? pollinators,
    BirdEntity? bird,
    bool clearBird = false,
    int? remainingSeconds,
    int? bloomsCount,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    bool? showRainbow,
    bool? showSunbeam,
    bool? showSparkles,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? playAreaReady,
    String? endReason,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      FlowerGardenState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        flower: flower ?? this.flower,
        pollinators: pollinators ?? this.pollinators,
        bird: clearBird ? null : (bird ?? this.bird),
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        bloomsCount: bloomsCount ?? this.bloomsCount,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        showRainbow: showRainbow ?? this.showRainbow,
        showSunbeam: showSunbeam ?? this.showSunbeam,
        showSparkles: showSparkles ?? this.showSparkles,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: showMascot ?? this.showMascot,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        endReason: endReason ?? this.endReason,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        flower,
        pollinators,
        bird,
        remainingSeconds,
        bloomsCount,
        coinsEarned,
        xpEarned,
        starsEarned,
        showRainbow,
        showSunbeam,
        showSparkles,
        feedbackMessage,
        lastRewardText,
        showMascot,
        playAreaReady,
        endReason,
      ];
}

class FlowerGardenResult extends Equatable {
  const FlowerGardenResult({
    required this.bloomsCount,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    this.endReason,
  });

  final int bloomsCount;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;
  final String? endReason;

  @override
  List<Object?> get props =>
      [bloomsCount, coins, xp, stars, sessionSeconds, endReason];
}

const kBloomPalettes = [
  BloomPalette(
    name: 'pink',
    petals: [Color(0xFFFF80AB), Color(0xFFF06292), Color(0xFFEC407A)],
    center: Color(0xFFFFD54F),
    glow: Color(0xFFFF4081),
  ),
  BloomPalette(
    name: 'sunshine',
    petals: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFFB300)],
    center: Color(0xFFFF8F00),
    glow: Color(0xFFFFCA28),
  ),
  BloomPalette(
    name: 'sky',
    petals: [Color(0xFF81D4FA), Color(0xFF4FC3F7), Color(0xFF29B6F6)],
    center: Color(0xFFB3E5FC),
    glow: Color(0xFF0288D1),
  ),
  BloomPalette(
    name: 'lavender',
    petals: [Color(0xFFCE93D8), Color(0xFFBA68C8), Color(0xFFAB47BC)],
    center: Color(0xFFE1BEE7),
    glow: Color(0xFF8E24AA),
  ),
  BloomPalette(
    name: 'rainbow',
    petals: [
      Color(0xFFFF7043),
      Color(0xFFFFCA28),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFAB47BC),
    ],
    center: Color(0xFFFFF59D),
    glow: Color(0xFF7E57C2),
  ),
  BloomPalette(
    name: 'turquoise',
    petals: [Color(0xFF80DEEA), Color(0xFF4DD0E1), Color(0xFF26C6DA)],
    center: Color(0xFFFFF176),
    glow: Color(0xFF00ACC1),
  ),
  BloomPalette(
    name: 'peach',
    petals: [Color(0xFFFFCCBC), Color(0xFFFFAB91), Color(0xFFFF8A65)],
    center: Color(0xFFFFE082),
    glow: Color(0xFFFF7043),
  ),
  BloomPalette(
    name: 'magic',
    petals: [Color(0xFFF8BBD0), Color(0xFFE1BEE7), Color(0xFFB3E5FC)],
    center: Color(0xFFFFF9C4),
    glow: Color(0xFFBA68C8),
  ),
];

const kGardenEncouragements = [
  'Great Job!',
  'Beautiful Bloom!',
  'Amazing!',
  'Wonderful!',
  'So Magical!',
  'Yay!',
  'Pretty Flower!',
  'Tap Again!',
];

const kBirdScareMessages = [
  'Nice Save!',
  'Bye Bye Birdie!',
  'Great Tap!',
];

const kBirdLandMessages = [
  'Let\'s Try Again!',
  'Great Job! Let\'s Grow Another Flower!',
  'What a Fun Garden!',
];

const kGardenSkills = [
  'Exploration',
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Attention',
  'Nature Recognition',
  'Cause & Effect',
];
