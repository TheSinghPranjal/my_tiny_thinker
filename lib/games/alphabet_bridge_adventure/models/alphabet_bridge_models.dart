import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AlphabetBridgePhase { ready, playing, paused, celebrating, finished }

enum AlphabetOrderMode { random, sequential }

enum AlphabetPracticeMode { mixed, uppercaseOnly, lowercaseOnly }

/// English letter A–Z (index 0 = A).
class AlphabetLetter extends Equatable {
  const AlphabetLetter(this.index);

  final int index;

  String get upper => String.fromCharCode(65 + index);
  String get lower => String.fromCharCode(97 + index);

  @override
  List<Object?> get props => [index];
}

abstract final class AlphabetCatalog {
  static final all = [
    for (var i = 0; i < 26; i++) AlphabetLetter(i),
  ];

  static const cardColors = <Color>[
    Color(0xFFFF8A80),
    Color(0xFFFFCC80),
    Color(0xFFFFF59D),
    Color(0xFFA5D6A7),
    Color(0xFF80DEEA),
    Color(0xFF90CAF9),
    Color(0xFFCE93D8),
    Color(0xFFF48FB1),
  ];

  static Color colorFor(int letterIndex) =>
      cardColors[letterIndex % cardColors.length];
}

class BridgeCard extends Equatable {
  const BridgeCard({
    required this.id,
    required this.letterIndex,
    required this.isUppercase,
    this.matched = false,
    this.selected = false,
    this.shake = false,
    this.hintPulse = false,
    this.celebrate = false,
    this.floatPhase = 0,
  });

  final String id;
  final int letterIndex;
  final bool isUppercase;
  final bool matched;
  final bool selected;
  final bool shake;
  final bool hintPulse;
  final bool celebrate;
  final double floatPhase;

  AlphabetLetter get letter => AlphabetLetter(letterIndex);
  String get glyph => isUppercase ? letter.upper : letter.lower;
  Color get color => AlphabetCatalog.colorFor(letterIndex);

  BridgeCard copyWith({
    bool? matched,
    bool? selected,
    bool? shake,
    bool? hintPulse,
    bool? celebrate,
    double? floatPhase,
  }) =>
      BridgeCard(
        id: id,
        letterIndex: letterIndex,
        isUppercase: isUppercase,
        matched: matched ?? this.matched,
        selected: selected ?? this.selected,
        shake: shake ?? this.shake,
        hintPulse: hintPulse ?? this.hintPulse,
        celebrate: celebrate ?? this.celebrate,
        floatPhase: floatPhase ?? this.floatPhase,
      );

  @override
  List<Object?> get props => [
        id,
        letterIndex,
        isUppercase,
        matched,
        selected,
        shake,
        hintPulse,
        celebrate,
        floatPhase,
      ];
}

class BridgeConnection extends Equatable {
  const BridgeConnection({
    required this.lowerId,
    required this.upperId,
    required this.letterIndex,
  });

  final String lowerId;
  final String upperId;
  final int letterIndex;

  @override
  List<Object?> get props => [lowerId, upperId, letterIndex];
}

class AlphabetBridgeSettings extends Equatable {
  const AlphabetBridgeSettings({
    this.sessionSeconds = 60,
    this.pairCount = 4,
    this.orderMode = AlphabetOrderMode.random,
    this.practiceMode = AlphabetPracticeMode.mixed,
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
  final AlphabetOrderMode orderMode;
  final AlphabetPracticeMode practiceMode;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  AlphabetBridgeSettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    AlphabetOrderMode? orderMode,
    AlphabetPracticeMode? practiceMode,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      AlphabetBridgeSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: pairCount ?? this.pairCount,
        orderMode: orderMode ?? this.orderMode,
        practiceMode: practiceMode ?? this.practiceMode,
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
        'orderMode': orderMode.name,
        'practiceMode': practiceMode.name,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory AlphabetBridgeSettings.fromJson(Map<String, dynamic> json) {
    AlphabetOrderMode order = AlphabetOrderMode.random;
    for (final m in AlphabetOrderMode.values) {
      if (m.name == json['orderMode']) order = m;
    }
    AlphabetPracticeMode practice = AlphabetPracticeMode.mixed;
    for (final m in AlphabetPracticeMode.values) {
      if (m.name == json['practiceMode']) practice = m;
    }
    return AlphabetBridgeSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
      pairCount: (json['pairCount'] as int? ?? 4).clamp(3, 7),
      orderMode: order,
      practiceMode: practice,
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
        orderMode,
        practiceMode,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class AlphabetBridgeState extends Equatable {
  const AlphabetBridgeState({
    this.phase = AlphabetBridgePhase.ready,
    this.settings = const AlphabetBridgeSettings(),
    this.lowerCards = const [],
    this.upperCards = const [],
    this.connections = const [],
    this.recentLetterIndexes = const [],
    this.sequentialCursor = 0,
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

  final AlphabetBridgePhase phase;
  final AlphabetBridgeSettings settings;
  final List<BridgeCard> lowerCards;
  final List<BridgeCard> upperCards;
  final List<BridgeConnection> connections;
  final List<int> recentLetterIndexes;
  final int sequentialCursor;
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
      lowerCards.isNotEmpty && lowerCards.every((c) => c.matched);

  AlphabetBridgeState copyWith({
    AlphabetBridgePhase? phase,
    AlphabetBridgeSettings? settings,
    List<BridgeCard>? lowerCards,
    List<BridgeCard>? upperCards,
    List<BridgeConnection>? connections,
    List<int>? recentLetterIndexes,
    int? sequentialCursor,
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
      AlphabetBridgeState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        lowerCards: lowerCards ?? this.lowerCards,
        upperCards: upperCards ?? this.upperCards,
        connections: connections ?? this.connections,
        recentLetterIndexes: recentLetterIndexes ?? this.recentLetterIndexes,
        sequentialCursor: sequentialCursor ?? this.sequentialCursor,
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
        lowerCards,
        upperCards,
        connections,
        recentLetterIndexes,
        sequentialCursor,
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

class AlphabetBridgeResult extends Equatable {
  const AlphabetBridgeResult({
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

const kAlphabetBridgeSkills = [
  'Alphabet Recognition',
  'Uppercase & Lowercase',
  'Visual Discrimination',
  'Line Tracing',
  'Fine Motor Skills',
  'Hand-Eye Coordination',
];

/// Session presets: 1–30 minutes (plus 60s default friendly options).
const kAlphabetBridgeSessionPresets = [60, 120, 180, 300, 600, 900, 1800];

const kAlphabetBridgeEncourage = [
  'Almost! Let\'s Try Again!',
  'Good Try!',
  'Can You Find the Matching Letter?',
  'Let\'s Look Carefully!',
];
