import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';

class AlphabetQuizHud extends StatelessWidget {
  const AlphabetQuizHud({
    super.key,
    required this.remainingSeconds,
    required this.score,
    required this.coinsEarned,
    required this.starsEarned,
    required this.onPause,
  });

  final int remainingSeconds;
  final int score;
  final int coinsEarned;
  final int starsEarned;
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
          _Pill(icon: Icons.star_rounded, label: '$score'),
          const SizedBox(width: AppSpacing.sm),
          _Pill(icon: Icons.monetization_on_rounded, label: '+$coinsEarned', gold: true),
          const SizedBox(width: AppSpacing.sm),
          _Pill(icon: Icons.auto_awesome, label: '+$starsEarned'),
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
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.orange, size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
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

class AlphabetQuizVictoryOverlay extends StatelessWidget {
  const AlphabetQuizVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final AlphabetQuizResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return Container(
      color: const Color(0xFFE65100).withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔤🎉📚', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  'Alphabet Adventure Complete!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('⭐ Score', '${result.score}'),
                _Row('✅ Correct', '${result.correctAnswers}'),
                _Row('🔤 Letters', '${result.lettersCompleted}'),
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
          Text(label, style: context.textTheme.titleMedium?.copyWith(color: AppColors.white)),
          Text(value, style: context.textTheme.titleLarge?.copyWith(color: AppColors.sunYellow)),
        ],
      ),
    );
  }
}
