import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

enum ShadowMatchPhase { ready, playing, paused, celebrating, finished }

enum ShadowDifficulty { easy, medium, hard }

class ShadowMatchSettings extends Equatable {
  const ShadowMatchSettings({
    this.sessionSeconds = 60,
    this.difficulty = ShadowDifficulty.easy,
    this.rewardMultiplier = 1.0,
    this.animationSpeed = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final ShadowDifficulty difficulty;
  final double rewardMultiplier;
  final double animationSpeed;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  int get itemsPerRound => switch (difficulty) {
        ShadowDifficulty.easy => 3,
        ShadowDifficulty.medium => 4,
        ShadowDifficulty.hard => 6,
      };

  ShadowMatchSettings copyWith({
    int? sessionSeconds,
    ShadowDifficulty? difficulty,
    double? rewardMultiplier,
    double? animationSpeed,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      ShadowMatchSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        difficulty: difficulty ?? this.difficulty,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        animationSpeed: animationSpeed ?? this.animationSpeed,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'difficulty': difficulty.name,
        'rewardMultiplier': rewardMultiplier,
        'animationSpeed': animationSpeed,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
      };

  factory ShadowMatchSettings.fromJson(Map<String, dynamic> json) {
    return ShadowMatchSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      difficulty: ShadowDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => ShadowDifficulty.easy,
      ),
      rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
      animationSpeed: (json['animationSpeed'] as num? ?? 1.0).toDouble().clamp(0.5, 1.5),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      narrationEnabled: json['narrationEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        difficulty,
        rewardMultiplier,
        animationSpeed,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
      ];
}

class ShadowSlot extends Equatable {
  const ShadowSlot({
    required this.itemId,
    this.matched = false,
    this.glow = false,
  });

  final String itemId;
  final bool matched;
  final bool glow;

  ShadowSlot copyWith({bool? matched, bool? glow}) => ShadowSlot(
        itemId: itemId,
        matched: matched ?? this.matched,
        glow: glow ?? this.glow,
      );

  @override
  List<Object?> get props => [itemId, matched, glow];
}

class DraggableItemState extends Equatable {
  const DraggableItemState({
    required this.itemId,
    this.matched = false,
    this.shake = false,
  });

  final String itemId;
  final bool matched;
  final bool shake;

  VocabItem? get item => EducationVocabulary.byId(itemId);

  DraggableItemState copyWith({bool? matched, bool? shake}) =>
      DraggableItemState(
        itemId: itemId,
        matched: matched ?? this.matched,
        shake: shake ?? this.shake,
      );

  @override
  List<Object?> get props => [itemId, matched, shake];
}

class ShadowMatchState extends Equatable {
  const ShadowMatchState({
    this.phase = ShadowMatchPhase.ready,
    this.settings = const ShadowMatchSettings(),
    this.shadows = const [],
    this.items = const [],
    this.remainingSeconds = 60,
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
    this.showMascot = false,
    this.showSparkles = false,
    this.pendingEnd = false,
    this.lastSpokenItemId,
  });

  final ShadowMatchPhase phase;
  final ShadowMatchSettings settings;
  final List<ShadowSlot> shadows;
  final List<DraggableItemState> items;
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
  final bool showMascot;
  final bool showSparkles;
  final bool pendingEnd;
  final String? lastSpokenItemId;

  bool get roundComplete => shadows.isNotEmpty && shadows.every((s) => s.matched);

  ShadowMatchState copyWith({
    ShadowMatchPhase? phase,
    ShadowMatchSettings? settings,
    List<ShadowSlot>? shadows,
    List<DraggableItemState>? items,
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
    bool? showMascot,
    bool? showSparkles,
    bool? pendingEnd,
    String? lastSpokenItemId,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      ShadowMatchState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        shadows: shadows ?? this.shadows,
        items: items ?? this.items,
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
        showMascot: showMascot ?? this.showMascot,
        showSparkles: showSparkles ?? this.showSparkles,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        lastSpokenItemId: lastSpokenItemId ?? this.lastSpokenItemId,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        shadows,
        items,
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
        showMascot,
        showSparkles,
        pendingEnd,
        lastSpokenItemId,
      ];
}

class ShadowMatchResult extends Equatable {
  const ShadowMatchResult({
    required this.score,
    required this.correctMatches,
    required this.attempts,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    required this.accuracy,
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

  @override
  List<Object?> get props =>
      [score, correctMatches, attempts, maxStreak, coins, xp, stars, sessionSeconds, accuracy];
}

const kShadowEncouragementsWrong = [
  'Oops! Let\'s Try Again!',
  'Almost!',
  'You Can Do It!',
  'Try Another Shadow!',
  'Great Try!',
];

const kShadowEncouragementsRight = [
  'Great Match!',
  'Wonderful!',
  'You Did It!',
  'Amazing!',
  'Super Star!',
];

const kShadowSkills = [
  'Object Recognition',
  'Visual Discrimination',
  'Drag & Drop',
  'Fine Motor Skills',
  'Vocabulary',
  'Observation',
];
