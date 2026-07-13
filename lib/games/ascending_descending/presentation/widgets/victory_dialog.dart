import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

class VictoryDialog extends StatelessWidget {
  const VictoryDialog({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
    this.onNextDifficulty,
  });

  final BubbleGameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback? onNextDifficulty;

  static Future<void> show(
    BuildContext context, {
    required BubbleGameResult result,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
    VoidCallback? onNextDifficulty,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        result: result,
        onPlayAgain: onPlayAgain,
        onHome: onHome,
        onNextDifficulty: onNextDifficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const IgnorePointer(child: ConfettiWidget()),
          TTCard(
            gradient: AppGradients.welcomeCard,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(size: 80, waving: true),
                Text(
                  result.isPerfect ? 'Perfect!' : 'Great Job!',
                  style: context.textTheme.displaySmall,
                ),
                if (result.isNewBest)
                  Text(
                    '🏆 New Best Score!',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.orange,
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _ResultRow('Score', '${result.score}'),
                _ResultRow('Stars', '⭐' * result.stars),
                _ResultRow('Coins', '+${result.coins}'),
                _ResultRow('XP', '+${result.xp}'),
                _ResultRow(
                  'Accuracy',
                  '${(result.accuracy * 100).round()}%',
                ),
                _ResultRow('Mistakes', '${result.mistakes}'),
                _ResultRow('Time', '${result.elapsedSeconds}s'),
                _ResultRow('Best Combo', '${result.longestCombo}'),
                const SizedBox(height: AppSpacing.xl),
                TTButton(
                  label: 'Play Again',
                  expanded: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onPlayAgain();
                  },
                ),
                if (onNextDifficulty != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TTButton(
                    label: 'Next Difficulty',
                    variant: TTButtonVariant.secondary,
                    expanded: true,
                    onPressed: () {
                      Navigator.pop(context);
                      onNextDifficulty!();
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TTButton(
                  label: 'Home',
                  variant: TTButtonVariant.ghost,
                  expanded: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onHome();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(value, style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class BubbleGameSetupSheet extends StatelessWidget {
  const BubbleGameSetupSheet({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  final BubbleGameConfig config;
  final ValueChanged<BubbleGameConfig> onConfigChanged;

  static Future<void> show(
    BuildContext context, {
    required BubbleGameConfig config,
    required ValueChanged<BubbleGameConfig> onConfigChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => BubbleGameSetupSheet(
        config: config,
        onConfigChanged: onConfigChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game Settings', style: context.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            _RangeSlider(
              label: 'Min Value',
              value: config.minValue.toDouble(),
              min: -99999,
              max: 99999,
              onChanged: (v) => onConfigChanged(
                config.copyWith(minValue: v.round()),
              ),
            ),
            _RangeSlider(
              label: 'Max Value',
              value: config.maxValue.toDouble(),
              min: -99999,
              max: 99999,
              onChanged: (v) => onConfigChanged(
                config.copyWith(maxValue: v.round()),
              ),
            ),
            _RangeSlider(
              label: 'Bubble Speed',
              value: config.bubbleSpeed,
              min: 0.3,
              max: 2.5,
              onChanged: (v) => onConfigChanged(
                config.copyWith(bubbleSpeed: v),
              ),
            ),
            SwitchListTile(
              title: const Text('Hints'),
              value: config.hintsEnabled,
              onChanged: (v) => onConfigChanged(config.copyWith(hintsEnabled: v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSlider extends StatelessWidget {
  const _RangeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}', style: context.textTheme.titleSmall),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
