import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/logic/classic_card_memory_logic.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/presentation/widgets/classic_memory_card.dart';

class ClassicMemoryBoard extends StatelessWidget {
  const ClassicMemoryBoard({
    super.key,
    required this.cards,
    required this.pairCount,
    required this.onFlip,
  });

  final List<MemoryCard> cards;
  final int pairCount;
  final void Function(int index) onFlip;

  @override
  Widget build(BuildContext context) {
    final grid = ClassicCardMemoryLogic.gridForPairs(pairCount);
    final cols = grid.$1;
    final rows = grid.$2;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final cellW = (constraints.maxWidth - gap * (cols - 1)) / cols;
        final cellH = (constraints.maxHeight - gap * (rows - 1)) / rows;
        final side = (cellW < cellH ? cellW : cellH).clamp(48.0, double.infinity);

        return Center(
          child: SizedBox(
            width: cols * side + gap * (cols - 1),
            height: rows * side + gap * (rows - 1),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) {
                return ClassicMemoryFlipCard(
                  face: cards[i].face,
                  isFlipped: cards[i].isFlipped,
                  isMatched: cards[i].isMatched,
                  isWrong: cards[i].isWrong,
                  onTap: () => onFlip(i),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ClassicMemoryVictoryOverlay extends StatelessWidget {
  const ClassicMemoryVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ClassicCardMemoryResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: TTCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: context.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Time's Up!",
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.softPurple,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _row('Score', '${result.score}'),
              _row('Matches', '${result.matches}'),
              _row('Rounds', '${result.roundsCompleted}'),
              _row('Coins', '+${result.coins}'),
              _row('XP', '+${result.xp}'),
              const SizedBox(height: AppSpacing.xl),
              TTButton(
                label: 'Play Again',
                expanded: true,
                onPressed: onPlayAgain,
              ),
              const SizedBox(height: AppSpacing.sm),
              TTButton(
                label: 'Home',
                expanded: true,
                variant: TTButtonVariant.ghost,
                onPressed: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
