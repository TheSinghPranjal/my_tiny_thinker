import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return AnimatedSkyBackground(
      child: SafeArea(
        child: ResponsivePadding(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const MascotWidget(size: 100, waving: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile.displayName,
                  style: context.textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TTCard(
                  gradient: AppGradients.welcomeCard,
                  child: Column(
                    children: [
                      TTXPBar(
                        currentXp: profile.xp,
                        xpForLevel: profile.xpForNextLevel,
                        level: profile.level,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.monetization_on_rounded,
                            label: 'Coins',
                            value: '${profile.coins}',
                            color: AppColors.sunYellow,
                          ),
                          _StatItem(
                            icon: Icons.star_rounded,
                            label: 'Stars',
                            value: '${profile.stars}',
                            color: AppColors.orange,
                          ),
                          _StatItem(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Streak',
                            value: '${profile.dailyStreak}',
                            color: AppColors.candyPink,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: context.textTheme.headlineSmall),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}
