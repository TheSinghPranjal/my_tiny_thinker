import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/ascending_descending/controllers/bubble_game_controller.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

class BubbleGameSetupScreen extends ConsumerWidget {
  const BubbleGameSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ageGroup = ref.watch(onboardingProvider).ageGroup;
    final isToddler = ageGroup == AgeGroup.littleExplorers;

    if (isToddler) {
      return _ToddlerSetupView(
        onPlay: () {
          ref
              .read(bubbleGameControllerProvider.notifier)
              .updateConfig(BubbleGameConfig.toddler());
          context.push(AppRoutes.bubbleGame);
        },
      );
    }

    return _StandardSetupView();
  }
}

class _ToddlerSetupView extends StatelessWidget {
  const _ToddlerSetupView({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return AnimatedSkyBackground(
      showElements: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🫧🔢',
          emojiSize: 80,
          title: 'Bubble Pop!',
          subtitle: 'Tap the number you see!',
          titleColor: AppColors.white,
          subtitleColor: AppColors.white,
          titleShadows: const [
            Shadow(color: AppColors.skyBlueDark, blurRadius: 6),
          ],
          playLabel: 'Play!',
          onPlay: onPlay,
        ),
      ),
    );
  }
}

class _StandardSetupView extends ConsumerStatefulWidget {
  const _StandardSetupView();

  @override
  ConsumerState<_StandardSetupView> createState() =>
      _StandardSetupViewState();
}

class _StandardSetupViewState extends ConsumerState<_StandardSetupView> {
  BubbleGameConfig? _config;

  static const _bubbleCounts = [5, 10, 15, 20, 25, 30, 40, 50];
  static const _timerOptions = [30, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initConfig());
  }

  void _initConfig() {
    var config = ref.read(bubbleGameConfigProvider);
    final settings = ref.read(settingsProvider);
    final diff = Difficulty.values.firstWhere(
      (d) => d.name == settings.difficulty,
      orElse: () => Difficulty.easy,
    );
    setState(() {
      _config = config.copyWith(
        difficulty: diff,
        minValue: 1,
        maxValue: 20,
        timerMode: TimerMode.timed,
        timerSeconds: 60,
        hintsEnabled: settings.hintsEnabled,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_config == null) {
      return const AnimatedSkyBackground(
        showGrass: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final config = _config!;

    return AnimatedSkyBackground(
      showGrass: false,
      showElements: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('🔵 Bubble Number Pop'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TTCard(
                gradient: AppGradients.bubbleBlue,
                child: Text(
                  'Find and tap each number in order!',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('Mode'),
              _ChipSelector<SortMode>(
                values: SortMode.values,
                selected: config.sortMode,
                label: (m) =>
                    m == SortMode.ascending ? '↑ Ascending' : '↓ Descending',
                onSelected: (m) =>
                    setState(() => _config = config.copyWith(sortMode: m)),
              ),
              _SectionTitle('Difficulty'),
              _ChipSelector<Difficulty>(
                values: Difficulty.values,
                selected: config.difficulty,
                label: (d) => d.name.capitalize,
                onSelected: (d) {
                  setState(() {
                    _config = config.copyWith(
                      difficulty: d,
                      minValue: d == Difficulty.easy ? 1 : -10,
                      maxValue: d == Difficulty.easy ? 20 : 50,
                    );
                  });
                },
              ),
              _SectionTitle('Bubble Count'),
              _ChipSelector<int>(
                values: _bubbleCounts,
                selected: config.bubbleCount,
                label: (c) => '$c',
                onSelected: (c) =>
                    setState(() => _config = config.copyWith(bubbleCount: c)),
              ),
              _SectionTitle('Timer'),
              _ChipSelector<int>(
                values: _timerOptions,
                selected: config.timerSeconds,
                label: (s) => '${s}s',
                onSelected: (s) => setState(
                  () => _config = config.copyWith(
                    timerMode: TimerMode.timed,
                    timerSeconds: s,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TTButton(
                label: 'Start Game!',
                expanded: true,
                size: TTButtonSize.large,
                enabled: config.isValid,
                onPressed: () {
                  ref
                      .read(bubbleGameControllerProvider.notifier)
                      .updateConfig(config);
                  context.push(AppRoutes.bubbleGame);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(text, style: context.textTheme.titleMedium),
    );
  }
}

class _ChipSelector<T> extends StatelessWidget {
  const _ChipSelector({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: values.map((v) {
        return ChoiceChip(
          label: Text(label(v)),
          selected: v == selected,
          selectedColor: AppColors.skyBlueLight,
          onSelected: (_) => onSelected(v),
        );
      }).toList(),
    );
  }
}
