import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/presentation/widgets/garden_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class FlowerGardenSetupScreen extends ConsumerWidget {
  const FlowerGardenSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GardenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🌸🦋',
          emojiSize: 72,
          title: 'Magical Flower Garden',
          subtitle: 'Tap the flower and watch nature come alive!',
          skills: kGardenSkills,
          skillChipColor: AppColors.candyPink.withValues(alpha: 0.25),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF2E7D32), blurRadius: 6),
                    ],
          onPlay: () => pushGameGuarded(context, ref, GameId.magicalFlowerGarden, AppRoutes.flowerGardenGame),
        ),
      ),
    );
  }
}
