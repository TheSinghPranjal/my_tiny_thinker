import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isPremium = ref.watch(isPremiumProvider);

    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TTCard(
              gradient: isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFFFFE082), Color(0xFFFFCC80)],
                    )
                  : null,
              child: Column(
                children: [
                  // _SettingTile(
                  //   icon: Icons.workspace_premium_rounded,
                  //   title: 'Developer: Premium Mode',
                  //   trailing: Switch(
                  //     value: isPremium,
                  //     activeThumbColor: AppColors.orange,
                  //     onChanged: (v) =>
                  //         ref.read(isPremiumProvider.notifier).setPremium(v),
                  //   ),
                  // ),
                  ListTile(
                    leading: const Icon(Icons.star_rounded, color: AppColors.orange),
                    title: const Text('TinyThink Premium'),
                    subtitle: Text(
                      isPremium ? 'Premium active' : 'Free plan · 5 plays/day',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(AppRoutes.premium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.music_note_rounded,
                    title: 'Music',
                    trailing: Switch(
                      value: settings.musicEnabled,
                      activeThumbColor: AppColors.skyBlue,
                      onChanged: (_) => settingsNotifier.toggleMusic(),
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.sports_esports_rounded,
                    title: 'Game sound',
                    trailing: Switch(
                      value: settings.soundEnabled,
                      activeThumbColor: AppColors.skyBlue,
                      onChanged: (_) => settingsNotifier.toggleSound(),
                    ),
                  ),
                  _SettingTile(
                    icon: Icons.lightbulb_rounded,
                    title: 'Hints',
                    trailing: Switch(
                      value: settings.hintsEnabled,
                      activeThumbColor: AppColors.skyBlue,
                      onChanged: (_) => settingsNotifier.toggleHints(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: const Text('Difficulty'),
                    subtitle: Text(settings.difficulty.capitalize),
                    onTap: () => _showDifficultyPicker(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: const Text('Language'),
                    subtitle: Text(settings.languageCode.toUpperCase()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TTButton(
              label: 'Reset Progress',
              variant: TTButtonVariant.danger,
              expanded: true,
              onPressed: () => _confirmReset(context, ref),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'TinyThink v1.0.0',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['easy', 'medium', 'hard', 'expert']
              .map(
                (d) => ListTile(
                  title: Text(d.capitalize),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setDifficulty(d);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    await TTDialog.show(
      context: context,
      title: 'Reset Progress?',
      emoji: '⚠️',
      message: 'This will erase all your coins, stars, and achievements.',
      primaryLabel: 'Reset',
      secondaryLabel: 'Cancel',
      secondaryAction: () {},
      primaryAction: () => ref.read(profileProvider.notifier).resetProgress(),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.skyBlue),
      title: Text(title),
      trailing: trailing,
    );
  }
}
