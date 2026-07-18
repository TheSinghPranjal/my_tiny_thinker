import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ColorShapeBridgePhase { ready, playing, paused, celebrating, finished }

enum ColorShapeBridgeMode { color, shape, colorShape }

enum BridgeColorKind {
  red,
  blue,
  green,
  yellow,
  orange,
  pink,
  purple,
  brown,
  black,
  white,
  grey,
  navy,
  skyBlue,
  maroon,
  violet,
  cyan,
  lime,
  olive,
  gold,
  silver,
}

enum BridgeShapeKind {
  circle,
  triangle,
  square,
  rectangle,
  rhombus,
  pentagon,
  hexagon,
  octagon,
  oval,
  heart,
  star,
  crescent,
  arrow,
  trapezium,
  parallelogram,
  cross,
  cylinder,
  cube,
  sphere,
}

class BridgeColorDef extends Equatable {
  const BridgeColorDef({
    required this.kind,
    required this.name,
    required this.color,
  });

  final BridgeColorKind kind;
  final String name;
  final Color color;

  @override
  List<Object?> get props => [kind, name, color];
}

class BridgeShapeDef extends Equatable {
  const BridgeShapeDef({
    required this.kind,
    required this.name,
  });

  final BridgeShapeKind kind;
  final String name;

  @override
  List<Object?> get props => [kind, name];
}

abstract final class ColorShapeCatalog {
  static const defaultColors = <BridgeColorKind>[
    BridgeColorKind.red,
    BridgeColorKind.blue,
    BridgeColorKind.green,
    BridgeColorKind.yellow,
    BridgeColorKind.orange,
    BridgeColorKind.pink,
    BridgeColorKind.purple,
    BridgeColorKind.brown,
  ];

  static const defaultShapes = <BridgeShapeKind>[
    BridgeShapeKind.circle,
    BridgeShapeKind.triangle,
    BridgeShapeKind.square,
    BridgeShapeKind.rectangle,
    BridgeShapeKind.star,
    BridgeShapeKind.heart,
    BridgeShapeKind.hexagon,
    BridgeShapeKind.oval,
  ];

  static BridgeColorDef color(BridgeColorKind kind) => switch (kind) {
        BridgeColorKind.red => const BridgeColorDef(
            kind: BridgeColorKind.red, name: 'Red', color: Color(0xFFE53935)),
        BridgeColorKind.blue => const BridgeColorDef(
            kind: BridgeColorKind.blue, name: 'Blue', color: Color(0xFF1E88E5)),
        BridgeColorKind.green => const BridgeColorDef(
            kind: BridgeColorKind.green, name: 'Green', color: Color(0xFF43A047)),
        BridgeColorKind.yellow => const BridgeColorDef(
            kind: BridgeColorKind.yellow,
            name: 'Yellow',
            color: Color(0xFFFDD835)),
        BridgeColorKind.orange => const BridgeColorDef(
            kind: BridgeColorKind.orange,
            name: 'Orange',
            color: Color(0xFFFB8C00)),
        BridgeColorKind.pink => const BridgeColorDef(
            kind: BridgeColorKind.pink, name: 'Pink', color: Color(0xFFEC407A)),
        BridgeColorKind.purple => const BridgeColorDef(
            kind: BridgeColorKind.purple,
            name: 'Purple',
            color: Color(0xFF8E24AA)),
        BridgeColorKind.brown => const BridgeColorDef(
            kind: BridgeColorKind.brown, name: 'Brown', color: Color(0xFF6D4C41)),
        BridgeColorKind.black => const BridgeColorDef(
            kind: BridgeColorKind.black, name: 'Black', color: Color(0xFF37474F)),
        BridgeColorKind.white => const BridgeColorDef(
            kind: BridgeColorKind.white, name: 'White', color: Color(0xFFFAFAFA)),
        BridgeColorKind.grey => const BridgeColorDef(
            kind: BridgeColorKind.grey, name: 'Grey', color: Color(0xFF9E9E9E)),
        BridgeColorKind.navy => const BridgeColorDef(
            kind: BridgeColorKind.navy,
            name: 'Navy Blue',
            color: Color(0xFF1A237E)),
        BridgeColorKind.skyBlue => const BridgeColorDef(
            kind: BridgeColorKind.skyBlue,
            name: 'Sky Blue',
            color: Color(0xFF4FC3F7)),
        BridgeColorKind.maroon => const BridgeColorDef(
            kind: BridgeColorKind.maroon,
            name: 'Maroon',
            color: Color(0xFF880E4F)),
        BridgeColorKind.violet => const BridgeColorDef(
            kind: BridgeColorKind.violet,
            name: 'Violet',
            color: Color(0xFF7E57C2)),
        BridgeColorKind.cyan => const BridgeColorDef(
            kind: BridgeColorKind.cyan, name: 'Cyan', color: Color(0xFF00ACC1)),
        BridgeColorKind.lime => const BridgeColorDef(
            kind: BridgeColorKind.lime,
            name: 'Lime Green',
            color: Color(0xFFC0CA33)),
        BridgeColorKind.olive => const BridgeColorDef(
            kind: BridgeColorKind.olive,
            name: 'Olive Green',
            color: Color(0xFF827717)),
        BridgeColorKind.gold => const BridgeColorDef(
            kind: BridgeColorKind.gold, name: 'Gold', color: Color(0xFFFFB300)),
        BridgeColorKind.silver => const BridgeColorDef(
            kind: BridgeColorKind.silver,
            name: 'Silver',
            color: Color(0xFFB0BEC5)),
      };

  static BridgeShapeDef shape(BridgeShapeKind kind) => switch (kind) {
        BridgeShapeKind.circle =>
          const BridgeShapeDef(kind: BridgeShapeKind.circle, name: 'Circle'),
        BridgeShapeKind.triangle =>
          const BridgeShapeDef(kind: BridgeShapeKind.triangle, name: 'Triangle'),
        BridgeShapeKind.square =>
          const BridgeShapeDef(kind: BridgeShapeKind.square, name: 'Square'),
        BridgeShapeKind.rectangle => const BridgeShapeDef(
            kind: BridgeShapeKind.rectangle, name: 'Rectangle'),
        BridgeShapeKind.rhombus => const BridgeShapeDef(
            kind: BridgeShapeKind.rhombus, name: 'Rhombus'),
        BridgeShapeKind.pentagon => const BridgeShapeDef(
            kind: BridgeShapeKind.pentagon, name: 'Pentagon'),
        BridgeShapeKind.hexagon =>
          const BridgeShapeDef(kind: BridgeShapeKind.hexagon, name: 'Hexagon'),
        BridgeShapeKind.octagon =>
          const BridgeShapeDef(kind: BridgeShapeKind.octagon, name: 'Octagon'),
        BridgeShapeKind.oval =>
          const BridgeShapeDef(kind: BridgeShapeKind.oval, name: 'Oval'),
        BridgeShapeKind.heart =>
          const BridgeShapeDef(kind: BridgeShapeKind.heart, name: 'Heart'),
        BridgeShapeKind.star =>
          const BridgeShapeDef(kind: BridgeShapeKind.star, name: 'Star'),
        BridgeShapeKind.crescent => const BridgeShapeDef(
            kind: BridgeShapeKind.crescent, name: 'Crescent'),
        BridgeShapeKind.arrow =>
          const BridgeShapeDef(kind: BridgeShapeKind.arrow, name: 'Arrow'),
        BridgeShapeKind.trapezium => const BridgeShapeDef(
            kind: BridgeShapeKind.trapezium, name: 'Trapezium'),
        BridgeShapeKind.parallelogram => const BridgeShapeDef(
            kind: BridgeShapeKind.parallelogram, name: 'Parallelogram'),
        BridgeShapeKind.cross =>
          const BridgeShapeDef(kind: BridgeShapeKind.cross, name: 'Cross'),
        BridgeShapeKind.cylinder => const BridgeShapeDef(
            kind: BridgeShapeKind.cylinder, name: 'Cylinder'),
        BridgeShapeKind.cube =>
          const BridgeShapeDef(kind: BridgeShapeKind.cube, name: 'Cube'),
        BridgeShapeKind.sphere =>
          const BridgeShapeDef(kind: BridgeShapeKind.sphere, name: 'Sphere'),
      };

  static String matchKey({
    required ColorShapeBridgeMode mode,
    BridgeColorKind? color,
    BridgeShapeKind? shape,
  }) =>
      switch (mode) {
        ColorShapeBridgeMode.color => 'color_${color!.name}',
        ColorShapeBridgeMode.shape => 'shape_${shape!.name}',
        ColorShapeBridgeMode.colorShape =>
          'combo_${color!.name}_${shape!.name}',
      };

  static String promptLabel({
    required ColorShapeBridgeMode mode,
    BridgeColorKind? color,
    BridgeShapeKind? shape,
  }) =>
      switch (mode) {
        ColorShapeBridgeMode.color => ColorShapeCatalog.color(color!).name,
        ColorShapeBridgeMode.shape => ColorShapeCatalog.shape(shape!).name,
        ColorShapeBridgeMode.colorShape =>
          '${ColorShapeCatalog.color(color!).name} ${ColorShapeCatalog.shape(shape!).name}',
      };
}

class ColorShapePairCard extends Equatable {
  const ColorShapePairCard({
    required this.id,
    required this.matchKey,
    required this.isPrompt,
    required this.mode,
    this.colorKind,
    this.shapeKind,
    this.matched = false,
    this.selected = false,
    this.shake = false,
    this.hintPulse = false,
    this.celebrate = false,
    this.animPhase = 0,
  });

  final String id;
  final String matchKey;
  final bool isPrompt;
  final ColorShapeBridgeMode mode;
  final BridgeColorKind? colorKind;
  final BridgeShapeKind? shapeKind;
  final bool matched;
  final bool selected;
  final bool shake;
  final bool hintPulse;
  final bool celebrate;
  final double animPhase;

  String get label => ColorShapeCatalog.promptLabel(
        mode: mode,
        color: colorKind,
        shape: shapeKind,
      );

  Color get accent {
    if (colorKind != null) return ColorShapeCatalog.color(colorKind!).color;
    return const Color(0xFF7E57C2);
  }

  ColorShapePairCard copyWith({
    bool? matched,
    bool? selected,
    bool? shake,
    bool? hintPulse,
    bool? celebrate,
    double? animPhase,
  }) =>
      ColorShapePairCard(
        id: id,
        matchKey: matchKey,
        isPrompt: isPrompt,
        mode: mode,
        colorKind: colorKind,
        shapeKind: shapeKind,
        matched: matched ?? this.matched,
        selected: selected ?? this.selected,
        shake: shake ?? this.shake,
        hintPulse: hintPulse ?? this.hintPulse,
        celebrate: celebrate ?? this.celebrate,
        animPhase: animPhase ?? this.animPhase,
      );

  @override
  List<Object?> get props => [
        id,
        matchKey,
        isPrompt,
        mode,
        colorKind,
        shapeKind,
        matched,
        selected,
        shake,
        hintPulse,
        celebrate,
        animPhase,
      ];
}

class ColorShapeBridgeConnection extends Equatable {
  const ColorShapeBridgeConnection({
    required this.promptId,
    required this.visualId,
    required this.matchKey,
  });

  final String promptId;
  final String visualId;
  final String matchKey;

  @override
  List<Object?> get props => [promptId, visualId, matchKey];
}

class ColorShapeBridgeSettings extends Equatable {
  const ColorShapeBridgeSettings({
    this.sessionSeconds = 60,
    this.pairCount = 4,
    this.mode = ColorShapeBridgeMode.colorShape,
    this.enabledColors = ColorShapeCatalog.defaultColors,
    this.enabledShapes = ColorShapeCatalog.defaultShapes,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final int pairCount;
  final ColorShapeBridgeMode mode;
  final List<BridgeColorKind> enabledColors;
  final List<BridgeShapeKind> enabledShapes;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  List<BridgeColorKind> get activeColors => enabledColors.length >= 2
      ? enabledColors
      : ColorShapeCatalog.defaultColors;

  List<BridgeShapeKind> get activeShapes => enabledShapes.length >= 2
      ? enabledShapes
      : ColorShapeCatalog.defaultShapes;

  ColorShapeBridgeSettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    ColorShapeBridgeMode? mode,
    List<BridgeColorKind>? enabledColors,
    List<BridgeShapeKind>? enabledShapes,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      ColorShapeBridgeSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: pairCount ?? this.pairCount,
        mode: mode ?? this.mode,
        enabledColors: enabledColors ?? this.enabledColors,
        enabledShapes: enabledShapes ?? this.enabledShapes,
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
        'pairCount': pairCount,
        'mode': mode.name,
        'enabledColors': enabledColors.map((e) => e.name).toList(),
        'enabledShapes': enabledShapes.map((e) => e.name).toList(),
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory ColorShapeBridgeSettings.fromJson(Map<String, dynamic> json) {
    ColorShapeBridgeMode mode = ColorShapeBridgeMode.colorShape;
    for (final m in ColorShapeBridgeMode.values) {
      if (m.name == json['mode']) mode = m;
    }
    final colorNames = (json['enabledColors'] as List?)?.cast<String>() ?? [];
    final shapeNames = (json['enabledShapes'] as List?)?.cast<String>() ?? [];
    final colors = colorNames
        .map(
          (n) => BridgeColorKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => BridgeColorKind.red,
          ),
        )
        .toSet()
        .toList();
    final shapes = shapeNames
        .map(
          (n) => BridgeShapeKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => BridgeShapeKind.circle,
          ),
        )
        .toSet()
        .toList();
    return ColorShapeBridgeSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
      pairCount: (json['pairCount'] as int? ?? 4).clamp(3, 7),
      mode: mode,
      enabledColors:
          colors.length >= 2 ? colors : ColorShapeCatalog.defaultColors,
      enabledShapes:
          shapes.length >= 2 ? shapes : ColorShapeCatalog.defaultShapes,
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
        pairCount,
        mode,
        enabledColors,
        enabledShapes,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class ColorShapeBridgeState extends Equatable {
  const ColorShapeBridgeState({
    this.phase = ColorShapeBridgePhase.ready,
    this.settings = const ColorShapeBridgeSettings(),
    this.promptCards = const [],
    this.visualCards = const [],
    this.connections = const [],
    this.recentKeys = const [],
    this.round = 1,
    this.roundsCompleted = 0,
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
    this.lastRewardText,
    this.spokenPhrase,
    this.showSparkles = false,
    this.showMascot = false,
    this.showRoundBonus = false,
    this.pendingEnd = false,
    this.envPhase = 0,
  });

  final ColorShapeBridgePhase phase;
  final ColorShapeBridgeSettings settings;
  final List<ColorShapePairCard> promptCards;
  final List<ColorShapePairCard> visualCards;
  final List<ColorShapeBridgeConnection> connections;
  final List<String> recentKeys;
  final int round;
  final int roundsCompleted;
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
  final String? lastRewardText;
  final String? spokenPhrase;
  final bool showSparkles;
  final bool showMascot;
  final bool showRoundBonus;
  final bool pendingEnd;
  final double envPhase;

  bool get roundComplete =>
      promptCards.isNotEmpty && promptCards.every((c) => c.matched);

  ColorShapeBridgeState copyWith({
    ColorShapeBridgePhase? phase,
    ColorShapeBridgeSettings? settings,
    List<ColorShapePairCard>? promptCards,
    List<ColorShapePairCard>? visualCards,
    List<ColorShapeBridgeConnection>? connections,
    List<String>? recentKeys,
    int? round,
    int? roundsCompleted,
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
    String? lastRewardText,
    String? spokenPhrase,
    bool? showSparkles,
    bool? showMascot,
    bool? showRoundBonus,
    bool? pendingEnd,
    double? envPhase,
    bool clearFeedback = false,
    bool clearSpoken = false,
  }) =>
      ColorShapeBridgeState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        promptCards: promptCards ?? this.promptCards,
        visualCards: visualCards ?? this.visualCards,
        connections: connections ?? this.connections,
        recentKeys: recentKeys ?? this.recentKeys,
        round: round ?? this.round,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
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
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        spokenPhrase: clearSpoken ? null : (spokenPhrase ?? this.spokenPhrase),
        showSparkles: showSparkles ?? this.showSparkles,
        showMascot: showMascot ?? this.showMascot,
        showRoundBonus: showRoundBonus ?? this.showRoundBonus,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        promptCards,
        visualCards,
        connections,
        recentKeys,
        round,
        roundsCompleted,
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
        lastRewardText,
        spokenPhrase,
        showSparkles,
        showMascot,
        showRoundBonus,
        pendingEnd,
        envPhase,
      ];
}

class ColorShapeBridgeResult extends Equatable {
  const ColorShapeBridgeResult({
    required this.score,
    required this.correctMatches,
    required this.attempts,
    required this.maxStreak,
    required this.roundsCompleted,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.accuracy,
  });

  final int score;
  final int correctMatches;
  final int attempts;
  final int maxStreak;
  final int roundsCompleted;
  final int coins;
  final int xp;
  final int stars;
  final double accuracy;

  @override
  List<Object?> get props => [
        score,
        correctMatches,
        attempts,
        maxStreak,
        roundsCompleted,
        coins,
        xp,
        stars,
        accuracy,
      ];
}

const kColorShapeBridgeSkills = [
  'Color Recognition',
  'Shape Recognition',
  'Color-Shape Association',
  'Visual Discrimination',
  'Early Geometry',
  'Vocabulary',
];

const kColorShapeBridgeSessionPresets = [60, 120, 180, 300, 600, 900, 1800];

const kColorShapeBridgeEncourage = [
  'Good Try!',
  'Let\'s Try Again!',
  'Look Carefully!',
  'Can You Find the Matching Shape?',
];
