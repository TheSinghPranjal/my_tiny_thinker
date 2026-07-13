import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

class TTBadge extends StatelessWidget {
  const TTBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.skyBlue,
    this.textColor = AppColors.white,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class TTCurrencyBadge extends StatelessWidget {
  const TTCurrencyBadge({
    super.key,
    required this.icon,
    required this.value,
    this.color = AppColors.sunYellow,
  });

  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$value',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TTDifficultyBadge extends StatelessWidget {
  const TTDifficultyBadge({super.key, required this.difficulty});

  final String difficulty;

  Color get _color => switch (difficulty.toLowerCase()) {
        'easy' => AppColors.mintGreen,
        'medium' => AppColors.sunYellow,
        'hard' => AppColors.orange,
        'expert' => AppColors.candyPink,
        _ => AppColors.skyBlue,
      };

  @override
  Widget build(BuildContext context) {
    return TTBadge(
      label: difficulty.toUpperCase(),
      color: _color,
      textColor: AppColors.textPrimary,
    );
  }
}

class TTComboBadge extends StatelessWidget {
  const TTComboBadge({super.key, required this.combo, required this.label});

  final int combo;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.rainbow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppColors.candyPink.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Text(
        '$combo Combo! $label',
        style: context.textTheme.titleMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
