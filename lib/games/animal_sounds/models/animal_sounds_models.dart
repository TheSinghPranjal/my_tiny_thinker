import 'package:equatable/equatable.dart';

enum AnimalSoundsPhase { ready, playing, celebrating, finished }

class AnimalDef extends Equatable {
  const AnimalDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.soundAsset,
  });

  final String id;
  final String name;
  final String emoji;
  final String soundAsset;

  @override
  List<Object?> get props => [id, name, emoji, soundAsset];
}

/// All animals with matching sound assets (mp3/wav).
const kAnimals = <AnimalDef>[
  AnimalDef(
    id: 'donkey',
    name: 'Donkey',
    emoji: '🫏',
    soundAsset: 'audio/animals/donkey.mp3',
  ),
  AnimalDef(
    id: 'elephant',
    name: 'Elephant',
    emoji: '🐘',
    soundAsset: 'audio/animals/elephant.mp3',
  ),
  AnimalDef(
    id: 'fly',
    name: 'Fly',
    emoji: '🪰',
    soundAsset: 'audio/animals/fly.wav',
  ),
  AnimalDef(
    id: 'goat',
    name: 'Goat',
    emoji: '🐐',
    soundAsset: 'audio/animals/goat.wav',
  ),
  AnimalDef(
    id: 'sheep',
    name: 'Sheep',
    emoji: '🐑',
    soundAsset: 'audio/animals/sheep.wav',
  ),
  AnimalDef(
    id: 'monkey',
    name: 'Monkey',
    emoji: '🐒',
    soundAsset: 'audio/animals/monkey.wav',
  ),
  AnimalDef(
    id: 'cricket',
    name: 'Cricket',
    emoji: '🦗',
    soundAsset: 'audio/animals/cricket.wav',
  ),
  AnimalDef(
    id: 'lion',
    name: 'Lion',
    emoji: '🦁',
    soundAsset: 'audio/animals/lion.wav',
  ),
  AnimalDef(
    id: 'horse',
    name: 'Horse',
    emoji: '🐴',
    soundAsset: 'audio/animals/horse.wav',
  ),
  AnimalDef(
    id: 'cow',
    name: 'Cow',
    emoji: '🐄',
    soundAsset: 'audio/animals/cow.wav',
  ),
  AnimalDef(
    id: 'bird',
    name: 'Bird',
    emoji: '🐦',
    soundAsset: 'audio/animals/bird.wav',
  ),
  AnimalDef(
    id: 'cat',
    name: 'Cat',
    emoji: '🐱',
    soundAsset: 'audio/animals/cat.wav',
  ),
  AnimalDef(
    id: 'dog',
    name: 'Dog',
    emoji: '🐶',
    soundAsset: 'audio/animals/dog.wav',
  ),
  AnimalDef(
    id: 'rooster',
    name: 'Rooster',
    emoji: '🐓',
    soundAsset: 'audio/animals/rooster.wav',
  ),
];

class AnimalSoundsSettings extends Equatable {
  const AnimalSoundsSettings({
    this.sessionSeconds = 60,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.autoPlaySound = true,
  });

  final int sessionSeconds;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool autoPlaySound;

  AnimalSoundsSettings copyWith({
    int? sessionSeconds,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? autoPlaySound,
  }) =>
      AnimalSoundsSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        autoPlaySound: autoPlaySound ?? this.autoPlaySound,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'hapticsEnabled': hapticsEnabled,
        'autoPlaySound': autoPlaySound,
      };

  factory AnimalSoundsSettings.fromJson(Map<String, dynamic> json) =>
      AnimalSoundsSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(60, 1800),
        rewardMultiplier: (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        autoPlaySound: json['autoPlaySound'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        sessionSeconds,
        rewardMultiplier,
        soundEnabled,
        musicEnabled,
        hapticsEnabled,
        autoPlaySound,
      ];
}

class AnimalOption extends Equatable {
  const AnimalOption({
    required this.animal,
    required this.isCorrect,
    this.shake = false,
    this.highlight = false,
  });

  final AnimalDef animal;
  final bool isCorrect;
  final bool shake;
  final bool highlight;

  AnimalOption copyWith({bool? shake, bool? highlight}) => AnimalOption(
        animal: animal,
        isCorrect: isCorrect,
        shake: shake ?? this.shake,
        highlight: highlight ?? this.highlight,
      );

  @override
  List<Object?> get props => [animal, isCorrect, shake, highlight];
}

class AnimalQuestion extends Equatable {
  const AnimalQuestion({
    required this.correct,
    required this.options,
  });

  final AnimalDef correct;
  final List<AnimalOption> options;

  @override
  List<Object?> get props => [correct, options];
}

class AnimalSoundsState extends Equatable {
  const AnimalSoundsState({
    this.phase = AnimalSoundsPhase.ready,
    this.settings = const AnimalSoundsSettings(),
    this.question,
    this.remainingSeconds = 60,
    this.correctCount = 0,
    this.attempts = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.streak = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.showSparkles = false,
    this.pendingEnd = false,
    this.queueIndex = 0,
    this.queue = const [],
  });

  final AnimalSoundsPhase phase;
  final AnimalSoundsSettings settings;
  final AnimalQuestion? question;
  final int remainingSeconds;
  final int correctCount;
  final int attempts;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int streak;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool showSparkles;
  final bool pendingEnd;
  final int queueIndex;
  final List<String> queue;

  AnimalSoundsState copyWith({
    AnimalSoundsPhase? phase,
    AnimalSoundsSettings? settings,
    AnimalQuestion? question,
    int? remainingSeconds,
    int? correctCount,
    int? attempts,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? streak,
    String? feedbackMessage,
    String? lastRewardText,
    bool? showSparkles,
    bool? pendingEnd,
    int? queueIndex,
    List<String>? queue,
    bool clearFeedback = false,
    bool clearReward = false,
  }) =>
      AnimalSoundsState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        question: question ?? this.question,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        correctCount: correctCount ?? this.correctCount,
        attempts: attempts ?? this.attempts,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        streak: streak ?? this.streak,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        showSparkles: showSparkles ?? this.showSparkles,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        queueIndex: queueIndex ?? this.queueIndex,
        queue: queue ?? this.queue,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        question,
        remainingSeconds,
        correctCount,
        attempts,
        coinsEarned,
        xpEarned,
        starsEarned,
        streak,
        feedbackMessage,
        lastRewardText,
        showSparkles,
        pendingEnd,
        queueIndex,
        queue,
      ];
}

class AnimalSoundsResult extends Equatable {
  const AnimalSoundsResult({
    required this.correctCount,
    required this.attempts,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.sessionSeconds,
  });

  final int correctCount;
  final int attempts;
  final int coins;
  final int xp;
  final int stars;
  final int sessionSeconds;

  @override
  List<Object?> get props =>
      [correctCount, attempts, coins, xp, stars, sessionSeconds];
}

const kAnimalSoundsSkills = [
  'Listening',
  'Sound Recognition',
  'Animal Knowledge',
  'Attention',
  'Vocabulary',
];

const kAnimalEncouragements = [
  'Great Job!',
  'Awesome!',
  'You got it!',
  'Wonderful!',
  'Fantastic!',
  'Super Ears!',
  'Amazing!',
];
