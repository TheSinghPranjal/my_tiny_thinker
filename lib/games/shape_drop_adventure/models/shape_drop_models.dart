import 'package:equatable/equatable.dart';

enum ShapeDropPhase { ready, playing, paused, celebrating, finished }

enum ShapeKind {
  circle,
  triangle,
  square,
  rectangle,
  oval,
  star,
  heart,
  diamond,
  pentagon,
  hexagon,
  heptagon,
  octagon,
  parallelogram,
  rhombus,
  crescent,
  cone,
  cube,
  cuboid,
  cylinder,
  sphere,
  trapezium,
  semicircle,
}

enum ShapePresentation { geometric, object }

class ShapeDef extends Equatable {
  const ShapeDef({
    required this.kind,
    required this.name,
    required this.color,
    required this.accent,
    this.objectEmoji,
    this.objectLabel,
  });

  final ShapeKind kind;
  final String name;
  final int color;
  final int accent;
  final String? objectEmoji;
  final String? objectLabel;

  @override
  List<Object?> get props => [kind, name, color, accent, objectEmoji, objectLabel];
}

abstract final class ShapeCatalog {
  static const preschoolCore = <ShapeKind>[
    ShapeKind.circle,
    ShapeKind.triangle,
    ShapeKind.square,
    ShapeKind.rectangle,
    ShapeKind.oval,
    ShapeKind.star,
    ShapeKind.heart,
    ShapeKind.diamond,
    ShapeKind.pentagon,
    ShapeKind.hexagon,
    ShapeKind.crescent,
    ShapeKind.semicircle,
  ];

  static const allKinds = ShapeKind.values;

  static String displayName(ShapeKind kind) => switch (kind) {
        ShapeKind.circle => 'Circle',
        ShapeKind.triangle => 'Triangle',
        ShapeKind.square => 'Square',
        ShapeKind.rectangle => 'Rectangle',
        ShapeKind.oval => 'Oval',
        ShapeKind.star => 'Star',
        ShapeKind.heart => 'Heart',
        ShapeKind.diamond => 'Diamond',
        ShapeKind.pentagon => 'Pentagon',
        ShapeKind.hexagon => 'Hexagon',
        ShapeKind.heptagon => 'Heptagon',
        ShapeKind.octagon => 'Octagon',
        ShapeKind.parallelogram => 'Parallelogram',
        ShapeKind.rhombus => 'Rhombus',
        ShapeKind.crescent => 'Crescent',
        ShapeKind.cone => 'Cone',
        ShapeKind.cube => 'Cube',
        ShapeKind.cuboid => 'Cuboid',
        ShapeKind.cylinder => 'Cylinder',
        ShapeKind.sphere => 'Sphere',
        ShapeKind.trapezium => 'Trapezium',
        ShapeKind.semicircle => 'Semicircle',
      };

  static int primaryColor(ShapeKind kind) => switch (kind) {
        ShapeKind.circle => 0xFF42A5F5,
        ShapeKind.triangle => 0xFFFF7043,
        ShapeKind.square => 0xFF66BB6A,
        ShapeKind.rectangle => 0xFFAB47BC,
        ShapeKind.oval => 0xFFFFCA28,
        ShapeKind.star => 0xFFFFEE58,
        ShapeKind.heart => 0xFFEC407A,
        ShapeKind.diamond => 0xFF26C6DA,
        ShapeKind.pentagon => 0xFF7E57C2,
        ShapeKind.hexagon => 0xFFFFA726,
        ShapeKind.heptagon => 0xFF26A69A,
        ShapeKind.octagon => 0xFF5C6BC0,
        ShapeKind.parallelogram => 0xFF8D6E63,
        ShapeKind.rhombus => 0xFFEF5350,
        ShapeKind.crescent => 0xFFFFF176,
        ShapeKind.cone => 0xFFFFAB91,
        ShapeKind.cube => 0xFF90CAF9,
        ShapeKind.cuboid => 0xFFA5D6A7,
        ShapeKind.cylinder => 0xFFCE93D8,
        ShapeKind.sphere => 0xFF81D4FA,
        ShapeKind.trapezium => 0xFFFF8A65,
        ShapeKind.semicircle => 0xFFF48FB1,
      };

  static int accentColor(ShapeKind kind) =>
      ColorShift.darken(primaryColor(kind));

  /// Object associations for preschool learning.
  static List<(String emoji, String label)> objectsFor(ShapeKind kind) =>
      switch (kind) {
        ShapeKind.circle => [
            ('⚽', 'Ball'),
            ('🍊', 'Orange'),
            ('🛞', 'Wheel'),
            ('🍪', 'Cookie'),
            ('☀️', 'Sun'),
          ],
        ShapeKind.triangle => [
            ('🍕', 'Pizza'),
            ('🏔️', 'Mountain'),
            ('🚩', 'Flag'),
            ('🧀', 'Cheese'),
          ],
        ShapeKind.square => [
            ('🥪', 'Sandwich'),
            ('🪟', 'Window'),
            ('🎁', 'Gift'),
            ('🧱', 'Tile'),
          ],
        ShapeKind.rectangle => [
            ('📖', 'Book'),
            ('📺', 'TV'),
            ('📓', 'Notebook'),
            ('🍫', 'Chocolate'),
            ('🚪', 'Door'),
          ],
        ShapeKind.oval => [
            ('🥚', 'Egg'),
            ('🍉', 'Melon'),
            ('🏉', 'Ball'),
            ('🎈', 'Balloon'),
          ],
        ShapeKind.star => [
            ('⭐', 'Star'),
            ('🌟', 'Sparkle'),
          ],
        ShapeKind.heart => [
            ('❤️', 'Heart'),
            ('💝', 'Gift Heart'),
          ],
        ShapeKind.diamond => [
            ('💎', 'Gem'),
            ('🪁', 'Kite'),
          ],
        ShapeKind.pentagon => [
            ('🏠', 'House'),
          ],
        ShapeKind.hexagon => [
            ('🍯', 'Honeycomb'),
          ],
        ShapeKind.crescent => [
            ('🌙', 'Moon'),
          ],
        ShapeKind.cone => [
            ('🍦', 'Ice Cream'),
            ('🎉', 'Party Hat'),
          ],
        ShapeKind.cube => [
            ('🎲', 'Dice'),
          ],
        ShapeKind.cuboid => [
            ('📦', 'Box'),
            ('✏️', 'Pencil Box'),
          ],
        ShapeKind.cylinder => [
            ('🥫', 'Can'),
          ],
        ShapeKind.sphere => [
            ('🌎', 'Globe'),
          ],
        ShapeKind.semicircle => [
            ('🌈', 'Rainbow'),
          ],
        _ => const [],
      };

  static ShapeDef geometric(ShapeKind kind) => ShapeDef(
        kind: kind,
        name: displayName(kind),
        color: primaryColor(kind),
        accent: accentColor(kind),
      );

  static ShapeDef objectVariant(ShapeKind kind, int seed) {
    final objs = objectsFor(kind);
    if (objs.isEmpty) return geometric(kind);
    final o = objs[seed % objs.length];
    return ShapeDef(
      kind: kind,
      name: displayName(kind),
      color: primaryColor(kind),
      accent: accentColor(kind),
      objectEmoji: o.$1,
      objectLabel: o.$2,
    );
  }
}

abstract final class ColorShift {
  static int darken(int color) {
    final r = ((color >> 16) & 0xFF) * 0.75;
    final g = ((color >> 8) & 0xFF) * 0.75;
    final b = (color & 0xFF) * 0.75;
    return 0xFF000000 |
        (r.round() << 16) |
        (g.round() << 8) |
        b.round();
  }
}

class ShapeDropSettings extends Equatable {
  const ShapeDropSettings({
    this.sessionSeconds = 60,
    this.rewardMultiplier = 1.0,
    this.objectLearningEnabled = true,
    this.sequentialMode = false,
    this.enabledShapes = ShapeCatalog.preschoolCore,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
    this.uppercaseLabels = true,
  });

  final int sessionSeconds;
  final double rewardMultiplier;
  final bool objectLearningEnabled;
  final bool sequentialMode;
  final List<ShapeKind> enabledShapes;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;
  final bool uppercaseLabels;

  List<ShapeKind> get activeShapes =>
      enabledShapes.isEmpty ? ShapeCatalog.preschoolCore : enabledShapes;

  ShapeDropSettings copyWith({
    int? sessionSeconds,
    double? rewardMultiplier,
    bool? objectLearningEnabled,
    bool? sequentialMode,
    List<ShapeKind>? enabledShapes,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
    bool? uppercaseLabels,
  }) =>
      ShapeDropSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        objectLearningEnabled:
            objectLearningEnabled ?? this.objectLearningEnabled,
        sequentialMode: sequentialMode ?? this.sequentialMode,
        enabledShapes: enabledShapes ?? this.enabledShapes,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
        uppercaseLabels: uppercaseLabels ?? this.uppercaseLabels,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'rewardMultiplier': rewardMultiplier,
        'objectLearningEnabled': objectLearningEnabled,
        'sequentialMode': sequentialMode,
        'enabledShapes': enabledShapes.map((e) => e.name).toList(),
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
        'uppercaseLabels': uppercaseLabels,
      };

  factory ShapeDropSettings.fromJson(Map<String, dynamic> json) {
    final names = (json['enabledShapes'] as List?)?.cast<String>() ?? [];
    final shapes = names
        .map(
          (n) => ShapeKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => ShapeKind.circle,
          ),
        )
        .toSet()
        .toList();
    return ShapeDropSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      objectLearningEnabled: json['objectLearningEnabled'] as bool? ?? true,
      sequentialMode: json['sequentialMode'] as bool? ?? false,
      enabledShapes: shapes.isEmpty ? ShapeCatalog.preschoolCore : shapes,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
      uppercaseLabels: json['uppercaseLabels'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        rewardMultiplier,
        objectLearningEnabled,
        sequentialMode,
        enabledShapes,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
        uppercaseLabels,
      ];
}

class ShapeOption extends Equatable {
  const ShapeOption({
    required this.id,
    required this.def,
    required this.presentation,
    this.matched = false,
    this.shake = false,
  });

  final String id;
  final ShapeDef def;
  final ShapePresentation presentation;
  final bool matched;
  final bool shake;

  ShapeOption copyWith({bool? matched, bool? shake}) => ShapeOption(
        id: id,
        def: def,
        presentation: presentation,
        matched: matched ?? this.matched,
        shake: shake ?? this.shake,
      );

  @override
  List<Object?> get props => [id, def, presentation, matched, shake];
}

class ShapeDropState extends Equatable {
  const ShapeDropState({
    this.phase = ShapeDropPhase.ready,
    this.settings = const ShapeDropSettings(),
    this.target,
    this.options = const [],
    this.remainingSeconds = 60,
    this.score = 0,
    this.correctMatches = 0,
    this.attempts = 0,
    this.wrongOnCurrent = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.outlineGlow = false,
    this.filled = false,
    this.sequentialIndex = 0,
    this.learnedShapes = const {},
    this.favoriteShape,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.pendingEnd = false,
    this.envPhase = 0,
  });

  final ShapeDropPhase phase;
  final ShapeDropSettings settings;
  final ShapeDef? target;
  final List<ShapeOption> options;
  final int remainingSeconds;
  final int score;
  final int correctMatches;
  final int attempts;
  final int wrongOnCurrent;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final bool outlineGlow;
  final bool filled;
  final int sequentialIndex;
  final Set<ShapeKind> learnedShapes;
  final ShapeKind? favoriteShape;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool pendingEnd;
  final double envPhase;

  ShapeDropState copyWith({
    ShapeDropPhase? phase,
    ShapeDropSettings? settings,
    ShapeDef? target,
    List<ShapeOption>? options,
    int? remainingSeconds,
    int? score,
    int? correctMatches,
    int? attempts,
    int? wrongOnCurrent,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    bool? outlineGlow,
    bool? filled,
    int? sequentialIndex,
    Set<ShapeKind>? learnedShapes,
    ShapeKind? favoriteShape,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? pendingEnd,
    double? envPhase,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearTarget = false,
  }) =>
      ShapeDropState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        target: clearTarget ? null : (target ?? this.target),
        options: options ?? this.options,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        correctMatches: correctMatches ?? this.correctMatches,
        attempts: attempts ?? this.attempts,
        wrongOnCurrent: wrongOnCurrent ?? this.wrongOnCurrent,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        outlineGlow: outlineGlow ?? this.outlineGlow,
        filled: filled ?? this.filled,
        sequentialIndex: sequentialIndex ?? this.sequentialIndex,
        learnedShapes: learnedShapes ?? this.learnedShapes,
        favoriteShape: favoriteShape ?? this.favoriteShape,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: showMascot ?? this.showMascot,
        showSparkles: showSparkles ?? this.showSparkles,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        target,
        options,
        remainingSeconds,
        score,
        correctMatches,
        attempts,
        wrongOnCurrent,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        outlineGlow,
        filled,
        sequentialIndex,
        learnedShapes,
        favoriteShape,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        pendingEnd,
        envPhase,
      ];
}

class ShapeDropResult extends Equatable {
  const ShapeDropResult({
    required this.score,
    required this.correctMatches,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    required this.accuracy,
    required this.shapesLearned,
    this.favoriteShape,
  });

  final int score;
  final int correctMatches;
  final int attempts;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;
  final double accuracy;
  final int shapesLearned;
  final ShapeKind? favoriteShape;

  @override
  List<Object?> get props => [
        score,
        correctMatches,
        attempts,
        maxStreak,
        coins,
        xp,
        stars,
        sessionSeconds,
        accuracy,
        shapesLearned,
        favoriteShape,
      ];
}

const kShapeDropSkills = [
  'Shape Recognition',
  'Object Association',
  'Drag & Drop',
  'Fine Motor Skills',
  'Visual Discrimination',
  'Early Geometry',
];

const kShapeDropRight = [
  'Amazing!',
  'Fantastic!',
  'You Found the Shape!',
  'Wonderful!',
  'Great Job!',
  'Super Star!',
];

const kShapeDropWrong = [
  'Almost!',
  "Let's Try Another Shape!",
  'Good Try!',
  'Can You Find the Right One?',
  'You Can Do It!',
];
