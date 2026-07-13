import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

class MemoryHud extends StatelessWidget {
  const MemoryHud({
    super.key,
    required this.score,
    required this.round,
    required this.totalRounds,
    required this.combo,
    this.feedback,
    this.isCorrect,
  });

  final int score;
  final int round;
  final int totalRounds;
  final int combo;
  final String? feedback;
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Chip(icon: Icons.star_rounded, label: '$score', color: AppColors.sunYellow),
            const SizedBox(width: AppSpacing.sm),
            _Chip(icon: Icons.flag_rounded, label: '$round/$totalRounds', color: AppColors.skyBlue),
            if (combo >= 2) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: AppGradients.rainbow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Text(
                  '${MemoryScoring.comboLabel(combo)} ($combo×)',
                  style: context.textTheme.labelSmall?.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ],
        ),
        if (feedback != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            feedback!,
            style: context.textTheme.titleMedium?.copyWith(
              color: isCorrect == true ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}

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
