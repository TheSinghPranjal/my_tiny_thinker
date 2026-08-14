import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

class ShapeDropVictoryOverlay extends StatelessWidget {
  const ShapeDropVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ShapeDropResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    final fav = result.favoriteShape != null
        ? ShapeCatalog.displayName(result.favoriteShape!)
        : '—';
    return GameCelebrationOverlay(
      title: 'Shape Drop Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '✅',
          label: 'Shapes Matched',
          value: '${result.correctMatches}',
        ),
        CelebrationStat(
          icon: '📚',
          label: 'Shapes Learned',
          value: '${result.shapesLearned}',
        ),
        CelebrationStat(icon: '💗', label: 'Favorite', value: fav),
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
