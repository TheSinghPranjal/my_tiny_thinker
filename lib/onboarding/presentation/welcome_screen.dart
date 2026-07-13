import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const MascotWidget(size: 140, waving: true),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome to TinyThink!',
                textAlign: TextAlign.center,
                style: context.textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  shadows: const [
                    Shadow(color: AppColors.skyBlueDark, blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Let's train your brain while having fun!",
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.95),
                ),
              ),
              const Spacer(flex: 3),
              TTButton(
                label: "Let's Play!",
                expanded: true,
                size: TTButtonSize.large,
                onPressed: () => context.go(AppRoutes.ageSelection),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
