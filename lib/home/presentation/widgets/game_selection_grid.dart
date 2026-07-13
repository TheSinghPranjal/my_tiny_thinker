import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class GameSelectionGrid extends StatelessWidget {
  const GameSelectionGrid({
    super.key,
    required this.onGameTap,
  });

  final void Function(GameId gameId) onGameTap;

  static const _games = [
    (GameId.bubbleNumberPop, '🔵', 'Bubble Number Pop', 'Easy', true),
    (GameId.memoryGame, '🧠', 'Memory Game', 'Medium', false),
    (GameId.oddOneOut, '👀', 'Odd One Out', 'Easy', false),
    (GameId.patternMatch, '🧩', 'Pattern Match', 'Medium', false),
    (GameId.colorMemory, '🌈', 'Color Memory', 'Easy', false),
    (null, '✨', 'More Coming Soon!', null, false),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      itemCount: _games.length,
      phoneColumns: 2,
      tabletColumns: 3,
      childAspectRatio: 0.82,
      itemBuilder: (context, index) {
        final game = _games[index];
        if (game.$1 == null) {
          return TTGameCard(
            emoji: game.$2,
            title: game.$3,
            color: AppColors.softPurple,
            comingSoon: true,
          );
        }
        return TTGameCard(
          emoji: game.$2,
          title: game.$3,
          color: AppColors.gameCardColors[index % AppColors.gameCardColors.length],
          difficulty: game.$4,
          starsEarned: game.$5 ? 2 : 0,
          bestScore: game.$5 ? 150 : 0,
          onPlay: () => onGameTap(game.$1!),
        );
      },
    );
  }
}
