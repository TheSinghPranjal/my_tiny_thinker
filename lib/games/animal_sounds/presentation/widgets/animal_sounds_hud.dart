import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/animal_sounds/models/animal_sounds_models.dart';

class AnimalSoundsVictoryOverlay extends StatelessWidget {
  const AnimalSoundsVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final AnimalSoundsResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Animal Sounds Celebration!',
      stats: [
        CelebrationStat(
          icon: '✅',
          label: 'Correct',
          value: '${result.correctCount}',
        ),
        CelebrationStat(
          icon: '🎯',
          label: 'Tries',
          value: '${result.attempts}',
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
