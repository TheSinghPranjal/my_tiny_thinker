import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/home/presentation/widgets/game_selection_grid.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      showGrass: false,
      child: SafeArea(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Games',
                style: context.textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  shadows: const [
                    Shadow(color: AppColors.skyBlueDark, blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick a game and start learning!',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: GameSelectionGrid(
                    onGameTap: (gameId) => navigateToGame(context, gameId),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
