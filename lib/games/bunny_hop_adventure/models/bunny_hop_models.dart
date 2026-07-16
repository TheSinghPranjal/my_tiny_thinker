import 'package:equatable/equatable.dart';

enum BunnyHopSessionPhase { ready, playing, paused, finished }

enum TravelDirection { towardB, towardA }

enum CarrotSide { sideA, sideB }

enum BunnyPhase { idle, hopping, landed, celebrating, falling, swimming, recovering }

enum LilyPadPhase { floating, sinking, sunk }

enum BunnyHopSpeed { verySlow, slow, normal, fast }

enum BunnyHopDifficulty { easy, normal, playful }

class BunnyHopSettings extends Equatable {
  const BunnyHopSettings({
    this.sessionSeconds = 60,
    this.lilyPadCount = 7,
    this.hopSpeed = BunnyHopSpeed.normal,
    this.crackedSinkDelay = 5.0,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = BunnyHopDifficulty.easy,
  });

  final int sessionSeconds;
  final int lilyPadCount;
  final BunnyHopSpeed hopSpeed;
  final double crackedSinkDelay;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final BunnyHopDifficulty difficulty;

  int get effectiveLilyPadCount => lilyPadCount.clamp(5, 18);

  double get hopSpeedMult => switch (hopSpeed) {
        BunnyHopSpeed.verySlow => 0.65,
        BunnyHopSpeed.slow => 0.85,
        BunnyHopSpeed.normal => 1.0,
        BunnyHopSpeed.fast => 1.25,
      };

  BunnyHopSettings copyWith({
    int? sessionSeconds,
    int? lilyPadCount,
    BunnyHopSpeed? hopSpeed,
    double? crackedSinkDelay,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    BunnyHopDifficulty? difficulty,
  }) =>
      BunnyHopSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        lilyPadCount: lilyPadCount ?? this.lilyPadCount,
        hopSpeed: hopSpeed ?? this.hopSpeed,
        crackedSinkDelay: crackedSinkDelay ?? this.crackedSinkDelay,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        highContrast: highContrast ?? this.highContrast,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
        difficulty: difficulty ?? this.difficulty,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'lilyPadCount': lilyPadCount,
        'hopSpeed': hopSpeed.name,
        'crackedSinkDelay': crackedSinkDelay,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'highContrast': highContrast,
        'largerTouchTargets': largerTouchTargets,
        'difficulty': difficulty.name,
      };

  factory BunnyHopSettings.fromJson(Map<String, dynamic> json) {
    return BunnyHopSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      lilyPadCount: (json['lilyPadCount'] as int? ?? 7).clamp(5, 18),
      hopSpeed: BunnyHopSpeed.values.firstWhere(
        (s) => s.name == json['hopSpeed'],
        orElse: () => BunnyHopSpeed.normal,
      ),
      crackedSinkDelay:
          (json['crackedSinkDelay'] as num? ?? 5.0).toDouble().clamp(3.0, 10.0),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? false,
      difficulty: BunnyHopDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => BunnyHopDifficulty.easy,
      ),
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        lilyPadCount,
        hopSpeed,
        crackedSinkDelay,
        rewardMultiplier,
        animationIntensity,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        highContrast,
        largerTouchTargets,
        difficulty,
      ];
}

class LilyPadEntity extends Equatable {
  const LilyPadEntity({
    required this.index,
    required this.x,
    required this.y,
    this.isCracked = false,
    this.phase = LilyPadPhase.floating,
    this.floatPhase = 0,
    this.sinkProgress = 0,
    this.bobOffset = 0,
  });

  final int index;
  final double x;
  final double y;
  final bool isCracked;
  final LilyPadPhase phase;
  final double floatPhase;
  final double sinkProgress;
  final double bobOffset;

  LilyPadEntity copyWith({
    double? x,
    double? y,
    bool? isCracked,
    LilyPadPhase? phase,
    double? floatPhase,
    double? sinkProgress,
    double? bobOffset,
  }) =>
      LilyPadEntity(
        index: index,
        x: x ?? this.x,
        y: y ?? this.y,
        isCracked: isCracked ?? this.isCracked,
        phase: phase ?? this.phase,
        floatPhase: floatPhase ?? this.floatPhase,
        sinkProgress: sinkProgress ?? this.sinkProgress,
        bobOffset: bobOffset ?? this.bobOffset,
      );

  @override
  List<Object?> get props =>
      [index, x, y, isCracked, phase, floatPhase, sinkProgress, bobOffset];
}

class BunnyEntity extends Equatable {
  const BunnyEntity({
    this.x = 0,
    this.y = 0,
    this.phase = BunnyPhase.idle,
    this.animPhase = 0,
    this.blinkTimer = 0,
    this.idleAction = 0,
    this.actionTimer = 0,
    this.hopProgress = 0,
    this.hopFromX = 0,
    this.hopFromY = 0,
    this.hopToX = 0,
    this.hopToY = 0,
    this.celebrateProgress = 0,
    this.fallProgress = 0,
    this.swimProgress = 0,
    this.shakeWater = 0,
    this.facingRight = true,
    this.squash = 1,
  });

  final double x;
  final double y;
  final BunnyPhase phase;
  final double animPhase;
  final double blinkTimer;
  final int idleAction;
  final double actionTimer;
  final double hopProgress;
  final double hopFromX;
  final double hopFromY;
  final double hopToX;
  final double hopToY;
  final double celebrateProgress;
  final double fallProgress;
  final double swimProgress;
  final double shakeWater;
  final bool facingRight;
  final double squash;

  BunnyEntity copyWith({
    double? x,
    double? y,
    BunnyPhase? phase,
    double? animPhase,
    double? blinkTimer,
    int? idleAction,
    double? actionTimer,
    double? hopProgress,
    double? hopFromX,
    double? hopFromY,
    double? hopToX,
    double? hopToY,
    double? celebrateProgress,
    double? fallProgress,
    double? swimProgress,
    double? shakeWater,
    bool? facingRight,
    double? squash,
  }) =>
      BunnyEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        animPhase: animPhase ?? this.animPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        idleAction: idleAction ?? this.idleAction,
        actionTimer: actionTimer ?? this.actionTimer,
        hopProgress: hopProgress ?? this.hopProgress,
        hopFromX: hopFromX ?? this.hopFromX,
        hopFromY: hopFromY ?? this.hopFromY,
        hopToX: hopToX ?? this.hopToX,
        hopToY: hopToY ?? this.hopToY,
        celebrateProgress: celebrateProgress ?? this.celebrateProgress,
        fallProgress: fallProgress ?? this.fallProgress,
        swimProgress: swimProgress ?? this.swimProgress,
        shakeWater: shakeWater ?? this.shakeWater,
        facingRight: facingRight ?? this.facingRight,
        squash: squash ?? this.squash,
      );

  @override
  List<Object?> get props => [
        x,
        y,
        phase,
        animPhase,
        blinkTimer,
        idleAction,
        actionTimer,
        hopProgress,
        hopFromX,
        hopFromY,
        hopToX,
        hopToY,
        celebrateProgress,
        fallProgress,
        swimProgress,
        shakeWater,
        facingRight,
        squash,
      ];
}

class CarrotEntity extends Equatable {
  const CarrotEntity({
    this.x = 0,
    this.y = 0,
    this.side = CarrotSide.sideB,
    this.glow = 0,
    this.bouncePhase = 0,
    this.sparklePhase = 0,
    this.visible = true,
  });

  final double x;
  final double y;
  final CarrotSide side;
  final double glow;
  final double bouncePhase;
  final double sparklePhase;
  final bool visible;

  CarrotEntity copyWith({
    double? x,
    double? y,
    CarrotSide? side,
    double? glow,
    double? bouncePhase,
    double? sparklePhase,
    bool? visible,
  }) =>
      CarrotEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        side: side ?? this.side,
        glow: glow ?? this.glow,
        bouncePhase: bouncePhase ?? this.bouncePhase,
        sparklePhase: sparklePhase ?? this.sparklePhase,
        visible: visible ?? this.visible,
      );

  @override
  List<Object?> get props => [x, y, side, glow, bouncePhase, sparklePhase, visible];
}

class BunnyHopState extends Equatable {
  const BunnyHopState({
    this.sessionPhase = BunnyHopSessionPhase.ready,
    this.settings = const BunnyHopSettings(),
    this.bunny = const BunnyEntity(),
    this.lilyPads = const [],
    this.carrot = const CarrotEntity(),
    this.travelDirection = TravelDirection.towardB,
    this.stepIndex = -1,
    this.crackedStandTimer = 0,
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.totalHops = 0,
    this.carrotsCollected = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.fallsRecovered = 0,
    this.envPhase = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.showCarrotCelebration = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
    this.originBankForCrossing = -1,
  });

  final BunnyHopSessionPhase sessionPhase;
  final BunnyHopSettings settings;
  final BunnyEntity bunny;
  final List<LilyPadEntity> lilyPads;
  final CarrotEntity carrot;
  final TravelDirection travelDirection;
  /// -1 = bank A, 0..n-1 = lily pad, n = bank B
  final int stepIndex;
  final double crackedStandTimer;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int totalHops;
  final int carrotsCollected;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final int fallsRecovered;
  final double envPhase;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool showCarrotCelebration;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;
  final int originBankForCrossing;

  int get padCount => settings.effectiveLilyPadCount;

  bool get hasActiveAnimation =>
      bunny.phase == BunnyPhase.hopping ||
      bunny.phase == BunnyPhase.celebrating ||
      bunny.phase == BunnyPhase.falling ||
      bunny.phase == BunnyPhase.swimming ||
      bunny.phase == BunnyPhase.recovering;

  bool get canTap =>
      sessionPhase == BunnyHopSessionPhase.playing &&
      (bunny.phase == BunnyPhase.idle || bunny.phase == BunnyPhase.landed);

  BunnyHopState copyWith({
    BunnyHopSessionPhase? sessionPhase,
    BunnyHopSettings? settings,
    BunnyEntity? bunny,
    List<LilyPadEntity>? lilyPads,
    CarrotEntity? carrot,
    TravelDirection? travelDirection,
    int? stepIndex,
    double? crackedStandTimer,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? totalHops,
    int? carrotsCollected,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    int? fallsRecovered,
    double? envPhase,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? showCarrotCelebration,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    int? originBankForCrossing,
    bool clearFeedback = false,
    bool resetCrackedTimer = false,
  }) =>
      BunnyHopState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        bunny: bunny ?? this.bunny,
        lilyPads: lilyPads ?? this.lilyPads,
        carrot: carrot ?? this.carrot,
        travelDirection: travelDirection ?? this.travelDirection,
        stepIndex: stepIndex ?? this.stepIndex,
        crackedStandTimer:
            resetCrackedTimer ? 0 : (crackedStandTimer ?? this.crackedStandTimer),
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        totalHops: totalHops ?? this.totalHops,
        carrotsCollected: carrotsCollected ?? this.carrotsCollected,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        fallsRecovered: fallsRecovered ?? this.fallsRecovered,
        envPhase: envPhase ?? this.envPhase,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        showCarrotCelebration: showCarrotCelebration ?? this.showCarrotCelebration,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        inactivityTimer: inactivityTimer ?? this.inactivityTimer,
        originBankForCrossing: originBankForCrossing ?? this.originBankForCrossing,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        bunny,
        lilyPads,
        carrot,
        travelDirection,
        stepIndex,
        crackedStandTimer,
        remainingSeconds,
        elapsedSeconds,
        totalHops,
        carrotsCollected,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        fallsRecovered,
        envPhase,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        showCarrotCelebration,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
        originBankForCrossing,
      ];
}

class BunnyHopResult extends Equatable {
  const BunnyHopResult({
    required this.totalHops,
    required this.carrotsCollected,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.fallsRecovered,
    required this.sessionSeconds,
  });

  final int totalHops;
  final int carrotsCollected;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int fallsRecovered;
  final int sessionSeconds;

  @override
  List<Object?> get props =>
      [totalHops, carrotsCollected, points, coins, xp, stars, longestStreak, fallsRecovered, sessionSeconds];
}

const kBunnyHopSkills = [
  'Visual Attention',
  'Hand-Eye Coordination',
  'Sequencing',
  'Spatial Awareness',
  'Cause & Effect',
  'Early Planning',
];

const kHopEncouragements = [
  'Great Hop!',
  'Keep Going!',
  'Nice Jump!',
  'You Can Do It!',
];

const kCarrotMessages = [
  'The Bunny Found the Carrot!',
  'Wonderful!',
  'Let\'s Hop Back!',
  'Great Job!',
];

const kFallMessages = [
  'Let\'s Hop Again!',
  'Almost!',
  'The Bunny is Ready!',
  'Try Again!',
];
