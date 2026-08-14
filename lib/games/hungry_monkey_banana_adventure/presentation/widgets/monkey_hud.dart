import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

class MonkeyVictoryOverlay extends StatelessWidget {
  const MonkeyVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final HungryMonkeyResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Hungry Monkey Celebration!',
      stats: [
        CelebrationStat(
          icon: '🍌',
          label: 'Bananas Fed',
          value: '${result.bananasFed}',
        ),
        CelebrationStat(
          icon: '🍎',
          label: 'Apples Tapped',
          value: '${result.applesTapped}',
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
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
