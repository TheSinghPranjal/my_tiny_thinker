import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';

class PondVictoryOverlay extends StatelessWidget {
  const PondVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final FrogPondResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Frog Pond Celebration!',
      stats: [
        CelebrationStat(
          icon: '🐸',
          label: 'Frogs Tapped',
          value: '${result.frogsTapped}',
        ),
        CelebrationStat(
          icon: '👑',
          label: 'King Frogs',
          value: '${result.kingFrogsRemoved}',
        ),
        CelebrationStat(icon: '⭐', label: 'Points', value: '+${result.points}'),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '🌟',
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
