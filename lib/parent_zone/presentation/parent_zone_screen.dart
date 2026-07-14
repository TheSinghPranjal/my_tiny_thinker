import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/models/player_profile.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/repository/cloud_pop_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/repository/flower_garden_settings_repository.dart';

class ParentZoneScreen extends ConsumerStatefulWidget {
  const ParentZoneScreen({super.key});

  @override
  ConsumerState<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends ConsumerState<ParentZoneScreen> {
  bool _unlocked = false;
  int _a = 0;
  int _b = 0;
  int _expectedAnswer = 0;
  final _answerController = TextEditingController();
  final _answerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = math.Random();
    setState(() {
      _a = 2 + random.nextInt(8);
      _b = 2 + random.nextInt(8);
      _expectedAnswer = _a * _b;
    });
    _answerController.clear();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    FocusScope.of(context).unfocus();
    final raw = _answerController.text.trim();
    final answer = int.tryParse(raw);
    final expected = _expectedAnswer;

    if (answer != null && answer == expected) {
      setState(() => _unlocked = true);
      HapticFeedback.mediumImpact();
      return;
    }

    TTDialog.show(
      context: context,
      title: 'Try Again',
      emoji: '🔒',
      message: 'That answer is not correct.',
      primaryLabel: 'OK',
    );
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return _buildLockScreen();
    }
    return _buildParentDashboard();
  }

  Widget _buildLockScreen() {
    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Parent Zone'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Parents Only', style: context.textTheme.headlineLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Solve this to enter:',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TTCard(
                        child: Column(
                          children: [
                            Text(
                              'What is $_a × $_b?',
                              style: context.textTheme.displaySmall,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextField(
                              controller: _answerController,
                              focusNode: _answerFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineMedium,
                              decoration: InputDecoration(
                                hintText: '?',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                              ),
                              onSubmitted: (_) => _checkAnswer(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TTButton(
                              label: 'Enter',
                              expanded: true,
                              onPressed: _checkAnswer,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Or long-press the lock for 3 seconds',
                        style: context.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onLongPress: () {
                          HapticFeedback.heavyImpact();
                          setState(() => _unlocked = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_open_rounded, size: 32),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParentDashboard() {
    final profile = ref.watch(profileProvider);
    final memoryStats = ref.watch(memoryHubStatsProvider);
    final gameStats = ref.watch(allGameStatsProvider);
    final onboarding = ref.watch(onboardingProvider);

    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Parent Dashboard'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TTCard(
              gradient: AppGradients.welcomeCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistics', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.lg),
                  _StatRow('Play Time', '${profile.totalPlayTimeMinutes} min'),
                  _StatRow('Level', '${profile.level}'),
                  _StatRow('Total XP', '${profile.xp}'),
                  _StatRow('Coins', '${profile.coins}'),
                  _StatRow('Stars', '${profile.stars}'),
                  _StatRow('Daily Streak', '${profile.dailyStreak} days'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Game Scores', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  ...GameId.values.map((id) {
                    final s = gameStats[id] ?? GameStats(gameId: id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        '${id.emoji} ${id.displayName}: best ${s.bestScore}, '
                        'played ${s.timesPlayed}×, ⭐ ${s.starsEarned}',
                        style: context.textTheme.bodySmall,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memory Games', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  _StatRow('Games Played', '${memoryStats.gamesPlayed}'),
                  _StatRow('Perfect Games', '${memoryStats.perfectGames}'),
                  _StatRow('Highest Combo', '${memoryStats.highestCombo}'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Learning Path', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Current: ${onboarding.ageGroup.emoji} '
                    '${onboarding.ageGroup.title} (${onboarding.ageGroup.ageRange})',
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AgeGroup.values.map((group) {
                      return ChoiceChip(
                        label: Text('${group.emoji} ${group.title}'),
                        selected: onboarding.ageGroup == group,
                        onSelected: (_) => ref
                            .read(onboardingProvider.notifier)
                            .overrideAgeGroup(group),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🌸 Magical Flower Garden',
                      style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  _FlowerGardenParentControls(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('☁️ Cloud Pop Garden',
                      style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  _CloudPopGardenParentControls(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🐠 Ocean Fish Adventure', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  _OceanFishParentControls(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Controls', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: const Text('Difficulty Settings'),
                    subtitle: Text(ref.watch(settingsProvider).difficulty),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: const Text('Reset All Progress'),
                    onTap: () async {
                      await TTDialog.show(
                        context: context,
                        title: 'Reset Everything?',
                        emoji: '⚠️',
                        message: 'This cannot be undone.',
                        primaryLabel: 'Reset',
                        secondaryLabel: 'Cancel',
                        secondaryAction: () {},
                        primaryAction: () =>
                            ref.read(profileProvider.notifier).resetProgress(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyLarge),
          Text(value, style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _FlowerGardenParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(flowerGardenSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session: ${s.sessionSeconds ~/ 60} min ${s.sessionSeconds % 60}s'),
        Slider(
          value: s.sessionSeconds.toDouble(),
          min: 60,
          max: 1800,
          divisions: 29,
          label: '${s.sessionSeconds}s',
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(sessionSeconds: v.round()),
                  ),
        ),
        Text('Flowers on screen: ${s.maxFlowersOnScreen}'),
        Slider(
          value: s.maxFlowersOnScreen.toDouble(),
          min: 4,
          max: 5,
          divisions: 1,
          label: '${s.maxFlowersOnScreen}',
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(maxFlowersOnScreen: v.round()),
                  ),
        ),
        Text('Flower float speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: FlowerMoveSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.flowerMoveSpeed == speed,
              onSelected: (_) =>
                  ref.read(flowerGardenSettingsProvider.notifier).patch(
                        (x) => x.copyWith(flowerMoveSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        Text('Animation intensity'),
        Slider(
          value: s.animationIntensity,
          min: 0.5,
          max: 1.5,
          divisions: 4,
          label: s.animationIntensity.toStringAsFixed(1),
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(animationIntensity: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(narrationEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Music'),
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hapticsEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
      ],
    );
  }
}

class _CloudPopGardenParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(cloudPopGardenSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session: ${s.sessionSeconds ~/ 60} min ${s.sessionSeconds % 60}s'),
        Slider(
          value: s.sessionSeconds.toDouble(),
          min: 60,
          max: 1800,
          divisions: 29,
          label: '${s.sessionSeconds}s',
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(sessionSeconds: v.round()),
                  ),
        ),
        Text('Cloud & flower pairs: ${s.pairCount}'),
        Slider(
          value: s.pairCount.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${s.pairCount}',
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(pairCount: v.round()),
                  ),
        ),
        Text('Cloud speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: CloudMoveSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.cloudMoveSpeed == speed,
              onSelected: (_) =>
                  ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                        (x) => x.copyWith(cloudMoveSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Bloom speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: BloomSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.bloomSpeed == speed,
              onSelected: (_) =>
                  ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                        (x) => x.copyWith(bloomSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Rains until rainbow: ${s.rainsForRainbow}'),
        Slider(
          value: s.rainsForRainbow.toDouble(),
          min: 2,
          max: 8,
          divisions: 6,
          label: '${s.rainsForRainbow}',
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rainsForRainbow: v.round()),
                  ),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        Text('Animation intensity'),
        Slider(
          value: s.animationIntensity,
          min: 0.5,
          max: 1.5,
          divisions: 4,
          label: s.animationIntensity.toStringAsFixed(1),
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(animationIntensity: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Rain sounds'),
          value: s.rainSoundEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rainSoundEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(narrationEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Music'),
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hapticsEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Lightning animations'),
          value: s.lightningEnabled,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(lightningEnabled: v),
                  ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(cloudPopGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
      ],
    );
  }
}

class _OceanFishParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(oceanFishSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fish on screen: ${s.maxFishOnScreen}'),
        Slider(
          value: s.maxFishOnScreen.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          label: '${s.maxFishOnScreen}',
          onChanged: (v) => ref.read(oceanFishSettingsProvider.notifier).patch(
                (x) => x.copyWith(maxFishOnScreen: v.round()),
              ),
        ),
        Text('Session: ${s.sessionSeconds ~/ 60} min ${s.sessionSeconds % 60}s'),
        Slider(
          value: s.sessionSeconds.toDouble(),
          min: 60,
          max: 1800,
          divisions: 29,
          label: '${s.sessionSeconds}s',
          onChanged: (v) => ref.read(oceanFishSettingsProvider.notifier).patch(
                (x) => x.copyWith(sessionSeconds: v.round()),
              ),
        ),
        Text('Swim speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: FishSwimSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.swimSpeed == speed,
              onSelected: (_) => ref.read(oceanFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(swimSpeed: speed),
                  ),
            );
          }).toList(),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Voice encouragement'),
          value: s.voiceEnabled,
          onChanged: (v) => ref.read(oceanFishSettingsProvider.notifier).patch(
                (x) => x.copyWith(voiceEnabled: v),
              ),
        ),
        Text('Fish size', style: context.textTheme.titleSmall),
        Slider(
          value: s.fishSizeScale,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: s.fishSizeScale.toStringAsFixed(1),
          onChanged: (v) => ref.read(oceanFishSettingsProvider.notifier).patch(
                (x) => x.copyWith(fishSizeScale: v),
              ),
        ),
      ],
    );
  }
}
