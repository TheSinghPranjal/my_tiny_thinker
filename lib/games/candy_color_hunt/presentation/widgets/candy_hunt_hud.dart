import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

class CandyHuntHud extends StatelessWidget {
  const CandyHuntHud({
    super.key,
    required this.remainingSeconds,
    required this.score,
    required this.coinsEarned,
    required this.starsEarned,
    required this.onPause,
    this.largerFonts = false,
  });

  final int remainingSeconds;
  final int score;
  final int coinsEarned;
  final int starsEarned;
  final VoidCallback onPause;
  final bool largerFonts;

  String get _timer {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pulse = remainingSeconds <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          AnimatedScale(
            scale: pulse ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: _Pill(
              icon: Icons.timer_rounded,
              label: _timer,
              highlight: pulse,
              large: largerFonts,
            ),
          ),
          const Spacer(),
          _Pill(
            icon: Icons.star_rounded,
            label: 'Score: $score',
            large: largerFonts,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Pill(
            icon: Icons.monetization_on_rounded,
            label: '+$coinsEarned',
            gold: true,
            large: largerFonts,
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.white.withValues(alpha: 0.96),
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: const Color(0xFFFF8A65).withValues(alpha: 0.35),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPause,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.pause_rounded,
                  size: 26,
                  color: Color(0xFF5D4037),
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
    this.large = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final bool gold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: highlight
                ? AppColors.error
                : gold
                    ? AppColors.orange
                    : const Color(0xFFFF7043),
            size: large ? 22 : 18,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: large ? 16 : 14,
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

class CandyHuntVictoryOverlay extends StatelessWidget {
  const CandyHuntVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final CandyHuntResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return Container(
      color: const Color(0xFFFF7043).withValues(alpha: 0.92),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐜🍬🎉', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  'Candy Color Celebration!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('⭐ Score', '${result.score}'),
                _Row('🍬 Candies Found', '${result.correctTaps}'),
                _Row('🎯 Accuracy', '$accuracyPct%'),
                _Row('🔥 Best Streak', '${result.maxStreak}'),
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
