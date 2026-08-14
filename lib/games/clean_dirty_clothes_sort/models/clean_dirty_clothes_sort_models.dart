import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum LaundrySortPhase { ready, playing, paused, celebrating, finished }

enum ClothesCleanliness { clean, dirty }

enum ClothesKind {
  tShirt,
  shirt,
  polo,
  skirt,
  shorts,
  trousers,
  jeans,
  socks,
  handkerchief,
  dress,
  jacket,
  sweater,
  hoodie,
  pajamas,
  babyClothes,
  towel,
  cap,
  mittens,
}

class ClothesDef extends Equatable {
  const ClothesDef({
    required this.kind,
    required this.name,
    required this.emoji,
  });

  final ClothesKind kind;
  final String name;
  final String emoji;

  @override
  List<Object?> get props => [kind, name, emoji];
}

abstract final class ClothesCatalog {
  static const kinds = ClothesKind.values;

  static ClothesDef def(ClothesKind kind) => switch (kind) {
        ClothesKind.tShirt => const ClothesDef(
            kind: ClothesKind.tShirt,
            name: 'T-Shirt',
            emoji: '👕',
          ),
        ClothesKind.shirt => const ClothesDef(
            kind: ClothesKind.shirt,
            name: 'Shirt',
            emoji: '👔',
          ),
        ClothesKind.polo => const ClothesDef(
            kind: ClothesKind.polo,
            name: 'Polo Shirt',
            emoji: '🎽',
          ),
        ClothesKind.skirt => const ClothesDef(
            kind: ClothesKind.skirt,
            name: 'Skirt',
            emoji: '👗',
          ),
        ClothesKind.shorts => const ClothesDef(
            kind: ClothesKind.shorts,
            name: 'Shorts',
            emoji: '🩳',
          ),
        ClothesKind.trousers => const ClothesDef(
            kind: ClothesKind.trousers,
            name: 'Trousers',
            emoji: '👖',
          ),
        ClothesKind.jeans => const ClothesDef(
            kind: ClothesKind.jeans,
            name: 'Jeans',
            emoji: '👖',
          ),
        ClothesKind.socks => const ClothesDef(
            kind: ClothesKind.socks,
            name: 'Socks',
            emoji: '🧦',
          ),
        ClothesKind.handkerchief => const ClothesDef(
            kind: ClothesKind.handkerchief,
            name: 'Handkerchief',
            emoji: '🤧',
          ),
        ClothesKind.dress => const ClothesDef(
            kind: ClothesKind.dress,
            name: 'Dress',
            emoji: '👗',
          ),
        ClothesKind.jacket => const ClothesDef(
            kind: ClothesKind.jacket,
            name: 'Jacket',
            emoji: '🧥',
          ),
        ClothesKind.sweater => const ClothesDef(
            kind: ClothesKind.sweater,
            name: 'Sweater',
            emoji: '🧶',
          ),
        ClothesKind.hoodie => const ClothesDef(
            kind: ClothesKind.hoodie,
            name: 'Hoodie',
            emoji: '🧥',
          ),
        ClothesKind.pajamas => const ClothesDef(
            kind: ClothesKind.pajamas,
            name: 'Pajamas',
            emoji: '🛏️',
          ),
        ClothesKind.babyClothes => const ClothesDef(
            kind: ClothesKind.babyClothes,
            name: 'Baby Clothes',
            emoji: '👶',
          ),
        ClothesKind.towel => const ClothesDef(
            kind: ClothesKind.towel,
            name: 'Towel',
            emoji: '🛁',
          ),
        ClothesKind.cap => const ClothesDef(
            kind: ClothesKind.cap,
            name: 'Cap',
            emoji: '🧢',
          ),
        ClothesKind.mittens => const ClothesDef(
            kind: ClothesKind.mittens,
            name: 'Mittens',
            emoji: '🧤',
          ),
      };
}

/// A clothing item floating in the laundry room play area.
class ClothesItem extends Equatable {
  const ClothesItem({
    required this.id,
    required this.kind,
    required this.cleanliness,
    this.x = 0.5,
    this.y = 0.5,
    this.vx = 0,
    this.vy = 0,
    this.shake = false,
    this.hidden = false,
    this.floatPhase = 0,
  });

  final String id;
  final ClothesKind kind;
  final ClothesCleanliness cleanliness;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final bool shake;
  final bool hidden;
  final double floatPhase;

  ClothesDef get def => ClothesCatalog.def(kind);

  bool get isClean => cleanliness == ClothesCleanliness.clean;

  ClothesItem copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    bool? shake,
    bool? hidden,
    double? floatPhase,
  }) =>
      ClothesItem(
        id: id,
        kind: kind,
        cleanliness: cleanliness,
        x: x ?? this.x,
        y: y ?? this.y,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
        shake: shake ?? this.shake,
        hidden: hidden ?? this.hidden,
        floatPhase: floatPhase ?? this.floatPhase,
      );

  @override
  List<Object?> get props =>
      [id, kind, cleanliness, x, y, vx, vy, shake, hidden, floatPhase];
}

/// Washing machine (dirty) or cupboard (clean).
class LaundryTarget extends Equatable {
  const LaundryTarget({
    required this.id,
    required this.accepts,
    this.glow = false,
    this.happy = false,
    this.wobble = false,
    this.washing = false,
    this.idlePhase = 0,
  });

  final String id;
  final ClothesCleanliness accepts;
  final bool glow;
  final bool happy;
  final bool wobble;
  final bool washing;
  final double idlePhase;

  bool get isWasher => accepts == ClothesCleanliness.dirty;

  String get label => isWasher ? 'Washing Machine' : 'Cupboard';

  LaundryTarget copyWith({
    bool? glow,
    bool? happy,
    bool? wobble,
    bool? washing,
    double? idlePhase,
  }) =>
      LaundryTarget(
        id: id,
        accepts: accepts,
        glow: glow ?? this.glow,
        happy: happy ?? this.happy,
        wobble: wobble ?? this.wobble,
        washing: washing ?? this.washing,
        idlePhase: idlePhase ?? this.idlePhase,
      );

  @override
  List<Object?> get props =>
      [id, accepts, glow, happy, wobble, washing, idlePhase];
}

class LaundrySortSettings extends Equatable {
  const LaundrySortSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.practiceMode = false,
    this.visibleItemCount = 5,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.celebrationsEnabled = true,
    this.hapticsEnabled = true,
    this.coinRewardsEnabled = true,
    this.floatingAnimation = true,
    this.bubbleEffects = true,
    this.leftHandedLayout = false,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final bool practiceMode;
  final int visibleItemCount;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool celebrationsEnabled;
  final bool hapticsEnabled;
  final bool coinRewardsEnabled;
  final bool floatingAnimation;
  final bool bubbleEffects;
  final bool leftHandedLayout;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => practiceMode;

  LaundrySortSettings copyWith({
    int? sessionSeconds,
    bool? practiceMode,
    int? visibleItemCount,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? celebrationsEnabled,
    bool? hapticsEnabled,
    bool? coinRewardsEnabled,
    bool? floatingAnimation,
    bool? bubbleEffects,
    bool? leftHandedLayout,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      LaundrySortSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        practiceMode: practiceMode ?? this.practiceMode,
        visibleItemCount: visibleItemCount ?? this.visibleItemCount,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        celebrationsEnabled: celebrationsEnabled ?? this.celebrationsEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        coinRewardsEnabled: coinRewardsEnabled ?? this.coinRewardsEnabled,
        floatingAnimation: floatingAnimation ?? this.floatingAnimation,
        bubbleEffects: bubbleEffects ?? this.bubbleEffects,
        leftHandedLayout: leftHandedLayout ?? this.leftHandedLayout,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'practiceMode': practiceMode,
        'visibleItemCount': visibleItemCount,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'celebrationsEnabled': celebrationsEnabled,
        'hapticsEnabled': hapticsEnabled,
        'coinRewardsEnabled': coinRewardsEnabled,
        'floatingAnimation': floatingAnimation,
        'bubbleEffects': bubbleEffects,
        'leftHandedLayout': leftHandedLayout,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory LaundrySortSettings.fromJson(Map<String, dynamic> json) =>
      LaundrySortSettings(
        sessionSeconds: GameDuration.snap(
          (json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds)
              .clamp(0, 1800),
        ),
        practiceMode: json['practiceMode'] as bool? ?? false,
        visibleItemCount:
            (json['visibleItemCount'] as int? ?? 5).clamp(3, 8),
        rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        narrationEnabled: json['narrationEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        celebrationsEnabled: json['celebrationsEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        coinRewardsEnabled: json['coinRewardsEnabled'] as bool? ?? true,
        floatingAnimation: json['floatingAnimation'] as bool? ?? true,
        bubbleEffects: json['bubbleEffects'] as bool? ?? true,
        leftHandedLayout: json['leftHandedLayout'] as bool? ?? false,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        sessionSeconds,
        practiceMode,
        visibleItemCount,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        celebrationsEnabled,
        hapticsEnabled,
        coinRewardsEnabled,
        floatingAnimation,
        bubbleEffects,
        leftHandedLayout,
        reducedMotion,
        largerTouchTargets,
      ];
}

class LaundrySortState extends Equatable {
  const LaundrySortState({
    this.phase = LaundrySortPhase.ready,
    this.settings = const LaundrySortSettings(),
    this.items = const [],
    this.targets = const [],
    this.pendingSpawns = 0,
    this.round = 1,
    this.remainingSeconds = 0,
    this.score = 0,
    this.correctSorts = 0,
    this.cleanStored = 0,
    this.dirtyWashed = 0,
    this.attempts = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showSparkles = false,
    this.showMilestone = false,
    this.pendingEnd = false,
    this.envPhase = 0,
    this.hoverTargetId,
    this.roomGlow = 0,
  });

  final LaundrySortPhase phase;
  final LaundrySortSettings settings;
  final List<ClothesItem> items;
  final List<LaundryTarget> targets;
  final int pendingSpawns;
  final int round;
  final int remainingSeconds;
  final int score;
  final int correctSorts;
  final int cleanStored;
  final int dirtyWashed;
  final int attempts;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showSparkles;
  final bool showMilestone;
  final bool pendingEnd;
  final double envPhase;
  final String? hoverTargetId;
  final double roomGlow;

  int get visibleCount =>
      items.where((i) => !i.hidden).length + pendingSpawns;

  LaundrySortState copyWith({
    LaundrySortPhase? phase,
    LaundrySortSettings? settings,
    List<ClothesItem>? items,
    List<LaundryTarget>? targets,
    int? pendingSpawns,
    int? round,
    int? remainingSeconds,
    int? score,
    int? correctSorts,
    int? cleanStored,
    int? dirtyWashed,
    int? attempts,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showSparkles,
    bool? showMilestone,
    bool? pendingEnd,
    double? envPhase,
    String? hoverTargetId,
    double? roomGlow,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearHover = false,
  }) =>
      LaundrySortState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        items: items ?? this.items,
        targets: targets ?? this.targets,
        pendingSpawns: pendingSpawns ?? this.pendingSpawns,
        round: round ?? this.round,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        correctSorts: correctSorts ?? this.correctSorts,
        cleanStored: cleanStored ?? this.cleanStored,
        dirtyWashed: dirtyWashed ?? this.dirtyWashed,
        attempts: attempts ?? this.attempts,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        showSparkles: showSparkles ?? this.showSparkles,
        showMilestone: showMilestone ?? this.showMilestone,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
        hoverTargetId:
            clearHover ? null : (hoverTargetId ?? this.hoverTargetId),
        roomGlow: roomGlow ?? this.roomGlow,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        items,
        targets,
        pendingSpawns,
        round,
        remainingSeconds,
        score,
        correctSorts,
        cleanStored,
        dirtyWashed,
        attempts,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        feedbackMessage,
        lastRewardText,
        showSparkles,
        showMilestone,
        pendingEnd,
        envPhase,
        hoverTargetId,
        roomGlow,
      ];
}

class LaundrySortResult extends Equatable {
  const LaundrySortResult({
    required this.score,
    required this.correctSorts,
    required this.cleanStored,
    required this.dirtyWashed,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.accuracy,
  });

  final int score;
  final int correctSorts;
  final int cleanStored;
  final int dirtyWashed;
  final int attempts;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;
  final double accuracy;

  @override
  List<Object?> get props => [
        score,
        correctSorts,
        cleanStored,
        dirtyWashed,
        attempts,
        maxStreak,
        coins,
        xp,
        stars,
        accuracy,
      ];
}

const kLaundryEncouragements = [
  'Great Job!',
  'Wonderful!',
  'Fantastic!',
  'Amazing!',
  'Excellent!',
  'Nice Sorting!',
  'Super Helper!',
  "You're Amazing!",
  'Awesome!',
  'Laundry Hero!',
  'Sparkling Clean!',
  'Keep Going!',
  'Brilliant!',
  'Perfect Choice!',
];

const kLaundryVictoryTitles = [
  "You're a Laundry Superstar!",
  'Amazing Helper!',
  'Sparkling Clean!',
  'Fantastic Sorting!',
  'Wonderful Work!',
  'Great Job Helping!',
  'Keep Learning!',
  "You're Getting Better Every Time!",
  'Awesome Helper!',
  "Let's Sort More Clothes!",
];

const kLaundrySortSkills = [
  'Classification Skills',
  'Logical Thinking',
  'Visual Discrimination',
  'Hand-Eye Coordination',
  'Fine Motor Skills',
  'Everyday Life Skills',
  'Decision Making',
  'Observation',
];
