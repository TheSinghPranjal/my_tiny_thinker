import 'package:equatable/equatable.dart';

enum GameId {
  bubbleNumberPop('bubble_number_pop', '🔵', 'Bubble Number Pop'),
  memoryGame('memory_game', '🧠', 'Memory Game'),
  oddOneOut('odd_one_out', '👀', 'Odd One Out'),
  patternMatch('pattern_match', '🧩', 'Pattern Match'),
  colorMemory('color_memory', '🌈', 'Color Memory'),
  oceanFishAdventure('ocean_fish_adventure', '🐠', 'Ocean Fish Adventure'),
  magicalFlowerGarden('magical_flower_garden', '🌸', 'Magical Flower Garden'),
  cloudPopGarden('cloud_pop_garden', '☁️', 'Cloud Pop Garden'),
  peekABooAnimalFriends('peek_a_boo_animal_friends', '🐾', 'Peek-a-Boo Animal Friends'),
  frogPondAdventure('frog_pond_adventure', '🐸', 'Frog Pond Adventure'),
  feedTheFrogAdventure('feed_the_frog_adventure', '🪰', 'Feed the Frog Adventure'),
  hungryMonkeyBananaAdventure(
    'hungry_monkey_banana_adventure',
    '🐵',
    'Hungry Monkey Banana Adventure',
  ),
  catchTheButterflyGarden(
    'catch_the_butterfly_garden',
    '🦋',
    'Catch the Butterfly Garden',
  ),
  catchTheFishAdventure(
    'catch_the_fish_adventure',
    '🎣',
    'Catch the Fish Adventure',
  ),
  hungryDuckPondAdventure(
    'hungry_duck_pond_adventure',
    '🦆',
    'Hungry Duck Pond Adventure',
  ),
  hungryTeddyCupcakeParty(
    'hungry_teddy_cupcake_party',
    '🧸',
    'Hungry Teddy Cupcake Party',
  ),
  bunnyHopAdventure(
    'bunny_hop_adventure',
    '🐰',
    'Bunny Hop Adventure',
  ),
  shadowMatchAdventure('shadow_match_adventure', '🌗', 'Shadow Match Adventure'),
  shapeDropAdventure('shape_drop_adventure', '🔷', 'Shape Drop Adventure'),
  candyColorHunt('candy_color_hunt', '🐜', 'Candy Color Hunt'),
  colorSchoolBags('color_school_bags', '🎒', 'Color School Bags'),
  alphabetAdventureQuiz('alphabet_adventure_quiz', '🔤', 'Alphabet Adventure Quiz'),
  animalSounds('animal_sounds', '🔊', 'Animal Sounds'),
  alphabetBridgeAdventure(
    'alphabet_bridge_adventure',
    '🌉',
    'Alphabet Bridge Adventure',
  ),
  numberBridgeAdventure(
    'number_bridge_adventure',
    '🔢',
    'Number Bridge Adventure',
  ),
  pictureBridgeAdventure(
    'picture_bridge_adventure',
    '🖼️',
    'Picture Bridge Adventure',
  ),
  colorShapeBridgeAdventure(
    'color_shape_bridge_adventure',
    '🔷',
    'Color & Shape Bridge Adventure',
  ),
  moonRescueAdventure(
    'moon_rescue_adventure',
    '🚀',
    'Moon Rescue Adventure',
  ),
  balloonParade(
    'balloon_parade',
    '🎈',
    'Balloon Parade',
  ),
  colorBalloonPop(
    'color_balloon_pop',
    '🎨',
    'Color Balloon Pop',
  );

  const GameId(this.id, this.emoji, this.displayName);
  final String id;
  final String emoji;
  final String displayName;
}

enum Difficulty { easy, medium, hard, expert }

enum TimerMode { relaxed, timed, endless }

enum SortMode { ascending, descending }

enum RewardType { coins, stars, xp, sticker, avatar, background, bubbleSkin }

class Reward extends Equatable {
  const Reward({
    required this.type,
    required this.amount,
    this.itemId,
  });

  final RewardType type;
  final int amount;
  final String? itemId;

  @override
  List<Object?> get props => [type, amount, itemId];
}

class GameRewardResult extends Equatable {
  const GameRewardResult({
    required this.coins,
    required this.stars,
    required this.xp,
    this.unlockedItems = const [],
    this.isPerfect = false,
    this.isNewBest = false,
  });

  final int coins;
  final int stars;
  final int xp;
  final List<String> unlockedItems;
  final bool isPerfect;
  final bool isNewBest;

  @override
  List<Object?> get props =>
      [coins, stars, xp, unlockedItems, isPerfect, isNewBest];
}

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.target = 1,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int target;

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) =>
      Achievement(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        progress: progress ?? this.progress,
        target: target,
      );

  double get progressPercent => target > 0 ? progress / target : 0;

  @override
  List<Object?> get props =>
      [id, title, description, emoji, isUnlocked, unlockedAt, progress, target];
}

class DailyRewardState extends Equatable {
  const DailyRewardState({
    this.lastClaimDate,
    this.streakDays = 0,
    this.canClaim = true,
  });

  final DateTime? lastClaimDate;
  final int streakDays;
  final bool canClaim;

  DailyRewardState copyWith({
    DateTime? lastClaimDate,
    int? streakDays,
    bool? canClaim,
  }) =>
      DailyRewardState(
        lastClaimDate: lastClaimDate ?? this.lastClaimDate,
        streakDays: streakDays ?? this.streakDays,
        canClaim: canClaim ?? this.canClaim,
      );

  @override
  List<Object?> get props => [lastClaimDate, streakDays, canClaim];
}
