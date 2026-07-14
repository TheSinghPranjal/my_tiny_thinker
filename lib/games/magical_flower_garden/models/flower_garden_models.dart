import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum GardenSessionPhase { ready, playing, paused, finished }

enum FlowerPhase { bud, blooming, open, cooldown }

enum PollinatorPhase { entering, collecting, leaving, gone }

enum FlowerMoveSpeed { verySlow, slow, normal }

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
    this.maxFlowersOnScreen = 4,
    this.flowerMoveSpeed = FlowerMoveSpeed.slow,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final int maxFlowersOnScreen;
  final FlowerMoveSpeed flowerMoveSpeed;
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

  FlowerGardenSettings copyWith({
    int? sessionSeconds,
    int? maxFlowersOnScreen,
    FlowerMoveSpeed? flowerMoveSpeed,
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
        maxFlowersOnScreen: maxFlowersOnScreen ?? this.maxFlowersOnScreen,
        flowerMoveSpeed: flowerMoveSpeed ?? this.flowerMoveSpeed,
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
        'maxFlowersOnScreen': maxFlowersOnScreen,
        'flowerMoveSpeed': flowerMoveSpeed.name,
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
      maxFlowersOnScreen:
          (json['maxFlowersOnScreen'] as int? ?? 4).clamp(4, 5),
      flowerMoveSpeed: FlowerMoveSpeed.values.firstWhere(
        (s) => s.name == json['flowerMoveSpeed'],
        orElse: () => FlowerMoveSpeed.slow,
      ),
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
        maxFlowersOnScreen,
        flowerMoveSpeed,
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
  });

  final String id;
  final double anchorX;
  final double anchorY;
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

  bool get isVisible => true;

  bool get canTap => phase == FlowerPhase.bud;

  FlowerEntity copyWith({
    double? anchorX,
    double? anchorY,
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
  }) =>
      FlowerEntity(
        id: id,
        anchorX: anchorX ?? this.anchorX,
        anchorY: anchorY ?? this.anchorY,
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
      );

  @override
  List<Object?> get props => [
        id,
        anchorX,
        anchorY,
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
      ];
}

class BeeEntity extends Equatable {
  const BeeEntity({
    required this.id,
    required this.flowerId,
    required this.x,
    required this.y,
    required this.phase,
    this.progress = 0,
    this.wingPhase = 0,
    this.rotation = 0,
  });

  final String id;
  final String flowerId;
  final double x;
  final double y;
  final PollinatorPhase phase;
  final double progress;
  final double wingPhase;
  final double rotation;

  BeeEntity copyWith({
    double? x,
    double? y,
    PollinatorPhase? phase,
    double? progress,
    double? wingPhase,
    double? rotation,
  }) =>
      BeeEntity(
        id: id,
        flowerId: flowerId,
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        wingPhase: wingPhase ?? this.wingPhase,
        rotation: rotation ?? this.rotation,
      );

  @override
  List<Object?> get props =>
      [id, flowerId, x, y, phase, progress, wingPhase, rotation];
}

class FlowerGardenState extends Equatable {
  const FlowerGardenState({
    this.sessionPhase = GardenSessionPhase.ready,
    this.settings = const FlowerGardenSettings(),
    this.flowers = const [],
    this.bees = const [],
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
  });

  final GardenSessionPhase sessionPhase;
  final FlowerGardenSettings settings;
  final List<FlowerEntity> flowers;
  final List<BeeEntity> bees;
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

  FlowerGardenState copyWith({
    GardenSessionPhase? sessionPhase,
    FlowerGardenSettings? settings,
    List<FlowerEntity>? flowers,
    List<BeeEntity>? bees,
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
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      FlowerGardenState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        flowers: flowers ?? this.flowers,
        bees: bees ?? this.bees,
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
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        flowers,
        bees,
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
      ];
}

class FlowerGardenResult extends Equatable {
  const FlowerGardenResult({
    required this.bloomsCount,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int bloomsCount;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props => [bloomsCount, coins, xp, stars, sessionSeconds];
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
  'Nature is Happy!',
];

const kGardenSkills = [
  'Exploration',
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Attention',
  'Nature Recognition',
  'Cause & Effect',
];
