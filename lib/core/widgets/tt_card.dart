import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

class TTCard extends StatelessWidget {
  const TTCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.padding,
    this.onTap,
    this.elevated = true,
    this.borderRadius,
  });

  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevated;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? AppColors.white) : null,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.skyBlue.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.candyPink.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return BounceTapWrapper(onTap: onTap, child: card);
    }
    return card;
  }
}

class TTGlassCard extends StatelessWidget {
  const TTGlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.glassOverlay,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

class TTGameCard extends StatelessWidget {
  const TTGameCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.color,
    this.difficulty,
    this.subtitle,
    this.starsEarned = 0,
    this.bestScore = 0,
    this.onPlay,
    this.comingSoon = false,
  });

  final String emoji;
  final String title;
  final Color color;
  final String? difficulty;
  final String? subtitle;
  final int starsEarned;
  final int bestScore;
  final VoidCallback? onPlay;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return TTCard(
      onTap: comingSoon ? null : onPlay,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.9),
          color,
          Color.lerp(color, Colors.white, 0.2)!,
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const Spacer(),
              if (starsEarned > 0)
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.sunYellow, size: 16),
                    Text(
                      '$starsEarned',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Spacer(),
                if (difficulty != null)
                  Text(
                    difficulty!,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                if (bestScore > 0)
                  Text(
                    'Best: $bestScore',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (comingSoon)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'Coming Soon!',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: color, size: 18),
                  Text(
                    'Play',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
