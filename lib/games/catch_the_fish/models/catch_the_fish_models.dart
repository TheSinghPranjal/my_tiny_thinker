import 'package:equatable/equatable.dart';

enum CatchFishSessionPhase { ready, playing, paused, finished }

enum CatchFishPhase { swimming, reeling, gone }

class CatchFishSettings extends Equatable {
  const CatchFishSettings({
    this.sessionSeconds = 60,
    this.fishCount = 5,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = false,
  });

  final int sessionSeconds;
  final int fishCount;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  int get effectiveFishCount => fishCount.clamp(5, 10);

  CatchFishSettings copyWith({
    int? sessionSeconds,
    int? fishCount,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      CatchFishSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        fishCount: fishCount ?? this.fishCount,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationIntensity: animationIntensity ?? this.animationIntensity,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'fishCount': fishCount,
        'rewardMultiplier': rewardMultiplier,
        'animationIntensity': animationIntensity,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory CatchFishSettings.fromJson(Map<String, dynamic> json) {
    return CatchFishSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      fishCount: (json['fishCount'] as int? ?? 5).clamp(5, 10),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationIntensity:
          (json['animationIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        fishCount,
        rewardMultiplier,
        animationIntensity,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class CatchFishEntity extends Equatable {
  const CatchFishEntity({
    required this.id,
    required this.varietyIndex,
    required this.x,
    required this.y,
    required this.lane,
    this.facingRight = true,
    this.phase = CatchFishPhase.swimming,
    this.pathT = 0,
    this.depth = 0.5,
    this.catchProgress = 0,
    this.catchStartX = 0,
    this.catchStartY = 0,
    this.glow = 0,
  });

  final String id;
  final int varietyIndex;
  final double x;
  final double y;
  final int lane;
  final bool facingRight;
  final CatchFishPhase phase;
  final double pathT;
  final double depth;
  final double catchProgress;
  final double catchStartX;
  final double catchStartY;
  final double glow;

  bool get canTap => phase == CatchFishPhase.swimming;

  CatchFishEntity copyWith({
    double? x,
    double? y,
    int? lane,
    bool? facingRight,
    CatchFishPhase? phase,
    double? pathT,
    double? depth,
    double? catchProgress,
    double? catchStartX,
    double? catchStartY,
    double? glow,
    int? varietyIndex,
  }) =>
      CatchFishEntity(
        id: id,
        varietyIndex: varietyIndex ?? this.varietyIndex,
        x: x ?? this.x,
        y: y ?? this.y,
        lane: lane ?? this.lane,
        facingRight: facingRight ?? this.facingRight,
        phase: phase ?? this.phase,
        pathT: pathT ?? this.pathT,
        depth: depth ?? this.depth,
        catchProgress: catchProgress ?? this.catchProgress,
        catchStartX: catchStartX ?? this.catchStartX,
        catchStartY: catchStartY ?? this.catchStartY,
        glow: glow ?? this.glow,
      );

  @override
  List<Object?> get props => [
        id,
        varietyIndex,
        x,
        y,
        lane,
        facingRight,
        phase,
        pathT,
        depth,
        catchProgress,
        catchStartX,
        catchStartY,
        glow,
      ];
}

class CatchTheFishState extends Equatable {
  const CatchTheFishState({
    this.sessionPhase = CatchFishSessionPhase.ready,
    this.settings = const CatchFishSettings(),
    this.fish = const [],
    this.remainingSeconds = 60,
    this.fishCaught = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.boatX = 0,
    this.boatY = 0,
    this.hookProgress = 0,
    this.hookTargetFishId,
    this.feedbackMessage,
    this.lastRewardText,
    this.showSparkles = false,
    this.showCelebration = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.endReason,
    this.envPhase = 0,
  });

  final CatchFishSessionPhase sessionPhase;
  final CatchFishSettings settings;
  final List<CatchFishEntity> fish;
  final int remainingSeconds;
  final int fishCaught;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final double boatX;
  final double boatY;
  final double hookProgress;
  final String? hookTargetFishId;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showSparkles;
  final bool showCelebration;
  final bool playAreaReady;
  final bool pendingEnd;
  final String? endReason;
  final double envPhase;

  bool get hasActiveReeling =>
      fish.any((f) => f.phase == CatchFishPhase.reeling) || hookProgress > 0;

  CatchTheFishState copyWith({
    CatchFishSessionPhase? sessionPhase,
    CatchFishSettings? settings,
    List<CatchFishEntity>? fish,
    int? remainingSeconds,
    int? fishCaught,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    double? boatX,
    double? boatY,
    double? hookProgress,
    String? hookTargetFishId,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showSparkles,
    bool? showCelebration,
    bool? playAreaReady,
    bool? pendingEnd,
    String? endReason,
    double? envPhase,
    bool clearFeedback = false,
    bool clearHookTarget = false,
  }) =>
      CatchTheFishState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        fish: fish ?? this.fish,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        fishCaught: fishCaught ?? this.fishCaught,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        boatX: boatX ?? this.boatX,
        boatY: boatY ?? this.boatY,
        hookProgress: hookProgress ?? this.hookProgress,
        hookTargetFishId: clearHookTarget
            ? null
            : (hookTargetFishId ?? this.hookTargetFishId),
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showSparkles: showSparkles ?? this.showSparkles,
        showCelebration: showCelebration ?? this.showCelebration,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        endReason: endReason ?? this.endReason,
        envPhase: envPhase ?? this.envPhase,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        fish,
        remainingSeconds,
        fishCaught,
        coinsEarned,
        xpEarned,
        starsEarned,
        boatX,
        boatY,
        hookProgress,
        hookTargetFishId,
        feedbackMessage,
        lastRewardText,
        showSparkles,
        showCelebration,
        playAreaReady,
        pendingEnd,
        endReason,
        envPhase,
      ];
}

class CatchTheFishResult extends Equatable {
  const CatchTheFishResult({
    required this.fishCaught,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    this.endReason,
  });

  final int fishCaught;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;
  final String? endReason;

  @override
  List<Object?> get props =>
      [fishCaught, coins, xp, stars, sessionSeconds, endReason];
}

const kCatchTheFishSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Reaction Timing',
  'Attention',
  'Cause & Effect',
  'Fine Motor Skills',
];

const kCatchEncouragements = [
  'Great Job!',
  'Awesome!',
  'You caught a fish!',
  'Wonderful!',
  'Fantastic!',
  'Amazing Catch!',
];

const kCatchEndMessages = [
  'Amazing Fishing!',
  "You're a Super Fisher!",
  'Wonderful Catch!',
];
