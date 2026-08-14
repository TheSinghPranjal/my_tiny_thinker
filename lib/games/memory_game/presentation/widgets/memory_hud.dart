import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: SingleChildScrollView(
        child: GameCelebrationCard(
          title: '${result.gameType.displayName} Celebration!',
          stats: [
            CelebrationStat(
              icon: '⭐',
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
              icon: '🔥',
              label: 'Combo',
              value: '${result.longestCombo}',
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
          homeLabel: 'Back to Hub',
        ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
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
                  onSelected: (_) =>
                      onConfigChanged(config.copyWith(cardTheme: t)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Timer and difficulty are set in Parent Zone.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TTButton(label: 'Start!', expanded: true, onPressed: onStart),
        ],
      ),
    );
  }
}
