import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/shared/peek_a_boo_animals.dart';

enum PeekABooSessionPhase { ready, playing, paused, finished }

enum BushVisualPhase { idle, swaying, shaking, hintShaking, bouncing, opening }

enum AnimalPhase { hidden, popping, visible, exiting, gone }

enum BushShakeFrequency { slow, normal, fast }

enum PeekAnimationSpeed { slow, normal, fast }

enum PeekDifficultyPreset { easy, normal, challenge }

class PeekABooSettings extends Equatable {
  const PeekABooSettings({
    this.sessionSeconds = 60,
    this.bushCount = 2,
    this.hiddenAnimalCount = 1,
    this.shakeFrequency = BushShakeFrequency.normal,
    this.animationSpeed = PeekAnimationSpeed.normal,
    this.difficultyPreset = PeekDifficultyPreset.easy,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.animalSoundsEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerFonts = false,
  });

  final int sessionSeconds;
  final int bushCount;
  final int hiddenAnimalCount;
  final BushShakeFrequency shakeFrequency;
  final PeekAnimationSpeed animationSpeed;
  final PeekDifficultyPreset difficultyPreset;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool animalSoundsEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerFonts;

  int get effectiveHiddenAnimals =>
      hiddenAnimalCount.clamp(1, maxAnimalsForBushCount(bushCount));

  int get effectiveBushCount => bushCount.clamp(2, 10);

  double get shakeIntervalMult => switch (shakeFrequency) {
        BushShakeFrequency.slow => 1.35,
        BushShakeFrequency.normal => 1.0,
        BushShakeFrequency.fast => 0.75,
      };

  double get animSpeedMult => switch (animationSpeed) {
        PeekAnimationSpeed.slow => 0.75,
        PeekAnimationSpeed.normal => 1.0,
        PeekAnimationSpeed.fast => 1.3,
      };

  static int maxAnimalsForBushCount(int count) {
    final c = count.clamp(2, 10);
    if (c <= 2) return 1;
    if (c <= 4) return 2;
    if (c <= 6) return 3;
    if (c <= 8) return 4;
    return 5;
  }

  PeekABooSettings copyWith({
    int? sessionSeconds,
    int? bushCount,
    int? hiddenAnimalCount,
    BushShakeFrequency? shakeFrequency,
    PeekAnimationSpeed? animationSpeed,
    PeekDifficultyPreset? difficultyPreset,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? animalSoundsEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerFonts,
  }) =>
      PeekABooSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        bushCount: bushCount ?? this.bushCount,
        hiddenAnimalCount: hiddenAnimalCount ?? this.hiddenAnimalCount,
        shakeFrequency: shakeFrequency ?? this.shakeFrequency,
        animationSpeed: animationSpeed ?? this.animationSpeed,
        difficultyPreset: difficultyPreset ?? this.difficultyPreset,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        animalSoundsEnabled: animalSoundsEnabled ?? this.animalSoundsEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        highContrast: highContrast ?? this.highContrast,
        largerFonts: largerFonts ?? this.largerFonts,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'bushCount': bushCount,
        'hiddenAnimalCount': hiddenAnimalCount,
        'shakeFrequency': shakeFrequency.name,
        'animationSpeed': animationSpeed.name,
        'difficultyPreset': difficultyPreset.name,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'soundEnabled': soundEnabled,
        'animalSoundsEnabled': animalSoundsEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'highContrast': highContrast,
        'largerFonts': largerFonts,
      };

  factory PeekABooSettings.fromJson(Map<String, dynamic> json) {
    final bushCount = (json['bushCount'] as int? ?? 2).clamp(2, 10);
    final maxAnimals = maxAnimalsForBushCount(bushCount);
    return PeekABooSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      bushCount: bushCount,
      hiddenAnimalCount:
          (json['hiddenAnimalCount'] as int? ?? 1).clamp(1, maxAnimals),
      shakeFrequency: BushShakeFrequency.values.firstWhere(
        (s) => s.name == json['shakeFrequency'],
        orElse: () => BushShakeFrequency.normal,
      ),
      animationSpeed: PeekAnimationSpeed.values.firstWhere(
        (s) => s.name == json['animationSpeed'],
        orElse: () => PeekAnimationSpeed.normal,
      ),
      difficultyPreset: PeekDifficultyPreset.values.firstWhere(
        (s) => s.name == json['difficultyPreset'],
        orElse: () => PeekDifficultyPreset.easy,
      ),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      animalSoundsEnabled: json['animalSoundsEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
      largerFonts: json['largerFonts'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        bushCount,
        hiddenAnimalCount,
        shakeFrequency,
        animationSpeed,
        difficultyPreset,
        rewardMultiplier,
        animationIntensity,
        soundEnabled,
        animalSoundsEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        highContrast,
        largerFonts,
      ];
}

class BushEntity extends Equatable {
  const BushEntity({
    required this.id,
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.colorIndex,
    this.swayPhase = 0,
    this.shakePhase = 0,
    this.shakeTimer = 4,
    this.shakeIntensity = 1,
    this.visualPhase = BushVisualPhase.swaying,
    this.bounceProgress = 0,
    this.openProgress = 0,
    this.hasAnimal = false,
  });

  final String id;
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final int colorIndex;
  final double swayPhase;
  final double shakePhase;
  final double shakeTimer;
  final double shakeIntensity;
  final BushVisualPhase visualPhase;
  final double bounceProgress;
  final double openProgress;
  final bool hasAnimal;

  bool get canTap =>
      visualPhase != BushVisualPhase.opening &&
      bounceProgress <= 0.01;

  BushEntity copyWith({
    double? swayPhase,
    double? shakePhase,
    double? shakeTimer,
    double? shakeIntensity,
    BushVisualPhase? visualPhase,
    double? bounceProgress,
    double? openProgress,
    bool? hasAnimal,
  }) =>
      BushEntity(
        id: id,
        centerX: centerX,
        centerY: centerY,
        width: width,
        height: height,
        colorIndex: colorIndex,
        swayPhase: swayPhase ?? this.swayPhase,
        shakePhase: shakePhase ?? this.shakePhase,
        shakeTimer: shakeTimer ?? this.shakeTimer,
        shakeIntensity: shakeIntensity ?? this.shakeIntensity,
        visualPhase: visualPhase ?? this.visualPhase,
        bounceProgress: bounceProgress ?? this.bounceProgress,
        openProgress: openProgress ?? this.openProgress,
        hasAnimal: hasAnimal ?? this.hasAnimal,
      );

  @override
  List<Object?> get props => [
        id,
        centerX,
        centerY,
        width,
        height,
        colorIndex,
        swayPhase,
        shakePhase,
        shakeTimer,
        shakeIntensity,
        visualPhase,
        bounceProgress,
        openProgress,
        hasAnimal,
      ];
}

class AnimalEntity extends Equatable {
  const AnimalEntity({
    required this.id,
    required this.bushId,
    required this.animalId,
    this.phase = AnimalPhase.hidden,
    this.x = 0,
    this.y = 0,
    this.popProgress = 0,
    this.visibleTimer = 0,
    this.exitProgress = 0,
    this.animPhase = 0,
    this.exitAngle = 0,
    this.wavePhase = 0,
  });

  final String id;
  final String bushId;
  final String animalId;
  final AnimalPhase phase;
  final double x;
  final double y;
  final double popProgress;
  final double visibleTimer;
  final double exitProgress;
  final double animPhase;
  final double exitAngle;
  final double wavePhase;

  PeekAnimalDef? get def => PeekABooAnimals.byId(animalId);

  bool get isInteractive =>
      phase == AnimalPhase.popping || phase == AnimalPhase.visible;

  AnimalEntity copyWith({
    AnimalPhase? phase,
    double? x,
    double? y,
    double? popProgress,
    double? visibleTimer,
    double? exitProgress,
    double? animPhase,
    double? exitAngle,
    double? wavePhase,
    String? bushId,
  }) =>
      AnimalEntity(
        id: id,
        bushId: bushId ?? this.bushId,
        animalId: animalId,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        popProgress: popProgress ?? this.popProgress,
        visibleTimer: visibleTimer ?? this.visibleTimer,
        exitProgress: exitProgress ?? this.exitProgress,
        animPhase: animPhase ?? this.animPhase,
        exitAngle: exitAngle ?? this.exitAngle,
        wavePhase: wavePhase ?? this.wavePhase,
      );

  @override
  List<Object?> get props => [
        id,
        bushId,
        animalId,
        phase,
        x,
        y,
        popProgress,
        visibleTimer,
        exitProgress,
        animPhase,
        exitAngle,
        wavePhase,
      ];
}

class PeekABooState extends Equatable {
  const PeekABooState({
    this.sessionPhase = PeekABooSessionPhase.ready,
    this.settings = const PeekABooSettings(),
    this.bushes = const [],
    this.animals = const [],
    this.remainingSeconds = 60,
    this.discoveriesCount = 0,
    this.bushesExplored = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.lastAnnouncement,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.missedAttempts = 0,
  });

  final PeekABooSessionPhase sessionPhase;
  final PeekABooSettings settings;
  final List<BushEntity> bushes;
  final List<AnimalEntity> animals;
  final int remainingSeconds;
  final int discoveriesCount;
  final int bushesExplored;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final String? feedbackMessage;
  final String? lastRewardText;
  final String? lastAnnouncement;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool pendingEnd;
  final int missedAttempts;

  bool get hasActiveReveal =>
      animals.any((a) => a.phase == AnimalPhase.popping || a.phase == AnimalPhase.visible || a.phase == AnimalPhase.exiting);

  PeekABooState copyWith({
    PeekABooSessionPhase? sessionPhase,
    PeekABooSettings? settings,
    List<BushEntity>? bushes,
    List<AnimalEntity>? animals,
    int? remainingSeconds,
    int? discoveriesCount,
    int? bushesExplored,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    String? feedbackMessage,
    String? lastRewardText,
    String? lastAnnouncement,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? pendingEnd,
    int? missedAttempts,
    bool clearFeedback = false,
  }) =>
      PeekABooState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        bushes: bushes ?? this.bushes,
        animals: animals ?? this.animals,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        discoveriesCount: discoveriesCount ?? this.discoveriesCount,
        bushesExplored: bushesExplored ?? this.bushesExplored,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        lastAnnouncement:
            clearFeedback ? null : (lastAnnouncement ?? this.lastAnnouncement),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        missedAttempts: missedAttempts ?? this.missedAttempts,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        bushes,
        animals,
        remainingSeconds,
        discoveriesCount,
        bushesExplored,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        feedbackMessage,
        lastRewardText,
        lastAnnouncement,
        showMascot,
        showSparkles,
        playAreaReady,
        pendingEnd,
        missedAttempts,
      ];
}

class PeekABooResult extends Equatable {
  const PeekABooResult({
    required this.discoveriesCount,
    required this.bushesExplored,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int discoveriesCount;
  final int bushesExplored;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props =>
      [discoveriesCount, bushesExplored, points, coins, xp, stars, sessionSeconds];
}

const kPeekABooSkills = [
  'Object Permanence',
  'Visual Attention',
  'Recognition',
  'Hand-Eye Coordination',
  'Memory',
  'Cause & Effect',
];

const kPeekEncouragements = [
  'Yay!',
  'Great Find!',
  'Peek-a-Boo!',
  'You Found It!',
  'Amazing!',
];

const kPeekMissMessages = [
  'Almost!',
  'Let\'s Try Another Bush!',
  'Can You Find the Animal?',
  'Look Carefully!',
];

const kBushColors = [
  Color(0xFF66BB6A),
  Color(0xFF81C784),
  Color(0xFF4CAF50),
  Color(0xFF43A047),
  Color(0xFF2E7D32),
  Color(0xFF8BC34A),
  Color(0xFF9CCC65),
  Color(0xFF7CB342),
  Color(0xFF558B2F),
  Color(0xFF689F38),
];

Color bushColorForIndex(int index) => kBushColors[index % kBushColors.length];
