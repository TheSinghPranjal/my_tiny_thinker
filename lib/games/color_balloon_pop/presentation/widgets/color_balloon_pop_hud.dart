import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';

class ColorBalloonVictoryOverlay extends StatelessWidget {
  const ColorBalloonVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ColorBalloonPopResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Color Balloon Celebration!',
      stats: [
        CelebrationStat(
          icon: '🎈',
          label: 'Balloons Popped',
          value: '${result.balloonsPopped}',
        ),
        CelebrationStat(
          icon: '🎯',
          label: 'Rounds Completed',
          value: '${result.roundsCompleted}',
        ),
        CelebrationStat(
          icon: '🎨',
          label: 'Colors Mastered',
          value: '${result.colorsMastered}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Longest Streak',
          value: '${result.maxStreak}',
        ),
        CelebrationStat(icon: '⭐', label: 'Points', value: '+${result.points}'),
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
