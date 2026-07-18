import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

/// Full-screen paused state that always offers a way back into the game.
///
/// Used when the pause dialog was dismissed (e.g. after visiting Parent Zone)
/// so the child is never stuck with no Resume control.
class GamePausedOverlay extends StatelessWidget {
  const GamePausedOverlay({
    super.key,
    required this.onResume,
    this.onOpenMenu,
    this.scrimColor = const Color(0xFF5E35B1),
  });

  final VoidCallback onResume;
  final VoidCallback? onOpenMenu;
  final Color scrimColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: scrimColor.withValues(alpha: 0.72),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏸️', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Paused',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Take a little break!',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TTButton(
                    label: 'Resume',
                    expanded: true,
                    size: TTButtonSize.large,
                    onPressed: onResume,
                  ),
                  if (onOpenMenu != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    TTButton(
                      label: 'Pause Menu',
                      expanded: true,
                      variant: TTButtonVariant.ghost,
                      onPressed: onOpenMenu,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
