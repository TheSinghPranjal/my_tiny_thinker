import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NumberBridgePhase { ready, playing, paused, celebrating, finished }

class NumberPairCard extends Equatable {
  const NumberPairCard({
    required this.id,
    required this.value,
    required this.isDigit,
    this.matched = false,
    this.selected = false,
    this.shake = false,
    this.hintPulse = false,
    this.celebrate = false,
    this.animPhase = 0,
  });

  final String id;
  final int value;
  final bool isDigit;
  final bool matched;
  final bool selected;
  final bool shake;
  final bool hintPulse;
  final bool celebrate;
  final double animPhase;

  String get label => isDigit ? '$value' : NumberWords.word(value);
  Color get color => NumberBridgePalette.colorFor(value);

  NumberPairCard copyWith({
    bool? matched,
    bool? selected,
    bool? shake,
    bool? hintPulse,
    bool? celebrate,
    double? animPhase,
  }) =>
      NumberPairCard(
        id: id,
        value: value,
        isDigit: isDigit,
        matched: matched ?? this.matched,
        selected: selected ?? this.selected,
        shake: shake ?? this.shake,
        hintPulse: hintPulse ?? this.hintPulse,
        celebrate: celebrate ?? this.celebrate,
        animPhase: animPhase ?? this.animPhase,
      );

  @override
  List<Object?> get props =>
      [id, value, isDigit, matched, selected, shake, hintPulse, celebrate, animPhase];
}

class NumberBridgeConnection extends Equatable {
  const NumberBridgeConnection({
    required this.digitId,
    required this.wordId,
    required this.value,
  });

  final String digitId;
  final String wordId;
  final int value;

  @override
  List<Object?> get props => [digitId, wordId, value];
}

class NumberBridgeSettings extends Equatable {
  const NumberBridgeSettings({
    this.sessionSeconds = 60,
    this.pairCount = 4,
    this.maxNumber = 20,
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
  final int maxNumber;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  NumberBridgeSettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    int? maxNumber,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      NumberBridgeSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: pairCount ?? this.pairCount,
        maxNumber: maxNumber ?? this.maxNumber,
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
        'maxNumber': maxNumber,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory NumberBridgeSettings.fromJson(Map<String, dynamic> json) =>
      NumberBridgeSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
        pairCount: (json['pairCount'] as int? ?? 4).clamp(3, 7),
        maxNumber: (json['maxNumber'] as int? ?? 20).clamp(20, 100),
        rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        narrationEnabled: json['narrationEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        sessionSeconds,
        pairCount,
        maxNumber,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class NumberBridgeState extends Equatable {
  const NumberBridgeState({
    this.phase = NumberBridgePhase.ready,
    this.settings = const NumberBridgeSettings(),
    this.digitCards = const [],
    this.wordCards = const [],
    this.connections = const [],
    this.recentValues = const [],
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

  final NumberBridgePhase phase;
  final NumberBridgeSettings settings;
  final List<NumberPairCard> digitCards;
  final List<NumberPairCard> wordCards;
  final List<NumberBridgeConnection> connections;
  final List<int> recentValues;
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
      digitCards.isNotEmpty && digitCards.every((c) => c.matched);

  NumberBridgeState copyWith({
    NumberBridgePhase? phase,
    NumberBridgeSettings? settings,
    List<NumberPairCard>? digitCards,
    List<NumberPairCard>? wordCards,
    List<NumberBridgeConnection>? connections,
    List<int>? recentValues,
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
      NumberBridgeState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        digitCards: digitCards ?? this.digitCards,
        wordCards: wordCards ?? this.wordCards,
        connections: connections ?? this.connections,
        recentValues: recentValues ?? this.recentValues,
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
        digitCards,
        wordCards,
        connections,
        recentValues,
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

class NumberBridgeResult extends Equatable {
  const NumberBridgeResult({
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

abstract final class NumberWords {
  static const _ones = [
    'Zero',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  /// Converts [n] (0–9999) to an English number word.
  static String word(int n) {
    if (n < 0 || n > 9999) return '$n';
    if (n < 20) return _ones[n];
    if (n < 100) {
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return _tens[t];
      return '${_tens[t]}-${_ones[o].toLowerCase()}';
    }
    if (n < 1000) {
      final h = n ~/ 100;
      final rest = n % 100;
      if (rest == 0) return '${_ones[h]} Hundred';
      return '${_ones[h]} Hundred ${word(rest)}';
    }
    final th = n ~/ 1000;
    final rest = n % 1000;
    if (rest == 0) return '${_ones[th]} Thousand';
    return '${_ones[th]} Thousand ${word(rest)}';
  }
}

abstract final class NumberBridgePalette {
  static const colors = <Color>[
    Color(0xFFFF8A80),
    Color(0xFFFFCC80),
    Color(0xFFFFF59D),
    Color(0xFFA5D6A7),
    Color(0xFF80DEEA),
    Color(0xFF90CAF9),
    Color(0xFFCE93D8),
    Color(0xFFF48FB1),
  ];

  static Color colorFor(int value) => colors[(value - 1).abs() % colors.length];
}

const kNumberBridgeSkills = [
  'Number Recognition',
  'Number Words',
  'Early Reading',
  'Visual Matching',
  'Fine Motor Skills',
  'Hand-Eye Coordination',
];

const kNumberBridgeSessionPresets = [60, 120, 180, 300, 600, 900, 1800];

const kNumberBridgeEncourage = [
  'Good Try!',
  'Let\'s Try Again!',
  'Can You Find the Correct Number?',
  'Almost!',
];
