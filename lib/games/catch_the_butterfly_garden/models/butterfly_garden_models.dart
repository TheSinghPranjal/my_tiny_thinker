import 'package:equatable/equatable.dart';

enum ButterflyGardenSessionPhase { ready, playing, paused, finished }

enum ButterflyPhase { flying, tapped, collecting, entering, gone }

enum BeePhase { flying, buzzed, leaving, gone }

enum ButterflyFlightSpeed { verySlow, slow, normal, fast }

enum ButterflyGardenDifficulty { easy, normal, playful }

class ButterflyGardenSettings extends Equatable {
  const ButterflyGardenSettings({
    this.sessionSeconds = 60,
    this.butterflyCount = 5,
    this.flightSpeed = ButterflyFlightSpeed.slow,
    this.goldenInterval = 20,
    this.beeSpawnMin = 6.0,
    this.beeSpawnMax = 10.0,
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
    this.difficulty = ButterflyGardenDifficulty.easy,
  });

  final int sessionSeconds;
  final int butterflyCount;
  final ButterflyFlightSpeed flightSpeed;
  final int goldenInterval;
  final double beeSpawnMin;
  final double beeSpawnMax;
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
  final ButterflyGardenDifficulty difficulty;

  int get effectiveButterflyCount => butterflyCount.clamp(3, 10);

  double get speedMult => switch (flightSpeed) {
        ButterflyFlightSpeed.verySlow => 0.55,
        ButterflyFlightSpeed.slow => 0.8,
        ButterflyFlightSpeed.normal => 1.0,
        ButterflyFlightSpeed.fast => 1.25,
      };

  ButterflyGardenSettings copyWith({
    int? sessionSeconds,
    int? butterflyCount,
    ButterflyFlightSpeed? flightSpeed,
    int? goldenInterval,
    double? beeSpawnMin,
    double? beeSpawnMax,
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
    ButterflyGardenDifficulty? difficulty,
  }) =>
      ButterflyGardenSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        butterflyCount: butterflyCount ?? this.butterflyCount,
        flightSpeed: flightSpeed ?? this.flightSpeed,
        goldenInterval: goldenInterval ?? this.goldenInterval,
        beeSpawnMin: beeSpawnMin ?? this.beeSpawnMin,
        beeSpawnMax: beeSpawnMax ?? this.beeSpawnMax,
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
        'butterflyCount': butterflyCount,
        'flightSpeed': flightSpeed.name,
        'goldenInterval': goldenInterval,
        'beeSpawnMin': beeSpawnMin,
        'beeSpawnMax': beeSpawnMax,
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

  factory ButterflyGardenSettings.fromJson(Map<String, dynamic> json) {
    var beeMin = (json['beeSpawnMin'] as num? ?? 6.0).toDouble().clamp(3.0, 15.0);
    var beeMax = (json['beeSpawnMax'] as num? ?? 10.0).toDouble().clamp(4.0, 20.0);
    if (beeMin > beeMax) {
      final swap = beeMin;
      beeMin = beeMax;
      beeMax = swap;
    }
    return ButterflyGardenSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      butterflyCount: (json['butterflyCount'] as int? ?? 5).clamp(3, 10),
      flightSpeed: ButterflyFlightSpeed.values.firstWhere(
        (s) => s.name == json['flightSpeed'],
        orElse: () => ButterflyFlightSpeed.slow,
      ),
      goldenInterval: (json['goldenInterval'] as int? ?? 20).clamp(10, 60),
      beeSpawnMin: beeMin,
      beeSpawnMax: beeMax,
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
      difficulty: ButterflyGardenDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => ButterflyGardenDifficulty.easy,
      ),
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        butterflyCount,
        flightSpeed,
        goldenInterval,
        beeSpawnMin,
        beeSpawnMax,
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

class ButterflyEntity extends Equatable {
  const ButterflyEntity({
    required this.id,
    required this.varietyIndex,
    required this.pathSeed,
    this.isGolden = false,
    this.phase = ButterflyPhase.flying,
    this.x = 0,
    this.y = 0,
    this.pathT = 0,
    this.wingPhase = 0,
    this.glow = 0,
    this.highlight = 0,
    this.sizeScale = 1,
    this.collectProgress = 0,
    this.collectStartX = 0,
    this.collectStartY = 0,
    this.enterProgress = 0,
    this.enterFromX = 0,
    this.enterFromY = 0,
    this.hoverPhase = 0,
  });

  final String id;
  final int varietyIndex;
  final int pathSeed;
  final bool isGolden;
  final ButterflyPhase phase;
  final double x;
  final double y;
  final double pathT;
  final double wingPhase;
  final double glow;
  final double highlight;
  final double sizeScale;
  final double collectProgress;
  final double collectStartX;
  final double collectStartY;
  final double enterProgress;
  final double enterFromX;
  final double enterFromY;
  final double hoverPhase;

  bool get canTap => phase == ButterflyPhase.flying;

  ButterflyEntity copyWith({
    ButterflyPhase? phase,
    double? x,
    double? y,
    double? pathT,
    double? wingPhase,
    double? glow,
    double? highlight,
    double? sizeScale,
    double? collectProgress,
    double? collectStartX,
    double? collectStartY,
    double? enterProgress,
    double? hoverPhase,
    bool? isGolden,
    int? varietyIndex,
  }) =>
      ButterflyEntity(
        id: id,
        varietyIndex: varietyIndex ?? this.varietyIndex,
        pathSeed: pathSeed,
        isGolden: isGolden ?? this.isGolden,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        pathT: pathT ?? this.pathT,
        wingPhase: wingPhase ?? this.wingPhase,
        glow: glow ?? this.glow,
        highlight: highlight ?? this.highlight,
        sizeScale: sizeScale ?? this.sizeScale,
        collectProgress: collectProgress ?? this.collectProgress,
        collectStartX: collectStartX ?? this.collectStartX,
        collectStartY: collectStartY ?? this.collectStartY,
        enterProgress: enterProgress ?? this.enterProgress,
        enterFromX: enterFromX,
        enterFromY: enterFromY,
        hoverPhase: hoverPhase ?? this.hoverPhase,
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
        wingPhase,
        glow,
        highlight,
        sizeScale,
        collectProgress,
        collectStartX,
        collectStartY,
        enterProgress,
        enterFromX,
        enterFromY,
        hoverPhase,
      ];
}

class BeeEntity extends Equatable {
  const BeeEntity({
    required this.id,
    required this.x,
    required this.y,
    this.phase = BeePhase.flying,
    this.pathT = 0,
    this.lifetime = 5,
    this.wingPhase = 0,
    this.wasTapped = false,
    this.vx = 1,
    this.vy = 0,
  });

  final String id;
  final double x;
  final double y;
  final BeePhase phase;
  final double pathT;
  final double lifetime;
  final double wingPhase;
  final bool wasTapped;
  final double vx;
  final double vy;

  bool get canTap => phase == BeePhase.flying || phase == BeePhase.buzzed;

  BeeEntity copyWith({
    BeePhase? phase,
    double? x,
    double? y,
    double? pathT,
    double? lifetime,
    double? wingPhase,
    bool? wasTapped,
    double? vx,
    double? vy,
  }) =>
      BeeEntity(
        id: id,
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        pathT: pathT ?? this.pathT,
        lifetime: lifetime ?? this.lifetime,
        wingPhase: wingPhase ?? this.wingPhase,
        wasTapped: wasTapped ?? this.wasTapped,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
      );

  @override
  List<Object?> get props =>
      [id, x, y, phase, pathT, lifetime, wingPhase, wasTapped, vx, vy];
}

class BasketEntity extends Equatable {
  const BasketEntity({
    this.x = 0,
    this.y = 0,
    this.lidOpen = 0,
    this.bouncePhase = 0,
    this.totalCollected = 0,
  });

  final double x;
  final double y;
  final double lidOpen;
  final double bouncePhase;
  final int totalCollected;

  BasketEntity copyWith({
    double? x,
    double? y,
    double? lidOpen,
    double? bouncePhase,
    int? totalCollected,
  }) =>
      BasketEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        lidOpen: lidOpen ?? this.lidOpen,
        bouncePhase: bouncePhase ?? this.bouncePhase,
        totalCollected: totalCollected ?? this.totalCollected,
      );

  @override
  List<Object?> get props => [x, y, lidOpen, bouncePhase, totalCollected];
}

class PendingButterflySpawn extends Equatable {
  const PendingButterflySpawn({
    required this.timer,
    this.isGolden = false,
  });

  final double timer;
  final bool isGolden;

  PendingButterflySpawn copyWith({double? timer, bool? isGolden}) =>
      PendingButterflySpawn(
        timer: timer ?? this.timer,
        isGolden: isGolden ?? this.isGolden,
      );

  @override
  List<Object?> get props => [timer, isGolden];
}

class ButterflyGardenState extends Equatable {
  const ButterflyGardenState({
    this.sessionPhase = ButterflyGardenSessionPhase.ready,
    this.settings = const ButterflyGardenSettings(),
    this.butterflies = const [],
    this.bees = const [],
    this.basket = const BasketEntity(),
    this.pendingSpawns = const [],
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.butterfliesCaught = 0,
    this.goldenCaught = 0,
    this.beesTapped = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.nextGoldenAt = 20,
    this.goldenDue = false,
    this.nextBeeSpawnIn = 7.0,
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

  final ButterflyGardenSessionPhase sessionPhase;
  final ButterflyGardenSettings settings;
  final List<ButterflyEntity> butterflies;
  final List<BeeEntity> bees;
  final BasketEntity basket;
  final List<PendingButterflySpawn> pendingSpawns;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int butterfliesCaught;
  final int goldenCaught;
  final int beesTapped;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final int nextGoldenAt;
  final bool goldenDue;
  final double nextBeeSpawnIn;
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
      butterflies.any(
        (b) =>
            b.phase == ButterflyPhase.tapped ||
            b.phase == ButterflyPhase.collecting ||
            b.phase == ButterflyPhase.entering,
      ) ||
      basket.lidOpen > 0;

  ButterflyGardenState copyWith({
    ButterflyGardenSessionPhase? sessionPhase,
    ButterflyGardenSettings? settings,
    List<ButterflyEntity>? butterflies,
    List<BeeEntity>? bees,
    BasketEntity? basket,
    List<PendingButterflySpawn>? pendingSpawns,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? butterfliesCaught,
    int? goldenCaught,
    int? beesTapped,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    int? nextGoldenAt,
    bool? goldenDue,
    double? nextBeeSpawnIn,
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
      ButterflyGardenState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        butterflies: butterflies ?? this.butterflies,
        bees: bees ?? this.bees,
        basket: basket ?? this.basket,
        pendingSpawns: pendingSpawns ?? this.pendingSpawns,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        butterfliesCaught: butterfliesCaught ?? this.butterfliesCaught,
        goldenCaught: goldenCaught ?? this.goldenCaught,
        beesTapped: beesTapped ?? this.beesTapped,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        nextGoldenAt: nextGoldenAt ?? this.nextGoldenAt,
        goldenDue: goldenDue ?? this.goldenDue,
        nextBeeSpawnIn: nextBeeSpawnIn ?? this.nextBeeSpawnIn,
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
        butterflies,
        bees,
        basket,
        pendingSpawns,
        remainingSeconds,
        elapsedSeconds,
        butterfliesCaught,
        goldenCaught,
        beesTapped,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        nextGoldenAt,
        goldenDue,
        nextBeeSpawnIn,
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

class ButterflyGardenResult extends Equatable {
  const ButterflyGardenResult({
    required this.butterfliesCaught,
    required this.goldenCaught,
    required this.beesTapped,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
  });

  final int butterfliesCaught;
  final int goldenCaught;
  final int beesTapped;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;

  @override
  List<Object?> get props => [
        butterfliesCaught,
        goldenCaught,
        beesTapped,
        points,
        coins,
        xp,
        stars,
        longestStreak,
        sessionSeconds,
      ];
}

const kButterflyGardenSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Reaction Timing',
  'Eye Movement Control',
  'Cause & Effect',
  'Attention',
];

const kButterflyEncouragements = [
  'Beautiful Butterfly!',
  'Great Catch!',
  'Let\'s Find Another One!',
  'Amazing!',
  'So Pretty!',
];

const kBeeMessages = [
  'Let\'s Catch Butterflies!',
  'The Bee is Busy!',
  'Bees Love Flowers!',
];
