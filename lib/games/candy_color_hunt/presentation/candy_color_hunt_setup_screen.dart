import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_world_background.dart';

class CandyColorHuntSetupScreen extends ConsumerWidget {
  const CandyColorHuntSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyWorldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 32),
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
                const Spacer(),
                const Text('🐜🍬🌈', style: TextStyle(fontSize: 72)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Candy Color Hunt',
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Help the hungry ant find candies of the right color!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFBF360C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppGradients.welcomeCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skills Developed',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: kCandyHuntSkills
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                backgroundColor:
                                    const Color(0xFFFFCC80).withValues(alpha: 0.45),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const MascotWidget(size: 72, waving: true),
                const Spacer(flex: 2),
                TTButton(
                  label: 'Play',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: () => context.push(AppRoutes.candyColorHuntGame),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
