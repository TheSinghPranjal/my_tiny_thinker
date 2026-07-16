import 'package:equatable/equatable.dart';

enum HungryDuckSessionPhase { ready, playing, paused, finished }

enum FishPhase { swimming, selected, sinking, entering, gone }

enum DuckPhase { idleSwim, chasing, eating, celebrating }

enum PondVisitorKind { turtle, frog, dragonfly, butterfly }

enum PondVisitorPhase { active, reacted, leaving, gone }

enum PondFishSwimSpeed { verySlow, slow, normal, fast }

enum DuckSwimSpeed { verySlow, slow, normal, fast }

enum HungryDuckDifficulty { easy, normal, playful }

class HungryDuckSettings extends Equatable {
  const HungryDuckSettings({
    this.sessionSeconds = 60,
    this.fishCount = 5,
    this.fishSpeed = PondFishSwimSpeed.slow,
    this.duckSpeed = DuckSwimSpeed.slow,
    this.goldenInterval = 20,
    this.visitorSpawnMin = 8.0,
    this.visitorSpawnMax = 12.0,
    this.replacementDelay = 1.0,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = HungryDuckDifficulty.easy,
  });

  final int sessionSeconds;
  final int fishCount;
  final PondFishSwimSpeed fishSpeed;
  final DuckSwimSpeed duckSpeed;
  final int goldenInterval;
  final double visitorSpawnMin;
  final double visitorSpawnMax;
  final double replacementDelay;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final HungryDuckDifficulty difficulty;

  int get effectiveFishCount => fishCount.clamp(4, 10);

  double get fishSpeedMult => switch (fishSpeed) {
        PondFishSwimSpeed.verySlow => 0.55,
        PondFishSwimSpeed.slow => 0.8,
        PondFishSwimSpeed.normal => 1.0,
        PondFishSwimSpeed.fast => 1.2,
      };

  double get duckSpeedMult => switch (duckSpeed) {
        DuckSwimSpeed.verySlow => 0.6,
        DuckSwimSpeed.slow => 0.85,
        DuckSwimSpeed.normal => 1.05,
        DuckSwimSpeed.fast => 1.25,
      };

  HungryDuckSettings copyWith({
    int? sessionSeconds,
    int? fishCount,
    PondFishSwimSpeed? fishSpeed,
    DuckSwimSpeed? duckSpeed,
    int? goldenInterval,
    double? visitorSpawnMin,
    double? visitorSpawnMax,
    double? replacementDelay,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    HungryDuckDifficulty? difficulty,
  }) =>
      HungryDuckSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        fishCount: fishCount ?? this.fishCount,
        fishSpeed: fishSpeed ?? this.fishSpeed,
        duckSpeed: duckSpeed ?? this.duckSpeed,
        goldenInterval: goldenInterval ?? this.goldenInterval,
        visitorSpawnMin: visitorSpawnMin ?? this.visitorSpawnMin,
        visitorSpawnMax: visitorSpawnMax ?? this.visitorSpawnMax,
        replacementDelay: replacementDelay ?? this.replacementDelay,
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
        'fishCount': fishCount,
        'fishSpeed': fishSpeed.name,
        'duckSpeed': duckSpeed.name,
        'goldenInterval': goldenInterval,
        'visitorSpawnMin': visitorSpawnMin,
        'visitorSpawnMax': visitorSpawnMax,
        'replacementDelay': replacementDelay,
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

  factory HungryDuckSettings.fromJson(Map<String, dynamic> json) {
    var vMin = (json['visitorSpawnMin'] as num? ?? 8.0).toDouble().clamp(4.0, 20.0);
    var vMax = (json['visitorSpawnMax'] as num? ?? 12.0).toDouble().clamp(5.0, 25.0);
    if (vMin > vMax) {
      final swap = vMin;
      vMin = vMax;
      vMax = swap;
    }
    return HungryDuckSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      fishCount: (json['fishCount'] as int? ?? 5).clamp(4, 10),
      fishSpeed: PondFishSwimSpeed.values.firstWhere(
        (s) => s.name == json['fishSpeed'],
        orElse: () => PondFishSwimSpeed.slow,
      ),
      duckSpeed: DuckSwimSpeed.values.firstWhere(
        (s) => s.name == json['duckSpeed'],
        orElse: () => DuckSwimSpeed.slow,
      ),
      goldenInterval: (json['goldenInterval'] as int? ?? 20).clamp(10, 60),
      visitorSpawnMin: vMin,
      visitorSpawnMax: vMax,
      replacementDelay:
          (json['replacementDelay'] as num? ?? 1.0).toDouble().clamp(0.5, 3.0),
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
      difficulty: HungryDuckDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => HungryDuckDifficulty.easy,
      ),
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        fishCount,
        fishSpeed,
        duckSpeed,
        goldenInterval,
        visitorSpawnMin,
        visitorSpawnMax,
        replacementDelay,
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

class PondFishEntity extends Equatable {
  const PondFishEntity({
    required this.id,
    required this.varietyIndex,
    required this.pathSeed,
    this.isGolden = false,
    this.phase = FishPhase.swimming,
    this.x = 0,
    this.y = 0,
    this.pathT = 0,
    this.depth = 0.5,
    this.glow = 0,
    this.highlight = 0,
    this.sinkProgress = 0,
    this.enterProgress = 0,
    this.enterFromX = 0,
    this.enterFromY = 0,
    this.facingRight = true,
  });

  final String id;
  final int varietyIndex;
  final int pathSeed;
  final bool isGolden;
  final FishPhase phase;
  final double x;
  final double y;
  final double pathT;
  final double depth;
  final double glow;
  final double highlight;
  final double sinkProgress;
  final double enterProgress;
  final double enterFromX;
  final double enterFromY;
  final bool facingRight;

  bool get canTap => phase == FishPhase.swimming;

  PondFishEntity copyWith({
    FishPhase? phase,
    double? x,
    double? y,
    double? pathT,
    double? depth,
    double? glow,
    double? highlight,
    double? sinkProgress,
    double? enterProgress,
    bool? facingRight,
    bool? isGolden,
    int? varietyIndex,
  }) =>
      PondFishEntity(
        id: id,
        varietyIndex: varietyIndex ?? this.varietyIndex,
        pathSeed: pathSeed,
        isGolden: isGolden ?? this.isGolden,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        pathT: pathT ?? this.pathT,
        depth: depth ?? this.depth,
        glow: glow ?? this.glow,
        highlight: highlight ?? this.highlight,
        sinkProgress: sinkProgress ?? this.sinkProgress,
        enterProgress: enterProgress ?? this.enterProgress,
        enterFromX: enterFromX,
        enterFromY: enterFromY,
        facingRight: facingRight ?? this.facingRight,
      );

  @override
  List<Object?> get props => [
        id,
        varietyIndex,
        pathSeed,
        isGolden,
        phase,
        x,
        y,
        pathT,
        depth,
        glow,
        highlight,
        sinkProgress,
        enterProgress,
        enterFromX,
        enterFromY,
        facingRight,
      ];
}

class DuckEntity extends Equatable {
  const DuckEntity({
    this.x = 0,
    this.y = 0,
    this.phase = DuckPhase.idleSwim,
    this.pathT = 0,
    this.pathSeed = 0,
    this.animPhase = 0,
    this.blinkTimer = 0,
    this.chaseProgress = 0,
    this.eatProgress = 0,
    this.celebrateProgress = 0,
    this.facingRight = true,
    this.ripplePhase = 0,
    this.targetFishId,
    this.wingFlap = 0,
    this.restX,
    this.restY,
  });

  final double x;
  final double y;
  final DuckPhase phase;
  final double pathT;
  final int pathSeed;
  final double animPhase;
  final double blinkTimer;
  final double chaseProgress;
  final double eatProgress;
  final double celebrateProgress;
  final bool facingRight;
  final double ripplePhase;
  final String? targetFishId;
  final double wingFlap;
  final double? restX;
  final double? restY;

  DuckEntity copyWith({
    double? x,
    double? y,
    DuckPhase? phase,
    double? pathT,
    double? animPhase,
    double? blinkTimer,
    double? chaseProgress,
    double? eatProgress,
    double? celebrateProgress,
    bool? facingRight,
    double? ripplePhase,
    String? targetFishId,
    bool clearTarget = false,
    double? wingFlap,
    double? restX,
    double? restY,
  }) =>
      DuckEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        pathT: pathT ?? this.pathT,
        pathSeed: pathSeed,
        animPhase: animPhase ?? this.animPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        chaseProgress: chaseProgress ?? this.chaseProgress,
        eatProgress: eatProgress ?? this.eatProgress,
        celebrateProgress: celebrateProgress ?? this.celebrateProgress,
        facingRight: facingRight ?? this.facingRight,
        ripplePhase: ripplePhase ?? this.ripplePhase,
        targetFishId: clearTarget ? null : (targetFishId ?? this.targetFishId),
        wingFlap: wingFlap ?? this.wingFlap,
        restX: restX ?? this.restX,
        restY: restY ?? this.restY,
      );

  @override
  List<Object?> get props => [
        x,
        y,
        phase,
        pathT,
        pathSeed,
        animPhase,
        blinkTimer,
        chaseProgress,
        eatProgress,
        celebrateProgress,
        facingRight,
        ripplePhase,
        targetFishId,
        wingFlap,
        restX,
        restY,
      ];
}

class PondVisitorEntity extends Equatable {
  const PondVisitorEntity({
    required this.id,
    required this.kind,
    this.phase = PondVisitorPhase.active,
    this.x = 0,
    this.y = 0,
    this.progress = 0,
    this.lifetime = 6,
    this.animPhase = 0,
    this.wasTapped = false,
  });

  final String id;
  final PondVisitorKind kind;
  final PondVisitorPhase phase;
  final double x;
  final double y;
  final double progress;
  final double lifetime;
  final double animPhase;
  final bool wasTapped;

  bool get canTap => phase == PondVisitorPhase.active || phase == PondVisitorPhase.reacted;

  PondVisitorEntity copyWith({
    PondVisitorPhase? phase,
    double? x,
    double? y,
    double? progress,
    double? lifetime,
    double? animPhase,
    bool? wasTapped,
  }) =>
      PondVisitorEntity(
        id: id,
        kind: kind,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        progress: progress ?? this.progress,
        lifetime: lifetime ?? this.lifetime,
        animPhase: animPhase ?? this.animPhase,
        wasTapped: wasTapped ?? this.wasTapped,
      );

  @override
  List<Object?> get props =>
      [id, kind, phase, x, y, progress, lifetime, animPhase, wasTapped];
}

class PendingFishSpawn extends Equatable {
  const PendingFishSpawn({required this.timer, this.isGolden = false});

  final double timer;
  final bool isGolden;

  PendingFishSpawn copyWith({double? timer, bool? isGolden}) =>
      PendingFishSpawn(timer: timer ?? this.timer, isGolden: isGolden ?? this.isGolden);

  @override
  List<Object?> get props => [timer, isGolden];
}

class HungryDuckState extends Equatable {
  const HungryDuckState({
    this.sessionPhase = HungryDuckSessionPhase.ready,
    this.settings = const HungryDuckSettings(),
    this.fish = const [],
    this.duck = const DuckEntity(),
    this.visitors = const [],
    this.pendingSpawns = const [],
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.fishCaught = 0,
    this.goldenCaught = 0,
    this.visitorsTapped = 0,
    this.duckSwims = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.nextGoldenAt = 20,
    this.goldenDue = false,
    this.nextVisitorSpawnIn = 9.0,
    this.sunsetFactor = 0,
    this.envPhase = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.showGoldenCelebration = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
  });

  final HungryDuckSessionPhase sessionPhase;
  final HungryDuckSettings settings;
  final List<PondFishEntity> fish;
  final DuckEntity duck;
  final List<PondVisitorEntity> visitors;
  final List<PendingFishSpawn> pendingSpawns;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int fishCaught;
  final int goldenCaught;
  final int visitorsTapped;
  final int duckSwims;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final int nextGoldenAt;
  final bool goldenDue;
  final double nextVisitorSpawnIn;
  final double sunsetFactor;
  final double envPhase;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool showGoldenCelebration;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;

  bool get hasActiveAnimation =>
      duck.phase != DuckPhase.idleSwim ||
      fish.any((f) => f.phase == FishPhase.selected || f.phase == FishPhase.sinking) ||
      fish.any((f) => f.phase == FishPhase.entering);

  HungryDuckState copyWith({
    HungryDuckSessionPhase? sessionPhase,
    HungryDuckSettings? settings,
    List<PondFishEntity>? fish,
    DuckEntity? duck,
    List<PondVisitorEntity>? visitors,
    List<PendingFishSpawn>? pendingSpawns,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? fishCaught,
    int? goldenCaught,
    int? visitorsTapped,
    int? duckSwims,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    int? nextGoldenAt,
    bool? goldenDue,
    double? nextVisitorSpawnIn,
    double? sunsetFactor,
    double? envPhase,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? showGoldenCelebration,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    bool clearFeedback = false,
  }) =>
      HungryDuckState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        fish: fish ?? this.fish,
        duck: duck ?? this.duck,
        visitors: visitors ?? this.visitors,
        pendingSpawns: pendingSpawns ?? this.pendingSpawns,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        fishCaught: fishCaught ?? this.fishCaught,
        goldenCaught: goldenCaught ?? this.goldenCaught,
        visitorsTapped: visitorsTapped ?? this.visitorsTapped,
        duckSwims: duckSwims ?? this.duckSwims,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        nextGoldenAt: nextGoldenAt ?? this.nextGoldenAt,
        goldenDue: goldenDue ?? this.goldenDue,
        nextVisitorSpawnIn: nextVisitorSpawnIn ?? this.nextVisitorSpawnIn,
        sunsetFactor: sunsetFactor ?? this.sunsetFactor,
        envPhase: envPhase ?? this.envPhase,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        showGoldenCelebration: showGoldenCelebration ?? this.showGoldenCelebration,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        inactivityTimer: inactivityTimer ?? this.inactivityTimer,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        fish,
        duck,
        visitors,
        pendingSpawns,
        remainingSeconds,
        elapsedSeconds,
        fishCaught,
        goldenCaught,
        visitorsTapped,
        duckSwims,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        nextGoldenAt,
        goldenDue,
        nextVisitorSpawnIn,
        sunsetFactor,
        envPhase,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        showGoldenCelebration,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
      ];
}

class HungryDuckResult extends Equatable {
  const HungryDuckResult({
    required this.fishCaught,
    required this.goldenCaught,
    required this.visitorsTapped,
    required this.duckSwims,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
  });

  final int fishCaught;
  final int goldenCaught;
  final int visitorsTapped;
  final int duckSwims;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;

  @override
  List<Object?> get props => [
        fishCaught,
        goldenCaught,
        visitorsTapped,
        duckSwims,
        points,
        coins,
        xp,
        stars,
        longestStreak,
        sessionSeconds,
      ];
}

const kHungryDuckSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Touch Accuracy',
  'Reaction Timing',
  'Cause & Effect',
  'Attention',
];

const kFishEncouragements = [
  'Yummy Fish!',
  'Great Catch!',
  'Quack Quack!',
  'The Duck is Happy!',
  'Amazing!',
];

const kVisitorMessages = [
  'Hello Friend!',
  'Nice to See You!',
  'Wave Wave!',
];
