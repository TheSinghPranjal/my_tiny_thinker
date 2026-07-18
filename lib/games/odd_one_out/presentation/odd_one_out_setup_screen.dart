import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/odd_one_out/controllers/odd_one_out_controller.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';

class OddOneOutSetupScreen extends ConsumerWidget {
  const OddOneOutSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var config = ref.watch(oddOneOutConfigProvider);
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
          title: const Text('👀 Odd One Out'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTCard(
                child: Text(
                  'Find the one that is different!',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Category', style: context.textTheme.titleMedium),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: OddOneOutCategory.values.map((c) {
                  return ChoiceChip(
                    label: Text('${c.emoji} ${c.label}'),
                    selected: config.category == c,
                    onSelected: (_) {
                      config = config.copyWith(category: c);
                      ref.read(oddOneOutConfigProvider.notifier).state = config;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Difficulty', style: context.textTheme.titleMedium),
              Wrap(
                spacing: AppSpacing.sm,
                children: OddOneOutDifficulty.values.map((d) {
                  return ChoiceChip(
                    label: Text(d.name.capitalize),
                    selected: config.difficulty == d,
                    onSelected: (_) {
                      config = config.copyWith(difficulty: d);
                      ref.read(oddOneOutConfigProvider.notifier).state = config;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              TTButton(
                label: 'Start Game!',
                expanded: true,
                size: TTButtonSize.large,
                onPressed: () {
                  ref.read(oddOneOutConfigProvider.notifier).state =
                      config.copyWith(hintsEnabled: hints);
                  context.push(AppRoutes.oddOneOutGame);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
