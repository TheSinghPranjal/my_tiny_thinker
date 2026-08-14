import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

class SortBagsVictoryOverlay extends StatelessWidget {
  const SortBagsVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final SortBagsResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return GameCelebrationOverlay(
      title: 'Color Sorting Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '🎒',
          label: 'Books Sorted',
          value: '${result.correctMatches}',
        ),
        CelebrationStat(
          icon: '🏁',
          label: 'Level Reached',
          value: '${result.levelReached}',
        ),
        CelebrationStat(icon: '🎯', label: 'Accuracy', value: '$accuracyPct%'),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Streak',
          value: '${result.maxStreak}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
