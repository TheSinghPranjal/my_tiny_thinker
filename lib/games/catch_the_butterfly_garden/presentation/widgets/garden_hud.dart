import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

class GardenVictoryOverlay extends StatelessWidget {
  const GardenVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ButterflyGardenResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Butterfly Garden Celebration!',
      stats: [
        CelebrationStat(
          icon: '🦋',
          label: 'Butterflies Collected',
          value: '${result.butterfliesCaught}',
        ),
        CelebrationStat(
          icon: '✨',
          label: 'Golden Butterflies',
          value: '${result.goldenCaught}',
        ),
        CelebrationStat(
          icon: '🐝',
          label: 'Bees Visited',
          value: '${result.beesTapped}',
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
