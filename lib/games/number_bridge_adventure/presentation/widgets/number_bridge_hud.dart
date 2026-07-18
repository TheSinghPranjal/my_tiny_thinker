import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

class NumberBridgeHud extends StatelessWidget {
  const NumberBridgeHud({
    super.key,
    required this.remainingSeconds,
    required this.unlimitedTime,
    required this.starsEarned,
    required this.score,
    required this.round,
    required this.onPause,
    this.largerFonts = false,
  });

  final int remainingSeconds;
  final bool unlimitedTime;
  final int starsEarned;
  final int score;
  final int round;
  final VoidCallback onPause;
  final bool largerFonts;

  String get _timer {
    if (unlimitedTime) return '∞';
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pulse = !unlimitedTime && remainingSeconds <= 10;
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
          const SizedBox(width: AppSpacing.sm),
          _Pill(
            icon: Icons.flag_rounded,
            label: 'R$round',
            large: largerFonts,
          ),
          const Spacer(),
          _Pill(
            icon: Icons.star_rounded,
            label: '$starsEarned',
            gold: true,
            large: largerFonts,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Pill(
            icon: Icons.emoji_events_rounded,
            label: '$score',
            large: largerFonts,
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.pause_rounded, size: 30),
            onPressed: onPause,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white.withValues(alpha: 0.95),
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
        color: highlight
            ? const Color(0xFFFFCC80)
            : AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withValues(alpha: 0.18),
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
            size: large ? 22 : 18,
            color: gold ? AppColors.sunYellow : const Color(0xFF0277BD),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: large ? 16 : 14,
              color: const Color(0xFF01579B),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberBridgeVictoryOverlay extends StatelessWidget {
  const NumberBridgeVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final NumberBridgeResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return Container(
      color: const Color(0xFF0288D1).withValues(alpha: 0.92),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔢🌉🎉', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  'Number Bridge Celebration!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('⭐ Score', '${result.score}'),
                _Row('🔢 Numbers Matched', '${result.correctMatches}'),
                _Row('🏁 Rounds', '${result.roundsCompleted}'),
                _Row('🔥 Best Streak', '${result.maxStreak}'),
                _Row('🎯 Accuracy', '$accuracyPct%'),
                _Row('🪙 Coins', '${result.coins}'),
                _Row('✨ XP', '${result.xp}'),
                _Row('🌟 Stars', '${result.stars}'),
                const SizedBox(height: AppSpacing.xl),
                TTButton(
                  label: 'Play Again',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: onPlayAgain,
                ),
                const SizedBox(height: AppSpacing.md),
                TTButton(
                  label: 'Home',
                  expanded: true,
                  variant: TTButtonVariant.secondary,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
