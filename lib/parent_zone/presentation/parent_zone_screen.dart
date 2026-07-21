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
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/providers/game_stats_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/repository/ocean_fish_settings_repository.dart';
import 'package:my_tiny_thinker/games/balloon_parade/repository/balloon_parade_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/repository/color_balloon_pop_settings_repository.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/repository/alphabet_quiz_settings_repository.dart';
import 'package:my_tiny_thinker/games/animal_sounds/repository/animal_sounds_settings_repository.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/repository/shadow_match_settings_repository.dart';
import 'package:my_tiny_thinker/games/odd_one_out/models/odd_one_out_models.dart';
import 'package:my_tiny_thinker/games/odd_one_out/repository/odd_one_out_settings_repository.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';
import 'package:my_tiny_thinker/games/pattern_match/repository/pattern_match_settings_repository.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/repository/shape_drop_settings_repository.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/repository/cloud_pop_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/repository/flower_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/repository/peek_a_boo_animal_friends_settings_repository.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/repository/feed_frog_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/repository/hungry_monkey_settings_repository.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/repository/butterfly_garden_settings_repository.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/repository/catch_the_fish_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/repository/hungry_duck_settings_repository.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/repository/hungry_teddy_settings_repository.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/logic/bunny_hop_logic.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/repository/bunny_hop_settings_repository.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/repository/candy_color_hunt_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';
import 'package:my_tiny_thinker/games/color_school_bags/repository/color_school_bags_settings_repository.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/repository/frog_pond_settings_repository.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/repository/alphabet_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/repository/number_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/repository/picture_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/repository/color_shape_bridge_settings_repository.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/repository/moon_rescue_settings_repository.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_pop_settings.dart';
import 'package:my_tiny_thinker/games/ascending_descending/repository/bubble_pop_settings_repository.dart';
import 'package:my_tiny_thinker/parent_zone/presentation/widgets/parent_game_settings_card.dart';

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
            if (!ref.watch(isPremiumProvider)) ...[
              TTCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB39DDB), Color(0xFFCE93D8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TinyThink Premium',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Unlock unlimited play, parent controls, and Learning Path sessions.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TTButton(
                      label: 'See Premium',
                      expanded: true,
                      onPressed: () => context.push(AppRoutes.premium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
                  Text('Age Learning Track', style: context.textTheme.headlineMedium),
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
            ParentGameSettingsCard(
              gameId: GameId.candyColorHunt,
              child: _CandyColorHuntParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.bunnyHopAdventure,
              child: _BunnyHopParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.hungryTeddyCupcakeParty,
              child: _HungryTeddyParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.hungryDuckPondAdventure,
              child: _HungryDuckParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.catchTheButterflyGarden,
              child: _ButterflyGardenParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.catchTheFishAdventure,
              child: _CatchTheFishParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.hungryMonkeyBananaAdventure,
              child: _HungryMonkeyParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.feedTheFrogAdventure,
              child: _FeedTheFrogParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.frogPondAdventure,
              child: _FrogPondParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.peekABooAnimalFriends,
              child: _PeekABooParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.magicalFlowerGarden,
              child: _FlowerGardenParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.colorSchoolBags,
              child: _ColorSchoolBagsParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.shapeDropAdventure,
              child: _ShapeDropParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.shadowMatchAdventure,
              child: _ShadowMatchParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.oddOneOut,
              child: _OddOneOutParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.patternMatch,
              child: _PatternMatchParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.alphabetAdventureQuiz,
              child: _AlphabetQuizParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.animalSounds,
              child: _AnimalSoundsParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.cloudPopGarden,
              child: _CloudPopGardenParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.oceanFishAdventure,
              child: _OceanFishParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.balloonParade,
              child: _BalloonParadeParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.colorBalloonPop,
              child: _ColorBalloonPopParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.bubbleNumberPop,
              child: const Text(
                'Numbers appear from 0 to 10. Pop the number shown on top. '
                'A new set of bubbles appears when all are popped.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.ascendingBubbleNumberPop,
              child: _OrderedBubblePopParentControls(
                provider: ascendingBubblePopSettingsProvider,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.descendingNumberPop,
              child: _OrderedBubblePopParentControls(
                provider: descendingNumberPopSettingsProvider,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.numberWordPop,
              child: const _NumberWordPopParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.alphabetBridgeAdventure,
              child: _AlphabetBridgeParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.numberBridgeAdventure,
              child: _NumberBridgeParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.pictureBridgeAdventure,
              child: _PictureBridgeParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.colorShapeBridgeAdventure,
              child: _ColorShapeBridgeParentControls(),
            ),
            const SizedBox(height: AppSpacing.lg),
            ParentGameSettingsCard(
              gameId: GameId.moonRescueAdventure,
              child: _MoonRescueParentControls(),
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

class _CandyColorHuntParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(candyColorHuntSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Color name narration',
          value: s.narrationEnabled,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(narrationEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(largerTouchTargets: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(candyColorHuntSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Colors included', style: context.textTheme.titleSmall),
        Text(
          'Keep at least 4 colors selected',
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: CandyColorKind.values.map((kind) {
            final def = CandyColorCatalog.def(kind);
            final selected = s.enabledColors.contains(kind);
            return FilterChip(
              avatar: CircleAvatar(backgroundColor: def.color, radius: 8),
              label: Text(def.name),
              selected: selected,
              onSelected: (_) async {
                final ok = await ref
                    .read(candyColorHuntSettingsProvider.notifier)
                    .toggleColor(kind);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please keep at least 4 colors selected for the game.',
                      ),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BunnyHopParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(bunnyHopSettingsProvider);
    final cracked = BunnyHopLogic.crackedPadCount(s.effectiveLilyPadCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: BunnyHopDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) =>
                  ref.read(bunnyHopSettingsProvider.notifier).applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Lily pads: ${s.lilyPadCount} (cracked: $cracked)'),
        Slider(
          value: s.lilyPadCount.toDouble(),
          min: 5,
          max: 18,
          divisions: 13,
          label: '${s.lilyPadCount}',
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(lilyPadCount: v.round()),
              ),
        ),
        Text('Hop speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: BunnyHopSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.hopSpeed == speed,
              onSelected: (_) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hopSpeed: speed),
                  ),
            );
          }).toList(),
        ),
        Text('Cracked pad sink delay: ${s.crackedSinkDelay.toStringAsFixed(1)}s'),
        Slider(
          value: s.crackedSinkDelay,
          min: 3,
          max: 10,
          divisions: 14,
          label: '${s.crackedSinkDelay.toStringAsFixed(1)}s',
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(crackedSinkDelay: v),
              ),
        ),
        Text('Reward multiplier: ${s.rewardMultiplier.toStringAsFixed(1)}x'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: '${s.rewardMultiplier.toStringAsFixed(1)}x',
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Background music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(bunnyHopSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _HungryTeddyParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(hungryTeddySettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: HungryTeddyDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) =>
                  ref.read(hungryTeddySettingsProvider.notifier).applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Cupcakes on table: ${s.cupcakeCount}'),
        Slider(
          value: s.cupcakeCount.toDouble(),
          min: 4,
          max: 10,
          divisions: 6,
          label: '${s.cupcakeCount}',
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(cupcakeCount: v.round()),
              ),
        ),
        Text('Drag sensitivity', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: TeddyDragSensitivity.values.map((level) {
            return ChoiceChip(
              label: Text(level.name),
              selected: s.dragSensitivity == level,
              onSelected: (_) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                    (x) => x.copyWith(dragSensitivity: level),
                  ),
            );
          }).toList(),
        ),
        Text('Golden cupcake every: ${s.goldenInterval}s'),
        Slider(
          value: s.goldenInterval.toDouble(),
          min: 10,
          max: 60,
          divisions: 10,
          label: '${s.goldenInterval}s',
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(goldenInterval: v.round()),
              ),
        ),
        Text('Reward multiplier: ${s.rewardMultiplier.toStringAsFixed(1)}x'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: '${s.rewardMultiplier.toStringAsFixed(1)}x',
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Background music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(hungryTeddySettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _HungryDuckParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(hungryDuckSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: HungryDuckDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) =>
                  ref.read(hungryDuckSettingsProvider.notifier).applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Fish in pond: ${s.fishCount}'),
        Slider(
          value: s.fishCount.toDouble(),
          min: 4,
          max: 10,
          divisions: 6,
          label: '${s.fishCount}',
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(fishCount: v.round()),
              ),
        ),
        Text('Fish speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: PondFishSwimSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.fishSpeed == speed,
              onSelected: (_) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                    (x) => x.copyWith(fishSpeed: speed),
                  ),
            );
          }).toList(),
        ),
        Text('Duck speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: DuckSwimSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.duckSpeed == speed,
              onSelected: (_) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                    (x) => x.copyWith(duckSpeed: speed),
                  ),
            );
          }).toList(),
        ),
        Text('Golden fish every: ${s.goldenInterval}s'),
        Slider(
          value: s.goldenInterval.toDouble(),
          min: 10,
          max: 60,
          divisions: 10,
          label: '${s.goldenInterval}s',
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(goldenInterval: v.round()),
              ),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Background music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(hungryDuckSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _ButterflyGardenParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(butterflyGardenSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: ButterflyGardenDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) => ref
                  .read(butterflyGardenSettingsProvider.notifier)
                  .applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Butterflies in garden: ${s.butterflyCount}'),
        Slider(
          value: s.butterflyCount.toDouble(),
          min: 3,
          max: 10,
          divisions: 7,
          label: '${s.butterflyCount}',
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(butterflyCount: v.round()),
              ),
        ),
        Text('Flight speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: ButterflyFlightSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.flightSpeed == speed,
              onSelected: (_) =>
                  ref.read(butterflyGardenSettingsProvider.notifier).patch(
                        (x) => x.copyWith(flightSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Golden butterfly every: ${s.goldenInterval}s'),
        Slider(
          value: s.goldenInterval.toDouble(),
          min: 10,
          max: 60,
          divisions: 10,
          label: '${s.goldenInterval}s',
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(goldenInterval: v.round()),
              ),
        ),
        Text(
          'Bee spawn delay: ${s.beeSpawnMin.toStringAsFixed(1)}–${s.beeSpawnMax.toStringAsFixed(1)}s',
        ),
        RangeSlider(
          values: RangeValues(
            s.beeSpawnMin.clamp(3.0, 15.0),
            s.beeSpawnMax.clamp(s.beeSpawnMin.clamp(3.0, 15.0), 20.0),
          ),
          min: 3,
          max: 20,
          divisions: 17,
          labels: RangeLabels(
            s.beeSpawnMin.toStringAsFixed(1),
            s.beeSpawnMax.toStringAsFixed(1),
          ),
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(beeSpawnMin: v.start, beeSpawnMax: v.end),
              ),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Background music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(butterflyGardenSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _CatchTheFishParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(catchTheFishSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fish on screen: ${s.fishCount}'),
        Slider(
          value: s.fishCount.toDouble(),
          min: 5,
          max: 10,
          divisions: 5,
          label: '${s.fishCount}',
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(fishCount: v.round()),
                  ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(largerTouchTargets: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(catchTheFishSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
      ],
    );
  }
}

class _HungryMonkeyParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(hungryMonkeySettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: HungryMonkeyDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) => ref
                  .read(hungryMonkeySettingsProvider.notifier)
                  .applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Bananas on tree: ${s.bananaCount}'),
        Slider(
          value: s.bananaCount.toDouble(),
          min: 5,
          max: 10,
          divisions: 5,
          label: '${s.bananaCount}',
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(bananaCount: v.round()),
              ),
        ),
        Text(
          'Apple spawn delay: ${s.appleSpawnMin.toStringAsFixed(1)}–${s.appleSpawnMax.toStringAsFixed(1)}s',
        ),
        RangeSlider(
          values: RangeValues(
            s.appleSpawnMin.clamp(2.0, 12.0),
            s.appleSpawnMax.clamp(s.appleSpawnMin.clamp(2.0, 12.0), 15.0),
          ),
          min: 2,
          max: 15,
          divisions: 13,
          labels: RangeLabels(
            s.appleSpawnMin.toStringAsFixed(1),
            s.appleSpawnMax.toStringAsFixed(1),
          ),
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(
                  appleSpawnMin: v.start,
                  appleSpawnMax: v.end,
                ),
              ),
        ),
        Text('Max apples at once: ${s.maxApples}'),
        Slider(
          value: s.maxApples.toDouble(),
          min: 0,
          max: 4,
          divisions: 4,
          label: '${s.maxApples}',
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(maxApples: v.round()),
              ),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
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
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(animationIntensity: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Background music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(hungryMonkeySettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _FeedTheFrogParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(feedFrogSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Flying insects: ${s.insectCount}'),
        Slider(
          value: s.insectCount.toDouble(),
          min: 4,
          max: 10,
          divisions: 6,
          label: '${s.insectCount}',
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(insectCount: v.round()),
              ),
        ),
        Text('Flight speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: InsectFlightSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.flightSpeed == speed,
              onSelected: (_) =>
                  ref.read(feedFrogSettingsProvider.notifier).patch(
                        (x) => x.copyWith(flightSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Night starts at: ${s.dayNightStartSeconds}s'),
        Slider(
          value: s.dayNightStartSeconds.toDouble(),
          min: 15,
          max: 90,
          divisions: 15,
          label: '${s.dayNightStartSeconds}s',
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(dayNightStartSeconds: v.round()),
              ),
        ),
        Text('Day-night cycle: ${s.dayNightCycleSeconds}s'),
        Slider(
          value: s.dayNightCycleSeconds.toDouble(),
          min: 40,
          max: 120,
          divisions: 8,
          label: '${s.dayNightCycleSeconds}s',
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(dayNightCycleSeconds: v.round()),
              ),
        ),
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(feedFrogSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _FrogPondParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(frogPondSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: FrogPondDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name),
              selected: s.difficulty == d,
              onSelected: (_) =>
                  ref.read(frogPondSettingsProvider.notifier).applyDifficulty(d),
            );
          }).toList(),
        ),
        Text('Lily pads: ${s.lilyPadCount}'),
        Slider(
          value: s.lilyPadCount.toDouble(),
          min: 2,
          max: 8,
          divisions: 6,
          label: '${s.lilyPadCount}',
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(lilyPadCount: v.round()),
              ),
        ),
        Text('Frog movement speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: FrogMoveSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.frogMoveSpeed == speed,
              onSelected: (_) =>
                  ref.read(frogPondSettingsProvider.notifier).patch(
                        (x) => x.copyWith(frogMoveSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text(
          'Replacement delay: ${s.replacementDelayMin.toStringAsFixed(1)}–${s.replacementDelayMax.toStringAsFixed(1)}s',
        ),
        RangeSlider(
          values: RangeValues(
            s.replacementDelayMin.clamp(1.0, 8.0),
            s.replacementDelayMax.clamp(
              s.replacementDelayMin.clamp(1.0, 8.0),
              8.0,
            ),
          ),
          min: 1,
          max: 8,
          divisions: 14,
          labels: RangeLabels(
            s.replacementDelayMin.toStringAsFixed(1),
            s.replacementDelayMax.toStringAsFixed(1),
          ),
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(
                  replacementDelayMin: v.start,
                  replacementDelayMax: v.end,
                ),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('King Frog events'),
          value: s.kingFrogEnabled,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(kingFrogEnabled: v),
              ),
        ),
        if (s.kingFrogEnabled) ...[
          Text('King Frog interval: ${s.kingFrogInterval}s'),
          Slider(
            value: s.kingFrogInterval.toDouble(),
            min: 15,
            max: 60,
            divisions: 3,
            label: '${s.kingFrogInterval}s',
            onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                  (x) => x.copyWith(kingFrogInterval: v.round()),
                ),
          ),
        ],
        Text('Reward multiplier'),
        Slider(
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          label: s.rewardMultiplier.toStringAsFixed(1),
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
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
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(animationIntensity: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger touch targets'),
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(frogPondSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
      ],
    );
  }
}

class _PeekABooParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(peekABooSettingsProvider);
    final maxAnimals = PeekABooSettings.maxAnimalsForBushCount(s.bushCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty preset', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: PeekDifficultyPreset.values.map((preset) {
            return ChoiceChip(
              label: Text(preset.name),
              selected: s.difficultyPreset == preset,
              onSelected: (_) => ref
                  .read(peekABooSettingsProvider.notifier)
                  .applyPreset(preset),
            );
          }).toList(),
        ),
        Text('Bushes: ${s.bushCount}'),
        Slider(
          value: s.bushCount.toDouble(),
          min: 2,
          max: 10,
          divisions: 8,
          label: '${s.bushCount}',
          onChanged: (v) {
            final count = v.round();
            final maxA = PeekABooSettings.maxAnimalsForBushCount(count);
            ref.read(peekABooSettingsProvider.notifier).patch(
                  (x) => x.copyWith(
                    bushCount: count,
                    hiddenAnimalCount: x.hiddenAnimalCount.clamp(1, maxA),
                  ),
                );
          },
        ),
        Text('Hidden animals: ${s.hiddenAnimalCount} (max $maxAnimals)'),
        Slider(
          value: s.hiddenAnimalCount.toDouble(),
          min: 1,
          max: maxAnimals.toDouble(),
          divisions: math.max(1, maxAnimals - 1),
          label: '${s.hiddenAnimalCount}',
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(hiddenAnimalCount: v.round()),
              ),
        ),
        Text('Bush shake frequency', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: BushShakeFrequency.values.map((freq) {
            return ChoiceChip(
              label: Text(freq.name),
              selected: s.shakeFrequency == freq,
              onSelected: (_) =>
                  ref.read(peekABooSettingsProvider.notifier).patch(
                        (x) => x.copyWith(shakeFrequency: freq),
                      ),
            );
          }).toList(),
        ),
        Text('Animation speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: PeekAnimationSpeed.values.map((speed) {
            return ChoiceChip(
              label: Text(speed.name),
              selected: s.animationSpeed == speed,
              onSelected: (_) =>
                  ref.read(peekABooSettingsProvider.notifier).patch(
                        (x) => x.copyWith(animationSpeed: speed),
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
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
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
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(animationIntensity: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sound effects'),
          value: s.soundEnabled,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Animal sounds'),
          value: s.animalSoundsEnabled,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(animalSoundsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Narration'),
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Music'),
          value: s.musicEnabled,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Haptic feedback'),
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reduced motion'),
          value: s.reducedMotion,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High contrast'),
          value: s.highContrast,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(highContrast: v),
              ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Larger fonts'),
          value: s.largerFonts,
          onChanged: (v) => ref.read(peekABooSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerFonts: v),
              ),
        ),
      ],
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
        Text('Bird speed', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: BirdSpeed.values.map((speed) {
            final label = switch (speed) {
              BirdSpeed.verySlow => 'Very Slow',
              BirdSpeed.slow => 'Slow',
              BirdSpeed.normal => 'Normal',
            };
            return ChoiceChip(
              label: Text(label),
              selected: s.birdSpeed == speed,
              onSelected: (_) =>
                  ref.read(flowerGardenSettingsProvider.notifier).patch(
                        (x) => x.copyWith(birdSpeed: speed),
                      ),
            );
          }).toList(),
        ),
        Text('Max flower move distance: ${(s.maxMoveDistance * 100).round()}%'),
        Slider(
          value: s.maxMoveDistance,
          min: 0.12,
          max: 0.35,
          divisions: 23,
          label: '${(s.maxMoveDistance * 100).round()}%',
          onChanged: (v) =>
              ref.read(flowerGardenSettingsProvider.notifier).patch(
                    (x) => x.copyWith(maxMoveDistance: v),
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

class _ColorSchoolBagsParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(colorSchoolBagsSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of bags: ${s.maxBackpacks}',
          style: context.textTheme.titleSmall,
        ),
        Text(
          'Default 3 · range 2–6',
          style: context.textTheme.bodySmall,
        ),
        Slider(
          value: s.maxBackpacks.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          label: '${s.maxBackpacks}',
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(maxBackpacks: v.round()),
                  ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Color name narration',
          value: s.narrationEnabled,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(narrationEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(largerTouchTargets: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(colorSchoolBagsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Colors included', style: context.textTheme.titleSmall),
        Text(
          'Keep at least 2 colors selected',
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: BagColorKind.values.map((kind) {
            final def = BagColorCatalog.def(kind);
            final selected = s.enabledColors.contains(kind);
            return FilterChip(
              avatar: CircleAvatar(backgroundColor: def.color, radius: 8),
              label: Text(def.name),
              selected: selected,
              onSelected: (_) async {
                final ok = await ref
                    .read(colorSchoolBagsSettingsProvider.notifier)
                    .toggleColor(kind);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please keep at least 2 colors selected for the game.',
                      ),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ShapeDropParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(shapeDropSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Object-based learning',
          value: s.objectLearningEnabled,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(objectLearningEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sequential shape order',
          value: s.sequentialMode,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(sequentialMode: v),
              ),
        ),
        _ParentSwitch(
          title: 'Narration / shape names',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'UPPERCASE labels',
          value: s.uppercaseLabels,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(uppercaseLabels: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(shapeDropSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Shapes included', style: context.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ShapeCatalog.preschoolCore.map((kind) {
            final selected = s.enabledShapes.contains(kind);
            return FilterChip(
              label: Text(ShapeCatalog.displayName(kind)),
              selected: selected,
              onSelected: (v) {
                final next = [...s.enabledShapes];
                if (v) {
                  if (!next.contains(kind)) next.add(kind);
                } else {
                  next.remove(kind);
                }
                ref.read(shapeDropSettingsProvider.notifier).patch(
                      (x) => x.copyWith(
                        enabledShapes: next.isEmpty
                            ? ShapeCatalog.preschoolCore
                            : next,
                      ),
                    );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PatternMatchParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(patternMatchSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: PatternDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
              selected: s.difficulty == d,
              onSelected: (_) => ref.read(patternMatchSettingsProvider.notifier).patch(
                    (x) => x.copyWith(difficulty: d),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(patternMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Hints',
          value: s.hintsEnabled,
          onChanged: (v) => ref.read(patternMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(hintsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(patternMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _OddOneOutParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(oddOneOutSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: OddOneOutCategory.values.map((c) {
            return ChoiceChip(
              label: Text('${c.emoji} ${c.label}'),
              selected: s.category == c,
              onSelected: (_) => ref.read(oddOneOutSettingsProvider.notifier).patch(
                    (x) => x.copyWith(category: c),
                  ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: OddOneOutDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
              selected: s.difficulty == d,
              onSelected: (_) => ref.read(oddOneOutSettingsProvider.notifier).patch(
                    (x) => x.copyWith(difficulty: d),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(oddOneOutSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Hints',
          value: s.hintsEnabled,
          onChanged: (v) => ref.read(oddOneOutSettingsProvider.notifier).patch(
                (x) => x.copyWith(hintsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(oddOneOutSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _ShadowMatchParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(shadowMatchSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: ShadowDifficulty.values.map((d) {
            return ChoiceChip(
              label: Text('${d.name} (${switch (d) {
                    ShadowDifficulty.easy => 3,
                    ShadowDifficulty.medium => 4,
                    ShadowDifficulty.hard => 6,
                  }} items)'),
              selected: s.difficulty == d,
              onSelected: (_) => ref.read(shadowMatchSettingsProvider.notifier).patch(
                    (x) => x.copyWith(difficulty: d),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(shadowMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(shadowMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(shadowMatchSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _AlphabetQuizParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(alphabetQuizSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alphabet order', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: AlphabetOrder.values.map((o) {
            return ChoiceChip(
              label: Text(o.name),
              selected: s.alphabetOrder == o,
              onSelected: (_) => ref.read(alphabetQuizSettingsProvider.notifier).patch(
                    (x) => x.copyWith(alphabetOrder: o),
                  ),
            );
          }).toList(),
        ),
        Text('Letter case', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: LetterCaseMode.values.map((m) {
            return ChoiceChip(
              label: Text(m.name),
              selected: s.letterCaseMode == m,
              onSelected: (_) => ref.read(alphabetQuizSettingsProvider.notifier).patch(
                    (x) => x.copyWith(letterCaseMode: m),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(alphabetQuizSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(alphabetQuizSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(alphabetQuizSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _AnimalSoundsParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(animalSoundsSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) =>
              ref.read(animalSoundsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Auto-play animal sound',
          value: s.autoPlaySound,
          onChanged: (v) =>
              ref.read(animalSoundsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(autoPlaySound: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(animalSoundsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(animalSoundsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Haptics',
          value: s.hapticsEnabled,
          onChanged: (v) =>
              ref.read(animalSoundsSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hapticsEnabled: v),
                  ),
        ),
      ],
    );
  }
}

class _ParentSlider extends StatelessWidget {
  const _ParentSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _ParentSwitch extends StatelessWidget {
  const _ParentSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
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

class _AlphabetBridgeParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(alphabetBridgeSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Letter pairs: ${s.pairCount}'),
        Slider(
          value: s.pairCount.toDouble(),
          min: 3,
          max: 7,
          divisions: 4,
          label: '${s.pairCount}',
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(pairCount: v.round()),
              ),
        ),
        Text('Letter order', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: AlphabetOrderMode.values.map((mode) {
            return ChoiceChip(
              label: Text(mode.name),
              selected: s.orderMode == mode,
              onSelected: (_) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(orderMode: mode),
                  ),
            );
          }).toList(),
        ),
        Text('Practice mode', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: AlphabetPracticeMode.values.map((mode) {
            return ChoiceChip(
              label: Text(mode.name),
              selected: s.practiceMode == mode,
              onSelected: (_) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(practiceMode: mode),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Letter narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(alphabetBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _NumberBridgeParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(numberBridgeSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number pairs: ${s.pairCount}'),
        Slider(
          value: s.pairCount.toDouble(),
          min: 3,
          max: 7,
          divisions: 4,
          label: '${s.pairCount}',
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(pairCount: v.round()),
              ),
        ),
        Text('Highest number: ${s.maxNumber}'),
        Slider(
          value: s.maxNumber.toDouble(),
          min: 20,
          max: 100,
          divisions: 16,
          label: '${s.maxNumber}',
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(maxNumber: v.round()),
              ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Number narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(numberBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _PictureBridgeParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(pictureBridgeSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Picture pairs: ${s.pairCount}'),
        Slider(
          value: s.pairCount.toDouble(),
          min: 3,
          max: 7,
          divisions: 4,
          label: '${s.pairCount}',
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(pairCount: v.round()),
              ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Word narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(pictureBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _ColorShapeBridgeParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(colorShapeBridgeSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match pairs: ${s.pairCount}'),
        Slider(
          value: s.pairCount.toDouble(),
          min: 3,
          max: 7,
          divisions: 4,
          label: '${s.pairCount}',
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(pairCount: v.round()),
              ),
        ),
        Text('Match mode', style: context.textTheme.titleSmall),
        Wrap(
          spacing: AppSpacing.sm,
          children: ColorShapeBridgeMode.values.map((mode) {
            return ChoiceChip(
              label: Text(mode.name),
              selected: s.mode == mode,
              onSelected: (_) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(mode: mode),
                  ),
            );
          }).toList(),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Name narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(colorShapeBridgeSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _MoonRescueParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(moonRescueSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Astronauts: ${s.astronautCount}'),
        Slider(
          value: s.astronautCount.toDouble(),
          min: 5,
          max: 12,
          divisions: 7,
          label: '${s.astronautCount}',
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(astronautCount: v.round()),
              ),
        ),
        Text('Rocket capacity: ${s.rocketCapacity}'),
        Slider(
          value: s.rocketCapacity.toDouble(),
          min: 2,
          max: 5,
          divisions: 3,
          label: '${s.rocketCapacity}',
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(rocketCapacity: v.round()),
              ),
        ),
        _ParentSlider(
          label: 'Float speed',
          value: s.floatSpeed,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(floatSpeed: v),
              ),
        ),
        _ParentSlider(
          label: 'Drift intensity',
          value: s.driftIntensity,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(driftIntensity: v),
              ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(rewardMultiplier: v),
              ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(soundEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Narration',
          value: s.narrationEnabled,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(narrationEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(musicEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Rocket sounds',
          value: s.rocketSoundsEnabled,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(rocketSoundsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(hapticsEnabled: v),
              ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(largerTouchTargets: v),
              ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) => ref.read(moonRescueSettingsProvider.notifier).patch(
                (x) => x.copyWith(reducedMotion: v),
              ),
        ),
      ],
    );
  }
}

class _BalloonParadeParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(balloonParadeSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Balloon spawn interval: ${s.spawnIntervalSeconds}s'),
        Slider(
          value: s.spawnIntervalSeconds.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${s.spawnIntervalSeconds}s',
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(spawnIntervalSeconds: v.round()),
                  ),
        ),
        Text('Balloons per spawn: ${s.balloonsPerSpawn}'),
        Slider(
          value: s.balloonsPerSpawn.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${s.balloonsPerSpawn}',
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(balloonsPerSpawn: v.round()),
                  ),
        ),
        _ParentSlider(
          label: 'Reward multiplier',
          value: s.rewardMultiplier,
          min: 0.5,
          max: 2.0,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(rewardMultiplier: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Encouraging phrases',
          value: s.narrationEnabled,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(narrationEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hapticsEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Reduced motion',
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(balloonParadeSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
      ],
    );
  }
}

class _ColorBalloonPopParentControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(colorBalloonPopSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParentSwitch(
          title: 'Voice pronunciation',
          value: s.voiceEnabled,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(voiceEnabled: v),
                  ),
        ),
        Text('Music volume: ${(s.musicVolume * 100).round()}%'),
        Slider(
          value: s.musicVolume,
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(s.musicVolume * 100).round()}%',
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicVolume: v),
                  ),
        ),
        Text('Animation speed: ${s.animationSpeed.toStringAsFixed(1)}x'),
        Slider(
          value: s.animationSpeed,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          label: '${s.animationSpeed.toStringAsFixed(1)}x',
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(animationSpeed: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Sound effects',
          value: s.soundEnabled,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(soundEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Background music',
          value: s.musicEnabled,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(musicEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Haptic feedback',
          value: s.hapticsEnabled,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(hapticsEnabled: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Larger touch targets',
          value: s.largerTouchTargets,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(largerTouchTargets: v),
                  ),
        ),
        _ParentSwitch(
          title: 'Reduced animation mode',
          value: s.reducedMotion,
          onChanged: (v) =>
              ref.read(colorBalloonPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(reducedMotion: v),
                  ),
        ),
      ],
    );
  }
}

class _OrderedBubblePopParentControls extends ConsumerWidget {
  const _OrderedBubblePopParentControls({required this.provider});

  final StateNotifierProvider<OrderedBubblePopSettingsNotifier,
      OrderedBubblePopSettings> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bubbles on screen: ${s.bubbleCount}'),
        Slider(
          value: s.bubbleCount.toDouble(),
          min: 5,
          max: 10,
          divisions: 5,
          label: '${s.bubbleCount}',
          onChanged: (v) => ref.read(provider.notifier).patch(
                (x) => x.copyWith(bubbleCount: v.round()),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Minimum number: ${s.minValue}'),
        _SignedNumberField(
          value: s.minValue,
          min: OrderedBubblePopSettings.absoluteMin,
          max: OrderedBubblePopSettings.absoluteMax,
          onChanged: (v) => ref.read(provider.notifier).patch(
                (x) => x.copyWith(minValue: v),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Maximum number: ${s.maxValue}'),
        _SignedNumberField(
          value: s.maxValue,
          min: OrderedBubblePopSettings.absoluteMin,
          max: OrderedBubblePopSettings.absoluteMax,
          onChanged: (v) => ref.read(provider.notifier).patch(
                (x) => x.copyWith(maxValue: v),
              ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Random numbers'),
          subtitle: Text(
            s.randomNumbers
                ? 'Bubbles use mixed numbers from the range (still in order).'
                : 'Bubbles use a consecutive sequence within the range.',
          ),
          value: s.randomNumbers,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) => ref.read(provider.notifier).patch(
                (x) => x.copyWith(randomNumbers: v ?? false),
              ),
        ),
      ],
    );
  }
}

class _NumberWordPopParentControls extends ConsumerWidget {
  const _NumberWordPopParentControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(numberWordPopSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bubbles on screen: ${s.bubbleCount}'),
        Slider(
          value: s.bubbleCount.toDouble(),
          min: 5,
          max: 10,
          divisions: 5,
          label: '${s.bubbleCount}',
          onChanged: (v) =>
              ref.read(numberWordPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(bubbleCount: v.round()),
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Minimum number: ${s.minValue}'),
        _SignedNumberField(
          value: s.minValue,
          min: NumberWordPopSettings.absoluteMin,
          max: NumberWordPopSettings.absoluteMax,
          allowNegative: false,
          onChanged: (v) =>
              ref.read(numberWordPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(minValue: v),
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Maximum number: ${s.maxValue}'),
        _SignedNumberField(
          value: s.maxValue,
          min: NumberWordPopSettings.absoluteMin,
          max: NumberWordPopSettings.absoluteMax,
          allowNegative: false,
          onChanged: (v) =>
              ref.read(numberWordPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(maxValue: v),
                  ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Random numbers'),
          subtitle: Text(
            s.randomNumbers
                ? 'Any number from the range can appear as the word target.'
                : 'Bubbles use a consecutive sequence; the word is one of them.',
          ),
          value: s.randomNumbers,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (v) =>
              ref.read(numberWordPopSettingsProvider.notifier).patch(
                    (x) => x.copyWith(randomNumbers: v ?? true),
                  ),
        ),
      ],
    );
  }
}

class _SignedNumberField extends StatefulWidget {
  const _SignedNumberField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.allowNegative = true,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool allowNegative;

  @override
  State<_SignedNumberField> createState() => _SignedNumberFieldState();
}

class _SignedNumberFieldState extends State<_SignedNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant _SignedNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final parsed = int.tryParse(raw.trim());
    if (parsed == null) {
      _controller.text = '${widget.value}';
      return;
    }
    widget.onChanged(parsed.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(
        signed: widget.allowNegative,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(widget.allowNegative ? r'^-?\d{0,4}$' : r'^\d{0,4}$'),
        ),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        helperText: widget.allowNegative
            ? 'From -9999 to 9999'
            : 'From 0 to 9999',
      ),
      onSubmitted: _commit,
      onEditingComplete: () => _commit(_controller.text),
      onTapOutside: (_) => _commit(_controller.text),
    );
  }
}
