import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

class TeddyVictoryOverlay extends StatelessWidget {
  const TeddyVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final HungryTeddyResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Cupcake Party Celebration!',
      stats: [
        CelebrationStat(
          icon: '🧁',
          label: 'Cupcakes Fed',
          value: '${result.cupcakesFed}',
        ),
        CelebrationStat(
          icon: '✨',
          label: 'Golden Cupcakes',
          value: '${result.goldenFed}',
        ),
        CelebrationStat(
          icon: '🍰',
          label: 'Favorite Flavor',
          value: result.favoriteFlavor,
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
