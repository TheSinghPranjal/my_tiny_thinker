import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class GameSelectionGrid extends ConsumerWidget {
  const GameSelectionGrid({
    super.key,
    required this.onGameTap,
    this.enabledGameIds,
    this.largeLayout = false,
  });

  final void Function(GameId gameId) onGameTap;
  final List<String>? enabledGameIds;
  final bool largeLayout;

  static const _allGames = [
    GameId.bubbleNumberPop,
    GameId.memoryGame,
    GameId.oddOneOut,
    GameId.patternMatch,
    GameId.colorMemory,
  ];

  static const _meta = {
    GameId.bubbleNumberPop: ('🔵', 'Bubble Number Pop', 'Easy'),
    GameId.memoryGame: ('🧠', 'Memory Game', 'Medium'),
    GameId.oddOneOut: ('👀', 'Odd One Out', 'Easy'),
    GameId.patternMatch: ('🧩', 'Pattern Match', 'Medium'),
    GameId.colorMemory: ('🌈', 'Color Memory', 'Easy'),
  };

  List<GameId> get _visibleGames {
    if (enabledGameIds == null) return _allGames;
    return _allGames
        .where((g) => enabledGameIds!.contains(g.id))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStats = ref.watch(allGameStatsProvider);
    final games = _visibleGames;
    final showComingSoon = !largeLayout && games.length < _allGames.length;

    return ResponsiveGrid(
      itemCount: games.length + (showComingSoon ? 1 : 0),
      phoneColumns: largeLayout ? 1 : 2,
      tabletColumns: largeLayout ? 2 : 3,
      childAspectRatio: largeLayout ? 2.2 : 0.82,
      itemBuilder: (context, index) {
        if (showComingSoon && index == games.length) {
          return const TTGameCard(
            emoji: '✨',
            title: 'More Coming Soon!',
            color: AppColors.softPurple,
            comingSoon: true,
          );
        }
        final gameId = games[index];
        final (emoji, title, difficulty) = _meta[gameId]!;
        final stats = allStats[gameId] ?? GameStats(gameId: gameId);

        return TTGameCard(
          emoji: emoji,
          title: title,
          color: AppColors.gameCardColors[index % AppColors.gameCardColors.length],
          difficulty: largeLayout ? null : difficulty,
          starsEarned: largeLayout ? 0 : stats.starsEarned,
          bestScore: largeLayout ? 0 : stats.bestScore,
          onPlay: () => onGameTap(gameId),
        );
      },
    );
  }
}
