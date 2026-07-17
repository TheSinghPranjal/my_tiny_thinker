import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SortBagsPhase { ready, playing, paused, celebrating, finished }

enum BagColorKind {
  red,
  blue,
  green,
  yellow,
  orange,
  pink,
  purple,
  brown,
  grey,
  black,
  white,
  skyBlue,
  navy,
  lightBlue,
  lightGreen,
  magenta,
  lilac,
  silver,
  gold,
}

class BagColorDef extends Equatable {
  const BagColorDef({
    required this.kind,
    required this.name,
    required this.color,
    required this.accent,
  });

  final BagColorKind kind;
  final String name;
  final Color color;
  final Color accent;

  @override
  List<Object?> get props => [kind, name, color, accent];
}

abstract final class BagColorCatalog {
  static const defaultEnabled = <BagColorKind>[
    BagColorKind.red,
    BagColorKind.blue,
    BagColorKind.green,
    BagColorKind.yellow,
  ];

  /// High-contrast starter set for level 1.
  static const contrasting = <BagColorKind>[
    BagColorKind.red,
    BagColorKind.blue,
    BagColorKind.green,
    BagColorKind.yellow,
    BagColorKind.orange,
    BagColorKind.purple,
    BagColorKind.pink,
  ];

  static BagColorDef def(BagColorKind kind) => switch (kind) {
        BagColorKind.red => const BagColorDef(
            kind: BagColorKind.red,
            name: 'Red',
            color: Color(0xFFE53935),
            accent: Color(0xFFFF8A80),
          ),
        BagColorKind.blue => const BagColorDef(
            kind: BagColorKind.blue,
            name: 'Blue',
            color: Color(0xFF1E88E5),
            accent: Color(0xFF90CAF9),
          ),
        BagColorKind.green => const BagColorDef(
            kind: BagColorKind.green,
            name: 'Green',
            color: Color(0xFF43A047),
            accent: Color(0xFFA5D6A7),
          ),
        BagColorKind.yellow => const BagColorDef(
            kind: BagColorKind.yellow,
            name: 'Yellow',
            color: Color(0xFFFDD835),
            accent: Color(0xFFFFF59D),
          ),
        BagColorKind.orange => const BagColorDef(
            kind: BagColorKind.orange,
            name: 'Orange',
            color: Color(0xFFFB8C00),
            accent: Color(0xFFFFCC80),
          ),
        BagColorKind.pink => const BagColorDef(
            kind: BagColorKind.pink,
            name: 'Pink',
            color: Color(0xFFEC407A),
            accent: Color(0xFFF8BBD0),
          ),
        BagColorKind.purple => const BagColorDef(
            kind: BagColorKind.purple,
            name: 'Purple',
            color: Color(0xFF8E24AA),
            accent: Color(0xFFCE93D8),
          ),
        BagColorKind.brown => const BagColorDef(
            kind: BagColorKind.brown,
            name: 'Brown',
            color: Color(0xFF6D4C41),
            accent: Color(0xFFBCAAA4),
          ),
        BagColorKind.grey => const BagColorDef(
            kind: BagColorKind.grey,
            name: 'Grey',
            color: Color(0xFF9E9E9E),
            accent: Color(0xFFE0E0E0),
          ),
        BagColorKind.black => const BagColorDef(
            kind: BagColorKind.black,
            name: 'Black',
            color: Color(0xFF37474F),
            accent: Color(0xFF90A4AE),
          ),
        BagColorKind.white => const BagColorDef(
            kind: BagColorKind.white,
            name: 'White',
            color: Color(0xFFFAFAFA),
            accent: Color(0xFFE0E0E0),
          ),
        BagColorKind.skyBlue => const BagColorDef(
            kind: BagColorKind.skyBlue,
            name: 'Sky Blue',
            color: Color(0xFF4FC3F7),
            accent: Color(0xFFB3E5FC),
          ),
        BagColorKind.navy => const BagColorDef(
            kind: BagColorKind.navy,
            name: 'Navy',
            color: Color(0xFF1A237E),
            accent: Color(0xFF7986CB),
          ),
        BagColorKind.lightBlue => const BagColorDef(
            kind: BagColorKind.lightBlue,
            name: 'Light Blue',
            color: Color(0xFF81D4FA),
            accent: Color(0xFFE1F5FE),
          ),
        BagColorKind.lightGreen => const BagColorDef(
            kind: BagColorKind.lightGreen,
            name: 'Light Green',
            color: Color(0xFFAED581),
            accent: Color(0xFFDCEDC8),
          ),
        BagColorKind.magenta => const BagColorDef(
            kind: BagColorKind.magenta,
            name: 'Magenta',
            color: Color(0xFFD500F9),
            accent: Color(0xFFE1BEE7),
          ),
        BagColorKind.lilac => const BagColorDef(
            kind: BagColorKind.lilac,
            name: 'Lilac',
            color: Color(0xFFB39DDB),
            accent: Color(0xFFEDE7F6),
          ),
        BagColorKind.silver => const BagColorDef(
            kind: BagColorKind.silver,
            name: 'Silver',
            color: Color(0xFFB0BEC5),
            accent: Color(0xFFECEFF1),
          ),
        BagColorKind.gold => const BagColorDef(
            kind: BagColorKind.gold,
            name: 'Gold',
            color: Color(0xFFFFC107),
            accent: Color(0xFFFFECB3),
          ),
      };
}

class SortBook extends Equatable {
  const SortBook({
    required this.id,
    required this.colorKind,
    this.matched = false,
    this.shake = false,
    this.floatPhase = 0,
  });

  final String id;
  final BagColorKind colorKind;
  final bool matched;
  final bool shake;
  final double floatPhase;

  BagColorDef get colorDef => BagColorCatalog.def(colorKind);

  SortBook copyWith({
    bool? matched,
    bool? shake,
    double? floatPhase,
  }) =>
      SortBook(
        id: id,
        colorKind: colorKind,
        matched: matched ?? this.matched,
        shake: shake ?? this.shake,
        floatPhase: floatPhase ?? this.floatPhase,
      );

  @override
  List<Object?> get props => [id, colorKind, matched, shake, floatPhase];
}

class SortBackpack extends Equatable {
  const SortBackpack({
    required this.id,
    required this.colorKind,
    this.open = false,
    this.filled = false,
    this.glow = false,
    this.hintPulse = false,
    this.smiling = false,
    this.breathPhase = 0,
  });

  final String id;
  final BagColorKind colorKind;
  final bool open;
  final bool filled;
  final bool glow;
  final bool hintPulse;
  final bool smiling;
  final double breathPhase;

  BagColorDef get colorDef => BagColorCatalog.def(colorKind);

  SortBackpack copyWith({
    bool? open,
    bool? filled,
    bool? glow,
    bool? hintPulse,
    bool? smiling,
    double? breathPhase,
  }) =>
      SortBackpack(
        id: id,
        colorKind: colorKind,
        open: open ?? this.open,
        filled: filled ?? this.filled,
        glow: glow ?? this.glow,
        hintPulse: hintPulse ?? this.hintPulse,
        smiling: smiling ?? this.smiling,
        breathPhase: breathPhase ?? this.breathPhase,
      );

  @override
  List<Object?> get props =>
      [id, colorKind, open, filled, glow, hintPulse, smiling, breathPhase];
}

class SortBagsSettings extends Equatable {
  const SortBagsSettings({
    this.sessionSeconds = 60,
    this.enabledColors = BagColorCatalog.defaultEnabled,
    this.maxBackpacks = 3,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final List<BagColorKind> enabledColors;
  final int maxBackpacks;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  List<BagColorKind> get activeColors =>
      enabledColors.length >= 2 ? enabledColors : BagColorCatalog.defaultEnabled;

  SortBagsSettings copyWith({
    int? sessionSeconds,
    List<BagColorKind>? enabledColors,
    int? maxBackpacks,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      SortBagsSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        enabledColors: enabledColors ?? this.enabledColors,
        maxBackpacks: maxBackpacks ?? this.maxBackpacks,
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
        'enabledColors': enabledColors.map((e) => e.name).toList(),
        'maxBackpacks': maxBackpacks,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory SortBagsSettings.fromJson(Map<String, dynamic> json) {
    final names = (json['enabledColors'] as List?)?.cast<String>() ?? [];
    final colors = names
        .map(
          (n) => BagColorKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => BagColorKind.red,
          ),
        )
        .toSet()
        .toList();
    return SortBagsSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
      enabledColors:
          colors.length >= 2 ? colors : BagColorCatalog.defaultEnabled,
      maxBackpacks: (json['maxBackpacks'] as int? ?? 3).clamp(2, 6),
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
        enabledColors,
        maxBackpacks,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class SortBagsState extends Equatable {
  const SortBagsState({
    this.phase = SortBagsPhase.ready,
    this.settings = const SortBagsSettings(),
    this.books = const [],
    this.backpacks = const [],
    this.level = 1,
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
    this.spokenColorName,
    this.showSparkles = false,
    this.showMascot = false,
    this.showMilestone = false,
    this.pendingEnd = false,
    this.envPhase = 0,
    this.hoverBagId,
  });

  final SortBagsPhase phase;
  final SortBagsSettings settings;
  final List<SortBook> books;
  final List<SortBackpack> backpacks;
  final int level;
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
  final String? spokenColorName;
  final bool showSparkles;
  final bool showMascot;
  final bool showMilestone;
  final bool pendingEnd;
  final double envPhase;
  final String? hoverBagId;

  bool get roundComplete =>
      books.isNotEmpty && books.every((b) => b.matched);

  SortBagsState copyWith({
    SortBagsPhase? phase,
    SortBagsSettings? settings,
    List<SortBook>? books,
    List<SortBackpack>? backpacks,
    int? level,
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
    String? spokenColorName,
    bool? showSparkles,
    bool? showMascot,
    bool? showMilestone,
    bool? pendingEnd,
    double? envPhase,
    String? hoverBagId,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearSpoken = false,
    bool clearHover = false,
  }) =>
      SortBagsState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        books: books ?? this.books,
        backpacks: backpacks ?? this.backpacks,
        level: level ?? this.level,
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
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        spokenColorName:
            clearSpoken ? null : (spokenColorName ?? this.spokenColorName),
        showSparkles: showSparkles ?? this.showSparkles,
        showMascot: showMascot ?? this.showMascot,
        showMilestone: showMilestone ?? this.showMilestone,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
        hoverBagId: clearHover ? null : (hoverBagId ?? this.hoverBagId),
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        books,
        backpacks,
        level,
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
        spokenColorName,
        showSparkles,
        showMascot,
        showMilestone,
        pendingEnd,
        envPhase,
        hoverBagId,
      ];
}

class SortBagsResult extends Equatable {
  const SortBagsResult({
    required this.score,
    required this.correctMatches,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.levelReached,
    required this.accuracy,
  });

  final int score;
  final int correctMatches;
  final int attempts;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;
  final int levelReached;
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
        levelReached,
        accuracy,
      ];
}

const kSortBagsSkills = [
  'Color Recognition',
  'Color Vocabulary',
  'Matching Skills',
  'Drag-and-Drop Coordination',
  'Fine Motor Skills',
  'Hand-Eye Coordination',
];

/// Session length presets in seconds (30s … 30 min).
const kSortBagsSessionPresets = [30, 60, 90, 120, 300, 600, 1800];
