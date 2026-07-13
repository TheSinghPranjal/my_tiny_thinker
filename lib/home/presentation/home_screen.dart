import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_badge.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/home/presentation/widgets/game_selection_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);

    return AnimatedSkyBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ResponsivePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      soundEnabled: settings.soundEnabled,
                      onSettings: () => context.push(AppRoutes.settings),
                      onAchievements: () => context.go(AppRoutes.rewards),
                      onParentZone: () => context.push(AppRoutes.parentZone),
                      coins: profile.coins,
                      stars: profile.stars,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _WelcomeCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Choose a Game',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        shadows: const [
                          Shadow(color: AppColors.skyBlueDark, blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsivePadding(
                child: GameSelectionGrid(
                  onGameTap: (gameId) => navigateToGame(context, gameId),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.soundEnabled,
    required this.onSettings,
    required this.onAchievements,
    required this.onParentZone,
    required this.coins,
    required this.stars,
  });

  final bool soundEnabled;
  final VoidCallback onSettings;
  final VoidCallback onAchievements;
  final VoidCallback onParentZone;
  final int coins;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TinyThink',
              style: context.textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                shadows: const [
                  Shadow(color: AppColors.skyBlueDark, blurRadius: 6),
                ],
              ),
            ),
            const MascotWidget(size: 48, waving: true),
          ],
        ),
        const Spacer(),
        TTCurrencyBadge(
          icon: Icons.monetization_on_rounded,
          value: coins,
          color: AppColors.sunYellow,
        ),
        const SizedBox(width: AppSpacing.sm),
        TTCurrencyBadge(
          icon: Icons.star_rounded,
          value: stars,
          color: AppColors.orange,
        ),
        const SizedBox(width: AppSpacing.sm),
        _IconButton(
          icon: soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          onTap: onSettings,
        ),
        _IconButton(
          icon: Icons.emoji_events_rounded,
          onTap: onAchievements,
        ),
        _IconButton(
          icon: Icons.lock_rounded,
          onTap: onParentZone,
        ),
        _IconButton(
          icon: Icons.settings_rounded,
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.skyBlue.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.skyBlueDark),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TTCard(
      gradient: AppGradients.welcomeCard,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Explorer!',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ready to play today?',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const MascotWidget(size: AppSpacing.mascotSize, waving: true),
        ],
      ),
    );
  }
}
