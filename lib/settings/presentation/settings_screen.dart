import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/settings/presentation/settings_art.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/widgets/tt_dialog.dart';

const _navy = Color(0xFF14224D);
const _greyBlue = Color(0xFF5F7290);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final isPremium = ref.watch(isPremiumProvider);

    return SettingsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, AppSpacing.lg),
            children: [
              _Header(
                onBack: () {
                  // Returning to shell / home — restore home music if not in a game.
                  final audio = ref.read(audioServiceProvider);
                  if (!audio.inGameplay) {
                    audio.playHomeMusic();
                  }
                  context.pop();
                },
              ),
              const SizedBox(height: 14),
              _PremiumCard(
                isPremium: isPremium,
                onTap: () => context.push(AppRoutes.premium),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                children: [
                  _SettingRow(
                    icon: Icons.music_note_rounded,
                    iconColor: const Color(0xFFEE5C7E),
                    tint: const Color(0xFFFCE6EE),
                    title: 'Music',
                    subtitle: 'Play background music',
                    trailing: _BlueSwitch(
                      value: settings.musicEnabled,
                      onChanged: (_) => settingsNotifier.toggleMusic(),
                    ),
                  ),
                  _SettingRow(
                    icon: Icons.sports_esports_rounded,
                    iconColor: const Color(0xFF7A57E0),
                    tint: const Color(0xFFEDE6FB),
                    title: 'Game sound',
                    subtitle: 'Play sound effects',
                    trailing: _BlueSwitch(
                      value: settings.soundEnabled,
                      onChanged: (_) => settingsNotifier.toggleSound(),
                    ),
                  ),
                  _SettingRow(
                    icon: Icons.lightbulb_rounded,
                    iconColor: const Color(0xFF2FB58A),
                    tint: const Color(0xFFDFF6EC),
                    title: 'Hints',
                    subtitle: 'Show helpful hints during games',
                    trailing: _BlueSwitch(
                      value: settings.hintsEnabled,
                      onChanged: (_) => settingsNotifier.toggleHints(),
                    ),
                  ),
                  // Testing switch: turns Premium on/off so premium features
                  // (Learning Path, parent controls, unlimited play) can be tried.
                  _SettingRow(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFFE59A12),
                    tint: const Color(0xFFFFF0CC),
                    title: 'Premium',
                    subtitle: isPremium ? 'Premium is on' : 'Turn on to unlock premium',
                    trailing: _BlueSwitch(
                      value: isPremium,
                      onChanged: (v) =>
                          ref.read(isPremiumProvider.notifier).setPremium(v),
                    ),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                children: [
                  _SettingRow(
                    icon: Icons.tune_rounded,
                    iconColor: const Color(0xFFF08A1D),
                    tint: const Color(0xFFFFEBD6),
                    title: 'Difficulty',
                    subtitle: settings.difficulty.capitalize,
                    trailing: const Icon(Icons.chevron_right_rounded, size: 30, color: _navy),
                    onTap: () => _showDifficultyPicker(context, ref),
                  ),
                  _SettingRow(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF3F86F5),
                    tint: const Color(0xFFE2EEFD),
                    title: 'Language',
                    subtitle: _languageLabel(settings.languageCode),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 30, color: _navy),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => _confirmReset(context, ref),
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEF6E6E), Color(0xFFE04E52)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD03A3E).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 30),
                      const SizedBox(width: 12),
                      Text(
                        'Reset Progress',
                        style: GoogleFonts.baloo2(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'This will clear all game progress, scores and streaks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _greyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'TinyThink v1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _greyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  static String _languageLabel(String code) => switch (code.toLowerCase()) {
        'en' => 'English (EN)',
        _ => code.toUpperCase(),
      };

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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 4,
            top: 12,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9BE8).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 36, color: _navy),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.baloo2(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize the app for a better\nlearning experience',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: _greyBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.isPremium, required this.onTap});

  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6E0), Color(0xFFFFEBC6)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0A93A).withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: SettingsCrown(size: 62),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TinyThink Premium',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.baloo2(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _navy,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              isPremium ? 'Premium active' : 'Free plan · 5 plays/day',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4A5A80),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFD75A), Color(0xFFF2B32C)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Upgrade',
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF3A2A0A),
                                  height: 1.1,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF3A2A0A)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock unlimited play, parent controls, and Learning Path sessions.',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: _greyBlue,
                    ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B9BE8).withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFE6EDF6), width: 1.2))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.baloo2(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: _greyBlue,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

/// Large blue toggle with a white thumb.
class _BlueSwitch extends StatelessWidget {
  const _BlueSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.15,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF3F86F5),
        activeThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFCBD6E6),
        inactiveThumbColor: Colors.white,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
