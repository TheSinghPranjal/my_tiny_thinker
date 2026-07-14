import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';

class PeekABooHud extends StatelessWidget {
  const PeekABooHud({
    super.key,
    required this.remainingSeconds,
    required this.discoveriesCount,
    required this.coinsEarned,
    required this.onPause,
    this.largerFonts = false,
  });

  final int remainingSeconds;
  final int discoveriesCount;
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
            icon: Icons.pets_rounded,
            label: '$discoveriesCount',
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
          Icon(icon, color: AppColors.grassGreen, size: 22),
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

class PeekABooVictoryOverlay extends StatelessWidget {
  const PeekABooVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final PeekABooResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1565C0).withValues(alpha: 0.82),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎆🐾🦋', style: TextStyle(fontSize: 56)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  'Amazing Peek-a-Boo Adventure!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Row('🐾 Animals Found', '${result.discoveriesCount}'),
                _Row('🌿 Bushes Explored', '${result.bushesExplored}'),
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

class AnnouncementBubble extends StatelessWidget {
  const AnnouncementBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.grassGreen,
        ),
      ),
    );
  }
}
