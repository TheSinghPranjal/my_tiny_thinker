import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

class MemoryVictoryDialog extends StatelessWidget {
  const MemoryVictoryDialog({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final MemoryGameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  static Future<void> show(
    BuildContext context, {
    required MemoryGameResult result,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MemoryVictoryDialog(
        result: result,
        onPlayAgain: onPlayAgain,
        onHome: onHome,
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
                const MascotWidget(size: 80),
                Text(
                  result.isPerfect ? 'Perfect Memory!' : 'Great Job!',
                  style: context.textTheme.headlineMedium,
                ),
                Text('${result.gameType.emoji} ${result.gameType.displayName}'),
                if (result.isNewBest)
                  Text('🏆 New Best!', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                _Row('Score', '${result.score}'),
                _Row('Stars', '⭐' * result.stars),
                _Row('Coins', '+${result.coins}'),
                _Row('XP', '+${result.xp}'),
                _Row('Accuracy', '${(result.accuracy * 100).round()}%'),
                _Row('Combo', '${result.longestCombo}'),
                const SizedBox(height: AppSpacing.xl),
                TTButton(label: 'Play Again', expanded: true, onPressed: () {
                  Navigator.pop(context);
                  onPlayAgain();
                }),
                const SizedBox(height: AppSpacing.sm),
                TTButton(
                  label: 'Back to Hub',
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

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
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

class MemorySetupSheet extends StatelessWidget {
  const MemorySetupSheet({
    super.key,
    required this.gameType,
    required this.config,
    required this.onStart,
    required this.onConfigChanged,
  });

  final MemoryMiniGameType gameType;
  final MemoryGameConfig config;
  final VoidCallback onStart;
  final ValueChanged<MemoryGameConfig> onConfigChanged;

  static Future<void> show(
    BuildContext context, {
    required MemoryMiniGameType gameType,
    required MemoryGameConfig config,
    required VoidCallback onStart,
    required ValueChanged<MemoryGameConfig> onConfigChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => MemorySetupSheet(
        gameType: gameType,
        config: config,
        onStart: onStart,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${gameType.emoji} ${gameType.displayName}',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Difficulty', style: context.textTheme.titleMedium),
          Wrap(
            spacing: AppSpacing.sm,
            children: MemoryDifficulty.values.map((d) {
              return ChoiceChip(
                label: Text(MemoryDifficultyConfig.label(d)),
                selected: config.difficulty == d,
                onSelected: (_) => onConfigChanged(config.copyWith(difficulty: d)),
              );
            }).toList(),
          ),
          if (gameType == MemoryMiniGameType.classicCard) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Card Theme', style: context.textTheme.titleMedium),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: MemoryCardTheme.values.map((t) {
                return ChoiceChip(
                  label: Text('${t.emoji} ${t.displayName}'),
                  selected: config.cardTheme == t,
                  onSelected: (_) => onConfigChanged(config.copyWith(cardTheme: t)),
                );
              }).toList(),
            ),
          ],
          SwitchListTile(
            title: const Text('Adaptive Learning'),
            subtitle: const Text('Difficulty adjusts to your skill'),
            value: config.adaptiveEnabled,
            onChanged: (v) => onConfigChanged(config.copyWith(adaptiveEnabled: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          TTButton(label: 'Start!', expanded: true, onPressed: onStart),
        ],
      ),
    );
  }
}
