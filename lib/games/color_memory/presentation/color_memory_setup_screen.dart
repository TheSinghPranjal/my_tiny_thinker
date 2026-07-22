import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/color_memory/controllers/color_memory_controller.dart';
import 'package:my_tiny_thinker/games/color_memory/models/color_memory_models.dart';

class ColorMemorySetupScreen extends ConsumerWidget {
  const ColorMemorySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var config = ref.watch(colorMemoryConfigProvider);
    final hints = ref.watch(settingsProvider).hintsEnabled;

    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('🌈 Color Memory'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTCard(
                child: Text(
                  'Watch the colors glow, then repeat the sequence!',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Difficulty', style: context.textTheme.titleMedium),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ColorMemoryDifficulty.values.map((d) {
                  return ChoiceChip(
                    label: Text(d.name.capitalize),
                    selected: config.difficulty == d,
                    onSelected: (_) {
                      config = config.copyWith(difficulty: d);
                      ref.read(colorMemoryConfigProvider.notifier).state =
                          config;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Color Theme', style: context.textTheme.titleMedium),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ColorMemoryTheme.values.map((t) {
                  return ChoiceChip(
                    label: Text('${t.tiles.first} ${t.label}'),
                    selected: config.theme == t,
                    onSelected: (_) {
                      config = config.copyWith(theme: t);
                      ref.read(colorMemoryConfigProvider.notifier).state =
                          config;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              TTButton(
                label: 'Start Game!',
                expanded: true,
                size: TTButtonSize.large,
                onPressed: () async {
                  if (!await ensureCanStartGame(
                    context,
                    ref,
                    GameId.colorMemory,
                  )) {
                    return;
                  }
                  if (!context.mounted) return;
                  ref.read(colorMemoryConfigProvider.notifier).state =
                      config.copyWith(hintsEnabled: hints);
                  context.push(AppRoutes.colorMemoryGame);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
