import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

class MoonRescueVictoryOverlay extends StatelessWidget {
  const MoonRescueVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final MoonRescueResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Moon Rescue Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '🧑‍🚀',
          label: 'Rescued',
          value: '${result.astronautsRescued}',
        ),
        CelebrationStat(
          icon: '🚀',
          label: 'Rockets Launched',
          value: '${result.rocketsLaunched}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Streak',
          value: '${result.maxStreak}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
