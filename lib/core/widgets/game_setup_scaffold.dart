import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

/// Overflow-safe intro layout used by game setup / skills screens.
///
/// Keeps the back control and Play button visible, while the middle content
/// (emoji, title, skills) scrolls on short viewports.
class GameSetupScaffold extends StatelessWidget {
  const GameSetupScaffold({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onPlay,
    this.skills = const [],
    this.skillChipColor,
    this.titleColor,
    this.subtitleColor,
    this.titleShadows,
    this.playLabel = 'Play',
    this.showMascot = true,
    this.emojiSize = 64,
    this.backButtonBackground,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onPlay;
  final List<String> skills;
  final Color? skillChipColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Shadow>? titleShadows;
  final String playLabel;
  final bool showMascot;
  final double emojiSize;
  final Color? backButtonBackground;

  @override
  Widget build(BuildContext context) {
    final chipColor =
        skillChipColor ?? AppColors.softPurple.withValues(alpha: 0.35);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 32),
                onPressed: () => context.pop(),
                style: IconButton.styleFrom(
                  backgroundColor: backButtonBackground ??
                      AppColors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emoji,
                              style: TextStyle(fontSize: emojiSize),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: context.textTheme.displaySmall?.copyWith(
                                color: titleColor ?? AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                shadows: titleShadows,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: subtitleColor ??
                                    (titleColor ?? AppColors.white)
                                        .withValues(alpha: 0.95),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            if (skills.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.welcomeCard,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusXl,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Skills Developed',
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        for (final skill in skills)
                                          Chip(
                                            visualDensity: VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                            label: Text(
                                              skill,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            backgroundColor: chipColor,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (showMascot) ...[
                              const SizedBox(height: AppSpacing.md),
                              const MascotWidget(size: 64, waving: true),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TTButton(
              label: playLabel,
              expanded: true,
              size: TTButtonSize.large,
              onPressed: onPlay,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
