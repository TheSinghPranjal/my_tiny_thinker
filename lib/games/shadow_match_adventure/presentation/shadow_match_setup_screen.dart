import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';

class ShadowMatchSetupScreen extends ConsumerWidget {
  const ShadowMatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🌗🦋✨',
          emojiSize: 72,
          title: 'Shadow Match Adventure',
          subtitle: 'Drag each picture to its matching shadow!',
          skills: kShadowSkills,
          skillChipColor: AppColors.lavender.withValues(alpha: 0.25),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF5E35B1), blurRadius: 6),
          ],
          onPlay: () => pushGameGuarded(context, ref, GameId.shadowMatchAdventure, AppRoutes.shadowMatchGame),
        ),
      ),
    );
  }
}