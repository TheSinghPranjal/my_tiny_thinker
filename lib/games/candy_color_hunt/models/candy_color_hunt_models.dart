import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CandyHuntPhase { ready, playing, paused, celebrating, finished }

enum CandyStyle { jelly, wrapped, hard, gummy, swirl }

enum CandyColorKind {
  red,
  blue,
  green,
  yellow,
  orange,
  pink,
  purple,
  brown,
  black,
  grey,
  white,
  navy,
  skyBlue,
  lightBlue,
  lightGreen,
  magenta,
  lilac,
  silver,
  gold,
}

class CandyColorDef extends Equatable {
  const CandyColorDef({
    required this.kind,
    required this.name,
    required this.color,
    required this.accent,
  });

  final CandyColorKind kind;
  final String name;
  final Color color;
  final Color accent;

  @override
  List<Object?> get props => [kind, name, color, accent];
}

abstract final class CandyColorCatalog {
  static const defaultEnabled = <CandyColorKind>[
    CandyColorKind.red,
    CandyColorKind.blue,
    CandyColorKind.green,
    CandyColorKind.yellow,
  ];

  static const all = CandyColorKind.values;

  static CandyColorDef def(CandyColorKind kind) => switch (kind) {
        CandyColorKind.red => const CandyColorDef(
            kind: CandyColorKind.red,
            name: 'Red',
            color: Color(0xFFE53935),
            accent: Color(0xFFFF8A80),
          ),
        CandyColorKind.blue => const CandyColorDef(
            kind: CandyColorKind.blue,
            name: 'Blue',
            color: Color(0xFF1E88E5),
            accent: Color(0xFF90CAF9),
          ),
        CandyColorKind.green => const CandyColorDef(
            kind: CandyColorKind.green,
            name: 'Green',
            color: Color(0xFF43A047),
            accent: Color(0xFFA5D6A7),
          ),
        CandyColorKind.yellow => const CandyColorDef(
            kind: CandyColorKind.yellow,
            name: 'Yellow',
            color: Color(0xFFFDD835),
            accent: Color(0xFFFFF59D),
          ),
        CandyColorKind.orange => const CandyColorDef(
            kind: CandyColorKind.orange,
            name: 'Orange',
            color: Color(0xFFFB8C00),
            accent: Color(0xFFFFCC80),
          ),
        CandyColorKind.pink => const CandyColorDef(
            kind: CandyColorKind.pink,
            name: 'Pink',
            color: Color(0xFFEC407A),
            accent: Color(0xFFF8BBD0),
          ),
        CandyColorKind.purple => const CandyColorDef(
            kind: CandyColorKind.purple,
            name: 'Purple',
            color: Color(0xFF8E24AA),
            accent: Color(0xFFCE93D8),
          ),
        CandyColorKind.brown => const CandyColorDef(
            kind: CandyColorKind.brown,
            name: 'Brown',
            color: Color(0xFF6D4C41),
            accent: Color(0xFFBCAAA4),
          ),
        CandyColorKind.black => const CandyColorDef(
            kind: CandyColorKind.black,
            name: 'Black',
            color: Color(0xFF37474F),
            accent: Color(0xFF90A4AE),
          ),
        CandyColorKind.grey => const CandyColorDef(
            kind: CandyColorKind.grey,
            name: 'Grey',
            color: Color(0xFF9E9E9E),
            accent: Color(0xFFE0E0E0),
          ),
        CandyColorKind.white => const CandyColorDef(
            kind: CandyColorKind.white,
            name: 'White',
            color: Color(0xFFFAFAFA),
            accent: Color(0xFFE0E0E0),
          ),
        CandyColorKind.navy => const CandyColorDef(
            kind: CandyColorKind.navy,
            name: 'Navy',
            color: Color(0xFF1A237E),
            accent: Color(0xFF7986CB),
          ),
        CandyColorKind.skyBlue => const CandyColorDef(
            kind: CandyColorKind.skyBlue,
            name: 'Sky Blue',
            color: Color(0xFF4FC3F7),
            accent: Color(0xFFB3E5FC),
          ),
        CandyColorKind.lightBlue => const CandyColorDef(
            kind: CandyColorKind.lightBlue,
            name: 'Light Blue',
            color: Color(0xFF81D4FA),
            accent: Color(0xFFE1F5FE),
          ),
        CandyColorKind.lightGreen => const CandyColorDef(
            kind: CandyColorKind.lightGreen,
            name: 'Light Green',
            color: Color(0xFFAED581),
            accent: Color(0xFFDCEDC8),
          ),
        CandyColorKind.magenta => const CandyColorDef(
            kind: CandyColorKind.magenta,
            name: 'Magenta',
            color: Color(0xFFD500F9),
            accent: Color(0xFFE1BEE7),
          ),
        CandyColorKind.lilac => const CandyColorDef(
            kind: CandyColorKind.lilac,
            name: 'Lilac',
            color: Color(0xFFB39DDB),
            accent: Color(0xFFEDE7F6),
          ),
        CandyColorKind.silver => const CandyColorDef(
            kind: CandyColorKind.silver,
            name: 'Silver',
            color: Color(0xFFB0BEC5),
            accent: Color(0xFFECEFF1),
          ),
        CandyColorKind.gold => const CandyColorDef(
            kind: CandyColorKind.gold,
            name: 'Gold',
            color: Color(0xFFFFC107),
            accent: Color(0xFFFFECB3),
          ),
      };
}

class CandyEntity extends Equatable {
  const CandyEntity({
    required this.id,
    required this.colorKind,
    required this.style,
    required this.slotIndex,
    this.wigglePhase = 0,
    this.pulseHint = false,
    this.wrongShake = false,
    this.eaten = false,
  });

  final String id;
  final CandyColorKind colorKind;
  final CandyStyle style;
  final int slotIndex;
  final double wigglePhase;
  final bool pulseHint;
  final bool wrongShake;
  final bool eaten;

  CandyColorDef get colorDef => CandyColorCatalog.def(colorKind);

  CandyEntity copyWith({
    double? wigglePhase,
    bool? pulseHint,
    bool? wrongShake,
    bool? eaten,
  }) =>
      CandyEntity(
        id: id,
        colorKind: colorKind,
        style: style,
        slotIndex: slotIndex,
        wigglePhase: wigglePhase ?? this.wigglePhase,
        pulseHint: pulseHint ?? this.pulseHint,
        wrongShake: wrongShake ?? this.wrongShake,
        eaten: eaten ?? this.eaten,
      );

  @override
  List<Object?> get props =>
      [id, colorKind, style, slotIndex, wigglePhase, pulseHint, wrongShake, eaten];
}

enum AntMood { idle, looking, happy, eating, shakeNo }

class CandyHuntSettings extends Equatable {
  const CandyHuntSettings({
    this.sessionSeconds = 60,
    this.enabledColors = CandyColorCatalog.defaultEnabled,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final List<CandyColorKind> enabledColors;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  List<CandyColorKind> get activeColors =>
      enabledColors.length >= 4 ? enabledColors : CandyColorCatalog.defaultEnabled;

  CandyHuntSettings copyWith({
    int? sessionSeconds,
    List<CandyColorKind>? enabledColors,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      CandyHuntSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        enabledColors: enabledColors ?? this.enabledColors,
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
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory CandyHuntSettings.fromJson(Map<String, dynamic> json) {
    final names = (json['enabledColors'] as List?)?.cast<String>() ?? [];
    final colors = names
        .map(
          (n) => CandyColorKind.values.firstWhere(
            (k) => k.name == n,
            orElse: () => CandyColorKind.red,
          ),
        )
        .toSet()
        .toList();
    return CandyHuntSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(30, 1800),
      enabledColors: colors.length >= 4 ? colors : CandyColorCatalog.defaultEnabled,
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
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class CandyHuntState extends Equatable {
  const CandyHuntState({
    this.phase = CandyHuntPhase.ready,
    this.settings = const CandyHuntSettings(),
    this.candies = const [],
    this.targetColor,
    this.remainingSeconds = 60,
    this.score = 0,
    this.correctTaps = 0,
    this.attempts = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.antMood = AntMood.idle,
    this.antAnimPhase = 0,
    this.blinkTimer = 0,
    this.bubbleScale = 1,
    this.feedbackMessage,
    this.lastRewardText,
    this.spokenColorName,
    this.showSparkles = false,
    this.showMascot = false,
    this.pendingEnd = false,
    this.envPhase = 0,
  });

  final CandyHuntPhase phase;
  final CandyHuntSettings settings;
  final List<CandyEntity> candies;
  final CandyColorKind? targetColor;
  final int remainingSeconds;
  final int score;
  final int correctTaps;
  final int attempts;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final AntMood antMood;
  final double antAnimPhase;
  final double blinkTimer;
  final double bubbleScale;
  final String? feedbackMessage;
  final String? lastRewardText;
  final String? spokenColorName;
  final bool showSparkles;
  final bool showMascot;
  final bool pendingEnd;
  final double envPhase;

  CandyColorDef? get targetDef =>
      targetColor == null ? null : CandyColorCatalog.def(targetColor!);

  CandyHuntState copyWith({
    CandyHuntPhase? phase,
    CandyHuntSettings? settings,
    List<CandyEntity>? candies,
    CandyColorKind? targetColor,
    int? remainingSeconds,
    int? score,
    int? correctTaps,
    int? attempts,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    AntMood? antMood,
    double? antAnimPhase,
    double? blinkTimer,
    double? bubbleScale,
    String? feedbackMessage,
    String? lastRewardText,
    String? spokenColorName,
    bool? showSparkles,
    bool? showMascot,
    bool? pendingEnd,
    double? envPhase,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearSpoken = false,
  }) =>
      CandyHuntState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        candies: candies ?? this.candies,
        targetColor: targetColor ?? this.targetColor,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        correctTaps: correctTaps ?? this.correctTaps,
        attempts: attempts ?? this.attempts,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        antMood: antMood ?? this.antMood,
        antAnimPhase: antAnimPhase ?? this.antAnimPhase,
        blinkTimer: blinkTimer ?? this.blinkTimer,
        bubbleScale: bubbleScale ?? this.bubbleScale,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        spokenColorName:
            clearSpoken ? null : (spokenColorName ?? this.spokenColorName),
        showSparkles: showSparkles ?? this.showSparkles,
        showMascot: showMascot ?? this.showMascot,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        candies,
        targetColor,
        remainingSeconds,
        score,
        correctTaps,
        attempts,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        antMood,
        antAnimPhase,
        blinkTimer,
        bubbleScale,
        feedbackMessage,
        lastRewardText,
        spokenColorName,
        showSparkles,
        showMascot,
        pendingEnd,
        envPhase,
      ];
}

class CandyHuntResult extends Equatable {
  const CandyHuntResult({
    required this.score,
    required this.correctTaps,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    required this.accuracy,
  });

  final int score;
  final int correctTaps;
  final int attempts;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;
  final double accuracy;

  @override
  List<Object?> get props => [
        score,
        correctTaps,
        attempts,
        maxStreak,
        coins,
        xp,
        stars,
        sessionSeconds,
        accuracy,
      ];
}

const kCandyHuntSkills = [
  'Color Recognition',
  'Color Vocabulary',
  'Visual Discrimination',
  'Hand-Eye Coordination',
  'Fine Motor Skills',
  'Listening Skills',
];

const kCandySessionPresets = [30, 60, 90, 120, 300, 600, 1800];
