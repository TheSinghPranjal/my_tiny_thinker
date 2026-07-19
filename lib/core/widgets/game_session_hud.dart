import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Shared in-game top bar used by every timed TinyThink game.
///
/// Layout: timer on the left; coins, stars (rewards), and pause on the right.
class GameSessionHud extends StatelessWidget {
  const GameSessionHud({
    super.key,
    required this.remainingSeconds,
    required this.coinsEarned,
    required this.starsEarned,
    required this.onPause,
    this.unlimitedTime = false,
    this.largerFonts = false,
    this.accentColor = const Color(0xFF5E35B1),
    this.highlightColor = AppColors.error,
  });

  final int remainingSeconds;
  final bool unlimitedTime;
  final int coinsEarned;
  final int starsEarned;
  final VoidCallback onPause;
  final bool largerFonts;
  final Color accentColor;
  final Color highlightColor;

  String get _timer {
    if (unlimitedTime) return '∞';
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _timerUrgent => !unlimitedTime && remainingSeconds <= 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _HudPill(
              icon: Icons.timer_rounded,
              label: _timer,
              accentColor: accentColor,
              highlight: _timerUrgent,
              highlightColor: highlightColor,
              large: largerFonts,
            ),
            const Spacer(),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              children: [
                _HudPill(
                  icon: Icons.monetization_on_rounded,
                  label: '+$coinsEarned',
                  accentColor: accentColor,
                  gold: true,
                  large: largerFonts,
                ),
                _HudPill(
                  icon: Icons.auto_awesome,
                  label: '+$starsEarned',
                  accentColor: accentColor,
                  large: largerFonts,
                ),
                _PauseButton(
                  onPause: onPause,
                  accentColor: accentColor,
                  large: largerFonts,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.onPause,
    required this.accentColor,
    required this.large,
  });

  final VoidCallback onPause;
  final Color accentColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: accentColor.withValues(alpha: 0.25),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPause,
        child: Padding(
          padding: EdgeInsets.all(large ? 8 : 7),
          child: Icon(
            Icons.pause_rounded,
            size: large ? 24 : 22,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.highlight = false,
    this.highlightColor = AppColors.error,
    this.gold = false,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final bool highlight;
  final Color highlightColor;
  final bool gold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final iconColor = highlight
        ? highlightColor
        : gold
            ? AppColors.orange
            : accentColor;
    final textColor = highlight ? highlightColor : const Color(0xFF37474F);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 8,
        vertical: large ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFFFCC80)
            : AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: large ? 20 : 18),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: large ? 15 : 13,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
