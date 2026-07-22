import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/presentation/widgets/cloud_pop_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class CloudPopGardenSetupScreen extends ConsumerWidget {
  const CloudPopGardenSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CloudPopBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '☁️🌧️🌸',
          emojiSize: 72,
          title: 'Cloud Pop Garden',
          subtitle: 'Tap the rain cloud above each flower and watch it bloom!',
          skills: kCloudPopSkills,
          skillChipColor: const Color(0xFF81D4FA).withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF0277BD), blurRadius: 6),
                    ],
          onPlay: () => pushGameGuarded(context, ref, GameId.cloudPopGarden, AppRoutes.cloudPopGardenGame),
        ),
      ),
    );
  }
}
