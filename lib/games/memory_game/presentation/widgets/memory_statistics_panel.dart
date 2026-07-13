import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

class MemoryStatisticsPanel extends StatelessWidget {
  const MemoryStatisticsPanel({super.key, required this.stats});

  final MemoryHubStatistics stats;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView(
            controller: scrollController,
            children: [
              Text('Memory Statistics', style: context.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.lg),
              TTCard(
                child: Column(
                  children: [
                    _StatRow('Games Played', '${stats.gamesPlayed}'),
                    _StatRow('Perfect Games', '${stats.perfectGames}'),
                    _StatRow('Highest Combo', '${stats.highestCombo}'),
                    _StatRow('Total Stars', '${stats.totalStars}'),
                    _StatRow('Daily Streak', '${stats.dailyStreak}'),
                    if (stats.favoriteGame != null)
                      _StatRow(
                        'Favorite Game',
                        stats.favoriteGame!.displayName,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Per Game', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...MemoryMiniGameType.values.map((type) {
                final s = stats.statsFor(type);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TTCard(
                    child: Row(
                      children: [
                        Text(type.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(type.displayName,
                                  style: context.textTheme.titleSmall),
                              Text(
                                'Best: ${s.bestScore} · Played: ${s.timesPlayed} · '
                                'Accuracy: ${(s.averageAccuracy * 100).round()}%',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyLarge),
          Text(value, style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}
