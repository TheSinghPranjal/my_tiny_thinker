import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Snapping Game Duration control used across Parent Zone.
class GameDurationSlider extends StatelessWidget {
  const GameDurationSlider({
    super.key,
    required this.sessionSeconds,
    required this.onChanged,
    this.enabled = true,
  });

  final int sessionSeconds;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final index = GameDuration.indexOf(sessionSeconds).toDouble();
    final label = GameDuration.label(sessionSeconds);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Game Duration',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Container(
                  key: ValueKey(label),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.skyBlue.withValues(alpha: 0.9),
                        AppColors.softPurple.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.skyBlue,
              inactiveTrackColor: AppColors.skyBlue.withValues(alpha: 0.2),
              thumbColor: AppColors.orange,
              overlayColor: AppColors.orange.withValues(alpha: 0.15),
              trackHeight: 8,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
              activeTickMarkColor: AppColors.white,
              inactiveTickMarkColor: AppColors.skyBlue.withValues(alpha: 0.35),
            ),
            child: Slider(
              value: index,
              min: 0,
              max: (GameDuration.presetSeconds.length - 1).toDouble(),
              divisions: GameDuration.presetSeconds.length - 1,
              label: label,
              onChanged: enabled
                  ? (v) => onChanged(GameDuration.presetSeconds[v.round()])
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final m in GameDuration.presetMinutes)
                Text(
                  '${m}m',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
