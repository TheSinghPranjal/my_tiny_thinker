import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

enum PictureBridgePhase { ready, playing, paused, celebrating, finished }

class PicturePairCard extends Equatable {
  const PicturePairCard({
    required this.id,
    required this.vocabId,
    required this.isPicture,
    this.matched = false,
    this.selected = false,
    this.shake = false,
    this.hintPulse = false,
    this.celebrate = false,
    this.animPhase = 0,
  });

  final String id;
  final String vocabId;
  final bool isPicture;
  final bool matched;
  final bool selected;
  final bool shake;
  final bool hintPulse;
  final bool celebrate;
  final double animPhase;

  VocabItem? get vocab => EducationVocabulary.byId(vocabId);
  String get label => isPicture ? (vocab?.emoji ?? '?') : (vocab?.name ?? '?');
  Color get color => PictureBridgePalette.colorFor(vocabId);

  PicturePairCard copyWith({
    bool? matched,
    bool? selected,
    bool? shake,
    bool? hintPulse,
    bool? celebrate,
    double? animPhase,
  }) =>
      PicturePairCard(
        id: id,
        vocabId: vocabId,
        isPicture: isPicture,
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
        vocabId,
        isPicture,
        matched,
        selected,
        shake,
        hintPulse,
        celebrate,
        animPhase,
      ];
}

class PictureBridgeConnection extends Equatable {
  const PictureBridgeConnection({
    required this.pictureId,
    required this.wordId,
    required this.vocabId,
  });

  final String pictureId;
  final String wordId;
  final String vocabId;

  @override
  List<Object?> get props => [pictureId, wordId, vocabId];
}

class PictureBridgeSettings extends Equatable {
  const PictureBridgeSettings({
    this.sessionSeconds = 60,
    this.pairCount = 4,
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
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  PictureBridgeSettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      PictureBridgeSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: pairCount ?? this.pairCount,
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
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory PictureBridgeSettings.fromJson(Map<String, dynamic> json) =>
      PictureBridgeSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
        pairCount: (json['pairCount'] as int? ?? 4).clamp(3, 7),
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
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class PictureBridgeState extends Equatable {
  const PictureBridgeState({
    this.phase = PictureBridgePhase.ready,
    this.settings = const PictureBridgeSettings(),
    this.pictureCards = const [],
    this.wordCards = const [],
    this.connections = const [],
    this.recentVocabIds = const [],
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

  final PictureBridgePhase phase;
  final PictureBridgeSettings settings;
  final List<PicturePairCard> pictureCards;
  final List<PicturePairCard> wordCards;
  final List<PictureBridgeConnection> connections;
  final List<String> recentVocabIds;
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
      pictureCards.isNotEmpty && pictureCards.every((c) => c.matched);

  PictureBridgeState copyWith({
    PictureBridgePhase? phase,
    PictureBridgeSettings? settings,
    List<PicturePairCard>? pictureCards,
    List<PicturePairCard>? wordCards,
    List<PictureBridgeConnection>? connections,
    List<String>? recentVocabIds,
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
      PictureBridgeState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        pictureCards: pictureCards ?? this.pictureCards,
        wordCards: wordCards ?? this.wordCards,
        connections: connections ?? this.connections,
        recentVocabIds: recentVocabIds ?? this.recentVocabIds,
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
        pictureCards,
        wordCards,
        connections,
        recentVocabIds,
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

class PictureBridgeResult extends Equatable {
  const PictureBridgeResult({
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

abstract final class PictureBridgePalette {
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

  static Color colorFor(String vocabId) {
    final hash = vocabId.codeUnits.fold<int>(0, (a, b) => a + b);
    return colors[hash.abs() % colors.length];
  }

  static int colorKeyFor(String vocabId) =>
      vocabId.codeUnits.fold<int>(0, (a, b) => a + b).abs();
}

const kPictureBridgeSkills = [
  'Picture Recognition',
  'Word Reading',
  'Vocabulary',
  'Visual Matching',
  'Fine Motor Skills',
  'Hand-Eye Coordination',
];

const kPictureBridgeSessionPresets = [60, 120, 180, 300, 600, 900, 1800];

const kPictureBridgeEncourage = [
  'Good Try!',
  'Let\'s Try Again!',
  'Can You Find the Word?',
  'Almost!',
];
