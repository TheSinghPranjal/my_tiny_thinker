import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

enum TTButtonVariant { primary, secondary, success, danger, ghost }

enum TTButtonSize { small, medium, large }

class TTButton extends ConsumerWidget {
  const TTButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = TTButtonVariant.primary,
    this.size = TTButtonSize.medium,
    this.expanded = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TTButtonVariant variant;
  final TTButtonSize size;
  final bool expanded;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (height, fontSize, hPad) = switch (size) {
      TTButtonSize.small => (40.0, 13.0, AppSpacing.md),
      TTButtonSize.medium => (AppSpacing.touchTargetMin, 15.0, AppSpacing.lg),
      TTButtonSize.large => (AppSpacing.touchTargetLarge, 17.0, AppSpacing.xl),
    };

    final gradient = _gradientForVariant(variant);
    final textColor = variant == TTButtonVariant.ghost
        ? AppColors.skyBlueDark
        : AppColors.white;

    final child = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        gradient: enabled ? gradient : null,
        color: enabled
            ? null
            : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        border: variant == TTButtonVariant.ghost
            ? Border.all(color: AppColors.skyBlue, width: 2)
            : null,
        boxShadow: enabled && variant != TTButtonVariant.ghost
            ? [
                BoxShadow(
                  color: AppColors.skyBlue.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: fontSize + 4),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    return BounceTapWrapper(
      enabled: enabled && onPressed != null,
      onTap: () {
        ref.read(hapticServiceProvider).trigger(HapticType.light);
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
        onPressed?.call();
      },
      child: expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }

  Gradient? _gradientForVariant(TTButtonVariant v) {
    return switch (v) {
      TTButtonVariant.primary => AppGradients.bubbleBlue,
      TTButtonVariant.secondary => AppGradients.bubblePurple,
      TTButtonVariant.success => AppGradients.bubbleGreen,
      TTButtonVariant.danger => const LinearGradient(
          colors: [AppColors.error, Color(0xFFE53935)],
        ),
      TTButtonVariant.ghost => null,
    };
  }
}
