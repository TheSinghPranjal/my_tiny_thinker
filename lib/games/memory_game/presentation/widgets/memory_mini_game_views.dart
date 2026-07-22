import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/game_hud_widgets.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/games/memory_game/presentation/widgets/memory_game_widgets.dart';

class MemoryMiniGameView extends StatelessWidget {
  const MemoryMiniGameView({
    super.key,
    required this.state,
    required this.controller,
  });

  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    if (state.phase == MemoryPhase.countdown) {
      return CountdownOverlay(count: state.countdown);
    }

    return switch (state.config!.gameType) {
      MemoryMiniGameType.classicCard =>
        _ClassicCardView(state: state, controller: controller),
      MemoryMiniGameType.sequence => _SequenceView(
          state: state,
          controller: controller,
        ),
      MemoryMiniGameType.color => _SequenceView(
          state: state,
          controller: controller,
          isColor: true,
        ),
    };
  }
}

class _ClassicCardView extends StatelessWidget {
  const _ClassicCardView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final cols = data['cols'] as int? ?? 2;
    final cards = (data['cards'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final card = cards[i];
        return MemoryCardWidget(
          emoji: card['value'] as String,
          isFlipped: card['flipped'] as bool? ?? false,
          isMatched: card['matched'] as bool? ?? false,
          onTap: () => controller.flipCard(card['id'] as int),
        );
      },
    );
  }
}

class _SequenceView extends StatelessWidget {
  const _SequenceView({
    required this.state,
    required this.controller,
    this.isColor = false,
  });

  final MemorySessionState state;
  final MemorySessionController controller;
  final bool isColor;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final activeIndex = data['activeIndex'] as int?;
    final isInput = state.phase == MemoryPhase.input;

    return Column(
      children: [
        Text(
          isInput ? 'Repeat the sequence!' : 'Watch carefully...',
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: List.generate(
            MemoryContent.sequenceColors.length,
            (i) {
              final (label, colorVal) = MemoryContent.sequenceColors[i];
              return SequenceTile(
                label: label,
                color: Color(colorVal),
                isActive: activeIndex == i,
                onTap: isInput
                    ? () => isColor
                        ? controller.tapColor(i)
                        : controller.tapSequenceColor(i)
                    : () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
