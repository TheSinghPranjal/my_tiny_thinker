import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum ClassicMemoryPhase {
  ready,
  countdown,
  playing,
  paused,
  celebrating,
  finished,
}

enum ClassicMemoryCategory {
  animals('animals', '🦁', 'Animals'),
  fruits('fruits', '🍎', 'Fruits'),
  shapes('shapes', '🔷', 'Shapes'),
  emojis('emojis', '😊', 'Emojis'),
  vehicles('vehicles', '🚗', 'Vehicles'),
  ocean('ocean', '🐠', 'Ocean'),
  dinosaurs('dinosaurs', '🦕', 'Dinosaurs'),
  space('space', '🚀', 'Space');

  const ClassicMemoryCategory(this.id, this.emoji, this.displayName);
  final String id;
  final String emoji;
  final String displayName;
}

class ClassicCardMemorySettings extends Equatable {
  const ClassicCardMemorySettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.pairCount = 4,
    this.category = ClassicMemoryCategory.animals,
    this.rotateCategories = true,
  });

  final int sessionSeconds;
  final int pairCount;
  final ClassicMemoryCategory category;
  /// When true, each new round picks a random category.
  final bool rotateCategories;

  ClassicCardMemorySettings copyWith({
    int? sessionSeconds,
    int? pairCount,
    ClassicMemoryCategory? category,
    bool? rotateCategories,
  }) =>
      ClassicCardMemorySettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        pairCount: (pairCount ?? this.pairCount).clamp(2, 12),
        category: category ?? this.category,
        rotateCategories: rotateCategories ?? this.rotateCategories,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'pairCount': pairCount,
        'category': category.name,
        'rotateCategories': rotateCategories,
      };

  factory ClassicCardMemorySettings.fromJson(Map<String, dynamic> json) {
    return ClassicCardMemorySettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
      pairCount: (json['pairCount'] as int? ?? 4).clamp(2, 12),
      category: ClassicMemoryCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ClassicMemoryCategory.animals,
      ),
      rotateCategories: json['rotateCategories'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [sessionSeconds, pairCount, category, rotateCategories];
}

class MemoryCard extends Equatable {
  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.face,
    this.isFlipped = false,
    this.isMatched = false,
    this.isWrong = false,
  });

  final String id;
  final String pairId;
  final String face;
  final bool isFlipped;
  final bool isMatched;
  final bool isWrong;

  bool get isFaceUp => isFlipped || isMatched;

  MemoryCard copyWith({
    bool? isFlipped,
    bool? isMatched,
    bool? isWrong,
  }) =>
      MemoryCard(
        id: id,
        pairId: pairId,
        face: face,
        isFlipped: isFlipped ?? this.isFlipped,
        isMatched: isMatched ?? this.isMatched,
        isWrong: isWrong ?? this.isWrong,
      );

  @override
  List<Object?> get props =>
      [id, pairId, face, isFlipped, isMatched, isWrong];
}

class ClassicCardMemoryState extends Equatable {
  const ClassicCardMemoryState({
    this.phase = ClassicMemoryPhase.ready,
    this.settings = const ClassicCardMemorySettings(),
    this.cards = const [],
    this.category = ClassicMemoryCategory.animals,
    this.remainingSeconds = 60,
    this.countdown = 3,
    this.score = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.matches = 0,
    this.mistakes = 0,
    this.roundsCompleted = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.firstFlippedIndex,
    this.lockInput = false,
    this.feedbackMessage,
    this.lastRewardText,
  });

  final ClassicMemoryPhase phase;
  final ClassicCardMemorySettings settings;
  final List<MemoryCard> cards;
  final ClassicMemoryCategory category;
  final int remainingSeconds;
  final int countdown;
  final int score;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int matches;
  final int mistakes;
  final int roundsCompleted;
  final int combo;
  final int maxCombo;
  final int? firstFlippedIndex;
  final bool lockInput;
  final String? feedbackMessage;
  final String? lastRewardText;

  bool get roundComplete =>
      cards.isNotEmpty && cards.every((c) => c.isMatched);

  ClassicCardMemoryState copyWith({
    ClassicMemoryPhase? phase,
    ClassicCardMemorySettings? settings,
    List<MemoryCard>? cards,
    ClassicMemoryCategory? category,
    int? remainingSeconds,
    int? countdown,
    int? score,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? matches,
    int? mistakes,
    int? roundsCompleted,
    int? combo,
    int? maxCombo,
    int? firstFlippedIndex,
    bool? lockInput,
    String? feedbackMessage,
    String? lastRewardText,
    bool clearFirstFlip = false,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      ClassicCardMemoryState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        cards: cards ?? this.cards,
        category: category ?? this.category,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        countdown: countdown ?? this.countdown,
        score: score ?? this.score,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        matches: matches ?? this.matches,
        mistakes: mistakes ?? this.mistakes,
        roundsCompleted: roundsCompleted ?? this.roundsCompleted,
        combo: combo ?? this.combo,
        maxCombo: maxCombo ?? this.maxCombo,
        firstFlippedIndex:
            clearFirstFlip ? null : (firstFlippedIndex ?? this.firstFlippedIndex),
        lockInput: lockInput ?? this.lockInput,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        cards,
        category,
        remainingSeconds,
        countdown,
        score,
        coinsEarned,
        xpEarned,
        starsEarned,
        matches,
        mistakes,
        roundsCompleted,
        combo,
        maxCombo,
        firstFlippedIndex,
        lockInput,
        feedbackMessage,
        lastRewardText,
      ];
}

class ClassicCardMemoryResult extends Equatable {
  const ClassicCardMemoryResult({
    required this.score,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.matches,
    required this.mistakes,
    required this.roundsCompleted,
    required this.maxCombo,
  });

  final int score;
  final int coins;
  final int xp;
  final int stars;
  final int matches;
  final int mistakes;
  final int roundsCompleted;
  final int maxCombo;

  @override
  List<Object?> get props =>
      [score, coins, xp, stars, matches, mistakes, roundsCompleted, maxCombo];
}

const kClassicMemorySkills = [
  'Visual Memory',
  'Concentration',
  'Matching',
  'Focus',
];
