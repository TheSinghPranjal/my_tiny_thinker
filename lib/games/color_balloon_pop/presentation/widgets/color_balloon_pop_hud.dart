import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';

class ColorBalloonPopHud extends StatelessWidget {
  const ColorBalloonPopHud({
    super.key,
    required this.remainingSeconds,
    required this.roundsCompleted,
    required this.coinsEarned,
    required this.onPause,
  });

  final int remainingSeconds;
  final int roundsCompleted;
  final int coinsEarned;
  final VoidCallback onPause;

  String get _timer {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
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
            highlight: remainingSeconds <= 10,
          ),
          const Spacer(),
          _Pill(icon: Icons.palette_rounded, label: '$roundsCompleted'),
          const SizedBox(width: AppSpacing.xs),
          _Pill(
            icon: Icons.monetization_on_rounded,
            label: '+$coinsEarned',
            gold: true,
          ),
          const SizedBox(width: AppSpacing.xs),
          Material(
            color: AppColors.white.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPause,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.pause_rounded,
                  size: 28,
                  color: AppColors.skyBlueDark,
                ),
              ),
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
    this.highlight = false,
    this.gold = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final bool gold;

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
        boxShadow: [
          BoxShadow(
            color: AppColors.skyBlue.withValues(alpha: 0.22),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight
                ? AppColors.error
                : gold
                    ? AppColors.orange
                    : AppColors.skyBlueDark,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight
                  ? AppColors.error
                  : gold
                      ? AppColors.orange
                      : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorBalloonVictoryOverlay extends StatelessWidget {
  const ColorBalloonVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ColorBalloonPopResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6A1B9A).withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(size: 100, waving: true),
                Text(
                  'Color Balloon Celebration!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('🎈 Balloons Popped', '${result.balloonsPopped}'),
                _Row('🎯 Rounds Completed', '${result.roundsCompleted}'),
                _Row('🎨 Colors Mastered', '${result.colorsMastered}'),
                _Row('🔥 Longest Streak', '${result.maxStreak}'),
                _Row('⭐ Points', '+${result.points}'),
                _Row('🪙 Coins', '+${result.coins}'),
                _Row('✨ XP', '+${result.xp}'),
                _Row('🌟 Happy Stars', '+${result.stars}'),
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
            style: context.textTheme.titleMedium?.copyWith(color: AppColors.white),
          ),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(color: AppColors.sunYellow),
          ),
        ],
      ),
    );
  }
}
