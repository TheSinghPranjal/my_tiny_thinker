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
import 'package:my_tiny_thinker/games/pattern_match/controllers/pattern_match_controller.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

class PatternMatchSetupScreen extends ConsumerWidget {
  const PatternMatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var config = ref.watch(patternMatchConfigProvider);
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
          title: const Text('🧩 Pattern Match'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTCard(
                child: Text(
                  'Complete the pattern!',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Difficulty', style: context.textTheme.titleMedium),
              Wrap(
                spacing: AppSpacing.sm,
                children: PatternDifficulty.values.map((d) {
                  return ChoiceChip(
                    label: Text(d.name.capitalize),
                    selected: config.difficulty == d,
                    onSelected: (_) {
                      config = config.copyWith(difficulty: d);
                      ref.read(patternMatchConfigProvider.notifier).state = config;
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
                  ref.read(patternMatchConfigProvider.notifier).state =
                      config.copyWith(hintsEnabled: hints);
                  context.push(AppRoutes.patternMatchGame);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
