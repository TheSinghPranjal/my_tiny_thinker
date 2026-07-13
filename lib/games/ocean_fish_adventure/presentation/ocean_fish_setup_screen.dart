import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/widgets/ocean_background.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';

class OceanFishSetupScreen extends ConsumerWidget {
  const OceanFishSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OceanBackground(
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
                      backgroundColor: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const Spacer(),
                const Text('🐠', style: TextStyle(fontSize: 80)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ocean Fish Adventure',
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0xFF01579B), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap the fish and watch them swim!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const MascotWidget(size: 72, waving: true),
                const Spacer(flex: 2),
                TTButton(
                  label: 'Dive In!',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: () => context.push(AppRoutes.oceanFishGame),
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
