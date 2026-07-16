import 'package:equatable/equatable.dart';

enum HungryTeddySessionPhase { ready, playing, paused, finished }

enum CupcakePhase { onTable, dragging, snapping, gone, baking }

enum TeddyPhase { idle, watching, excited, receiving, eating, celebrating, goldenCelebration }

enum PartyVisitorKind { balloon, toyAnimal, giftBox, bird }

enum PartyVisitorPhase { active, reacted, leaving, gone }

enum TeddyDragSensitivity { veryLow, low, normal, high }

enum HungryTeddyDifficulty { easy, normal, playful }

class HungryTeddySettings extends Equatable {
  const HungryTeddySettings({
    this.sessionSeconds = 60,
    this.cupcakeCount = 6,
    this.dragSensitivity = TeddyDragSensitivity.normal,
    this.goldenInterval = 20,
    this.visitorSpawnMin = 8.0,
    this.visitorSpawnMax = 12.0,
    this.regrowDelay = 1.0,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = HungryTeddyDifficulty.easy,
  });

  final int sessionSeconds;
  final int cupcakeCount;
  final TeddyDragSensitivity dragSensitivity;
  final int goldenInterval;
  final double visitorSpawnMin;
  final double visitorSpawnMax;
  final double regrowDelay;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final HungryTeddyDifficulty difficulty;

  int get effectiveCupcakeCount => cupcakeCount.clamp(4, 10);

  double get snapRadiusMult => switch (dragSensitivity) {
        TeddyDragSensitivity.veryLow => 1.55,
        TeddyDragSensitivity.low => 1.25,
        TeddyDragSensitivity.normal => 1.0,
        TeddyDragSensitivity.high => 0.82,
      };

  HungryTeddySettings copyWith({
    int? sessionSeconds,
    int? cupcakeCount,
    TeddyDragSensitivity? dragSensitivity,
    int? goldenInterval,
    double? visitorSpawnMin,
    double? visitorSpawnMax,
    double? regrowDelay,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    HungryTeddyDifficulty? difficulty,
  }) =>
      HungryTeddySettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        cupcakeCount: cupcakeCount ?? this.cupcakeCount,
        dragSensitivity: dragSensitivity ?? this.dragSensitivity,
        goldenInterval: goldenInterval ?? this.goldenInterval,
        visitorSpawnMin: visitorSpawnMin ?? this.visitorSpawnMin,
        visitorSpawnMax: visitorSpawnMax ?? this.visitorSpawnMax,
        regrowDelay: regrowDelay ?? this.regrowDelay,
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
        'cupcakeCount': cupcakeCount,
        'dragSensitivity': dragSensitivity.name,
        'goldenInterval': goldenInterval,
        'visitorSpawnMin': visitorSpawnMin,
        'visitorSpawnMax': visitorSpawnMax,
        'regrowDelay': regrowDelay,
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

  factory HungryTeddySettings.fromJson(Map<String, dynamic> json) {
    var vMin = (json['visitorSpawnMin'] as num? ?? 8.0).toDouble().clamp(4.0, 20.0);
    var vMax = (json['visitorSpawnMax'] as num? ?? 12.0).toDouble().clamp(5.0, 25.0);
    if (vMin > vMax) {
      final swap = vMin;
      vMin = vMax;
      vMax = swap;
    }
    return HungryTeddySettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      cupcakeCount: (json['cupcakeCount'] as int? ?? 6).clamp(4, 10),
      dragSensitivity: TeddyDragSensitivity.values.firstWhere(
        (s) => s.name == json['dragSensitivity'],
        orElse: () => TeddyDragSensitivity.normal,
      ),
      goldenInterval: (json['goldenInterval'] as int? ?? 20).clamp(10, 60),
      visitorSpawnMin: vMin,
      visitorSpawnMax: vMax,
      regrowDelay: (json['regrowDelay'] as num? ?? 1.0).toDouble().clamp(0.5, 3.0),
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
      difficulty: HungryTeddyDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => HungryTeddyDifficulty.easy,
      ),
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        cupcakeCount,
        dragSensitivity,
        goldenInterval,
        visitorSpawnMin,
        visitorSpawnMax,
        regrowDelay,
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

class CupcakeEntity extends Equatable {
  const CupcakeEntity({
    required this.id,
    required this.slotIndex,
    required this.varietyIndex,
    required this.x,
    required this.y,
    this.isGolden = false,
    this.phase = CupcakePhase.onTable,
    this.dragX = 0,
    this.dragY = 0,
    this.homeX = 0,
    this.homeY = 0,
    this.glow = 0,
    this.scale = 1,
    this.snapProgress = 0,
    this.bakeProgress = 0,
    this.sparklePhase = 0,
  });

  final String id;
  final int slotIndex;
  final int varietyIndex;
  final double x;
  final double y;
  final bool isGolden;
  final CupcakePhase phase;
  final double dragX;
  final double dragY;
  final double homeX;
  final double homeY;
  final double glow;
  final double scale;
  final double snapProgress;
  final double bakeProgress;
  final double sparklePhase;

  bool get canDrag => phase == CupcakePhase.onTable;

  CupcakeEntity copyWith({
    int? varietyIndex,
    double? x,
    double? y,
    bool? isGolden,
    CupcakePhase? phase,
    double? dragX,
    double? dragY,
    double? homeX,
    double? homeY,
    double? glow,
    double? scale,
    double? snapProgress,
    double? bakeProgress,
    double? sparklePhase,
  }) =>
      CupcakeEntity(
        id: id,
        slotIndex: slotIndex,
        varietyIndex: varietyIndex ?? this.varietyIndex,
        x: x ?? this.x,
        y: y ?? this.y,
        isGolden: isGolden ?? this.isGolden,
        phase: phase ?? this.phase,
        dragX: dragX ?? this.dragX,
        dragY: dragY ?? this.dragY,
        homeX: homeX ?? this.homeX,
        homeY: homeY ?? this.homeY,
        glow: glow ?? this.glow,
        scale: scale ?? this.scale,
        snapProgress: snapProgress ?? this.snapProgress,
        bakeProgress: bakeProgress ?? this.bakeProgress,
        sparklePhase: sparklePhase ?? this.sparklePhase,
      );

  @override
  List<Object?> get props => [
        id,
        slotIndex,
        varietyIndex,
        x,
        y,
        isGolden,
        phase,
        dragX,
        dragY,
        homeX,
        homeY,
        glow,
        scale,
        snapProgress,
        bakeProgress,
        sparklePhase,
      ];
}

class TeddyEntity extends Equatable {
  const TeddyEntity({
    this.x = 0,
    this.y = 0,
    this.phase = TeddyPhase.idle,
    this.animPhase = 0,
    this.blinkTimer = 0,
    this.actionTimer = 0,
    this.headAngle = 0,
    this.excitedLevel = 0,
    this.eatProgress = 0,
    this.celebrateProgress = 0,
    this.idleAction = 0,
    this.targetCupcakeId,
    this.mouthOpen = 0,
    this.feedWasGolden = false,
  });

  final double x;
  final double y;
  final TeddyPhase phase;
  final double animPhase;
  final double blinkTimer;
  final double actionTimer;
  final double headAngle;
  final double excitedLevel;
  final double eatProgress;
  final double celebrateProgress;
  final int idleAction;
  final String? targetCupcakeId;
  final double mouthOpen;
  final bool feedWasGolden;

  TeddyEntity copyWith({
    double? x,
    double? y,
    TeddyPhase? phase,
    double? animPhase,
    double? blinkTimer,
    double? actionTimer,
    double? headAngle,
    double? excitedLevel,
    double? eatProgress,
    double? celebrateProgress,
    int? idleAction,
    String? targetCupcakeId,
    double? mouthOpen,
    bool? feedWasGolden,
    bool clearTarget = false,
  }) =>
      TeddyEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        animPhase: animPhase ?? this.animPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        actionTimer: actionTimer ?? this.actionTimer,
        headAngle: headAngle ?? this.headAngle,
        excitedLevel: excitedLevel ?? this.excitedLevel,
        eatProgress: eatProgress ?? this.eatProgress,
        celebrateProgress: celebrateProgress ?? this.celebrateProgress,
        idleAction: idleAction ?? this.idleAction,
        targetCupcakeId: clearTarget ? null : (targetCupcakeId ?? this.targetCupcakeId),
        mouthOpen: mouthOpen ?? this.mouthOpen,
        feedWasGolden: feedWasGolden ?? this.feedWasGolden,
      );

  @override
  List<Object?> get props => [
        x,
        y,
        phase,
        animPhase,
        blinkTimer,
        actionTimer,
        headAngle,
        excitedLevel,
        eatProgress,
        celebrateProgress,
        idleAction,
        targetCupcakeId,
        mouthOpen,
        feedWasGolden,
      ];
}

class PartyVisitorEntity extends Equatable {
  const PartyVisitorEntity({
    required this.id,
    required this.kind,
    required this.x,
    required this.y,
    this.phase = PartyVisitorPhase.active,
    this.progress = 0,
    this.wasTapped = false,
    this.reactProgress = 0,
  });

  final String id;
  final PartyVisitorKind kind;
  final double x;
  final double y;
  final PartyVisitorPhase phase;
  final double progress;
  final bool wasTapped;
  final double reactProgress;

  bool get canTap => phase == PartyVisitorPhase.active && !wasTapped;

  PartyVisitorEntity copyWith({
    double? x,
    double? y,
    PartyVisitorPhase? phase,
    double? progress,
    bool? wasTapped,
    double? reactProgress,
  }) =>
      PartyVisitorEntity(
        id: id,
        kind: kind,
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        wasTapped: wasTapped ?? this.wasTapped,
        reactProgress: reactProgress ?? this.reactProgress,
      );

  @override
  List<Object?> get props => [id, kind, x, y, phase, progress, wasTapped, reactProgress];
}

class PendingCupcakeRegrow extends Equatable {
  const PendingCupcakeRegrow({
    required this.slotIndex,
    required this.timer,
    this.isGolden = false,
  });

  final int slotIndex;
  final double timer;
  final bool isGolden;

  PendingCupcakeRegrow copyWith({double? timer}) =>
      PendingCupcakeRegrow(slotIndex: slotIndex, timer: timer ?? this.timer, isGolden: isGolden);

  @override
  List<Object?> get props => [slotIndex, timer, isGolden];
}

class HungryTeddyState extends Equatable {
  const HungryTeddyState({
    this.sessionPhase = HungryTeddySessionPhase.ready,
    this.settings = const HungryTeddySettings(),
    this.cupcakes = const [],
    this.teddy = const TeddyEntity(),
    this.visitors = const [],
    this.pendingRegrows = const [],
    this.draggingCupcakeId,
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.cupcakesFed = 0,
    this.goldenFed = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.favoriteFlavorIndex = 0,
    this.flavorCounts = const {},
    this.goldenDue = false,
    this.nextGoldenAt = 20,
    this.nextVisitorSpawnIn = 10.0,
    this.eveningFactor = 0,
    this.envPhase = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.showGoldenCelebration = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
    this.visitorsTapped = 0,
  });

  final HungryTeddySessionPhase sessionPhase;
  final HungryTeddySettings settings;
  final List<CupcakeEntity> cupcakes;
  final TeddyEntity teddy;
  final List<PartyVisitorEntity> visitors;
  final List<PendingCupcakeRegrow> pendingRegrows;
  final String? draggingCupcakeId;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int cupcakesFed;
  final int goldenFed;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final int favoriteFlavorIndex;
  final Map<int, int> flavorCounts;
  final bool goldenDue;
  final int nextGoldenAt;
  final double nextVisitorSpawnIn;
  final double eveningFactor;
  final double envPhase;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool showGoldenCelebration;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;
  final int visitorsTapped;

  bool get hasActiveAnimation =>
      cupcakes.any(
        (c) =>
            c.phase == CupcakePhase.dragging ||
            c.phase == CupcakePhase.snapping ||
            c.phase == CupcakePhase.baking,
      ) ||
      teddy.phase == TeddyPhase.receiving ||
      teddy.phase == TeddyPhase.eating ||
      teddy.phase == TeddyPhase.celebrating ||
      teddy.phase == TeddyPhase.goldenCelebration;

  HungryTeddyState copyWith({
    HungryTeddySessionPhase? sessionPhase,
    HungryTeddySettings? settings,
    List<CupcakeEntity>? cupcakes,
    TeddyEntity? teddy,
    List<PartyVisitorEntity>? visitors,
    List<PendingCupcakeRegrow>? pendingRegrows,
    String? draggingCupcakeId,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? cupcakesFed,
    int? goldenFed,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    int? favoriteFlavorIndex,
    Map<int, int>? flavorCounts,
    bool? goldenDue,
    int? nextGoldenAt,
    double? nextVisitorSpawnIn,
    double? eveningFactor,
    double? envPhase,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? showGoldenCelebration,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    int? visitorsTapped,
    bool clearFeedback = false,
    bool clearDrag = false,
  }) =>
      HungryTeddyState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        cupcakes: cupcakes ?? this.cupcakes,
        teddy: teddy ?? this.teddy,
        visitors: visitors ?? this.visitors,
        pendingRegrows: pendingRegrows ?? this.pendingRegrows,
        draggingCupcakeId:
            clearDrag ? null : (draggingCupcakeId ?? this.draggingCupcakeId),
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        cupcakesFed: cupcakesFed ?? this.cupcakesFed,
        goldenFed: goldenFed ?? this.goldenFed,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        favoriteFlavorIndex: favoriteFlavorIndex ?? this.favoriteFlavorIndex,
        flavorCounts: flavorCounts ?? this.flavorCounts,
        goldenDue: goldenDue ?? this.goldenDue,
        nextGoldenAt: nextGoldenAt ?? this.nextGoldenAt,
        nextVisitorSpawnIn: nextVisitorSpawnIn ?? this.nextVisitorSpawnIn,
        eveningFactor: eveningFactor ?? this.eveningFactor,
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
        visitorsTapped: visitorsTapped ?? this.visitorsTapped,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        cupcakes,
        teddy,
        visitors,
        pendingRegrows,
        draggingCupcakeId,
        remainingSeconds,
        elapsedSeconds,
        cupcakesFed,
        goldenFed,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        favoriteFlavorIndex,
        flavorCounts,
        goldenDue,
        nextGoldenAt,
        nextVisitorSpawnIn,
        eveningFactor,
        envPhase,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        showGoldenCelebration,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
        visitorsTapped,
      ];
}

class HungryTeddyResult extends Equatable {
  const HungryTeddyResult({
    required this.cupcakesFed,
    required this.goldenFed,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
    required this.favoriteFlavor,
  });

  final int cupcakesFed;
  final int goldenFed;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;
  final String favoriteFlavor;

  @override
  List<Object?> get props => [
        cupcakesFed,
        goldenFed,
        points,
        coins,
        xp,
        stars,
        longestStreak,
        sessionSeconds,
        favoriteFlavor,
      ];
}

const kHungryTeddySkills = [
  'Hand-Eye Coordination',
  'Drag & Drop',
  'Visual Tracking',
  'Object Recognition',
  'Fine Motor Skills',
  'Cause & Effect',
];

const kTeddyEncouragements = [
  'Great Job!',
  'The Teddy Loves Cupcakes!',
  'Yummy Cupcake!',
  'Let\'s Feed Another One!',
  'Wonderful!',
];

const kGoldenMessages = [
  'Golden Cupcake!',
  'Double Rewards!',
  'Amazing!',
];

const kPartyVisitorMessages = [
  'Hello, friend!',
  'What a fun party!',
  'Look at that!',
];
