import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/responsive_layout.dart';
import 'package:my_tiny_thinker/core/widgets/tiny_think_title.dart';
import 'package:my_tiny_thinker/home/presentation/widgets/game_selection_grid.dart';
import 'package:my_tiny_thinker/home/presentation/widgets/learning_path_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playHomeMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final onboarding = ref.watch(onboardingProvider);
    final ageGroup = onboarding.ageGroup;
    final enabledIds = enabledGameIdsForAge(ageGroup);
    final avatarEmoji = kAvatars
        .firstWhere(
          (a) => a.$1 == onboarding.avatarId,
          orElse: () => kAvatars.first,
        )
        .$2;

    return AnimatedSkyBackground(
      landscapeAsset: 'assets/images/home_landscape.png',
      showGrass: false,
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
                    const SizedBox(height: AppSpacing.md),
                    _WelcomeCard(
                      ageGroup: ageGroup,
                      avatarEmoji: avatarEmoji,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const LearningPathCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Choose a Game',
                            style: GoogleFonts.baloo2(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF15245A),
                              height: 1.1,
                            ),
                          ),
                        ),
                        _ViewAllButton(onTap: () => context.go(AppRoutes.games)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsivePadding(
                child: GameSelectionGrid(
                  enabledGameIds: enabledIds,
                  largeLayout: useLargeLayoutForAge(ageGroup),
                  showComingSoon: ageGroup != AgeGroup.smartExplorers &&
                      ageGroup != AgeGroup.brainMasters &&
                      ageGroup != AgeGroup.youngGeniuses,
                  onGameTap: (gameId) =>
                      navigateToGameGuarded(context, ref, gameId),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: TinyThinkTitle(fontSize: 46, showTagline: true),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatPill(
                  leading: const _CoinIcon(),
                  value: coins,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  leading: const Icon(
                    Icons.star_rounded,
                    size: 22,
                    color: Color(0xFFFF9A1F),
                  ),
                  value: stars,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconButton(
                  icon: soundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  onTap: onSettings,
                ),
                const SizedBox(width: 6),
                _IconButton(
                  icon: Icons.emoji_events_rounded,
                  onTap: onAchievements,
                ),
                const SizedBox(width: 6),
                _IconButton(
                  icon: Icons.lock_rounded,
                  onTap: onParentZone,
                ),
                const SizedBox(width: 6),
                _IconButton(
                  icon: Icons.settings_rounded,
                  onTap: onSettings,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CoinIcon extends StatelessWidget {
  const _CoinIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE066), Color(0xFFFFB300)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        r'$',
        style: GoogleFonts.baloo2(
          fontSize: 14,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE08A00),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.leading, required this.value});

  final Widget leading;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B9BE8).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            '$value',
            style: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF15245A),
              height: 1.0,
            ),
          ),
        ],
      ),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5FF).withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9BE8).withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 21, color: const Color(0xFF2F86E6)),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9BE8).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View All',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF15245A),
                height: 1.1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF15245A)),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.ageGroup,
    required this.avatarEmoji,
  });

  final AgeGroup ageGroup;
  final String avatarEmoji;

  String get _greeting => switch (ageGroup) {
        AgeGroup.littleExplorers => 'Hi little friend!',
        AgeGroup.tinyLearners => 'Hello buddy!',
        AgeGroup.smartExplorers => 'Hello Explorer!',
        AgeGroup.brainMasters => 'Ready to think?',
        AgeGroup.youngGeniuses => 'Brain time!',
      };

  String get _subtitle => switch (ageGroup) {
        AgeGroup.littleExplorers => 'Tap and play — no rush!',
        AgeGroup.tinyLearners => 'Fun games just for you!',
        AgeGroup.smartExplorers => 'Ready to play today?',
        AgeGroup.brainMasters => 'Challenge your brain!',
        AgeGroup.youngGeniuses => 'Level up your skills!',
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B9BE8).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card artwork (cream sky, leaves and the waving bunny). It is
                // anchored to the right so the bunny is never cropped.
                Image.asset(
                  'assets/images/hello_buddy_card.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 158, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _greeting,
                          style: GoogleFonts.baloo2(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF14224D),
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF66738F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5EDFB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ageGroup.emoji, style: const TextStyle(fontSize: 17)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                ageGroup.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.baloo2(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF14224D),
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF14224D)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Speech bubble sticking out of the top-right corner.
        Positioned(
          top: -12,
          right: -6,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEB0),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "Let's\nLearn ♥\nTogether!",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 12,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3B2A14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
