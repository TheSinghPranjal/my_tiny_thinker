import 'package:equatable/equatable.dart';

enum WebMatchSessionPhase { ready, playing, paused, finished }

enum WebButterflyPhase {
  entering,
  fluttering,
  flyingToWeb,
  onWeb,
  mismatchRelease,
  matchedDance,
  flyingAway,
  gone,
}

enum ButterflyAccessory {
  none,
  crown,
  flowerGarland,
  bow,
  heart,
  star,
  ribbon,
}

class ButterflyWebMatchingSettings extends Equatable {
  const ButterflyWebMatchingSettings({
    this.sessionSeconds = 60,
    this.practiceMode = false,
    this.pairCount = 3,
    this.floatingAnimation = true,
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
  final int pairCount;
  final bool floatingAnimation;
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

  int get effectivePairCount => pairCount.clamp(3, 5);
  int get butterflyCount => effectivePairCount * 2;

  ButterflyWebMatchingSettings copyWith({
    int? sessionSeconds,
    bool? practiceMode,
    int? pairCount,
    bool? floatingAnimation,
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
      ButterflyWebMatchingSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        practiceMode: practiceMode ?? this.practiceMode,
        pairCount: pairCount ?? this.pairCount,
        floatingAnimation: floatingAnimation ?? this.floatingAnimation,
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
        'pairCount': pairCount,
        'floatingAnimation': floatingAnimation,
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

  factory ButterflyWebMatchingSettings.fromJson(Map<String, dynamic> json) {
    return ButterflyWebMatchingSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      practiceMode: json['practiceMode'] as bool? ?? false,
      pairCount: (json['pairCount'] as int? ?? 3).clamp(3, 5),
      floatingAnimation: json['floatingAnimation'] as bool? ?? true,
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
        pairCount,
        floatingAnimation,
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

class WebButterflyEntity extends Equatable {
  const WebButterflyEntity({
    required this.id,
    required this.pairId,
    required this.varietyIndex,
    required this.pathSeed,
    required this.x,
    required this.y,
    this.accessory = ButterflyAccessory.none,
    this.isGolden = false,
    this.phase = WebButterflyPhase.entering,
    this.pathT = 0,
    this.wingPhase = 0,
    this.hoverPhase = 0,
    this.animProgress = 0,
    this.webOpacity = 0,
    this.glow = 0,
    this.webX = 0,
    this.webY = 0,
    this.enterFromX = 0,
    this.enterFromY = 0,
    this.enterTargetX = 0,
    this.enterTargetY = 0,
    this.danceCenterX = 0,
    this.danceCenterY = 0,
  });

  final String id;
  final int pairId;
  final int varietyIndex;
  final int pathSeed;
  final double x;
  final double y;
  final ButterflyAccessory accessory;
  final bool isGolden;
  final WebButterflyPhase phase;
  final double pathT;
  final double wingPhase;
  final double hoverPhase;
  final double animProgress;
  final double webOpacity;
  final double glow;
  /// Where the web holds this butterfly when selected.
  final double webX;
  final double webY;
  final double enterFromX;
  final double enterFromY;
  final double enterTargetX;
  final double enterTargetY;
  final double danceCenterX;
  final double danceCenterY;

  bool get canTap =>
      phase == WebButterflyPhase.fluttering ||
      phase == WebButterflyPhase.entering ||
      phase == WebButterflyPhase.onWeb;

  bool get isActive => phase != WebButterflyPhase.gone;

  WebButterflyEntity copyWith({
    double? x,
    double? y,
    ButterflyAccessory? accessory,
    bool? isGolden,
    WebButterflyPhase? phase,
    double? pathT,
    double? wingPhase,
    double? hoverPhase,
    double? animProgress,
    double? webOpacity,
    double? glow,
    double? webX,
    double? webY,
    double? enterFromX,
    double? enterFromY,
    double? enterTargetX,
    double? enterTargetY,
    double? danceCenterX,
    double? danceCenterY,
  }) =>
      WebButterflyEntity(
        id: id,
        pairId: pairId,
        varietyIndex: varietyIndex,
        pathSeed: pathSeed,
        x: x ?? this.x,
        y: y ?? this.y,
        accessory: accessory ?? this.accessory,
        isGolden: isGolden ?? this.isGolden,
        phase: phase ?? this.phase,
        pathT: pathT ?? this.pathT,
        wingPhase: wingPhase ?? this.wingPhase,
        hoverPhase: hoverPhase ?? this.hoverPhase,
        animProgress: animProgress ?? this.animProgress,
        webOpacity: webOpacity ?? this.webOpacity,
        glow: glow ?? this.glow,
        webX: webX ?? this.webX,
        webY: webY ?? this.webY,
        enterFromX: enterFromX ?? this.enterFromX,
        enterFromY: enterFromY ?? this.enterFromY,
        enterTargetX: enterTargetX ?? this.enterTargetX,
        enterTargetY: enterTargetY ?? this.enterTargetY,
        danceCenterX: danceCenterX ?? this.danceCenterX,
        danceCenterY: danceCenterY ?? this.danceCenterY,
      );

  @override
  List<Object?> get props => [
        id,
        pairId,
        varietyIndex,
        pathSeed,
        x,
        y,
        accessory,
        isGolden,
        phase,
        pathT,
        wingPhase,
        hoverPhase,
        animProgress,
        webOpacity,
        glow,
        webX,
        webY,
        enterFromX,
        enterFromY,
        enterTargetX,
        enterTargetY,
        danceCenterX,
        danceCenterY,
      ];
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

class ButterflyWebMatchingState extends Equatable {
  const ButterflyWebMatchingState({
    this.sessionPhase = WebMatchSessionPhase.ready,
    this.settings = const ButterflyWebMatchingSettings(),
    this.butterflies = const [],
    this.selectedId,
    this.sparkles = const [],
    this.remainingSeconds = 60,
    this.pairsMatched = 0,
    this.boardsCleared = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.rewardPoints = 0,
    this.rainbowTokens = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.gardenBloom = 0,
    this.envPhase = 0,
    this.inputLocked = false,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.showRainbow = false,
  });

  final WebMatchSessionPhase sessionPhase;
  final ButterflyWebMatchingSettings settings;
  final List<WebButterflyEntity> butterflies;
  final String? selectedId;
  final List<TapSparkle> sparkles;
  final int remainingSeconds;
  final int pairsMatched;
  final int boardsCleared;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int rewardPoints;
  final int rainbowTokens;
  final int currentStreak;
  final int longestStreak;
  final double gardenBloom;
  final double envPhase;
  final bool inputLocked;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool showRainbow;

  int get remainingPairs =>
      butterflies.where((b) => b.isActive).map((b) => b.pairId).toSet().length;

  ButterflyWebMatchingState copyWith({
    WebMatchSessionPhase? sessionPhase,
    ButterflyWebMatchingSettings? settings,
    List<WebButterflyEntity>? butterflies,
    String? selectedId,
    List<TapSparkle>? sparkles,
    int? remainingSeconds,
    int? pairsMatched,
    int? boardsCleared,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? rewardPoints,
    int? rainbowTokens,
    int? currentStreak,
    int? longestStreak,
    double? gardenBloom,
    double? envPhase,
    bool? inputLocked,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? showRainbow,
    bool clearSelected = false,
    bool clearFeedback = false,
  }) =>
      ButterflyWebMatchingState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        butterflies: butterflies ?? this.butterflies,
        selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
        sparkles: sparkles ?? this.sparkles,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        pairsMatched: pairsMatched ?? this.pairsMatched,
        boardsCleared: boardsCleared ?? this.boardsCleared,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        rainbowTokens: rainbowTokens ?? this.rainbowTokens,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        gardenBloom: gardenBloom ?? this.gardenBloom,
        envPhase: envPhase ?? this.envPhase,
        inputLocked: inputLocked ?? this.inputLocked,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: clearFeedback ? false : (showMascot ?? this.showMascot),
        showSparkles: showSparkles ?? this.showSparkles,
        playAreaReady: playAreaReady ?? this.playAreaReady,
        showRainbow: showRainbow ?? this.showRainbow,
      );

  @override
  List<Object?> get props => [
        sessionPhase,
        settings,
        butterflies,
        selectedId,
        sparkles,
        remainingSeconds,
        pairsMatched,
        boardsCleared,
        coinsEarned,
        xpEarned,
        starsEarned,
        rewardPoints,
        rainbowTokens,
        currentStreak,
        longestStreak,
        gardenBloom,
        envPhase,
        inputLocked,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
        showRainbow,
      ];
}

class ButterflyWebMatchingResult extends Equatable {
  const ButterflyWebMatchingResult({
    required this.pairsMatched,
    required this.coins,
    required this.stars,
    required this.xp,
    required this.rewardPoints,
    required this.rainbowTokens,
    required this.longestStreak,
    required this.boardsCleared,
    required this.sessionSeconds,
    required this.encouragement,
  });

  final int pairsMatched;
  final int coins;
  final int stars;
  final int xp;
  final int rewardPoints;
  final int rainbowTokens;
  final int longestStreak;
  final int boardsCleared;
  final int sessionSeconds;
  final String encouragement;

  @override
  List<Object?> get props => [
        pairsMatched,
        coins,
        stars,
        xp,
        rewardPoints,
        rainbowTokens,
        longestStreak,
        boardsCleared,
        sessionSeconds,
        encouragement,
      ];
}

const kButterflyWebSkills = [
  'Visual Memory',
  'Concentration',
  'Observation',
  'Matching Ability',
  'Attention Span',
  'Pattern Recognition',
  'Hand-Eye Coordination',
];

const kButterflyWebEncouragements = [
  'Great Match!',
  'Wonderful!',
  'Amazing!',
  'Fantastic!',
  'Excellent!',
  'Beautiful Butterfly!',
  'Perfect Pair!',
  'You Found It!',
  'Great Job!',
  'Keep Going!',
  "You're Amazing!",
  'Butterfly Friends!',
  'Super Matching!',
  'Wonderful Memory!',
];

const kButterflyWebEndMessages = [
  "You're a Butterfly Friend!",
  'Amazing Memory!',
  'Fantastic Matching!',
  'Wonderful Explorer!',
  'Beautiful Garden Builder!',
  'Great Observation!',
  'Keep Learning!',
  "You're Getting Better Every Time!",
  'Magical Job!',
  "Let's Match More Butterflies!",
];
