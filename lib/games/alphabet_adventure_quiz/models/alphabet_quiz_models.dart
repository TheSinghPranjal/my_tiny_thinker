import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';

enum AlphabetQuizPhase { ready, playing, paused, celebrating, finished }

enum AlphabetOrder { random, sequential }

enum LetterCaseMode { uppercase, lowercase, both }

class AlphabetQuizSettings extends Equatable {
  const AlphabetQuizSettings({
    this.sessionSeconds = 60,
    this.alphabetOrder = AlphabetOrder.random,
    this.letterCaseMode = LetterCaseMode.uppercase,
    this.rewardMultiplier = 1.0,
    this.animationSpeed = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int sessionSeconds;
  final AlphabetOrder alphabetOrder;
  final LetterCaseMode letterCaseMode;
  final double rewardMultiplier;
  final double animationSpeed;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  AlphabetQuizSettings copyWith({
    int? sessionSeconds,
    AlphabetOrder? alphabetOrder,
    LetterCaseMode? letterCaseMode,
    double? rewardMultiplier,
    double? animationSpeed,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) =>
      AlphabetQuizSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        alphabetOrder: alphabetOrder ?? this.alphabetOrder,
        letterCaseMode: letterCaseMode ?? this.letterCaseMode,
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
        'alphabetOrder': alphabetOrder.name,
        'letterCaseMode': letterCaseMode.name,
        'rewardMultiplier': rewardMultiplier,
        'animationSpeed': animationSpeed,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
      };

  factory AlphabetQuizSettings.fromJson(Map<String, dynamic> json) {
    return AlphabetQuizSettings(
      sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
      alphabetOrder: AlphabetOrder.values.firstWhere(
        (o) => o.name == json['alphabetOrder'],
        orElse: () => AlphabetOrder.random,
      ),
      letterCaseMode: LetterCaseMode.values.firstWhere(
        (m) => m.name == json['letterCaseMode'],
        orElse: () => LetterCaseMode.uppercase,
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
        alphabetOrder,
        letterCaseMode,
        rewardMultiplier,
        animationSpeed,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        hapticsEnabled,
        reducedMotion,
      ];
}

class AlphabetOption extends Equatable {
  const AlphabetOption({
    required this.itemId,
    required this.isCorrect,
    this.shake = false,
    this.glow = false,
  });

  final String itemId;
  final bool isCorrect;
  final bool shake;
  final bool glow;

  VocabItem? get item => EducationVocabulary.byId(itemId);

  AlphabetOption copyWith({bool? shake, bool? glow}) => AlphabetOption(
        itemId: itemId,
        isCorrect: isCorrect,
        shake: shake ?? this.shake,
        glow: glow ?? this.glow,
      );

  @override
  List<Object?> get props => [itemId, isCorrect, shake, glow];
}

class AlphabetQuestion extends Equatable {
  const AlphabetQuestion({
    required this.letter,
    required this.correctItemId,
    required this.options,
    required this.prompt,
  });

  final String letter;
  final String correctItemId;
  final List<AlphabetOption> options;
  final String prompt;

  @override
  List<Object?> get props => [letter, correctItemId, options, prompt];
}

class AlphabetQuizState extends Equatable {
  const AlphabetQuizState({
    this.phase = AlphabetQuizPhase.ready,
    this.settings = const AlphabetQuizSettings(),
    this.question,
    this.remainingSeconds = 60,
    this.score = 0,
    this.correctAnswers = 0,
    this.attempts = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.lettersCompleted = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showMascot = false,
    this.showSparkles = false,
    this.pendingEnd = false,
    this.letterQueue = const [],
    this.letterQueueIndex = 0,
  });

  final AlphabetQuizPhase phase;
  final AlphabetQuizSettings settings;
  final AlphabetQuestion? question;
  final int remainingSeconds;
  final int score;
  final int correctAnswers;
  final int attempts;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int lettersCompleted;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showMascot;
  final bool showSparkles;
  final bool pendingEnd;
  final List<String> letterQueue;
  final int letterQueueIndex;

  AlphabetQuizState copyWith({
    AlphabetQuizPhase? phase,
    AlphabetQuizSettings? settings,
    AlphabetQuestion? question,
    int? remainingSeconds,
    int? score,
    int? correctAnswers,
    int? attempts,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? lettersCompleted,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showMascot,
    bool? showSparkles,
    bool? pendingEnd,
    List<String>? letterQueue,
    int? letterQueueIndex,
    bool clearFeedback = false,
    bool clearQuestion = false,
  }) =>
      AlphabetQuizState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        question: clearQuestion ? null : (question ?? this.question),
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        attempts: attempts ?? this.attempts,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        lettersCompleted: lettersCompleted ?? this.lettersCompleted,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        showMascot: showMascot ?? this.showMascot,
        showSparkles: showSparkles ?? this.showSparkles,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        letterQueue: letterQueue ?? this.letterQueue,
        letterQueueIndex: letterQueueIndex ?? this.letterQueueIndex,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        question,
        remainingSeconds,
        score,
        correctAnswers,
        attempts,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        lettersCompleted,
        feedbackMessage,
        lastRewardText,
        showMascot,
        showSparkles,
        pendingEnd,
        letterQueue,
        letterQueueIndex,
      ];
}

class AlphabetQuizResult extends Equatable {
  const AlphabetQuizResult({
    required this.score,
    required this.correctAnswers,
    required this.attempts,
    required this.maxStreak,
    required this.lettersCompleted,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
    required this.accuracy,
  });

  final int score;
  final int correctAnswers;
  final int attempts;
  final int maxStreak;
  final int lettersCompleted;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;
  final double accuracy;

  @override
  List<Object?> get props => [
        score,
        correctAnswers,
        attempts,
        maxStreak,
        lettersCompleted,
        coins,
        xp,
        stars,
        sessionSeconds,
        accuracy,
      ];
}

const kAlphabetEncouragementsWrong = [
  'Almost! Let\'s Try Again!',
  'Good Try!',
  'Can You Find Another One?',
  'Let\'s Look Carefully!',
];

const kAlphabetEncouragementsRight = [
  'Excellent!',
  'Great Job!',
  'You Got It!',
  'Super Smart!',
  'Amazing!',
];

const kAlphabetSkills = [
  'Alphabet Recognition',
  'Phonics',
  'Vocabulary',
  'Letter-Object Association',
  'Visual Discrimination',
  'Early Literacy',
];
