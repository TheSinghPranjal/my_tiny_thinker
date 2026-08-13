import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum FoodSortPhase { ready, playing, paused, celebrating, finished }

enum FoodCategory { healthy, junk }

enum FoodSortDifficulty { beginner, easy, medium, advanced }

enum FoodKind {
  apple,
  banana,
  strawberry,
  grapes,
  carrot,
  broccoli,
  cucumber,
  orange,
  mango,
  watermelon,
  pineapple,
  lettuce,
  kiwi,
  corn,
  potato,
  pear,
  burger,
  pizza,
  fries,
  hotDog,
  donut,
  cookie,
  chocolate,
  cake,
  noodles,
  soda,
  candy,
  cupcake,
  lollipop,
  popcorn,
}

class FoodDef extends Equatable {
  const FoodDef({
    required this.kind,
    required this.name,
    required this.emoji,
    required this.category,
  });

  final FoodKind kind;
  final String name;
  final String emoji;
  final FoodCategory category;

  @override
  List<Object?> get props => [kind, name, emoji, category];
}

abstract final class FoodCatalog {
  static const beginnerFoods = <FoodKind>[
    FoodKind.apple,
    FoodKind.banana,
    FoodKind.burger,
    FoodKind.pizza,
  ];

  static const defaultHealthy = <FoodKind>[
    FoodKind.apple,
    FoodKind.banana,
    FoodKind.strawberry,
    FoodKind.grapes,
    FoodKind.carrot,
    FoodKind.broccoli,
    FoodKind.cucumber,
    FoodKind.orange,
    FoodKind.mango,
    FoodKind.watermelon,
    FoodKind.pineapple,
    FoodKind.lettuce,
    FoodKind.kiwi,
    FoodKind.corn,
    FoodKind.potato,
    FoodKind.pear,
  ];

  static const defaultJunk = <FoodKind>[
    FoodKind.burger,
    FoodKind.pizza,
    FoodKind.fries,
    FoodKind.hotDog,
    FoodKind.donut,
    FoodKind.cookie,
    FoodKind.chocolate,
    FoodKind.cake,
    FoodKind.noodles,
    FoodKind.soda,
    FoodKind.candy,
    FoodKind.cupcake,
    FoodKind.lollipop,
    FoodKind.popcorn,
  ];

  static FoodDef def(FoodKind kind) => switch (kind) {
        FoodKind.apple => const FoodDef(
            kind: FoodKind.apple,
            name: 'Apple',
            emoji: '🍎',
            category: FoodCategory.healthy,
          ),
        FoodKind.banana => const FoodDef(
            kind: FoodKind.banana,
            name: 'Banana',
            emoji: '🍌',
            category: FoodCategory.healthy,
          ),
        FoodKind.strawberry => const FoodDef(
            kind: FoodKind.strawberry,
            name: 'Strawberry',
            emoji: '🍓',
            category: FoodCategory.healthy,
          ),
        FoodKind.grapes => const FoodDef(
            kind: FoodKind.grapes,
            name: 'Grapes',
            emoji: '🍇',
            category: FoodCategory.healthy,
          ),
        FoodKind.carrot => const FoodDef(
            kind: FoodKind.carrot,
            name: 'Carrot',
            emoji: '🥕',
            category: FoodCategory.healthy,
          ),
        FoodKind.broccoli => const FoodDef(
            kind: FoodKind.broccoli,
            name: 'Broccoli',
            emoji: '🥦',
            category: FoodCategory.healthy,
          ),
        FoodKind.cucumber => const FoodDef(
            kind: FoodKind.cucumber,
            name: 'Cucumber',
            emoji: '🥒',
            category: FoodCategory.healthy,
          ),
        FoodKind.orange => const FoodDef(
            kind: FoodKind.orange,
            name: 'Orange',
            emoji: '🍊',
            category: FoodCategory.healthy,
          ),
        FoodKind.mango => const FoodDef(
            kind: FoodKind.mango,
            name: 'Mango',
            emoji: '🥭',
            category: FoodCategory.healthy,
          ),
        FoodKind.watermelon => const FoodDef(
            kind: FoodKind.watermelon,
            name: 'Watermelon',
            emoji: '🍉',
            category: FoodCategory.healthy,
          ),
        FoodKind.pineapple => const FoodDef(
            kind: FoodKind.pineapple,
            name: 'Pineapple',
            emoji: '🍍',
            category: FoodCategory.healthy,
          ),
        FoodKind.lettuce => const FoodDef(
            kind: FoodKind.lettuce,
            name: 'Lettuce',
            emoji: '🥬',
            category: FoodCategory.healthy,
          ),
        FoodKind.kiwi => const FoodDef(
            kind: FoodKind.kiwi,
            name: 'Kiwi',
            emoji: '🥝',
            category: FoodCategory.healthy,
          ),
        FoodKind.corn => const FoodDef(
            kind: FoodKind.corn,
            name: 'Corn',
            emoji: '🌽',
            category: FoodCategory.healthy,
          ),
        FoodKind.potato => const FoodDef(
            kind: FoodKind.potato,
            name: 'Potato',
            emoji: '🥔',
            category: FoodCategory.healthy,
          ),
        FoodKind.pear => const FoodDef(
            kind: FoodKind.pear,
            name: 'Pear',
            emoji: '🍐',
            category: FoodCategory.healthy,
          ),
        FoodKind.burger => const FoodDef(
            kind: FoodKind.burger,
            name: 'Burger',
            emoji: '🍔',
            category: FoodCategory.junk,
          ),
        FoodKind.pizza => const FoodDef(
            kind: FoodKind.pizza,
            name: 'Pizza',
            emoji: '🍕',
            category: FoodCategory.junk,
          ),
        FoodKind.fries => const FoodDef(
            kind: FoodKind.fries,
            name: 'French Fries',
            emoji: '🍟',
            category: FoodCategory.junk,
          ),
        FoodKind.hotDog => const FoodDef(
            kind: FoodKind.hotDog,
            name: 'Hot Dog',
            emoji: '🌭',
            category: FoodCategory.junk,
          ),
        FoodKind.donut => const FoodDef(
            kind: FoodKind.donut,
            name: 'Donut',
            emoji: '🍩',
            category: FoodCategory.junk,
          ),
        FoodKind.cookie => const FoodDef(
            kind: FoodKind.cookie,
            name: 'Cookie',
            emoji: '🍪',
            category: FoodCategory.junk,
          ),
        FoodKind.chocolate => const FoodDef(
            kind: FoodKind.chocolate,
            name: 'Chocolate',
            emoji: '🍫',
            category: FoodCategory.junk,
          ),
        FoodKind.cake => const FoodDef(
            kind: FoodKind.cake,
            name: 'Cake',
            emoji: '🍰',
            category: FoodCategory.junk,
          ),
        FoodKind.noodles => const FoodDef(
            kind: FoodKind.noodles,
            name: 'Instant Noodles',
            emoji: '🍜',
            category: FoodCategory.junk,
          ),
        FoodKind.soda => const FoodDef(
            kind: FoodKind.soda,
            name: 'Soda',
            emoji: '🥤',
            category: FoodCategory.junk,
          ),
        FoodKind.candy => const FoodDef(
            kind: FoodKind.candy,
            name: 'Candy',
            emoji: '🍭',
            category: FoodCategory.junk,
          ),
        FoodKind.cupcake => const FoodDef(
            kind: FoodKind.cupcake,
            name: 'Cupcake',
            emoji: '🧁',
            category: FoodCategory.junk,
          ),
        FoodKind.lollipop => const FoodDef(
            kind: FoodKind.lollipop,
            name: 'Lollipop',
            emoji: '🍬',
            category: FoodCategory.junk,
          ),
        FoodKind.popcorn => const FoodDef(
            kind: FoodKind.popcorn,
            name: 'Popcorn',
            emoji: '🍿',
            category: FoodCategory.junk,
          ),
      };

  static List<FoodKind> healthyKinds() =>
      FoodKind.values.where((k) => def(k).category == FoodCategory.healthy).toList();

  static List<FoodKind> junkKinds() =>
      FoodKind.values.where((k) => def(k).category == FoodCategory.junk).toList();
}

/// A food inside a glossy bubble drifting across the upper play area.
///
/// [x] and [y] are normalised 0..1 fractions of the free space available to the
/// bubble, so the board can lay bubbles out without knowing pixel sizes and a
/// bubble can never drift partly off screen.
class FloatingFood extends Equatable {
  const FloatingFood({
    required this.id,
    required this.kind,
    this.x = 0.5,
    this.y = 0.5,
    this.vx = 0,
    this.vy = 0,
    this.shake = false,
    this.hidden = false,
    this.floatPhase = 0,
    this.rotationPhase = 0,
  });

  final String id;
  final FoodKind kind;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final bool shake;
  final bool hidden;
  final double floatPhase;
  final double rotationPhase;

  FoodDef get foodDef => FoodCatalog.def(kind);

  FoodCategory get category => foodDef.category;

  FloatingFood copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    bool? shake,
    bool? hidden,
    double? floatPhase,
    double? rotationPhase,
  }) =>
      FloatingFood(
        id: id,
        kind: kind,
        x: x ?? this.x,
        y: y ?? this.y,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
        shake: shake ?? this.shake,
        hidden: hidden ?? this.hidden,
        floatPhase: floatPhase ?? this.floatPhase,
        rotationPhase: rotationPhase ?? this.rotationPhase,
      );

  @override
  List<Object?> get props =>
      [id, kind, x, y, vx, vy, shake, hidden, floatPhase, rotationPhase];
}

/// One of the two baskets at the bottom of the screen that food is dragged into.
class SortBasket extends Equatable {
  const SortBasket({
    required this.id,
    required this.category,
    this.glow = false,
    this.hintPulse = false,
    this.happy = false,
    this.wobble = false,
    this.idlePhase = 0,
  });

  final String id;
  final FoodCategory category;

  /// Highlighted because a correctly matching food is hovering over it.
  final bool glow;

  /// Pulsed as a gentle hint after food was dropped into the wrong basket.
  final bool hintPulse;

  /// Bouncing after receiving a correct food.
  final bool happy;

  /// Shaking softly after receiving a wrong food.
  final bool wobble;

  final double idlePhase;

  bool get isHealthy => category == FoodCategory.healthy;

  String get label => isHealthy ? 'Healthy Food' : 'Junk Food';

  String get iconEmoji => isHealthy ? '🥦' : '🍔';

  SortBasket copyWith({
    bool? glow,
    bool? hintPulse,
    bool? happy,
    bool? wobble,
    double? idlePhase,
  }) =>
      SortBasket(
        id: id,
        category: category,
        glow: glow ?? this.glow,
        hintPulse: hintPulse ?? this.hintPulse,
        happy: happy ?? this.happy,
        wobble: wobble ?? this.wobble,
        idlePhase: idlePhase ?? this.idlePhase,
      );

  @override
  List<Object?> get props =>
      [id, category, glow, hintPulse, happy, wobble, idlePhase];
}

class FoodSortSettings extends Equatable {
  const FoodSortSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.enabledHealthy = FoodCatalog.defaultHealthy,
    this.enabledJunk = FoodCatalog.defaultJunk,
    this.maxDifficulty = FoodSortDifficulty.advanced,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final List<FoodKind> enabledHealthy;
  final List<FoodKind> enabledJunk;
  final FoodSortDifficulty maxDifficulty;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  List<FoodKind> get activeHealthy =>
      enabledHealthy.length >= 4 ? enabledHealthy : FoodCatalog.defaultHealthy;

  List<FoodKind> get activeJunk =>
      enabledJunk.length >= 4 ? enabledJunk : FoodCatalog.defaultJunk;

  FoodSortSettings copyWith({
    int? sessionSeconds,
    List<FoodKind>? enabledHealthy,
    List<FoodKind>? enabledJunk,
    FoodSortDifficulty? maxDifficulty,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      FoodSortSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        enabledHealthy: enabledHealthy ?? this.enabledHealthy,
        enabledJunk: enabledJunk ?? this.enabledJunk,
        maxDifficulty: maxDifficulty ?? this.maxDifficulty,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'enabledHealthy': enabledHealthy.map((e) => e.name).toList(),
        'enabledJunk': enabledJunk.map((e) => e.name).toList(),
        'maxDifficulty': maxDifficulty.name,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory FoodSortSettings.fromJson(Map<String, dynamic> json) {
    List<FoodKind> parseList(List? names) => (names?.cast<String>() ?? [])
        .map(
          (n) => FoodKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => FoodKind.apple,
          ),
        )
        .toSet()
        .toList();

    final healthy = parseList(json['enabledHealthy'] as List?);
    final junk = parseList(json['enabledJunk'] as List?);
    final diffName = json['maxDifficulty'] as String? ?? 'advanced';
    final diff = FoodSortDifficulty.values.firstWhere(
      (d) => d.name == diffName,
      orElse: () => FoodSortDifficulty.beginner,
    );

    return FoodSortSettings(
      sessionSeconds: GameDuration.snap(
        (json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds)
            .clamp(0, 1800),
      ),
      enabledHealthy:
          healthy.length >= 4 ? healthy : FoodCatalog.defaultHealthy,
      enabledJunk: junk.length >= 4 ? junk : FoodCatalog.defaultJunk,
      maxDifficulty: diff,
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        enabledHealthy,
        enabledJunk,
        maxDifficulty,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class FoodSortState extends Equatable {
  const FoodSortState({
    this.phase = FoodSortPhase.ready,
    this.settings = const FoodSortSettings(),
    this.foods = const [],
    this.baskets = const [],
    this.round = 1,
    this.remainingSeconds = 0,
    this.score = 0,
    this.correctMatches = 0,
    this.attempts = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.feedbackMessage,
    this.subFeedbackMessage,
    this.lastRewardText,
    this.spokenFoodName,
    this.showSparkles = false,
    this.showMascot = false,
    this.showMilestone = false,
    this.pendingEnd = false,
    this.envPhase = 0,
    this.hoverBasketId,
    this.wrongHintText,
  });

  final FoodSortPhase phase;
  final FoodSortSettings settings;
  final List<FloatingFood> foods;
  final List<SortBasket> baskets;
  final int round;
  final int remainingSeconds;
  final int score;
  final int correctMatches;
  final int attempts;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final String? feedbackMessage;
  final String? subFeedbackMessage;
  final String? lastRewardText;
  final String? spokenFoodName;
  final bool showSparkles;
  final bool showMascot;
  final bool showMilestone;
  final bool pendingEnd;
  final double envPhase;
  final String? hoverBasketId;
  final String? wrongHintText;

  FoodSortState copyWith({
    FoodSortPhase? phase,
    FoodSortSettings? settings,
    List<FloatingFood>? foods,
    List<SortBasket>? baskets,
    int? round,
    int? remainingSeconds,
    int? score,
    int? correctMatches,
    int? attempts,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    String? feedbackMessage,
    String? subFeedbackMessage,
    String? lastRewardText,
    String? spokenFoodName,
    bool? showSparkles,
    bool? showMascot,
    bool? showMilestone,
    bool? pendingEnd,
    double? envPhase,
    String? hoverBasketId,
    String? wrongHintText,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearSpoken = false,
    bool clearHover = false,
    bool clearHint = false,
  }) =>
      FoodSortState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        foods: foods ?? this.foods,
        baskets: baskets ?? this.baskets,
        round: round ?? this.round,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        correctMatches: correctMatches ?? this.correctMatches,
        attempts: attempts ?? this.attempts,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        subFeedbackMessage:
            clearFeedback ? null : (subFeedbackMessage ?? this.subFeedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        spokenFoodName:
            clearSpoken ? null : (spokenFoodName ?? this.spokenFoodName),
        showSparkles: showSparkles ?? this.showSparkles,
        showMascot: showMascot ?? this.showMascot,
        showMilestone: showMilestone ?? this.showMilestone,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
        hoverBasketId:
            clearHover ? null : (hoverBasketId ?? this.hoverBasketId),
        wrongHintText: clearHint ? null : (wrongHintText ?? this.wrongHintText),
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        foods,
        baskets,
        round,
        remainingSeconds,
        score,
        correctMatches,
        attempts,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        feedbackMessage,
        subFeedbackMessage,
        lastRewardText,
        spokenFoodName,
        showSparkles,
        showMascot,
        showMilestone,
        pendingEnd,
        envPhase,
        hoverBasketId,
        wrongHintText,
      ];
}

class FoodSortResult extends Equatable {
  const FoodSortResult({
    required this.score,
    required this.correctMatches,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.roundReached,
    required this.accuracy,
  });

  final int score;
  final int correctMatches;
  final int attempts;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;
  final int roundReached;
  final double accuracy;

  @override
  List<Object?> get props => [
        score,
        correctMatches,
        attempts,
        maxStreak,
        coins,
        xp,
        stars,
        roundReached,
        accuracy,
      ];
}

const kFoodSortSkills = [
  'Healthy Eating',
  'Food Recognition',
  'Category Sorting',
  'Drag-and-Drop Coordination',
  'Fine Motor Skills',
  'Visual Discrimination',
];
