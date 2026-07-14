import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/frog_varieties.dart';

enum FrogPondSessionPhase { ready, playing, paused, finished }

enum FrogPhase { idle, reacting, jumping, entering, gone }

enum PadState { occupied, empty, waiting }

enum FrogMoveSpeed { verySlow, slow, normal }

enum FrogPondDifficulty { easy, normal, playful }

class FrogPondSettings extends Equatable {
  const FrogPondSettings({
    this.sessionSeconds = 60,
    this.lilyPadCount = 2,
    this.frogMoveSpeed = FrogMoveSpeed.slow,
    this.replacementDelayMin = 2.0,
    this.replacementDelayMax = 5.0,
    this.kingFrogInterval = 15,
    this.kingFrogEnabled = true,
    this.rewardMultiplier = 1.0,
    this.animationIntensity = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.highContrast = false,
    this.largerTouchTargets = false,
    this.difficulty = FrogPondDifficulty.easy,
  });

  final int sessionSeconds;
  final int lilyPadCount;
  final FrogMoveSpeed frogMoveSpeed;
  final double replacementDelayMin;
  final double replacementDelayMax;
  final int kingFrogInterval;
  final bool kingFrogEnabled;
  final double rewardMultiplier;
  final double animationIntensity;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool highContrast;
  final bool largerTouchTargets;
  final FrogPondDifficulty difficulty;

  int get effectivePadCount => lilyPadCount.clamp(2, 8);

  double get moveSpeedMult => switch (frogMoveSpeed) {
        FrogMoveSpeed.verySlow => 0.7,
        FrogMoveSpeed.slow => 1.0,
        FrogMoveSpeed.normal => 1.25,
      };

  FrogPondSettings copyWith({
    int? sessionSeconds,
    int? lilyPadCount,
    FrogMoveSpeed? frogMoveSpeed,
    double? replacementDelayMin,
    double? replacementDelayMax,
    int? kingFrogInterval,
    bool? kingFrogEnabled,
    double? rewardMultiplier,
    double? animationIntensity,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? highContrast,
    bool? largerTouchTargets,
    FrogPondDifficulty? difficulty,
  }) =>
      FrogPondSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        lilyPadCount: lilyPadCount ?? this.lilyPadCount,
        frogMoveSpeed: frogMoveSpeed ?? this.frogMoveSpeed,
        replacementDelayMin: replacementDelayMin ?? this.replacementDelayMin,
        replacementDelayMax: replacementDelayMax ?? this.replacementDelayMax,
        kingFrogInterval: kingFrogInterval ?? this.kingFrogInterval,
        kingFrogEnabled: kingFrogEnabled ?? this.kingFrogEnabled,
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
        'frogMoveSpeed': frogMoveSpeed.name,
        'replacementDelayMin': replacementDelayMin,
        'replacementDelayMax': replacementDelayMax,
        'kingFrogInterval': kingFrogInterval,
        'kingFrogEnabled': kingFrogEnabled,
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

  factory FrogPondSettings.fromJson(Map<String, dynamic> json) {
    var delayMin =
        (json['replacementDelayMin'] as num? ?? 2.0).toDouble().clamp(1.0, 7.0);
    var delayMax =
        (json['replacementDelayMax'] as num? ?? 5.0).toDouble().clamp(2.0, 8.0);
    if (delayMin > delayMax) {
      final swap = delayMin;
      delayMin = delayMax;
      delayMax = swap;
    }
    return FrogPondSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
        lilyPadCount: (json['lilyPadCount'] as int? ?? 2).clamp(2, 8),
        frogMoveSpeed: FrogMoveSpeed.values.firstWhere(
          (s) => s.name == json['frogMoveSpeed'],
          orElse: () => FrogMoveSpeed.slow,
        ),
        replacementDelayMin: delayMin,
        replacementDelayMax: delayMax,
        kingFrogInterval: (json['kingFrogInterval'] as int? ?? 15).clamp(15, 60),
        kingFrogEnabled: json['kingFrogEnabled'] as bool? ?? true,
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
        difficulty: FrogPondDifficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => FrogPondDifficulty.easy,
        ),
      );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        lilyPadCount,
        frogMoveSpeed,
        replacementDelayMin,
        replacementDelayMax,
        kingFrogInterval,
        kingFrogEnabled,
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
    required this.id,
    required this.centerX,
    required this.centerY,
    required this.radius,
    this.swayPhase = 0,
    this.ripplePhase = 0,
    this.state = PadState.occupied,
    this.emptyTimer = 0,
    this.splashProgress = 0,
    this.showSplash = false,
  });

  final String id;
  final double centerX;
  final double centerY;
  final double radius;
  final double swayPhase;
  final double ripplePhase;
  final PadState state;
  final double emptyTimer;
  final double splashProgress;
  final bool showSplash;

  LilyPadEntity copyWith({
    double? swayPhase,
    double? ripplePhase,
    PadState? state,
    double? emptyTimer,
    double? splashProgress,
    bool? showSplash,
  }) =>
      LilyPadEntity(
        id: id,
        centerX: centerX,
        centerY: centerY,
        radius: radius,
        swayPhase: swayPhase ?? this.swayPhase,
        ripplePhase: ripplePhase ?? this.ripplePhase,
        state: state ?? this.state,
        emptyTimer: emptyTimer ?? this.emptyTimer,
        splashProgress: splashProgress ?? this.splashProgress,
        showSplash: showSplash ?? this.showSplash,
      );

  @override
  List<Object?> get props =>
      [id, centerX, centerY, radius, swayPhase, ripplePhase, state, emptyTimer, splashProgress, showSplash];
}

class FrogEntity extends Equatable {
  const FrogEntity({
    required this.id,
    required this.padId,
    required this.varietyIndex,
    this.isKing = false,
    this.phase = FrogPhase.idle,
    this.x = 0,
    this.y = 0,
    this.animPhase = 0,
    this.blinkTimer = 0,
    this.jumpProgress = 0,
    this.enterProgress = 0,
    this.reactProgress = 0,
    this.crownGems = 8,
    this.enterFromX = 0,
    this.enterFromY = 0,
  });

  final String id;
  final String padId;
  final int varietyIndex;
  final bool isKing;
  final FrogPhase phase;
  final double x;
  final double y;
  final double animPhase;
  final double blinkTimer;
  final double jumpProgress;
  final double enterProgress;
  final double reactProgress;
  final int crownGems;
  final double enterFromX;
  final double enterFromY;

  static const kingTapRequired = 8;

  FrogVariety get variety => FrogVarieties.byIndex(varietyIndex);

  bool get canTap => phase == FrogPhase.idle || (isKing && phase == FrogPhase.idle);

  bool get isTappable =>
      phase == FrogPhase.idle || (isKing && phase == FrogPhase.reacting);

  FrogEntity copyWith({
    String? padId,
    int? varietyIndex,
    bool? isKing,
    FrogPhase? phase,
    double? x,
    double? y,
    double? animPhase,
    double? blinkTimer,
    double? jumpProgress,
    double? enterProgress,
    double? reactProgress,
    int? crownGems,
    double? enterFromX,
    double? enterFromY,
  }) =>
      FrogEntity(
        id: id,
        padId: padId ?? this.padId,
        varietyIndex: varietyIndex ?? this.varietyIndex,
        isKing: isKing ?? this.isKing,
        phase: phase ?? this.phase,
        x: x ?? this.x,
        y: y ?? this.y,
        animPhase: animPhase ?? this.animPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        jumpProgress: jumpProgress ?? this.jumpProgress,
        enterProgress: enterProgress ?? this.enterProgress,
        reactProgress: reactProgress ?? this.reactProgress,
        crownGems: crownGems ?? this.crownGems,
        enterFromX: enterFromX ?? this.enterFromX,
        enterFromY: enterFromY ?? this.enterFromY,
      );

  @override
  List<Object?> get props => [
        id,
        padId,
        varietyIndex,
        isKing,
        phase,
        x,
        y,
        animPhase,
        blinkTimer,
        jumpProgress,
        enterProgress,
        reactProgress,
        crownGems,
        enterFromX,
        enterFromY,
      ];
}

class FrogPondState extends Equatable {
  const FrogPondState({
    this.sessionPhase = FrogPondSessionPhase.ready,
    this.settings = const FrogPondSettings(),
    this.pads = const [],
    this.frogs = const [],
    this.remainingSeconds = 60,
    this.elapsedSeconds = 0,
    this.frogsTapped = 0,
    this.kingFrogsRemoved = 0,
    this.pointsEarned = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.kingDue = false,
    this.nextKingAt = 15,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.playAreaReady = false,
    this.pendingEnd = false,
    this.inactivityTimer = 0,
  });

  final FrogPondSessionPhase sessionPhase;
  final FrogPondSettings settings;
  final List<LilyPadEntity> pads;
  final List<FrogEntity> frogs;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int frogsTapped;
  final int kingFrogsRemoved;
  final int pointsEarned;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int longestStreak;
  final int currentStreak;
  final bool kingDue;
  final int nextKingAt;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool playAreaReady;
  final bool pendingEnd;
  final double inactivityTimer;

  bool get hasKing => frogs.any((f) => f.isKing && f.phase != FrogPhase.gone);

  bool get hasActiveAnimation => frogs.any(
        (f) =>
            f.phase == FrogPhase.jumping ||
            f.phase == FrogPhase.entering ||
            f.phase == FrogPhase.reacting,
      ) ||
      pads.any((p) => p.showSplash);

  FrogPondState copyWith({
    FrogPondSessionPhase? sessionPhase,
    FrogPondSettings? settings,
    List<LilyPadEntity>? pads,
    List<FrogEntity>? frogs,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? frogsTapped,
    int? kingFrogsRemoved,
    int? pointsEarned,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? longestStreak,
    int? currentStreak,
    bool? kingDue,
    int? nextKingAt,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? playAreaReady,
    bool? pendingEnd,
    double? inactivityTimer,
    bool clearFeedback = false,
  }) =>
      FrogPondState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        settings: settings ?? this.settings,
        pads: pads ?? this.pads,
        frogs: frogs ?? this.frogs,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        frogsTapped: frogsTapped ?? this.frogsTapped,
        kingFrogsRemoved: kingFrogsRemoved ?? this.kingFrogsRemoved,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
        kingDue: kingDue ?? this.kingDue,
        nextKingAt: nextKingAt ?? this.nextKingAt,
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
        pads,
        frogs,
        remainingSeconds,
        elapsedSeconds,
        frogsTapped,
        kingFrogsRemoved,
        pointsEarned,
        coinsEarned,
        xpEarned,
        starsEarned,
        longestStreak,
        currentStreak,
        kingDue,
        nextKingAt,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        playAreaReady,
        pendingEnd,
        inactivityTimer,
      ];
}

class FrogPondResult extends Equatable {
  const FrogPondResult({
    required this.frogsTapped,
    required this.kingFrogsRemoved,
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.longestStreak,
    required this.sessionSeconds,
  });

  final int frogsTapped;
  final int kingFrogsRemoved;
  final int points;
  final int coins;
  final int xp;
  final int stars;
  final int longestStreak;
  final int sessionSeconds;

  @override
  List<Object?> get props =>
      [frogsTapped, kingFrogsRemoved, points, coins, xp, stars, longestStreak, sessionSeconds];
}

const kFrogPondSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Reaction Timing',
  'Cause & Effect',
  'Touch Accuracy',
  'Attention',
];

const kFrogEncouragements = [
  'Splash!',
  'Great Tap!',
  'Ribbit!',
  'Nice Jump!',
  'Hooray!',
];

const kKingMessages = [
  'Royal Frog!',
  'Double Reward!',
  'King Splash!',
  'Amazing!',
];
