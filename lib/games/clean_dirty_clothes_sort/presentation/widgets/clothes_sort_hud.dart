import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

class LaundrySortVictoryOverlay extends StatelessWidget {
  const LaundrySortVictoryOverlay({
    super.key,
    required this.title,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final String title;
  final LaundrySortResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return GameCelebrationOverlay(
      title: title,
      stats: [
        CelebrationStat(
          icon: '👕',
          label: 'Clothes Sorted',
          value: '${result.correctSorts}',
        ),
        CelebrationStat(
          icon: '🧺',
          label: 'Clean Stored',
          value: '${result.cleanStored}',
        ),
        CelebrationStat(
          icon: '🫧',
          label: 'Dirty Washed',
          value: '${result.dirtyWashed}',
        ),
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
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
