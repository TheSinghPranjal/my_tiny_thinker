import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

enum CompleteWordPhase {
  ready,
  countdown,
  playing,
  celebrating,
  paused,
  finished,
}

enum WordLengthDifficulty {
  three(3, '3 Letters'),
  four(4, '4 Letters'),
  five(5, '5 Letters'),
  six(6, '6 Letters');

  const WordLengthDifficulty(this.length, this.label);
  final int length;
  final String label;
}

class CompleteWordSettings extends Equatable {
  const CompleteWordSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.wordLength = WordLengthDifficulty.three,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final int sessionSeconds;
  final WordLengthDifficulty wordLength;
  final bool soundEnabled;
  final bool hapticsEnabled;

  CompleteWordSettings copyWith({
    int? sessionSeconds,
    WordLengthDifficulty? wordLength,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) =>
      CompleteWordSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        wordLength: wordLength ?? this.wordLength,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'wordLength': wordLength.name,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      };

  factory CompleteWordSettings.fromJson(Map<String, dynamic> json) {
    return CompleteWordSettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
      wordLength: WordLengthDifficulty.values.firstWhere(
        (w) => w.name == json['wordLength'],
        orElse: () => WordLengthDifficulty.three,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [sessionSeconds, wordLength, soundEnabled, hapticsEnabled];
}

class WordEntry extends Equatable {
  const WordEntry({
    required this.word,
    required this.emoji,
  });

  final String word;
  final String emoji;

  int get length => word.length;

  @override
  List<Object?> get props => [word, emoji];
}

class LetterTile extends Equatable {
  const LetterTile({
    required this.id,
    required this.letter,
    this.used = false,
  });

  final String id;
  final String letter;
  final bool used;

  LetterTile copyWith({bool? used}) => LetterTile(
        id: id,
        letter: letter,
        used: used ?? this.used,
      );

  @override
  List<Object?> get props => [id, letter, used];
}

class CompleteWordState extends Equatable {
  const CompleteWordState({
    this.phase = CompleteWordPhase.ready,
    this.settings = const CompleteWordSettings(),
    this.currentWord,
    this.filled = const [],
    this.tiles = const [],
    this.nextIndex = 0,
    this.remainingSeconds = 60,
    this.countdown = 3,
    this.score = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.lettersCorrect = 0,
    this.lettersWrong = 0,
    this.wordsCompleted = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.hintTileId,
    this.wrongTileId,
    this.flyingLetter,
    this.feedbackMessage,
    this.lastRewardText,
    this.pendingEnd = false,
  });

  final CompleteWordPhase phase;
  final CompleteWordSettings settings;
  final WordEntry? currentWord;
  /// Letters placed so far (length = word length, nulls as empty via '').
  final List<String> filled;
  final List<LetterTile> tiles;
  final int nextIndex;
  final int remainingSeconds;
  final int countdown;
  final int score;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final int lettersCorrect;
  final int lettersWrong;
  final int wordsCompleted;
  final int combo;
  final int maxCombo;
  final String? hintTileId;
  final String? wrongTileId;
  final String? flyingLetter;
  final String? feedbackMessage;
  final String? lastRewardText;
  final bool pendingEnd;

  bool get wordComplete =>
      currentWord != null &&
      filled.length == currentWord!.length &&
      filled.every((c) => c.isNotEmpty);

  double get accuracy {
    final total = lettersCorrect + lettersWrong;
    if (total == 0) return 1;
    return lettersCorrect / total;
  }

  CompleteWordState copyWith({
    CompleteWordPhase? phase,
    CompleteWordSettings? settings,
    WordEntry? currentWord,
    List<String>? filled,
    List<LetterTile>? tiles,
    int? nextIndex,
    int? remainingSeconds,
    int? countdown,
    int? score,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    int? lettersCorrect,
    int? lettersWrong,
    int? wordsCompleted,
    int? combo,
    int? maxCombo,
    String? hintTileId,
    String? wrongTileId,
    String? flyingLetter,
    String? feedbackMessage,
    String? lastRewardText,
    bool? pendingEnd,
    bool clearHint = false,
    bool clearWrong = false,
    bool clearFlying = false,
    bool clearFeedback = false,
    bool clearReward = false,
    bool clearWord = false,
  }) =>
      CompleteWordState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        currentWord: clearWord ? null : (currentWord ?? this.currentWord),
        filled: filled ?? this.filled,
        tiles: tiles ?? this.tiles,
        nextIndex: nextIndex ?? this.nextIndex,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        countdown: countdown ?? this.countdown,
        score: score ?? this.score,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        lettersCorrect: lettersCorrect ?? this.lettersCorrect,
        lettersWrong: lettersWrong ?? this.lettersWrong,
        wordsCompleted: wordsCompleted ?? this.wordsCompleted,
        combo: combo ?? this.combo,
        maxCombo: maxCombo ?? this.maxCombo,
        hintTileId: clearHint ? null : (hintTileId ?? this.hintTileId),
        wrongTileId: clearWrong ? null : (wrongTileId ?? this.wrongTileId),
        flyingLetter: clearFlying ? null : (flyingLetter ?? this.flyingLetter),
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearReward ? null : (lastRewardText ?? this.lastRewardText),
        pendingEnd: pendingEnd ?? this.pendingEnd,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        currentWord,
        filled,
        tiles,
        nextIndex,
        remainingSeconds,
        countdown,
        score,
        coinsEarned,
        xpEarned,
        starsEarned,
        lettersCorrect,
        lettersWrong,
        wordsCompleted,
        combo,
        maxCombo,
        hintTileId,
        wrongTileId,
        flyingLetter,
        feedbackMessage,
        lastRewardText,
        pendingEnd,
      ];
}

class CompleteWordResult extends Equatable {
  const CompleteWordResult({
    required this.wordsCompleted,
    required this.lettersCorrect,
    required this.lettersWrong,
    required this.accuracy,
    required this.coins,
    required this.xp,
    required this.stars,
    required this.score,
    required this.maxCombo,
    required this.encouragement,
  });

  final int wordsCompleted;
  final int lettersCorrect;
  final int lettersWrong;
  final double accuracy;
  final int coins;
  final int xp;
  final int stars;
  final int score;
  final int maxCombo;
  final String encouragement;

  @override
  List<Object?> get props => [
        wordsCompleted,
        lettersCorrect,
        lettersWrong,
        accuracy,
        coins,
        xp,
        stars,
        score,
        maxCombo,
        encouragement,
      ];
}

const kCompleteWordSkills = [
  'Spelling',
  'Vocabulary',
  'Letter Recognition',
  'Sequencing',
  'Concentration',
];

const kLetterPraise = [
  'Great!',
  'Correct!',
  'Awesome!',
  'Excellent!',
  'Nice Job!',
];

const kWordPraise = [
  'Fantastic!',
  'You spelled it!',
  'Excellent Work!',
  "You're Amazing!",
  'Super Speller!',
];

const kEndPraise = [
  'Fantastic Reader!',
  'Super Speller!',
  'Word Master!',
  'Keep Learning!',
  'Brilliant Work!',
];
