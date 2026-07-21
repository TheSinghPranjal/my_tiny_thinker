import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/presentation/widgets/ocean_fishing_background.dart';

class CatchTheFishSetupScreen extends ConsumerWidget {
  const CatchTheFishSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OceanFishingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🎣🐠',
          emojiSize: 72,
          title: 'Catch the Fish Adventure',
          subtitle: 'Tap the fish and reel them into the boat!',
          skills: kCatchTheFishSkills,
          skillChipColor: const Color(0xFF4FC3F7).withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF01579B), blurRadius: 6),
          ],
          onPlay: () => context.push(AppRoutes.catchTheFishGame),
        ),
      ),
    );
  }
}
