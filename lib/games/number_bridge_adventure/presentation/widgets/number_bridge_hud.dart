import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

class NumberBridgeVictoryOverlay extends StatelessWidget {
  const NumberBridgeVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final NumberBridgeResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return GameCelebrationOverlay(
      title: 'Number Bridge Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '🔢',
          label: 'Numbers Matched',
          value: '${result.correctMatches}',
        ),
        CelebrationStat(
          icon: '🏁',
          label: 'Rounds',
          value: '${result.roundsCompleted}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Streak',
          value: '${result.maxStreak}',
        ),
        CelebrationStat(icon: '🎯', label: 'Accuracy', value: '$accuracyPct%'),
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
