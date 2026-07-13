import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_badge.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  bool _showConfetti = false;

  Future<void> _claimDailyReward() async {
    final reward = await ref.read(dailyRewardProvider.notifier).claim();
    await ref.read(profileProvider.notifier).addCoins(10 + reward.streakDays * 2);
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final dailyReward = ref.watch(dailyRewardProvider);

    return AnimatedSkyBackground(
      child: Stack(
        children: [
          SafeArea(
            child: ResponsivePadding(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards',
                      style: context.textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _DailyRewardCard(
                      canClaim: dailyReward.canClaim,
                      streakDays: dailyReward.streakDays,
                      onClaim: _claimDailyReward,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TTCard(
                      gradient: AppGradients.welcomeCard,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RewardStat(
                            icon: Icons.monetization_on_rounded,
                            value: profile.coins,
                            label: 'Coins',
                          ),
                          _RewardStat(
                            icon: Icons.star_rounded,
                            value: profile.stars,
                            label: 'Stars',
                          ),
                          _RewardStat(
                            icon: Icons.bolt_rounded,
                            value: profile.xp,
                            label: 'XP',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Achievements', style: context.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.md),
                    ..._defaultAchievements.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: TTCard(
                          child: Row(
                            children: [
                              Text(a.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title, style: context.textTheme.titleMedium),
                                    Text(
                                      a.description,
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (a.isUnlocked)
                                const TTBadge(
                                  label: 'Done!',
                                  color: AppColors.mintGreen,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showConfetti)
            const IgnorePointer(child: ConfettiWidget()),
        ],
      ),
    );
  }
}

class _DailyRewardCard extends StatelessWidget {
  const _DailyRewardCard({
    required this.canClaim,
    required this.streakDays,
    required this.onClaim,
  });

  final bool canClaim;
  final int streakDays;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return TTCard(
      gradient: AppGradients.bubbleYellow,
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 48)),
          Text(
            'Daily Treasure',
            style: context.textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
            ),
          ),
          if (streakDays > 0)
            Text(
              '$streakDays day streak! 🔥',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TTButton(
            label: canClaim ? 'Open Chest!' : 'Come back tomorrow!',
            enabled: canClaim,
            onPressed: onClaim,
          ),
        ],
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  const _RewardStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.sunYellow, size: 28),
        Text('$value', style: context.textTheme.headlineSmall),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

const _defaultAchievements = [
  Achievement(
    id: 'first_game',
    title: 'First Steps',
    description: 'Complete your first game',
    emoji: '🌟',
  ),
  Achievement(
    id: 'combo_5',
    title: 'Combo Star',
    description: 'Get a 5 combo',
    emoji: '⚡',
  ),
  Achievement(
    id: 'perfect_game',
    title: 'Perfect!',
    description: 'Complete a game with no mistakes',
    emoji: '🏆',
  ),
];
