import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/game_config/game_catalog.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_provider.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class LearningPathCard extends ConsumerWidget {
  const LearningPathCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (!isPremium) return const SizedBox.shrink();

    final age = ref.watch(onboardingProvider.select((s) => s.ageGroup));
    final category = LearningCategory.fromAgeGroup(age);
    ref.watch(learningPathPrefsProvider);
    final queue =
        ref.read(learningPathSessionProvider.notifier).buildQueue(category);

    return TTCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF81D4FA), Color(0xFFCE93D8), Color(0xFFFFCC80)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Learning Path',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'TinyThink can guide your child through selected '
            '${category.label} games automatically — no need to return home '
            'after each game.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            queue.isEmpty
                ? 'Enable games in Parent Controls to start.'
                : '${queue.length} games ready in this path',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TTButton(
              label: 'Start Learning Path',
              size: TTButtonSize.large,
              onPressed: queue.isEmpty
                  ? null
                  : () {
                      final ok = ref
                          .read(learningPathSessionProvider.notifier)
                          .start(category);
                      if (!ok) return;
                      final first = ref.read(learningPathSessionProvider).currentGame;
                      if (first == null) return;
                      navigateToGame(context, first);
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.parentZone),
              child: Text(
                'Choose games in Parent Controls',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
