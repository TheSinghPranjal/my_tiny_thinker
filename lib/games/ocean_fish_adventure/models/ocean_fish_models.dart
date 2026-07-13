import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FishPhase { entering, waiting, tapped, exiting, gone }

enum FishSwimSpeed { verySlow, slow, normal, fast }

enum OceanFishPhase { ready, playing, paused, celebrating, finished }

/// Visual + behavioral preset for each fish type.
class FishVariant {
  const FishVariant({
    required this.bodyColor,
    required this.finColor,
    required this.pattern,
    required this.emoji,
  });

  final Color bodyColor;
  final Color finColor;
  final String pattern; // solid, stripes, spots, rainbow
  final String emoji;
}

class OceanFishSettings extends Equatable {
  const OceanFishSettings({
    this.maxFishOnScreen = 5,
    this.swimSpeed = FishSwimSpeed.slow,
    this.sessionSeconds = 60,
    this.rewardMultiplier = 1.0,
    this.fishSizeScale = 1.0,
    this.bubbleDensity = 1.0,
    this.effectsIntensity = 1.0,
    this.voiceEnabled = true,
  });

  final int maxFishOnScreen;
  final FishSwimSpeed swimSpeed;
  final int sessionSeconds;
  final double rewardMultiplier;
  final double fishSizeScale;
  final double bubbleDensity;
  final double effectsIntensity;
  final bool voiceEnabled;

  double get speedMultiplier => switch (swimSpeed) {
        FishSwimSpeed.verySlow => 0.5,
        FishSwimSpeed.slow => 0.75,
        FishSwimSpeed.normal => 1.0,
        FishSwimSpeed.fast => 1.35,
      };

  OceanFishSettings copyWith({
    int? maxFishOnScreen,
    FishSwimSpeed? swimSpeed,
    int? sessionSeconds,
    double? rewardMultiplier,
    double? fishSizeScale,
    double? bubbleDensity,
    double? effectsIntensity,
    bool? voiceEnabled,
  }) =>
      OceanFishSettings(
        maxFishOnScreen: maxFishOnScreen ?? this.maxFishOnScreen,
        swimSpeed: swimSpeed ?? this.swimSpeed,
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        fishSizeScale: fishSizeScale ?? this.fishSizeScale,
        bubbleDensity: bubbleDensity ?? this.bubbleDensity,
        effectsIntensity: effectsIntensity ?? this.effectsIntensity,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      );

  Map<String, dynamic> toJson() => {
        'maxFishOnScreen': maxFishOnScreen,
        'swimSpeed': swimSpeed.name,
        'sessionSeconds': sessionSeconds,
        'rewardMultiplier': rewardMultiplier,
        'fishSizeScale': fishSizeScale,
        'bubbleDensity': bubbleDensity,
        'effectsIntensity': effectsIntensity,
        'voiceEnabled': voiceEnabled,
      };

  factory OceanFishSettings.fromJson(Map<String, dynamic> json) {
    return OceanFishSettings(
      maxFishOnScreen: json['maxFishOnScreen'] as int? ?? 5,
      swimSpeed: FishSwimSpeed.values.firstWhere(
        (s) => s.name == json['swimSpeed'],
        orElse: () => FishSwimSpeed.slow,
      ),
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      fishSizeScale: (json['fishSizeScale'] as num? ?? 1.0).toDouble(),
      bubbleDensity: (json['bubbleDensity'] as num? ?? 1.0).toDouble(),
      effectsIntensity: (json['effectsIntensity'] as num? ?? 1.0).toDouble(),
      voiceEnabled: json['voiceEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        maxFishOnScreen,
        swimSpeed,
        sessionSeconds,
        rewardMultiplier,
        fishSizeScale,
        bubbleDensity,
        effectsIntensity,
        voiceEnabled,
      ];
}

class FishEntity extends Equatable {
  const FishEntity({
    required this.id,
    required this.variantIndex,
    required this.x,
    required this.y,
    required this.rotation,
    required this.phase,
    required this.size,
    this.slotIndex = 0,
    this.pathT = 0,
    this.waitAngle = 0,
    this.exitProgress = 0,
    this.startX = 0,
    this.startY = 0,
    this.controlX = 0,
    this.controlY = 0,
    this.targetX = 0,
    this.targetY = 0,
    this.exitX = 0,
    this.exitY = 0,
    this.wiggle = 0,
    this.scale = 1,
  });

  final String id;
  final int variantIndex;
  final int slotIndex;
  final double x;
  final double y;
  final double rotation;
  final FishPhase phase;
  final double size;
  final double pathT;
  final double waitAngle;
  final double exitProgress;
  final double startX;
  final double startY;
  final double controlX;
  final double controlY;
  final double targetX;
  final double targetY;
  final double exitX;
  final double exitY;
  final double wiggle;
  final double scale;

  FishEntity copyWith({
    double? x,
    double? y,
    double? rotation,
    FishPhase? phase,
    double? pathT,
    double? waitAngle,
    double? exitProgress,
    double? wiggle,
    double? scale,
  }) =>
      FishEntity(
        id: id,
        variantIndex: variantIndex,
        slotIndex: slotIndex,
        x: x ?? this.x,
        y: y ?? this.y,
        rotation: rotation ?? this.rotation,
        phase: phase ?? this.phase,
        size: size,
        pathT: pathT ?? this.pathT,
        waitAngle: waitAngle ?? this.waitAngle,
        exitProgress: exitProgress ?? this.exitProgress,
        startX: startX,
        startY: startY,
        controlX: controlX,
        controlY: controlY,
        targetX: targetX,
        targetY: targetY,
        exitX: exitX,
        exitY: exitY,
        wiggle: wiggle ?? this.wiggle,
        scale: scale ?? this.scale,
      );

  @override
  List<Object?> get props =>
      [id, variantIndex, slotIndex, x, y, rotation, phase, pathT, waitAngle, exitProgress, wiggle, scale];
}

class OceanFishState extends Equatable {
  const OceanFishState({
    this.phase = OceanFishPhase.ready,
    this.settings = const OceanFishSettings(),
    this.fish = const [],
    this.remainingSeconds = 60,
    this.fishTapped = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.feedbackMessage,
    this.showMascotCelebrate = false,
    this.lastRewardText,
  });

  final OceanFishPhase phase;
  final OceanFishSettings settings;
  final List<FishEntity> fish;
  final int remainingSeconds;
  final int fishTapped;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final String? feedbackMessage;
  final bool showMascotCelebrate;
  final String? lastRewardText;

  int get activeFishCount =>
      fish.where((f) => f.phase != FishPhase.gone).length;

  OceanFishState copyWith({
    OceanFishPhase? phase,
    OceanFishSettings? settings,
    List<FishEntity>? fish,
    int? remainingSeconds,
    int? fishTapped,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    String? feedbackMessage,
    bool? showMascotCelebrate,
    String? lastRewardText,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      OceanFishState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        fish: fish ?? this.fish,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        fishTapped: fishTapped ?? this.fishTapped,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        showMascotCelebrate: showMascotCelebrate ?? this.showMascotCelebrate,
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        fish,
        remainingSeconds,
        fishTapped,
        coinsEarned,
        xpEarned,
        starsEarned,
        feedbackMessage,
        showMascotCelebrate,
        lastRewardText,
      ];
}

class OceanFishResult extends Equatable {
  const OceanFishResult({
    required this.fishTapped,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int fishTapped;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props => [fishTapped, coins, xp, stars, sessionSeconds];
}

const kFishVariants = [
  FishVariant(bodyColor: Color(0xFF42A5F5), finColor: Color(0xFF1565C0), pattern: 'solid', emoji: '🐟'),
  FishVariant(bodyColor: Color(0xFFFF7043), finColor: Color(0xFFE64A19), pattern: 'stripes', emoji: '🐠'),
  FishVariant(bodyColor: Color(0xFFFFCA28), finColor: Color(0xFFFF8F00), pattern: 'spots', emoji: '🐡'),
  FishVariant(bodyColor: Color(0xFF66BB6A), finColor: Color(0xFF2E7D32), pattern: 'solid', emoji: '🐟'),
  FishVariant(bodyColor: Color(0xFFAB47BC), finColor: Color(0xFF6A1B9A), pattern: 'rainbow', emoji: '🐠'),
  FishVariant(bodyColor: Color(0xFFEC407A), finColor: Color(0xFFC2185B), pattern: 'spots', emoji: '🐡'),
  FishVariant(bodyColor: Color(0xFF26C6DA), finColor: Color(0xFF00838F), pattern: 'stripes', emoji: '🐟'),
  FishVariant(bodyColor: Color(0xFFFF5722), finColor: Color(0xFFBF360C), pattern: 'solid', emoji: '🐠'),
  FishVariant(bodyColor: Color(0xFF7E57C2), finColor: Color(0xFF4527A0), pattern: 'rainbow', emoji: '🐡'),
  FishVariant(bodyColor: Color(0xFF29B6F6), finColor: Color(0xFF0277BD), pattern: 'stripes', emoji: '🐟'),
  FishVariant(bodyColor: Color(0xFFFFB74D), finColor: Color(0xFFF57C00), pattern: 'spots', emoji: '🐠'),
  FishVariant(bodyColor: Color(0xFF4DB6AC), finColor: Color(0xFF00695C), pattern: 'solid', emoji: '🐡'),
];

const kEncouragements = [
  'Great Job!',
  'You Found a Fish!',
  'Amazing!',
  'Wonderful!',
  "Let's Find Another Fish!",
  'Super!',
  'Yay!',
];
