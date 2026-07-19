import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_widget.dart';

class ColorTargetCard extends StatelessWidget {
  const ColorTargetCard({
    super.key,
    required this.targetHue,
    required this.instruction,
  });

  final BalloonHue targetHue;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            targetHue.primaryColor.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: targetHue.primaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: targetHue.accentColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 70,
            child: CustomPaint(
              painter: BalloonPainter(
                hue: targetHue,
                pattern: BalloonPattern.solid,
                face: BalloonFace.happy,
                ribbon: BalloonRibbon.curly,
                shineSeed: 0.4,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              instruction,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
