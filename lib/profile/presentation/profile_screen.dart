import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/models/kid_profiles.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "What's your name?",
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w800, color: const Color(0xFF14224D)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 14,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Type a name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(profileProvider.notifier).renameActive(name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final profiles = notifier.allProfiles;
    final activeId = notifier.activeProfileId;
    final active = KidProfilePresets.byId(activeId);

    return AnimatedSkyBackground(
      child: SafeArea(
        child: ResponsivePadding(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                // Big avatar for the active profile.
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFFFD75A), width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(active.emoji, style: const TextStyle(fontSize: 62, height: 1.1)),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () => _editName(context, ref, profile.displayName),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.baloo2(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            shadows: const [
                              Shadow(color: Color(0x88296AA8), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF3F86F5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Profile switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < KidProfilePresets.all.length; i++)
                      _ProfileChip(
                        emoji: KidProfilePresets.all[i].emoji,
                        name: profiles[i].displayName,
                        selected: KidProfilePresets.all[i].id == activeId,
                        onTap: () => notifier.switchProfile(KidProfilePresets.all[i].id),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TTCard(
                  gradient: AppGradients.welcomeCard,
                  child: Column(
                    children: [
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

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.emoji,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 60 : 52,
              height: selected ? 60 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                border: Border.all(
                  color: selected ? const Color(0xFFFFC928) : Colors.white,
                  width: selected ? 4 : 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFC928).withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: TextStyle(fontSize: selected ? 32 : 27, height: 1.1)),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.baloo2(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? const Color(0xFF14224D) : const Color(0xFF3B5A94),
                height: 1.1,
              ),
            ),
          ],
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
