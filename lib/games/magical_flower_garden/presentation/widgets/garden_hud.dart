import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

class GardenVictoryOverlay extends StatelessWidget {
  const GardenVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final FlowerGardenResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final title = 'Amazing Garden Adventure!';
    final subtitle = 'You explored the magical garden!';

    return Container(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.82),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎆🌈🦋', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('🌸 Flowers Bloomed', '${result.bloomsCount}'),
                _Row('🪙 Coins', '+${result.coins}'),
                _Row('⭐ Happy Stars', '+${result.stars}'),
                _Row('✨ XP', '+${result.xp}'),
                const SizedBox(height: AppSpacing.xl),
                TTButton(
                  label: 'Play Again!',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: onPlayAgain,
                ),
                const SizedBox(height: AppSpacing.sm),
                TTButton(
                  label: 'Home',
                  variant: TTButtonVariant.ghost,
                  expanded: true,
                  onPressed: onHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.titleMedium?.copyWith(color: AppColors.white)),
          Text(value, style: context.textTheme.titleLarge?.copyWith(color: AppColors.sunYellow)),
        ],
      ),
    );
  }
}
