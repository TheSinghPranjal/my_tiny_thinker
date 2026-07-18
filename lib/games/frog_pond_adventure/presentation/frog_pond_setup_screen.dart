import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/pond_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class FrogPondSetupScreen extends ConsumerWidget {
  const FrogPondSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PondBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐸💧',
          emojiSize: 72,
          title: 'Frog Pond Adventure',
          subtitle: 'Tap the frogs and watch them splash!',
          skills: kFrogPondSkills,
          skillChipColor: const Color(0xFF4FC3F7).withValues(alpha: 0.25),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF0277BD), blurRadius: 6),
                    ],
          onPlay: () => context.push(AppRoutes.frogPondGame),
        ),
      ),
    );
  }
}
