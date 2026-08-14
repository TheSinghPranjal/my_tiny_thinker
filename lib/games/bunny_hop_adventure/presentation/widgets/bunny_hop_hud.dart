import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

class BunnyHopVictoryOverlay extends StatelessWidget {
  const BunnyHopVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final BunnyHopResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Bunny Hop Celebration!',
      stats: [
        CelebrationStat(
          icon: '🐾',
          label: 'Total Hops',
          value: '${result.totalHops}',
        ),
        CelebrationStat(
          icon: '🥕',
          label: 'Carrots Collected',
          value: '${result.carrotsCollected}',
        ),
        CelebrationStat(icon: '⭐', label: 'Points', value: '+${result.points}'),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
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
        CelebrationStat(
          icon: '💧',
          label: 'Splash Recoveries',
          value: '${result.fallsRecovered}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
