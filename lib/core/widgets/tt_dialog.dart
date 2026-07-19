import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

class TTDialog extends StatelessWidget {
  const TTDialog({
    super.key,
    required this.title,
    this.message,
    this.emoji,
    this.child,
    this.primaryAction,
    this.primaryLabel = 'OK',
    this.secondaryAction,
    this.secondaryLabel,
    this.showConfetti = false,
  });

  final String title;
  final String? message;
  final String? emoji;
  final Widget? child;
  final VoidCallback? primaryAction;
  final String primaryLabel;
  final VoidCallback? secondaryAction;
  final String? secondaryLabel;
  final bool showConfetti;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    String? emoji,
    Widget? child,
    VoidCallback? primaryAction,
    String primaryLabel = 'OK',
    VoidCallback? secondaryAction,
    String? secondaryLabel,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => TTDialog(
        title: title,
        message: message,
        emoji: emoji,
        primaryAction: primaryAction,
        primaryLabel: primaryLabel,
        secondaryAction: secondaryAction,
        secondaryLabel: secondaryLabel,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppGradients.welcomeCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: AppSpacing.lg),
              child!,
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                if (secondaryAction != null && secondaryLabel != null) ...[
                  Expanded(
                    child: TTButton(
                      label: secondaryLabel!,
                      variant: TTButtonVariant.ghost,
                      onPressed: () {
                        Navigator.of(context).pop();
                        secondaryAction!();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: TTButton(
                    label: primaryLabel,
                    onPressed: () {
                      Navigator.of(context).pop();
                      primaryAction?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TTPauseDialog extends StatelessWidget {
  const TTPauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    this.onSettings,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final FutureOr<void> Function()? onSettings;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResume,
    required VoidCallback onRestart,
    required VoidCallback onHome,
    FutureOr<void> Function()? onSettings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TTPauseDialog(
        onResume: onResume,
        onRestart: onRestart,
        onHome: onHome,
        onSettings: onSettings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TTDialog(
      title: 'Paused',
      emoji: '⏸️',
      message: 'Take a little break!',
      primaryLabel: 'Resume',
      primaryAction: onResume,
      secondaryLabel: 'Restart',
      secondaryAction: onRestart,
      child: Column(
        children: [
          TTButton(
            label: 'Home',
            variant: TTButtonVariant.secondary,
            expanded: true,
            onPressed: () {
              Navigator.of(context).pop();
              onHome();
            },
          ),
          if (onSettings != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TTButton(
              label: 'Settings',
              variant: TTButtonVariant.ghost,
              expanded: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await onSettings!();
              },
            ),
          ],
        ],
      ),
    );
  }
}
