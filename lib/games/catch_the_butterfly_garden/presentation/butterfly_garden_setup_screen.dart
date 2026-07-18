import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class ButterflyGardenSetupScreen extends ConsumerWidget {
  const ButterflyGardenSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GardenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🦋🌸',
          emojiSize: 72,
          title: 'Catch the Butterfly Garden',
          subtitle: 'Tap the butterflies and fill your basket!',
          skills: kButterflyGardenSkills,
          skillChipColor: const Color(0xFFCE93D8).withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF7B1FA2), blurRadius: 6),
                    ],
          onPlay: () => context.push(AppRoutes.butterflyGardenGame),
        ),
      ),
    );
  }
}
