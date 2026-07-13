import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';
import 'package:my_tiny_thinker/games/memory_game/controllers/memory_session_controller.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

class ParentZoneScreen extends ConsumerStatefulWidget {
  const ParentZoneScreen({super.key});

  @override
  ConsumerState<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends ConsumerState<ParentZoneScreen> {
  bool _unlocked = false;
  late int _a;
  late int _b;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = math.Random();
    _a = 2 + random.nextInt(8);
    _b = 2 + random.nextInt(8);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == _a * _b) {
      setState(() => _unlocked = true);
      HapticFeedback.mediumImpact();
    } else {
      TTDialog.show(
        context: context,
        title: 'Try Again',
        emoji: '🔒',
        message: 'That answer is not correct.',
        primaryLabel: 'OK',
      );
      _generateQuestion();
      _answerController.clear();
    }
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Parent Zone'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Parents Only',
                style: context.textTheme.headlineLarge,
              ),
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
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium,
                      decoration: InputDecoration(
                        hintText: '?',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
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
      ),
    );
  }

  Widget _buildParentDashboard() {
    final profile = ref.watch(profileProvider);
    final memoryStats = ref.watch(memoryHubStatsProvider);

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
                  Text('Memory Games', style: context.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  _StatRow('Games Played', '${memoryStats.gamesPlayed}'),
                  _StatRow('Perfect Games', '${memoryStats.perfectGames}'),
                  _StatRow('Highest Combo', '${memoryStats.highestCombo}'),
                  if (memoryStats.favoriteGame != null)
                    _StatRow(
                      'Favorite',
                      memoryStats.favoriteGame!.displayName,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  ...MemoryMiniGameType.values.take(5).map((type) {
                    final s = memoryStats.statsFor(type);
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        '${type.emoji} ${type.displayName}: '
                        '${(s.averageAccuracy * 100).round()}% accuracy, '
                        'best ${s.bestScore}',
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
