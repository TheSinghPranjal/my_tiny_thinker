import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

class VictoryDialog extends StatelessWidget {
  const VictoryDialog({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
    this.title = 'Bubble Number Pop Celebration!',
  });

  final BubbleGameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required BubbleGameResult result,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
    String title = 'Bubble Number Pop Celebration!',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        result: result,
        onPlayAgain: onPlayAgain,
        onHome: onHome,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: SingleChildScrollView(
        child: GameCelebrationCard(
          title: title,
          stats: [
            CelebrationStat(
              icon: '🏆',
              label: 'Score',
              value: '${result.score}',
            ),
            CelebrationStat(
              icon: '🌟',
              label: 'Happy Stars',
              value: '+${result.stars}',
            ),
            CelebrationStat(
              icon: '🪙',
              label: 'Coins',
              value: '+${result.coins}',
            ),
            CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
            CelebrationStat(
              icon: '🎯',
              label: 'Accuracy',
              value: '${(result.accuracy * 100).round()}%',
            ),
            CelebrationStat(
              icon: '⏱',
              label: 'Time Left',
              value: _formatTime(result.remainingSeconds),
            ),
            CelebrationStat(
              icon: '🔥',
              label: 'Best Combo',
              value: '${result.longestCombo}',
            ),
            CelebrationStat(
              icon: '❌',
              label: 'Mistakes',
              value: '${result.mistakes}',
            ),
          ],
          onPlayAgain: () {
            Navigator.pop(context);
            onPlayAgain();
          },
          onHome: () {
            Navigator.pop(context);
            onHome();
          },
        ),
      ),
    );
  }
}

String _formatTime(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
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
              onChanged: (v) =>
                  onConfigChanged(config.copyWith(minValue: v.round())),
            ),
            _RangeSlider(
              label: 'Max Value',
              value: config.maxValue.toDouble(),
              min: -99999,
              max: 99999,
              onChanged: (v) =>
                  onConfigChanged(config.copyWith(maxValue: v.round())),
            ),
            _RangeSlider(
              label: 'Bubble Speed',
              value: config.bubbleSpeed,
              min: 0.3,
              max: 2.5,
              onChanged: (v) =>
                  onConfigChanged(config.copyWith(bubbleSpeed: v)),
            ),
            SwitchListTile(
              title: const Text('Hints'),
              value: config.hintsEnabled,
              onChanged: (v) =>
                  onConfigChanged(config.copyWith(hintsEnabled: v)),
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
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
