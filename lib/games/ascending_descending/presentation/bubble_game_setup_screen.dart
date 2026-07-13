import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/ascending_descending/controllers/bubble_game_controller.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';
import 'package:my_tiny_thinker/games/ascending_descending/presentation/widgets/victory_dialog.dart';

class BubbleGameSetupScreen extends ConsumerStatefulWidget {
  const BubbleGameSetupScreen({super.key});

  @override
  ConsumerState<BubbleGameSetupScreen> createState() =>
      _BubbleGameSetupScreenState();
}

class _BubbleGameSetupScreenState extends ConsumerState<BubbleGameSetupScreen> {
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
    final range = BubbleNumberGenerator.defaultRangeForDifficulty(diff);
    setState(() {
      _config = config.copyWith(
        difficulty: diff,
        minValue: range.$1,
        maxValue: range.$2,
        bubbleSpeed: BubbleNumberGenerator.speedForDifficulty(diff),
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
                  'Pop bubbles in the right order!',
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
                onSelected: (m) => setState(() => _config = config.copyWith(sortMode: m)),
              ),
              _SectionTitle('Difficulty'),
              _ChipSelector<Difficulty>(
                values: Difficulty.values,
                selected: config.difficulty,
                label: (d) => d.name.capitalize,
                onSelected: (d) {
                  final range = BubbleNumberGenerator.defaultRangeForDifficulty(d);
                  setState(() {
                    _config = config.copyWith(
                      difficulty: d,
                      minValue: range.$1,
                      maxValue: range.$2,
                      bubbleSpeed: BubbleNumberGenerator.speedForDifficulty(d),
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
              _SectionTitle('Number Range'),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'Min',
                      value: config.minValue,
                      onChanged: (v) =>
                          setState(() => _config = config.copyWith(minValue: v)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _NumberField(
                      label: 'Max',
                      value: config.maxValue,
                      onChanged: (v) =>
                          setState(() => _config = config.copyWith(maxValue: v)),
                    ),
                  ),
                ],
              ),
              if (!config.isValid)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Min cannot exceed Max',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              _SectionTitle('Timer'),
              _ChipSelector<TimerMode>(
                values: TimerMode.values,
                selected: config.timerMode,
                label: (t) => t.name.capitalize,
                onSelected: (t) =>
                    setState(() => _config = config.copyWith(timerMode: t)),
              ),
              if (config.timerMode == TimerMode.timed) ...[
                _ChipSelector<int>(
                  values: _timerOptions,
                  selected: config.timerSeconds,
                  label: (s) => '${s}s',
                  onSelected: (s) => setState(
                    () => _config = config.copyWith(timerSeconds: s),
                  ),
                ),
              ],
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
              const SizedBox(height: AppSpacing.md),
              TTButton(
                label: 'Advanced Settings',
                variant: TTButtonVariant.ghost,
                expanded: true,
                onPressed: () => BubbleGameSetupSheet.show(
                  context,
                  config: config,
                  onConfigChanged: (c) => setState(() => _config = c),
                ),
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
        final isSelected = v == selected;
        return ChoiceChip(
          label: Text(label(v)),
          selected: isSelected,
          selectedColor: AppColors.skyBlueLight,
          onSelected: (_) => onSelected(v),
        );
      }).toList(),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final v = int.tryParse(text);
        if (v != null) onChanged(v.clamp(-99999, 99999));
      },
    );
  }
}
