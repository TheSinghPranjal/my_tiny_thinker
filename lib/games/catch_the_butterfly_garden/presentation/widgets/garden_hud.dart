import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

class GardenHud extends StatelessWidget {
  const GardenHud({
    super.key,
    required this.remainingSeconds,
    required this.butterfliesCaught,
    required this.coinsEarned,
    required this.onPause,
    this.largerFonts = false,
  });

  final int remainingSeconds;
  final int butterfliesCaught;
  final int coinsEarned;
  final VoidCallback onPause;
  final bool largerFonts;

  String get _timer {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = largerFonts ? 1.2 : 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _Pill(
            icon: Icons.timer_rounded,
            label: _timer,
            color: remainingSeconds <= 10 ? AppColors.error : AppColors.white,
            fontScale: fontScale,
          ),
          const Spacer(),
          _Pill(
            icon: Icons.pest_control_outlined,
            label: '$butterfliesCaught',
            color: AppColors.white,
            fontScale: fontScale,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Pill(
            icon: Icons.monetization_on_rounded,
            label: '+$coinsEarned',
            color: AppColors.sunYellow,
            fontScale: fontScale,
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.pause_rounded, size: 28),
            onPressed: onPause,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    this.fontScale = 1,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7B1FA2), size: 22),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: (context.textTheme.titleMedium?.fontSize ?? 16) * fontScale,
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

class GardenVictoryOverlay extends StatelessWidget {
  const GardenVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ButterflyGardenResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7B1FA2).withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦋✨🌸', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  'Beautiful Butterfly Garden!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('🦋 Butterflies Collected', '${result.butterfliesCaught}'),
                _Row('✨ Golden Butterflies', '${result.goldenCaught}'),
                _Row('🐝 Bees Visited', '${result.beesTapped}'),
                _Row('⭐ Points', '+${result.points}'),
                _Row('🪙 Coins', '+${result.coins}'),
                _Row('🌟 XP', '+${result.xp}'),
                _Row('💫 Happy Stars', '+${result.stars}'),
                _Row('🔥 Best Streak', '${result.longestStreak}'),
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
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.95),
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
