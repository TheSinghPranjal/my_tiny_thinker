import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class GameSelectionGrid extends ConsumerWidget {
  const GameSelectionGrid({
    super.key,
    required this.onGameTap,
    this.enabledGameIds,
    this.largeLayout = false,
  });

  final void Function(GameId gameId) onGameTap;
  final List<String>? enabledGameIds;
  final bool largeLayout;

  static const _allGames = [
    GameId.candyColorHunt,
    GameId.bunnyHopAdventure,
    GameId.hungryTeddyCupcakeParty,
    GameId.hungryDuckPondAdventure,
    GameId.catchTheButterflyGarden,
    GameId.catchTheFishAdventure,
    GameId.hungryMonkeyBananaAdventure,
    GameId.feedTheFrogAdventure,
    GameId.frogPondAdventure,
    GameId.peekABooAnimalFriends,
    GameId.colorSchoolBags,
    GameId.alphabetBridgeAdventure,
    GameId.numberBridgeAdventure,
    GameId.pictureBridgeAdventure,
    GameId.colorShapeBridgeAdventure,
    GameId.moonRescueAdventure,
    GameId.shapeDropAdventure,
    GameId.shadowMatchAdventure,
    GameId.alphabetAdventureQuiz,
    GameId.animalSounds,
    GameId.cloudPopGarden,
    GameId.magicalFlowerGarden,
    GameId.oceanFishAdventure,
    GameId.balloonParade,
    GameId.colorBalloonPop,
    GameId.bubbleNumberPop,
    GameId.ascendingBubbleNumberPop,
    GameId.descendingNumberPop,
    GameId.numberWordPop,
    GameId.classicCardMemory,
    GameId.completeTheWordAdventure,
    GameId.memoryGame,
    GameId.oddOneOut,
    GameId.patternMatch,
    GameId.colorMemory,
  ];

  static const _meta = {
    GameId.peekABooAnimalFriends: (
      '🐾',
      'Peek-a-Boo Animal Friends',
      'Tap the bushes and find the hidden animals!',
      'Easy',
    ),
    GameId.frogPondAdventure: (
      '🐸',
      'Frog Pond Adventure',
      'Tap the frogs and watch them splash!',
      'Easy',
    ),
    GameId.feedTheFrogAdventure: (
      '🪰',
      'Feed the Frog Adventure',
      'Tap the flying bugs and feed the happy frog!',
      'Easy',
    ),
    GameId.hungryMonkeyBananaAdventure: (
      '🐵',
      'Hungry Monkey Banana Adventure',
      'Tap bananas and feed the hungry monkey!',
      'Easy',
    ),
    GameId.catchTheButterflyGarden: (
      '🦋',
      'Catch the Butterfly Garden',
      'Tap butterflies and fill your basket!',
      'Easy',
    ),
    GameId.catchTheFishAdventure: (
      '🎣',
      'Catch the Fish Adventure',
      'Tap fish and reel them into the boat!',
      'Easy',
    ),
    GameId.hungryDuckPondAdventure: (
      '🦆',
      'Hungry Duck Pond Adventure',
      'Tap fish and feed the hungry duck!',
      'Easy',
    ),
    GameId.hungryTeddyCupcakeParty: (
      '🧸',
      'Hungry Teddy Cupcake Party',
      'Drag cupcakes to feed the hungry teddy!',
      'Easy',
    ),
    GameId.candyColorHunt: (
      '🐜',
      'Candy Color Hunt',
      'Tap matching candies for the hungry ant!',
      'Easy',
    ),
    GameId.bunnyHopAdventure: (
      '🐰',
      'Bunny Hop Adventure',
      'Tap to hop across lily pads to the carrot!',
      'Easy',
    ),
    GameId.colorSchoolBags: (
      '🎒',
      'Color School Bags',
      'Drag books into matching backpacks!',
      'Easy',
    ),
    GameId.alphabetBridgeAdventure: (
      '🌉',
      'Alphabet Bridge Adventure',
      'Connect little letters to big letters!',
      'Easy',
    ),
    GameId.numberBridgeAdventure: (
      '🔢',
      'Number Bridge Adventure',
      'Connect digits to number words!',
      'Easy',
    ),
    GameId.pictureBridgeAdventure: (
      '🖼️',
      'Picture Bridge Adventure',
      'Connect pictures to their words!',
      'Easy',
    ),
    GameId.colorShapeBridgeAdventure: (
      '🔷',
      'Color & Shape Bridge Adventure',
      'Connect words to colors and shapes!',
      'Easy',
    ),
    GameId.moonRescueAdventure: (
      '🚀',
      'Moon Rescue Adventure',
      'Flick astronauts to the Moon and launch!',
      'Easy',
    ),
    GameId.shapeDropAdventure: (
      '🔷',
      'Shape Drop Adventure',
      'Drag shapes into the dotted outline!',
      'Easy',
    ),
    GameId.shadowMatchAdventure: (
      '🌗',
      'Shadow Match Adventure',
      'Drag pictures to their shadows!',
      'Easy',
    ),
    GameId.alphabetAdventureQuiz: (
      '🔤',
      'Alphabet Adventure Quiz',
      'Match letters with pictures!',
      'Easy',
    ),
    GameId.animalSounds: (
      '🔊',
      'Animal Sounds',
      'Listen and tap the matching animal!',
      'Easy',
    ),
    GameId.cloudPopGarden: (
      '☁️',
      'Cloud Pop Garden',
      'Tap rain clouds and watch flowers bloom!',
      'Easy',
    ),
    GameId.magicalFlowerGarden: (
      '🌸',
      'Magical Flower Garden',
      'Tap the flower and watch nature come alive!',
      'Easy',
    ),
    GameId.oceanFishAdventure: ('🐠', 'Ocean Fish Adventure', null, 'Easy'),
    GameId.balloonParade: (
      '🎈',
      'Balloon Parade',
      'Tap rising balloons in a magical parade!',
      'Easy',
    ),
    GameId.colorBalloonPop: (
      '🎨',
      'Color Balloon Pop',
      'Find and pop the matching color balloon!',
      'Easy',
    ),
    GameId.bubbleNumberPop: (
      '🔵',
      'Bubble Number Pop',
      'Pop the number you see on top!',
      'Easy',
    ),
    GameId.ascendingBubbleNumberPop: (
      '🔵',
      'Ascending Bubble Number Pop',
      'Pop numbers from smallest to biggest!',
      'Easy',
    ),
    GameId.descendingNumberPop: (
      '🔻',
      'Descending Number Pop',
      'Pop numbers from biggest to smallest!',
      'Easy',
    ),
    GameId.numberWordPop: (
      '🔤',
      'Number Word Pop',
      'Read the word and pop that number!',
      'Easy',
    ),
    GameId.classicCardMemory: (
      '🃏',
      'Classic Card Memory',
      'Flip cards and find matching pairs!',
      'Easy',
    ),
    GameId.completeTheWordAdventure: (
      '✏️',
      'Complete the Word Adventure',
      'Tap letters to spell the word!',
      'Medium',
    ),
    GameId.memoryGame: ('🧠', 'Memory Game', null, 'Medium'),
    GameId.oddOneOut: ('👀', 'Odd One Out', 'Tap the one that is different!', 'Easy'),
    GameId.patternMatch: ('🧩', 'Pattern Match', 'Complete the pattern!', 'Medium'),
    GameId.colorMemory: ('🌈', 'Color Memory', null, 'Easy'),
  };

  List<GameId> get _visibleGames {
    if (enabledGameIds == null) return _allGames;
    return _allGames
        .where((g) => enabledGameIds!.contains(g.id))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStats = ref.watch(allGameStatsProvider);
    final games = _visibleGames;
    final showComingSoon = !largeLayout && games.length < _allGames.length;

    return ResponsiveGrid(
      itemCount: games.length + (showComingSoon ? 1 : 0),
      phoneColumns: largeLayout ? 1 : 2,
      tabletColumns: largeLayout ? 2 : 3,
      childAspectRatio: largeLayout ? 2.4 : 0.78,
      itemBuilder: (context, index) {
        if (showComingSoon && index == games.length) {
          return const TTGameCard(
            emoji: '✨',
            title: 'More Coming Soon!',
            color: AppColors.softPurple,
            comingSoon: true,
          );
        }
        final gameId = games[index];
        final (emoji, title, subtitle, difficulty) = _meta[gameId]!;
        final stats = allStats[gameId] ?? GameStats(gameId: gameId);

        return TTGameCard(
          emoji: emoji,
          title: title,
          subtitle: subtitle,
          color: AppColors.gameCardColors[index % AppColors.gameCardColors.length],
          difficulty: largeLayout ? null : difficulty,
          starsEarned: largeLayout ? 0 : stats.starsEarned,
          bestScore: largeLayout ? 0 : stats.bestScore,
          onPlay: () => onGameTap(gameId),
        );
      },
    );
  }
}
