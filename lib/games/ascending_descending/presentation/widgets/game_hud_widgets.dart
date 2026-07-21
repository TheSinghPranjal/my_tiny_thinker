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
    this.toddlerMode = false,
    this.large = false,
    this.showAsWord = false,
    this.wordLabel,
  });

  final int? targetNumber;
  final SortMode sortMode;
  final bool toddlerMode;
  final bool large;
  final bool showAsWord;
  final String? wordLabel;

  @override
  Widget build(BuildContext context) {
    if (targetNumber == null) return const SizedBox.shrink();

    final display = showAsWord
        ? (wordLabel ?? targetNumber.toString())
        : targetNumber.toString();

    return PulseAnimation(
      child: TTCard(
        gradient: AppGradients.bubbleBlue,
        padding: EdgeInsets.symmetric(
          horizontal: large ? AppSpacing.xxl : AppSpacing.xl,
          vertical: large ? AppSpacing.lg : AppSpacing.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!toddlerMode && !showAsWord) ...[
              Icon(
                sortMode == SortMode.ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: AppColors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              showAsWord ? 'Find:' : 'Find:',
              style: (large
                      ? context.textTheme.headlineSmall
                      : context.textTheme.titleMedium)
                  ?.copyWith(
                color: AppColors.white.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                display,
                textAlign: TextAlign.center,
                style: (large || showAsWord
                        ? context.textTheme.displaySmall
                        : context.textTheme.displaySmall)
                    ?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: showAsWord && display.length > 12 ? 28 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameTimerBadge extends StatelessWidget {
  const GameTimerBadge({
    super.key,
    required this.seconds,
    this.large = false,
  });

  final int seconds;
  final bool large;

  String get _formatted {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.md : AppSpacing.sm,
        vertical: large ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: urgent
            ? AppColors.error
            : AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: (urgent ? AppColors.error : AppColors.skyBlue)
                .withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: large ? 24 : 18,
            color: urgent ? AppColors.white : AppColors.skyBlueDark,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            _formatted,
            style: (large
                    ? context.textTheme.titleLarge
                    : context.textTheme.labelLarge)
                ?.copyWith(
              color: urgent ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackToast extends StatelessWidget {
  const FeedbackToast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PulseAnimation(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.rainbow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPink.withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          message,
          style: context.textTheme.headlineSmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    super.key,
    required this.score,
    this.combo = 0,
    this.comboLabel,
    this.large = false,
    this.lastPointsEarned = 0,
  });

  final int score;
  final int combo;
  final String? comboLabel;
  final bool large;
  final int lastPointsEarned;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: large ? AppSpacing.lg : AppSpacing.md,
            vertical: large ? AppSpacing.md : AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.sunYellow,
                size: large ? 28 : 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$score',
                style: (large
                        ? context.textTheme.headlineSmall
                        : context.textTheme.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (lastPointsEarned > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          FloatingPointsBadge(points: lastPointsEarned),
        ],
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

class FloatingPointsBadge extends StatelessWidget {
  const FloatingPointsBadge({super.key, required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(points),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, t, child) {
        return Transform.translate(
          offset: Offset(0, -20 * t),
          child: Opacity(
            opacity: 1 - t,
            child: child,
          ),
        );
      },
      child: Text(
        '+$points',
        style: context.textTheme.titleMedium?.copyWith(
          color: AppColors.sunYellow,
          fontWeight: FontWeight.w800,
          shadows: const [
            Shadow(color: AppColors.skyBlueDark, blurRadius: 4),
          ],
        ),
      ),
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
    this.lastPointsEarned = 0,
    this.toddlerMode = false,
  });

  final int current;
  final int total;
  final int score;
  final int combo;
  final int lastPointsEarned;
  final bool toddlerMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          child: LinearProgressIndicator(
            value: total > 0 ? current / total : 0,
            minHeight: toddlerMode ? 16 : 10,
            backgroundColor: AppColors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(AppColors.mintGreen),
          ),
        ),
        SizedBox(height: toddlerMode ? AppSpacing.md : AppSpacing.sm),
        ScoreWidget(
          score: score,
          combo: combo,
          comboLabel: combo >= 2 ? _comboLabel(combo) : null,
          large: toddlerMode,
          lastPointsEarned: lastPointsEarned,
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
