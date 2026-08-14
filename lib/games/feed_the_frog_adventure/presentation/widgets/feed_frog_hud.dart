import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';

class FeedFrogVictoryOverlay extends StatelessWidget {
  const FeedFrogVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final FeedFrogResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Feed the Frog Celebration!',
      stats: [
        CelebrationStat(
          icon: '🪰',
          label: 'Insects Eaten',
          value: '${result.insectsEaten}',
        ),
        CelebrationStat(
          icon: '✨',
          label: 'Fireflies Caught',
          value: '${result.firefliesCaught}',
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
