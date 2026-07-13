import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
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
      MemoryMiniGameType.classicCard => _ClassicCardView(state: state, controller: controller),
      MemoryMiniGameType.sequence => _SequenceView(state: state, controller: controller, isSound: false),
      MemoryMiniGameType.position => _PositionView(state: state, controller: controller),
      MemoryMiniGameType.pictureRecall => _PictureRecallView(state: state, controller: controller),
      MemoryMiniGameType.sound => _SequenceView(state: state, controller: controller, isSound: true),
      MemoryMiniGameType.flash => _FlashView(state: state, controller: controller),
      MemoryMiniGameType.number => _NumberView(state: state, controller: controller),
      MemoryMiniGameType.color => _SequenceView(state: state, controller: controller, isSound: false, isColor: true),
      MemoryMiniGameType.emojiMemory => _EmojiView(state: state, controller: controller),
      MemoryMiniGameType.objectTray => _ObjectTrayView(state: state, controller: controller),
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
    required this.isSound,
    this.isColor = false,
  });

  final MemorySessionState state;
  final MemorySessionController controller;
  final bool isSound;
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
            isSound ? MemoryContent.sounds.length : MemoryContent.sequenceColors.length,
            (i) {
              if (isSound) {
                final (emoji, label) = MemoryContent.sounds[i];
                return SequenceTile(
                  label: label,
                  color: AppColors.skyBlue,
                  emoji: emoji,
                  isActive: activeIndex == i,
                  onTap: isInput ? () => controller.tapSound(i) : () {},
                );
              }
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

class _PositionView extends StatelessWidget {
  const _PositionView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final gridSize = data['gridSize'] as int? ?? 3;
    final positions = (data['positions'] as List?)?.cast<int>() ?? [];
    final tapped = (data['tapped'] as List?)?.cast<int>() ?? [];
    final isShowing = state.phase == MemoryPhase.showing;

    return Column(
      children: [
        Text(
          isShowing ? 'Remember the spots!' : 'Tap where they were!',
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, i) {
              final hasObject = positions.contains(i);
              final wasTapped = tapped.contains(i);
              return GestureDetector(
                onTap: isShowing ? null : () => controller.tapGridCell(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isShowing && hasObject
                        ? AppColors.candyPink
                        : wasTapped
                            ? AppColors.mintGreen.withValues(alpha: 0.6)
                            : AppColors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Center(
                    child: isShowing && hasObject
                        ? const Text('⭐', style: TextStyle(fontSize: 24))
                        : wasTapped
                            ? const Icon(Icons.check_rounded)
                            : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PictureRecallView extends StatelessWidget {
  const _PictureRecallView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final scene = data['scene'] as Map<String, dynamic>? ?? {};
    final isShowing = state.phase == MemoryPhase.showing;

    if (isShowing) {
      return TTCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎈' * (scene['balloons'] as int? ?? 3),
                style: const TextStyle(fontSize: 28)),
            Text(scene['animal'] as String? ?? '🐶',
                style: const TextStyle(fontSize: 48)),
            Text('🚗 ${scene['carColor']}',
                style: context.textTheme.titleLarge),
            Text(
              '🌳 Tree on ${scene['treeSide']}',
              style: context.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    final options = (data['options'] as List?)?.cast<String>() ?? [];
    return Column(
      children: [
        Text(data['question'] as String? ?? '',
            style: context.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xl),
        ...options.map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TTButton(
              label: opt,
              expanded: true,
              onPressed: () => controller.answerQuestion(opt),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlashView extends StatelessWidget {
  const _FlashView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final isShowing = state.phase == MemoryPhase.showing;

    if (isShowing) {
      final shown = (data['shown'] as List?)?.cast<String>() ?? [];
      return Wrap(
        spacing: AppSpacing.md,
        alignment: WrapAlignment.center,
        children: shown
            .map((e) => Text(e, style: const TextStyle(fontSize: 48)))
            .toList(),
      );
    }

    final options = (data['options'] as List?)?.cast<String>() ?? [];
    return Column(
      children: [
        Text('Which one was missing?',
            style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          children: options
              .map(
                (e) => GestureDetector(
                  onTap: () => controller.selectFlashItem(e),
                  child: Text(e, style: const TextStyle(fontSize: 48)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NumberView extends StatefulWidget {
  const _NumberView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  State<_NumberView> createState() => _NumberViewState();
}

class _NumberViewState extends State<_NumberView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShowing = widget.state.phase == MemoryPhase.showing;
    final number = widget.state.gameData['number'] as String? ?? '';

    if (isShowing) {
      return Center(
        child: Text(number, style: context.textTheme.displayLarge),
      );
    }

    return Column(
      children: [
        Text('What was the number?', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TTButton(
          label: 'Submit',
          expanded: true,
          onPressed: () => widget.controller.submitNumber(_controller.text.trim()),
        ),
      ],
    );
  }
}

class _EmojiView extends StatelessWidget {
  const _EmojiView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final mode = data['mode'] as String? ?? 'missing';
    final isShowing = state.phase == MemoryPhase.showing;

    if (mode == 'missing') {
      if (isShowing) {
        final shown = (data['shown'] as List?)?.cast<String>() ?? [];
        return Wrap(
          spacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: shown
              .map((e) => Text(e, style: const TextStyle(fontSize: 40)))
              .toList(),
        );
      }
      final shown = (data['shown'] as List?)?.cast<String>() ?? [];
      final options = {...shown, data['missing']}.toList()..shuffle();
      return Column(
        children: [
          Text('Which emoji was missing?',
              style: context.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            children: options
                .map(
                  (e) => GestureDetector(
                    onTap: () => controller.selectEmoji(e),
                    child: Text(e, style: const TextStyle(fontSize: 40)),
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    // Order mode - emoji sequence
    final emojis = (data['emojis'] as List?)?.cast<String>() ?? [];
    final activeIndex = data['activeIndex'] as int?;
    final isInput = state.phase == MemoryPhase.input;

    return Column(
      children: [
        Text(
          isInput ? 'Repeat the emoji order!' : 'Watch the emojis...',
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          children: List.generate(emojis.length, (i) {
            return SequenceTile(
              label: emojis[i],
              color: AppColors.candyPink,
              emoji: emojis[i],
              isActive: activeIndex == i,
              onTap: isInput ? () => controller.tapSequenceColor(i) : () {},
            );
          }),
        ),
      ],
    );
  }
}

class _ObjectTrayView extends StatelessWidget {
  const _ObjectTrayView({required this.state, required this.controller});
  final MemorySessionState state;
  final MemorySessionController controller;

  @override
  Widget build(BuildContext context) {
    final data = state.gameData;
    final isShowing = state.phase == MemoryPhase.showing;
    final shown = (data['shown'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final options = (data['options'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final selected = (data['selected'] as List?)?.cast<String>() ?? [];

    if (isShowing) {
      return Wrap(
        spacing: AppSpacing.md,
        alignment: WrapAlignment.center,
        children: shown
            .map(
              (o) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(o['emoji'] as String, style: const TextStyle(fontSize: 40)),
                  Text(o['label'] as String? ?? ''),
                ],
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        Text('Select objects you remember!',
            style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options.map((o) {
              final emoji = o['emoji'] as String;
              final isSelected = selected.contains(emoji);
              return FilterChip(
                label: Text('${o['emoji']} ${o['label']}'),
                selected: isSelected,
                onSelected: (_) => controller.toggleObject(emoji),
              );
            }).toList(),
          ),
        ),
        TTButton(
          label: 'Submit',
          expanded: true,
          onPressed: () => controller.submitObjectTray(),
        ),
      ],
    );
  }
}
