import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';

class CloudPopVictoryOverlay extends StatelessWidget {
  const CloudPopVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final CloudPopGardenResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Cloud Pop Celebration!',
      stats: [
        CelebrationStat(
          icon: '💧',
          label: 'Flowers Watered',
          value: '${result.flowersWatered}',
        ),
        CelebrationStat(
          icon: '☁️',
          label: 'Clouds Tapped',
          value: '${result.cloudsTapped}',
        ),
        CelebrationStat(
          icon: '🌧️',
          label: 'Rain Events',
          value: '${result.successfulRains}',
        ),
        CelebrationStat(
          icon: '🌈',
          label: 'Rainbows',
          value: '${result.rainbowsCreated}',
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
