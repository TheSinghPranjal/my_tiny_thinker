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
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/jungle_background.dart';

class HungryMonkeySetupScreen extends ConsumerWidget {
  const HungryMonkeySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JungleBackground(
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
                const Text('🐵🍌', style: TextStyle(fontSize: 72)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Hungry Monkey Banana Adventure',
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0xFF33691E), blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap the bananas and feed the happy monkey!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.95),
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
                        children: kHungryMonkeySkills
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                backgroundColor:
                                    const Color(0xFF81C784).withValues(alpha: 0.35),
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
                  onPressed: () => context.push(AppRoutes.hungryMonkeyGame),
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
