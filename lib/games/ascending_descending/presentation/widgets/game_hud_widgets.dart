import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class TargetNumberCard extends StatelessWidget {
  const TargetNumberCard({
    super.key,
    required this.targetNumber,
    required this.sortMode,
  });

  final int? targetNumber;
  final SortMode sortMode;

  @override
  Widget build(BuildContext context) {
    if (targetNumber == null) return const SizedBox.shrink();

    return PulseAnimation(
      child: TTCard(
        gradient: AppGradients.bubbleBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sortMode == SortMode.ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: AppColors.white,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Find:',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatNumber(targetNumber!),
              style: context.textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) => n.toString();
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    super.key,
    required this.score,
    this.combo = 0,
    this.comboLabel,
  });

  final int score;
  final int combo;
  final String? comboLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.sunYellow, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$score',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (combo >= 2 && comboLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.rainbow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Text(
              '$combo× $comboLabel',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class GameHudBar extends StatelessWidget {
  const GameHudBar({
    super.key,
    required this.current,
    required this.total,
    required this.score,
    required this.combo,
    this.remainingSeconds,
    this.timerMode = TimerMode.relaxed,
  });

  final int current;
  final int total;
  final int score;
  final int combo;
  final int? remainingSeconds;
  final TimerMode timerMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                child: LinearProgressIndicator(
                  value: total > 0 ? current / total : 0,
                  minHeight: 10,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.mintGreen),
                ),
              ),
            ),
            if (timerMode == TimerMode.timed && remainingSeconds != null) ...[
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: remainingSeconds! <= 10
                      ? AppColors.error
                      : AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${remainingSeconds}s',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: remainingSeconds! <= 10
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ScoreWidget(
          score: score,
          combo: combo,
          comboLabel: combo >= 2 ? _comboLabel(combo) : null,
        ),
      ],
    );
  }

  String _comboLabel(int c) {
    if (c >= 10) return 'Excellent!';
    if (c >= 5) return 'Super!';
    if (c >= 3) return 'Fantastic!';
    return 'Amazing!';
  }
}

class CountdownOverlay extends StatelessWidget {
  const CountdownOverlay({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.skyBlueDark.withValues(alpha: 0.4),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Text(
                count > 0 ? '$count' : 'Go!',
                style: context.textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 96,
                  shadows: const [
                    Shadow(color: AppColors.candyPink, blurRadius: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
