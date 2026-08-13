import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum WhackSessionPhase { ready, playing, paused, finished }

enum MolePhase { hidden, peeking, visible, hit, hiding, gone }

enum MoleAppearSpeed { slow, normal, fast }

enum MoleVisibility { easy, medium, hard }

enum MoleAccessory {
  none,
  partyHat,
  crown,
  bow,
  flower,
  glasses,
  scarf,
  bowTie,
  pirateHat,
  heroMask,
  mustache,
}

enum MoleIdleAnim {
  blink,
  lookAround,
  wave,
  smile,
  earWiggle,
  bounce,
  laugh,
  headTilt,
}

enum CheerAnimal { rabbit, bird, squirrel, hedgehog, butterfly, frog }

class WhackAMoleSettings extends Equatable {
  const WhackAMoleSettings({
    this.sessionSeconds = 60,
    this.practiceMode = false,
    this.holeCount = 4,
    this.appearSpeed = MoleAppearSpeed.normal,
    this.visibility = MoleVisibility.easy,
    this.delayMin = 0.7,
    this.delayMax = 1.4,
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
  final int holeCount;
  final MoleAppearSpeed appearSpeed;
  final MoleVisibility visibility;
  final double delayMin;
  final double delayMax;
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

  int get effectiveHoleCount => holeCount.clamp(4, 8);

  double get appearSpeedMult => switch (appearSpeed) {
        MoleAppearSpeed.slow => 0.7,
        MoleAppearSpeed.normal => 1.0,
        MoleAppearSpeed.fast => 1.35,
      };

  double get visibilitySeconds => switch (visibility) {
        MoleVisibility.easy => 2.8,
        MoleVisibility.medium => 2.1,
        MoleVisibility.hard => 1.5,
      };

  WhackAMoleSettings copyWith({
    int? sessionSeconds,
    bool? practiceMode,
    int? holeCount,
    MoleAppearSpeed? appearSpeed,
    MoleVisibility? visibility,
    double? delayMin,
    double? delayMax,
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
      WhackAMoleSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        practiceMode: practiceMode ?? this.practiceMode,
        holeCount: holeCount ?? this.holeCount,
        appearSpeed: appearSpeed ?? this.appearSpeed,
        visibility: visibility ?? this.visibility,
        delayMin: delayMin ?? this.delayMin,
        delayMax: delayMax ?? this.delayMax,
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
        'holeCount': holeCount,
        'appearSpeed': appearSpeed.name,
        'visibility': visibility.name,
        'delayMin': delayMin,
        'delayMax': delayMax,
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

  factory WhackAMoleSettings.fromJson(Map<String, dynamic> json) {
    var delayMin = (json['delayMin'] as num? ?? 0.7).toDouble().clamp(0.3, 4.0);
    var delayMax = (json['delayMax'] as num? ?? 1.4).toDouble().clamp(0.5, 5.0);
    if (delayMin > delayMax) {
      final swap = delayMin;
      delayMin = delayMax;
      delayMax = swap;
    }
    return WhackAMoleSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      practiceMode: json['practiceMode'] as bool? ?? false,
      holeCount: (json['holeCount'] as int? ?? 4).clamp(4, 8),
      appearSpeed: MoleAppearSpeed.values.firstWhere(
        (s) => s.name == json['appearSpeed'],
        orElse: () => MoleAppearSpeed.normal,
      ),
      visibility: MoleVisibility.values.firstWhere(
        (s) => s.name == json['visibility'],
        orElse: () => MoleVisibility.easy,
      ),
      delayMin: delayMin,
      delayMax: delayMax,
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
        holeCount,
        appearSpeed,
        visibility,
        delayMin,
        delayMax,
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

class MoleHoleEntity extends Equatable {
  const MoleHoleEntity({
    required this.id,
    required this.index,
    required this.centerX,
    required this.centerY,
    required this.radius,
    this.swayPhase = 0,
    this.sparklePhase = 0,
    this.decorSeed = 0,
  });

  final String id;
  final int index;
  final double centerX;
  final double centerY;
  final double radius;
  final double swayPhase;
  final double sparklePhase;
  final int decorSeed;

  MoleHoleEntity copyWith({
    double? centerX,
    double? centerY,
    double? radius,
    double? swayPhase,
    double? sparklePhase,
  }) =>
      MoleHoleEntity(
        id: id,
        index: index,
        centerX: centerX ?? this.centerX,
        centerY: centerY ?? this.centerY,
        radius: radius ?? this.radius,
        swayPhase: swayPhase ?? this.swayPhase,
        sparklePhase: sparklePhase ?? this.sparklePhase,
        decorSeed: decorSeed,
      );

  @override
  List<Object?> get props =>
      [id, index, centerX, centerY, radius, swayPhase, sparklePhase, decorSeed];
}

class MoleEntity extends Equatable {
  const MoleEntity({
    required this.id,
    required this.holeId,
    this.phase = MolePhase.hidden,
    this.accessory = MoleAccessory.none,
    this.idleAnim = MoleIdleAnim.blink,
    this.popProgress = 0,
    this.visibleTimer = 0,
    this.hitProgress = 0,
    this.hideProgress = 0,
    this.animPhase = 0,
    this.furTone = 0,
  });

  final String id;
  final String holeId;
  final MolePhase phase;
  final MoleAccessory accessory;
  final MoleIdleAnim idleAnim;
  final double popProgress;
  final double visibleTimer;
  final double hitProgress;
  final double hideProgress;
  final double animPhase;
  final int furTone;

  bool get isTappable =>
      phase == MolePhase.peeking || phase == MolePhase.visible;

  bool get isActive =>
      phase != MolePhase.hidden && phase != MolePhase.gone;

  MoleEntity copyWith({
    MolePhase? phase,
    MoleAccessory? accessory,
    MoleIdleAnim? idleAnim,
    double? popProgress,
    double? visibleTimer,
    double? hitProgress,
    double? hideProgress,
    double? animPhase,
    int? furTone,
  }) =>
      MoleEntity(
        id: id,
        holeId: holeId,
        phase: phase ?? this.phase,
        accessory: accessory ?? this.accessory,
        idleAnim: idleAnim ?? this.idleAnim,
        popProgress: popProgress ?? this.popProgress,
        visibleTimer: visibleTimer ?? this.visibleTimer,
        hitProgress: hitProgress ?? this.hitProgress,
        hideProgress: hideProgress ?? this.hideProgress,
        animPhase: animPhase ?? this.animPhase,
        furTone: furTone ?? this.furTone,
      );

  @override
  List<Object?> get props => [
        id,
        holeId,
        phase,
        accessory,
        idleAnim,
        popProgress,
        visibleTimer,
        hitProgress,
        hideProgress,
        animPhase,
        furTone,
      ];
}

class CheerEntity extends Equatable {
  const CheerEntity({
    required this.id,
    required this.animal,
    required this.side,
    this.progress = 0,
  });

  final String id;
  final CheerAnimal animal;
  final bool side; // false = left, true = right
  final double progress;

  CheerEntity copyWith({double? progress}) => CheerEntity(
        id: id,
        animal: animal,
        side: side,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props => [id, animal, side, progress];
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

class WhackAMoleState extends Equatable {
  const WhackAMoleState({
    this.sessionPhase = WhackSessionPhase.ready,
    this.settings = const WhackAMoleSettings(),
    this.holes = const [],
    this.activeMole,
    this.cheers = const [],
    this.sparkles = const [],
    this.remainingSeconds = 60,
    this.molesTapped = 0,
    this.molesAppeared = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.rewardPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.fastestReactionMs = 0,
    this.progressMeter = 0,
    this.spawnDelay = 0,
    this.lastHoleId,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.moleAppearAtMs = 0,
  });

  final WhackSessionPhase sessionPhase;
  final WhackAMoleSettings settings;
  final List<MoleHoleEntity> holes;
  final MoleEntity? activeMole;
  final List<CheerEntity> cheers;
  final List<TapSparkle> sparkles;
  final int remainingSeconds;
  final int molesTapped;
  final int molesAppeared;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int rewardPoints;
  final int currentStreak;
  final int longestStreak;
  final int fastestReactionMs;
  final double progressMeter;
  final double spawnDelay;
  final String? lastHoleId;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool pendingEnd;
  final int moleAppearAtMs;

  bool get hasActiveMole =>
      activeMole != null && activeMole!.phase != MolePhase.gone;

  double get accuracy =>
      molesAppeared <= 0 ? 1.0 : (molesTapped / molesAppeared).clamp(0.0, 1.0);

  WhackAMoleState copyWith({
    WhackSessionPhase? sessionPhase,
    WhackAMoleSettings? settings,
    List<MoleHoleEntity>? holes,
    MoleEntity? activeMole,
    List<CheerEntity>? cheers,
    List<TapSparkle>? sparkles,
    int? remainingSeconds,
    int? molesTapped,
    int? molesAppeared,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? rewardPoints,
    int? currentStreak,
    int? longestStreak,
    int? fastestReactionMs,
    double? progressMeter,
    double? spawnDelay,
    String? lastHoleId,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? pendingEnd,
    int? moleAppearAtMs,
    bool clearMole = false,
    bool clearFeedback = false,
  }) =>
      WhackAMoleState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        holes: holes ?? this.holes,
        activeMole: clearMole ? null : (activeMole ?? this.activeMole),
        cheers: cheers ?? this.cheers,
        sparkles: sparkles ?? this.sparkles,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        molesTapped: molesTapped ?? this.molesTapped,
        molesAppeared: molesAppeared ?? this.molesAppeared,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        fastestReactionMs: fastestReactionMs ?? this.fastestReactionMs,
        progressMeter: progressMeter ?? this.progressMeter,
        spawnDelay: spawnDelay ?? this.spawnDelay,
        lastHoleId: lastHoleId ?? this.lastHoleId,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        moleAppearAtMs: moleAppearAtMs ?? this.moleAppearAtMs,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        holes,
        activeMole,
        cheers,
        sparkles,
        remainingSeconds,
        molesTapped,
        molesAppeared,
        coinsEarned,
        xpEarned,
        starsEarned,
        rewardPoints,
        currentStreak,
        longestStreak,
        fastestReactionMs,
        progressMeter,
        spawnDelay,
        lastHoleId,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
        pendingEnd,
        moleAppearAtMs,
      ];
}

class WhackAMoleResult extends Equatable {
  const WhackAMoleResult({
    required this.molesTapped,
    required this.coins,
    required this.stars,
    required this.xp,
    required this.rewardPoints,
    required this.longestStreak,
    required this.fastestReactionMs,
    required this.accuracy,
    required this.sessionSeconds,
    required this.encouragement,
  });

  final int molesTapped;
  final int coins;
  final int stars;
  final int xp;
  final int rewardPoints;
  final int longestStreak;
  final int fastestReactionMs;
  final double accuracy;
  final int sessionSeconds;
  final String encouragement;

  @override
  List<Object?> get props => [
        molesTapped,
        coins,
        stars,
        xp,
        rewardPoints,
        longestStreak,
        fastestReactionMs,
        accuracy,
        sessionSeconds,
        encouragement,
      ];
}

const kWhackAMoleSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Reaction Speed',
  'Focus',
  'Attention Span',
  'Finger Control',
];

const kWhackEncouragements = [
  'Great Job!',
  'Fantastic!',
  'Nice Tap!',
  'Excellent!',
  'Amazing!',
  'Awesome!',
  'Super Fast!',
  'You Got It!',
  'Wonderful!',
  'Brilliant!',
  'Keep Going!',
  "You're Amazing!",
];

const kWhackEndMessages = [
  'Fantastic Reflexes!',
  "You're a Mole Master!",
  'Amazing Tapping!',
  'Super Fast!',
  "You're Getting Better Every Time!",
  'Incredible Focus!',
  'Great Playing!',
  'Keep Learning!',
  "You're Awesome!",
  "Let's Play Again!",
];

const kFurTones = [
  Color(0xFF8D6E63),
  Color(0xFFA1887F),
  Color(0xFF6D4C41),
  Color(0xFFBCAAA4),
  Color(0xFF795548),
];
