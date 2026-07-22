import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';

enum LearningCategory {
  littleExplorers('Little Explorers', '🐣'),
  tinyLearners('Tiny Learners', '🌱'),
  smartExplorers('Smart Explorers', '🚀'),
  brainMasters('Brain Masters', '🧠'),
  youngGeniuses('Young Geniuses', '🌟');

  const LearningCategory(this.label, this.emoji);
  final String label;
  final String emoji;

  static LearningCategory fromAgeGroup(AgeGroup group) => switch (group) {
        AgeGroup.littleExplorers => LearningCategory.littleExplorers,
        AgeGroup.tinyLearners => LearningCategory.tinyLearners,
        AgeGroup.smartExplorers => LearningCategory.smartExplorers,
        AgeGroup.brainMasters => LearningCategory.brainMasters,
        AgeGroup.youngGeniuses => LearningCategory.youngGeniuses,
      };

  AgeGroup get ageGroup => switch (this) {
        LearningCategory.littleExplorers => AgeGroup.littleExplorers,
        LearningCategory.tinyLearners => AgeGroup.tinyLearners,
        LearningCategory.smartExplorers => AgeGroup.smartExplorers,
        LearningCategory.brainMasters => AgeGroup.brainMasters,
        LearningCategory.youngGeniuses => AgeGroup.youngGeniuses,
      };
}

class GameCatalogEntry {
  const GameCatalogEntry({
    required this.gameId,
    required this.category,
    required this.subtitle,
    this.hasParentControls = true,
  });

  final GameId gameId;
  final LearningCategory category;
  final String subtitle;
  final bool hasParentControls;
}

/// Single source of truth for game metadata used by Parent Zone & Learning Path.
abstract final class GameCatalog {
  static const entries = <GameCatalogEntry>[
    GameCatalogEntry(
      gameId: GameId.candyColorHunt,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap matching candies for the hungry ant!',
    ),
    GameCatalogEntry(
      gameId: GameId.bunnyHopAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap to hop across lily pads to the carrot!',
    ),
    GameCatalogEntry(
      gameId: GameId.hungryTeddyCupcakeParty,
      category: LearningCategory.littleExplorers,
      subtitle: 'Drag cupcakes to feed the hungry teddy!',
    ),
    GameCatalogEntry(
      gameId: GameId.hungryDuckPondAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap fish and feed the hungry duck!',
    ),
    GameCatalogEntry(
      gameId: GameId.catchTheButterflyGarden,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap butterflies and fill your basket!',
    ),
    GameCatalogEntry(
      gameId: GameId.catchTheFishAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap fish and reel them into the boat!',
    ),
    GameCatalogEntry(
      gameId: GameId.hungryMonkeyBananaAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap bananas and feed the hungry monkey!',
    ),
    GameCatalogEntry(
      gameId: GameId.feedTheFrogAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap the flying bugs and feed the happy frog!',
    ),
    GameCatalogEntry(
      gameId: GameId.frogPondAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap the frogs and watch them splash!',
    ),
    GameCatalogEntry(
      gameId: GameId.peekABooAnimalFriends,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap the bushes and find the hidden animals!',
    ),
    GameCatalogEntry(
      gameId: GameId.cloudPopGarden,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap rain clouds and watch flowers bloom!',
    ),
    GameCatalogEntry(
      gameId: GameId.magicalFlowerGarden,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap the flower and watch nature come alive!',
    ),
    GameCatalogEntry(
      gameId: GameId.oceanFishAdventure,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap the fish swimming in the ocean!',
    ),
    GameCatalogEntry(
      gameId: GameId.balloonParade,
      category: LearningCategory.littleExplorers,
      subtitle: 'Tap rising balloons in a magical parade!',
    ),
    GameCatalogEntry(
      gameId: GameId.colorSchoolBags,
      category: LearningCategory.tinyLearners,
      subtitle: 'Drag books into matching backpacks!',
    ),
    GameCatalogEntry(
      gameId: GameId.colorBalloonPop,
      category: LearningCategory.tinyLearners,
      subtitle: 'Find and pop the matching color balloon!',
    ),
    GameCatalogEntry(
      gameId: GameId.alphabetBridgeAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Connect little letters to big letters!',
    ),
    GameCatalogEntry(
      gameId: GameId.numberBridgeAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Connect digits to number words!',
    ),
    GameCatalogEntry(
      gameId: GameId.pictureBridgeAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Connect pictures to their words!',
    ),
    GameCatalogEntry(
      gameId: GameId.moonRescueAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Flick astronauts to the Moon and launch!',
    ),
    GameCatalogEntry(
      gameId: GameId.shapeDropAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Drag shapes into the dotted outline!',
    ),
    GameCatalogEntry(
      gameId: GameId.shadowMatchAdventure,
      category: LearningCategory.tinyLearners,
      subtitle: 'Drag pictures to their shadows!',
    ),
    GameCatalogEntry(
      gameId: GameId.alphabetAdventureQuiz,
      category: LearningCategory.tinyLearners,
      subtitle: 'Match letters with pictures!',
    ),
    GameCatalogEntry(
      gameId: GameId.animalSounds,
      category: LearningCategory.tinyLearners,
      subtitle: 'Listen and tap the matching animal!',
    ),
    GameCatalogEntry(
      gameId: GameId.oddOneOut,
      category: LearningCategory.tinyLearners,
      subtitle: 'Tap the picture that does not belong!',
    ),
    GameCatalogEntry(
      gameId: GameId.colorShapeBridgeAdventure,
      category: LearningCategory.smartExplorers,
      subtitle: 'Connect words to colors and shapes!',
    ),
    GameCatalogEntry(
      gameId: GameId.bubbleNumberPop,
      category: LearningCategory.littleExplorers,
      subtitle: 'Pop the number you see on top!',
    ),
    GameCatalogEntry(
      gameId: GameId.ascendingBubbleNumberPop,
      category: LearningCategory.tinyLearners,
      subtitle: 'Pop bubbles from smallest to biggest!',
    ),
    GameCatalogEntry(
      gameId: GameId.descendingNumberPop,
      category: LearningCategory.tinyLearners,
      subtitle: 'Pop bubbles from biggest to smallest!',
    ),
    GameCatalogEntry(
      gameId: GameId.numberWordPop,
      category: LearningCategory.tinyLearners,
      subtitle: 'Read the number word and pop the matching bubble!',
    ),
    GameCatalogEntry(
      gameId: GameId.classicCardMemory,
      category: LearningCategory.smartExplorers,
      subtitle: 'Flip cards and match pairs again and again!',
    ),
    GameCatalogEntry(
      gameId: GameId.completeTheWordAdventure,
      category: LearningCategory.brainMasters,
      subtitle: 'Tap scrambled letters to spell the word!',
    ),
    GameCatalogEntry(
      gameId: GameId.memoryGame,
      category: LearningCategory.smartExplorers,
      subtitle: 'Find matching pairs!',
      hasParentControls: false,
    ),
    GameCatalogEntry(
      gameId: GameId.patternMatch,
      category: LearningCategory.smartExplorers,
      subtitle: 'Look at the pattern and pick what comes next!',
    ),
    GameCatalogEntry(
      gameId: GameId.colorMemory,
      category: LearningCategory.smartExplorers,
      subtitle: 'Remember the colors!',
      hasParentControls: false,
    ),
  ];

  static GameCatalogEntry? entryFor(GameId id) {
    for (final e in entries) {
      if (e.gameId == id) return e;
    }
    return null;
  }

  static List<GameCatalogEntry> forCategory(LearningCategory category) =>
      entries.where((e) => e.category == category).toList(growable: false);

  static List<GameCatalogEntry> get withParentControls => entries
      .where((e) => e.hasParentControls)
      .toList(growable: false);
}
