import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';

/// Floating encouragement banner that does not affect layout height.
class GameFeedbackBanner extends StatelessWidget {
  const GameFeedbackBanner({
    super.key,
    this.message,
    this.rewardText,
    this.showMascot = false,
    this.rewardShadowColor = AppColors.grassGreen,
    this.plainMessage = false,
    this.messageColor,
  });

  final String? message;
  final String? rewardText;
  final bool showMascot;
  final Color rewardShadowColor;
  final bool plainMessage;
  final Color? messageColor;

  bool get _visible =>
      message != null || rewardText != null || showMascot;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null)
              plainMessage
                  ? Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: messageColor ?? AppColors.white,
                        fontWeight: FontWeight.w800,
                        shadows: messageColor == null
                            ? const [
                                Shadow(
                                  color: AppColors.skyBlueDark,
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    )
                  : PulseAnimation(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.rainbow,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusRound),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.candyPink.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
            if (rewardText != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  rewardText!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.sunYellow,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(color: rewardShadowColor, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            if (showMascot)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: MascotWidget(size: 48, waving: true),
              ),
          ],
        ),
      ),
    );
  }
}

/// Positions [GameFeedbackBanner] over gameplay without shifting layout.
class GameFeedbackOverlay extends StatelessWidget {
  const GameFeedbackOverlay({
    super.key,
    this.message,
    this.rewardText,
    this.showMascot = false,
    this.top = 52,
    this.rewardShadowColor = AppColors.grassGreen,
    this.plainMessage = false,
    this.messageColor,
  });

  final String? message;
  final String? rewardText;
  final bool showMascot;
  final double top;
  final Color rewardShadowColor;
  final bool plainMessage;
  final Color? messageColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: GameFeedbackBanner(
        message: message,
        rewardText: rewardText,
        showMascot: showMascot,
        rewardShadowColor: rewardShadowColor,
        plainMessage: plainMessage,
        messageColor: messageColor,
      ),
    );
  }
}
