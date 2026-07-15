import 'package:equatable/equatable.dart';

enum HungryMonkeySessionPhase { ready, playing, paused, finished }

enum BananaPhase { onTree, tapped, falling, growing, gone }

enum ApplePhase { appearing, visible, wobble, fading, gone }

enum MonkeyPhase { idle, reaching, catching, eating, sad, clapping }

enum HungryMonkeyDifficulty { easy, normal, playful }

class HungryMonkeySettings extends Equatable {
  const HungryMonkeySettings({
    this.sessionSeconds = 60,
    this.bananaCount = 7,
    this.appleSpawnMin = 4.0,
    this.appleSpawnMax = 7.0,
    this.maxApples = 3,
    this.bananaRegrowDelay = 1.0,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = HungryMonkeyDifficulty.easy,
  });

  final int sessionSeconds;
  final int bananaCount;
  final double appleSpawnMin;
  final double appleSpawnMax;
  final int maxApples;
  final double bananaRegrowDelay;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final HungryMonkeyDifficulty difficulty;

  int get effectiveBananaCount => bananaCount.clamp(5, 10);

  HungryMonkeySettings copyWith({
    int? sessionSeconds,
    int? bananaCount,
    double? appleSpawnMin,
    double? appleSpawnMax,
    int? maxApples,
    double? bananaRegrowDelay,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    HungryMonkeyDifficulty? difficulty,
  }) =>
      HungryMonkeySettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        bananaCount: bananaCount ?? this.bananaCount,
        appleSpawnMin: appleSpawnMin ?? this.appleSpawnMin,
        appleSpawnMax: appleSpawnMax ?? this.appleSpawnMax,
        maxApples: maxApples ?? this.maxApples,
        bananaRegrowDelay: bananaRegrowDelay ?? this.bananaRegrowDelay,
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
        'bananaCount': bananaCount,
        'appleSpawnMin': appleSpawnMin,
        'appleSpawnMax': appleSpawnMax,
        'maxApples': maxApples,
        'bananaRegrowDelay': bananaRegrowDelay,
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

  factory HungryMonkeySettings.fromJson(Map<String, dynamic> json) {
    var spawnMin =
        (json['appleSpawnMin'] as num? ?? 4.0).toDouble().clamp(2.0, 12.0);
    var spawnMax =
        (json['appleSpawnMax'] as num? ?? 7.0).toDouble().clamp(3.0, 15.0);
    if (spawnMin > spawnMax) {
      final swap = spawnMin;
      spawnMin = spawnMax;
      spawnMax = swap;
    }
    return HungryMonkeySettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      bananaCount: (json['bananaCount'] as int? ?? 7).clamp(5, 10),
      appleSpawnMin: spawnMin,
      appleSpawnMax: spawnMax,
      maxApples: (json['maxApples'] as int? ?? 3).clamp(0, 4),
      bananaRegrowDelay:
          (json['bananaRegrowDelay'] as num? ?? 1.0).toDouble().clamp(0.5, 3.0),
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
      difficulty: HungryMonkeyDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => HungryMonkeyDifficulty.easy,
      ),
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        bananaCount,
        appleSpawnMin,
        appleSpawnMax,
        maxApples,
        bananaRegrowDelay,
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

class BananaEntity extends Equatable {
  const BananaEntity({
    required this.id,
    required this.slotIndex,
    required this.x,
    required this.y,
    this.phase = BananaPhase.onTree,
    this.sizeScale = 1.0,
    this.rotation = 0,
    this.glow = 0,
    this.tapProgress = 0,
    this.fallProgress = 0,
    this.growProgress = 0,
    this.fallStartX = 0,
    this.fallStartY = 0,
  });

  final String id;
  final int slotIndex;
  final double x;
  final double y;
  final BananaPhase phase;
  final double sizeScale;
  final double rotation;
  final double glow;
  final double tapProgress;
  final double fallProgress;
  final double growProgress;
  final double fallStartX;
  final double fallStartY;

  bool get canTap => phase == BananaPhase.onTree;

  BananaEntity copyWith({
    BananaPhase? phase,
    double? x,
    double? y,
    double? sizeScale,
    double? rotation,
    double? glow,
    double? tapProgress,
    double? fallProgress,
    double? growProgress,
    double? fallStartX,
    double? fallStartY,
  }) =>
      BananaEntity(
        id: id,
        slotIndex: slotIndex,
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        sizeScale: sizeScale ?? this.sizeScale,
        rotation: rotation ?? this.rotation,
        glow: glow ?? this.glow,
        tapProgress: tapProgress ?? this.tapProgress,
        fallProgress: fallProgress ?? this.fallProgress,
        growProgress: growProgress ?? this.growProgress,
        fallStartX: fallStartX ?? this.fallStartX,
        fallStartY: fallStartY ?? this.fallStartY,
      );

  @override
  List<Object?> get props => [
        id,
        slotIndex,
        x,
        y,
        phase,
        sizeScale,
        rotation,
        glow,
        tapProgress,
        fallProgress,
        growProgress,
        fallStartX,
        fallStartY,
      ];
}

class AppleEntity extends Equatable {
  const AppleEntity({
    required this.id,
    required this.x,
    required this.y,
    this.phase = ApplePhase.appearing,
    this.lifetime = 3.0,
    this.wobblePhase = 0,
    this.bounceProgress = 0,
    this.fadeProgress = 0,
    this.wasTapped = false,
  });

  final String id;
  final double x;
  final double y;
  final ApplePhase phase;
  final double lifetime;
  final double wobblePhase;
  final double bounceProgress;
  final double fadeProgress;
  final bool wasTapped;

  bool get canTap =>
      phase == ApplePhase.visible ||
      phase == ApplePhase.wobble ||
      phase == ApplePhase.appearing;

  AppleEntity copyWith({
    ApplePhase? phase,
    double? lifetime,
    double? wobblePhase,
    double? bounceProgress,
    double? fadeProgress,
    bool? wasTapped,
  }) =>
      AppleEntity(
        id: id,
        x: x,
        y: y,
        phase: phase ?? this.phase,
        lifetime: lifetime ?? this.lifetime,
        wobblePhase: wobblePhase ?? this.wobblePhase,
        bounceProgress: bounceProgress ?? this.bounceProgress,
        fadeProgress: fadeProgress ?? this.fadeProgress,
        wasTapped: wasTapped ?? this.wasTapped,
      );

  @override
  List<Object?> get props =>
      [id, x, y, phase, lifetime, wobblePhase, bounceProgress, fadeProgress, wasTapped];
}

class MonkeyEntity extends Equatable {
  const MonkeyEntity({
    this.x = 0,
    this.y = 0,
    this.phase = MonkeyPhase.idle,
    this.animPhase = 0,
    this.blinkTimer = 0,
    this.actionTimer = 0,
    this.reachProgress = 0,
    this.eatProgress = 0,
    this.sadProgress = 0,
    this.headShake = 0,
    this.earDroop = 0,
    this.idleAction = 0,
    this.tailWag = 0,
  });

  final double x;
  final double y;
  final MonkeyPhase phase;
  final double animPhase;
  final double blinkTimer;
  final double actionTimer;
  final double reachProgress;
  final double eatProgress;
  final double sadProgress;
  final double headShake;
  final double earDroop;
  final int idleAction;
  final double tailWag;

  MonkeyEntity copyWith({
    double? x,
    double? y,
    MonkeyPhase? phase,
    double? animPhase,
    double? blinkTimer,
    double? actionTimer,
    double? reachProgress,
    double? eatProgress,
    double? sadProgress,
    double? headShake,
    double? earDroop,
    int? idleAction,
    double? tailWag,
  }) =>
      MonkeyEntity(
        x: x ?? this.x,
        y: y ?? this.y,
        phase: phase ?? this.phase,
        animPhase: animPhase ?? this.animPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        actionTimer: actionTimer ?? this.actionTimer,
        reachProgress: reachProgress ?? this.reachProgress,
        eatProgress: eatProgress ?? this.eatProgress,
        sadProgress: sadProgress ?? this.sadProgress,
        headShake: headShake ?? this.headShake,
        earDroop: earDroop ?? this.earDroop,
        idleAction: idleAction ?? this.idleAction,
        tailWag: tailWag ?? this.tailWag,
      );

  @override
  List<Object?> get props => [
        x,
        y,
        phase,
        animPhase,
        blinkTimer,
        actionTimer,
        reachProgress,
        eatProgress,
        sadProgress,
        headShake,
        earDroop,
        idleAction,
        tailWag,
      ];
}

class PendingBananaRegrow extends Equatable {
  const PendingBananaRegrow({required this.slotIndex, required this.timer});

  final int slotIndex;
  final double timer;

  PendingBananaRegrow copyWith({double? timer}) =>
      PendingBananaRegrow(slotIndex: slotIndex, timer: timer ?? this.timer);

  @override
  List<Object?> get props => [slotIndex, timer];
}

class HungryMonkeyState extends Equatable {
  const HungryMonkeyState({
    this.sessionPhase = HungryMonkeySessionPhase.ready,
    this.settings = const HungryMonkeySettings(),
    this.bananas = const [],
    this.apples = const [],
    this.monkey = const MonkeyEntity(),
    this.pendingRegrows = const [],
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.bananasFed = 0,
    this.applesTapped = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.nextAppleSpawnIn = 5.0,
    this.envPhase = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
  });

  final HungryMonkeySessionPhase sessionPhase;
  final HungryMonkeySettings settings;
  final List<BananaEntity> bananas;
  final List<AppleEntity> apples;
  final MonkeyEntity monkey;
  final List<PendingBananaRegrow> pendingRegrows;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int bananasFed;
  final int applesTapped;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final double nextAppleSpawnIn;
  final double envPhase;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;

  bool get hasActiveAnimation =>
      bananas.any(
        (b) =>
            b.phase == BananaPhase.tapped ||
            b.phase == BananaPhase.falling ||
            b.phase == BananaPhase.growing,
      ) ||
      monkey.phase == MonkeyPhase.reaching ||
      monkey.phase == MonkeyPhase.catching ||
      monkey.phase == MonkeyPhase.eating ||
      monkey.phase == MonkeyPhase.clapping;

  HungryMonkeyState copyWith({
    HungryMonkeySessionPhase? sessionPhase,
    HungryMonkeySettings? settings,
    List<BananaEntity>? bananas,
    List<AppleEntity>? apples,
    MonkeyEntity? monkey,
    List<PendingBananaRegrow>? pendingRegrows,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? bananasFed,
    int? applesTapped,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    double? nextAppleSpawnIn,
    double? envPhase,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    bool clearFeedback = false,
  }) =>
      HungryMonkeyState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        bananas: bananas ?? this.bananas,
        apples: apples ?? this.apples,
        monkey: monkey ?? this.monkey,
        pendingRegrows: pendingRegrows ?? this.pendingRegrows,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        bananasFed: bananasFed ?? this.bananasFed,
        applesTapped: applesTapped ?? this.applesTapped,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        nextAppleSpawnIn: nextAppleSpawnIn ?? this.nextAppleSpawnIn,
        envPhase: envPhase ?? this.envPhase,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        inactivityTimer: inactivityTimer ?? this.inactivityTimer,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        bananas,
        apples,
        monkey,
        pendingRegrows,
        remainingSeconds,
        elapsedSeconds,
        bananasFed,
        applesTapped,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        nextAppleSpawnIn,
        envPhase,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
      ];
}

class HungryMonkeyResult extends Equatable {
  const HungryMonkeyResult({
    required this.bananasFed,
    required this.applesTapped,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
  });

  final int bananasFed;
  final int applesTapped;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;

  @override
  List<Object?> get props =>
      [bananasFed, applesTapped, points, coins, xp, stars, longestStreak, sessionSeconds];
}

const kHungryMonkeySkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Object Recognition',
  'Cause & Effect',
  'Touch Accuracy',
  'Attention',
];

const kBananaEncouragements = [
  'Yummy Banana!',
  'Monkey Loves Bananas!',
  'Great Job!',
  'Let\'s Feed More Bananas!',
  'The Monkey is Happy!',
];

const kAppleMessages = [
  'Oops! Monkey likes bananas!',
  'Let\'s Find a Banana!',
  'Try a Banana Instead!',
];
