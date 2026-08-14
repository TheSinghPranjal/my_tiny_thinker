import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

class GardenVictoryOverlay extends StatelessWidget {
  const GardenVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final FlowerGardenResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Magical Flower Celebration!',
      stats: [
        CelebrationStat(
          icon: '🌸',
          label: 'Flowers Bloomed',
          value: '${result.bloomsCount}',
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
