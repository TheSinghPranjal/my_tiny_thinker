import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';

class OceanFishHud extends StatelessWidget {
  const OceanFishHud({
    super.key,
    required this.remainingSeconds,
    required this.fishTapped,
    required this.coinsEarned,
    required this.feedbackMessage,
    required this.rewardText,
    required this.showMascot,
    required this.onPause,
  });

  final int remainingSeconds;
  final int fishTapped;
  final int coinsEarned;
  final String? feedbackMessage;
  final String? rewardText;
  final bool showMascot;
  final VoidCallback onPause;

  String get _timer {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _Pill(
                icon: Icons.timer_rounded,
                label: _timer,
                color: remainingSeconds <= 10
                    ? AppColors.error
                    : AppColors.white,
              ),
              const Spacer(),
              _Pill(
                icon: Icons.set_meal_rounded,
                label: '$fishTapped',
                color: AppColors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              _Pill(
                icon: Icons.monetization_on_rounded,
                label: '+$coinsEarned',
                color: AppColors.sunYellow,
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.home_rounded, size: 28),
                onPressed: onPause,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        if (feedbackMessage != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.rainbow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            ),
            child: Text(
              feedbackMessage!,
              style: context.textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        if (rewardText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              rewardText!,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.sunYellow,
                fontWeight: FontWeight.w800,
                shadows: const [
                  Shadow(color: AppColors.skyBlueDark, blurRadius: 4),
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
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.skyBlueDark, size: 22),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color == AppColors.sunYellow
                  ? AppColors.orange
                  : color == AppColors.error
                      ? AppColors.error
                      : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class OceanVictoryOverlay extends StatelessWidget {
  const OceanVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final OceanFishResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF01579B).withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(size: 100, waving: true),
                Text(
                  'Amazing Ocean Adventure!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('🐟 Fish Found', '${result.fishTapped}'),
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
