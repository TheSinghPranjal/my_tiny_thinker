import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/flying_insects.dart';

enum FeedFrogSessionPhase { ready, playing, paused, finished }

enum InsectPhase { flying, selected, caught, entering, gone }

enum FrogFeedPhase { idle, tongueExtend, tongueRetract, chewing }

enum InsectFlightSpeed { verySlow, slow, normal, fast }

enum FeedFrogDifficulty { easy, normal, playful }

class FeedFrogSettings extends Equatable {
  const FeedFrogSettings({
    this.sessionSeconds = 60,
    this.insectCount = 5,
    this.flightSpeed = InsectFlightSpeed.slow,
    this.dayNightStartSeconds = 30,
    this.dayNightTransitionSeconds = 6,
    this.dayNightCycleSeconds = 60,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = FeedFrogDifficulty.easy,
  });

  final int sessionSeconds;
  final int insectCount;
  final InsectFlightSpeed flightSpeed;
  final int dayNightStartSeconds;
  final int dayNightTransitionSeconds;
  final int dayNightCycleSeconds;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final FeedFrogDifficulty difficulty;

  int get effectiveInsectCount => insectCount.clamp(4, 10);

  double get speedMult => switch (flightSpeed) {
        InsectFlightSpeed.verySlow => 0.55,
        InsectFlightSpeed.slow => 0.8,
        InsectFlightSpeed.normal => 1.0,
        InsectFlightSpeed.fast => 1.25,
      };

  FeedFrogSettings copyWith({
    int? sessionSeconds,
    int? insectCount,
    InsectFlightSpeed? flightSpeed,
    int? dayNightStartSeconds,
    int? dayNightTransitionSeconds,
    int? dayNightCycleSeconds,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    FeedFrogDifficulty? difficulty,
  }) =>
      FeedFrogSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        insectCount: insectCount ?? this.insectCount,
        flightSpeed: flightSpeed ?? this.flightSpeed,
        dayNightStartSeconds: dayNightStartSeconds ?? this.dayNightStartSeconds,
        dayNightTransitionSeconds:
            dayNightTransitionSeconds ?? this.dayNightTransitionSeconds,
        dayNightCycleSeconds: dayNightCycleSeconds ?? this.dayNightCycleSeconds,
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
        'insectCount': insectCount,
        'flightSpeed': flightSpeed.name,
        'dayNightStartSeconds': dayNightStartSeconds,
        'dayNightTransitionSeconds': dayNightTransitionSeconds,
        'dayNightCycleSeconds': dayNightCycleSeconds,
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

  factory FeedFrogSettings.fromJson(Map<String, dynamic> json) =>
      FeedFrogSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
        insectCount: (json['insectCount'] as int? ?? 5).clamp(4, 10),
        flightSpeed: InsectFlightSpeed.values.firstWhere(
          (s) => s.name == json['flightSpeed'],
          orElse: () => InsectFlightSpeed.slow,
        ),
        dayNightStartSeconds:
            (json['dayNightStartSeconds'] as int? ?? 30).clamp(15, 120),
        dayNightTransitionSeconds:
            (json['dayNightTransitionSeconds'] as int? ?? 6).clamp(3, 15),
        dayNightCycleSeconds:
            (json['dayNightCycleSeconds'] as int? ?? 60).clamp(40, 180),
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
        difficulty: FeedFrogDifficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => FeedFrogDifficulty.easy,
        ),
      );

  @override
  List<Object?> get props => [
        sessionSeconds,
        insectCount,
        flightSpeed,
        dayNightStartSeconds,
        dayNightTransitionSeconds,
        dayNightCycleSeconds,
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

class InsectEntity extends Equatable {
  const InsectEntity({
    required this.id,
    required this.kindIndex,
    required this.isFirefly,
    required this.pathSeed,
    this.phase = InsectPhase.flying,
    this.x = 0,
    this.y = 0,
    this.pathT = 0,
    this.wingPhase = 0,
    this.glowPhase = 0,
    this.highlight = 0,
    this.enterProgress = 0,
    this.enterFromX = 0,
    this.enterFromY = 0,
  });

  final String id;
  final int kindIndex;
  final bool isFirefly;
  final int pathSeed;
  final InsectPhase phase;
  final double x;
  final double y;
  final double pathT;
  final double wingPhase;
  final double glowPhase;
  final double highlight;
  final double enterProgress;
  final double enterFromX;
  final double enterFromY;

  InsectDef get def => isFirefly
      ? FlyingInsects.pickFirefly(kindIndex)
      : FlyingInsects.pickButterfly(kindIndex);

  bool get canTap => phase == InsectPhase.flying;

  InsectEntity copyWith({
    InsectPhase? phase,
    double? x,
    double? y,
    double? pathT,
    double? wingPhase,
    double? glowPhase,
    double? highlight,
    double? enterProgress,
    bool? isFirefly,
    int? kindIndex,
  }) =>
      InsectEntity(
        id: id,
        kindIndex: kindIndex ?? this.kindIndex,
        isFirefly: isFirefly ?? this.isFirefly,
        pathSeed: pathSeed,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        pathT: pathT ?? this.pathT,
        wingPhase: wingPhase ?? this.wingPhase,
        glowPhase: glowPhase ?? this.glowPhase,
        highlight: highlight ?? this.highlight,
        enterProgress: enterProgress ?? this.enterProgress,
        enterFromX: enterFromX,
        enterFromY: enterFromY,
      );

  @override
  List<Object?> get props => [
        id,
        kindIndex,
        isFirefly,
        pathSeed,
        phase,
        x,
        y,
        pathT,
        wingPhase,
        glowPhase,
        highlight,
        enterProgress,
        enterFromX,
        enterFromY,
      ];
}

class FeedFrogState extends Equatable {
  const FeedFrogState({
    this.sessionPhase = FeedFrogSessionPhase.ready,
    this.settings = const FeedFrogSettings(),
    this.insects = const [],
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.nightFactor = 0,
    this.frogPhase = FrogFeedPhase.idle,
    this.frogAnimPhase = 0,
    this.frogBlinkTimer = 0,
    this.tongueProgress = 0,
    this.targetInsectId,
    this.tongueTipX = 0,
    this.tongueTipY = 0,
    this.frogX = 0,
    this.frogY = 0,
    this.insectsEaten = 0,
    this.firefliesCaught = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
    this.favoriteKind = InsectKind.butterfly,
  });

  final FeedFrogSessionPhase sessionPhase;
  final FeedFrogSettings settings;
  final List<InsectEntity> insects;
  final int remainingSeconds;
  final int elapsedSeconds;
  final double nightFactor;
  final FrogFeedPhase frogPhase;
  final double frogAnimPhase;
  final double frogBlinkTimer;
  final double tongueProgress;
  final String? targetInsectId;
  final double tongueTipX;
  final double tongueTipY;
  final double frogX;
  final double frogY;
  final int insectsEaten;
  final int firefliesCaught;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;
  final InsectKind favoriteKind;

  bool get isFeeding =>
      frogPhase == FrogFeedPhase.tongueExtend ||
      frogPhase == FrogFeedPhase.tongueRetract ||
      frogPhase == FrogFeedPhase.chewing;

  FeedFrogState copyWith({
    FeedFrogSessionPhase? sessionPhase,
    FeedFrogSettings? settings,
    List<InsectEntity>? insects,
    int? remainingSeconds,
    int? elapsedSeconds,
    double? nightFactor,
    FrogFeedPhase? frogPhase,
    double? frogAnimPhase,
    double? frogBlinkTimer,
    double? tongueProgress,
    String? targetInsectId,
    bool clearTarget = false,
    double? tongueTipX,
    double? tongueTipY,
    double? frogX,
    double? frogY,
    int? insectsEaten,
    int? firefliesCaught,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    InsectKind? favoriteKind,
    bool clearFeedback = false,
  }) =>
      FeedFrogState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        insects: insects ?? this.insects,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        nightFactor: nightFactor ?? this.nightFactor,
        frogPhase: frogPhase ?? this.frogPhase,
        frogAnimPhase: frogAnimPhase ?? this.frogAnimPhase,
        frogBlinkTimer: frogBlinkTimer ?? this.frogBlinkTimer,
        tongueProgress: tongueProgress ?? this.tongueProgress,
        targetInsectId:
            clearTarget ? null : (targetInsectId ?? this.targetInsectId),
        tongueTipX: tongueTipX ?? this.tongueTipX,
        tongueTipY: tongueTipY ?? this.tongueTipY,
        frogX: frogX ?? this.frogX,
        frogY: frogY ?? this.frogY,
        insectsEaten: insectsEaten ?? this.insectsEaten,
        firefliesCaught: firefliesCaught ?? this.firefliesCaught,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        inactivityTimer: inactivityTimer ?? this.inactivityTimer,
        favoriteKind: favoriteKind ?? this.favoriteKind,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        insects,
        remainingSeconds,
        elapsedSeconds,
        nightFactor,
        frogPhase,
        frogAnimPhase,
        frogBlinkTimer,
        tongueProgress,
        targetInsectId,
        tongueTipX,
        tongueTipY,
        frogX,
        frogY,
        insectsEaten,
        firefliesCaught,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
        favoriteKind,
      ];
}

class FeedFrogResult extends Equatable {
  const FeedFrogResult({
    required this.insectsEaten,
    required this.firefliesCaught,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
    required this.favoriteKind,
  });

  final int insectsEaten;
  final int firefliesCaught;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;
  final InsectKind favoriteKind;

  @override
  List<Object?> get props => [
        insectsEaten,
        firefliesCaught,
        points,
        coins,
        xp,
        stars,
        longestStreak,
        sessionSeconds,
        favoriteKind,
      ];
}

const kFeedFrogSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Touch Accuracy',
  'Reaction Timing',
  'Cause & Effect',
  'Attention',
];

const kFeedEncouragements = [
  'Yummy!',
  'Great Job!',
  'The Frog is Happy!',
  'Let\'s Catch Another Butterfly!',
  'Wonderful!',
];
