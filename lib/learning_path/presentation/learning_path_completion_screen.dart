import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class LearningPathCompletionScreen extends ConsumerWidget {
  const LearningPathCompletionScreen({super.key, required this.summary});

  final LearningPathSession summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = (summary.totalPlaySeconds / 60).ceil().clamp(1, 999);
    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                const MascotWidget(size: 96, waving: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Learning Journey Complete!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  summary.category?.label ?? 'Learning Path',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: TTCard(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _Stat('Games Completed', '${summary.gamesCompleted}'),
                          _Stat('Coins Earned', '${summary.totalCoins}'),
                          _Stat('XP Gained', '${summary.totalXp}'),
                          _Stat('Happy Stars', '${summary.totalStars}'),
                          _Stat('Play Time', '$minutes min'),
                          if (summary.achievements.isNotEmpty)
                            _Stat(
                              'Achievements',
                              summary.achievements.join(', '),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TTButton(
                  label: 'Back Home',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
