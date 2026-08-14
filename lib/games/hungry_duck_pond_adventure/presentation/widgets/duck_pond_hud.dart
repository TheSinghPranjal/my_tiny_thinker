import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

class DuckPondVictoryOverlay extends StatelessWidget {
  const DuckPondVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final HungryDuckResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Hungry Duck Celebration!',
      stats: [
        CelebrationStat(
          icon: '🐟',
          label: 'Fish Caught',
          value: '${result.fishCaught}',
        ),
        CelebrationStat(
          icon: '✨',
          label: 'Golden Fish',
          value: '${result.goldenCaught}',
        ),
        CelebrationStat(
          icon: '🦆',
          label: 'Duck Swims',
          value: '${result.duckSwims}',
        ),
        CelebrationStat(icon: '⭐', label: 'Points', value: '+${result.points}'),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '🌟', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '💫',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Streak',
          value: '${result.longestStreak}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
