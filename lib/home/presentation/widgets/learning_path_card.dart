import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/home/presentation/widgets/home_illustrations.dart';
import 'package:my_tiny_thinker/core/game_config/game_catalog.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_provider.dart';
import 'package:my_tiny_thinker/core/premium/premium_provider.dart';
import 'package:my_tiny_thinker/core/providers/onboarding_provider.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';

class LearningPathCard extends ConsumerWidget {
  const LearningPathCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final age = ref.watch(onboardingProvider.select((s) => s.ageGroup));
    final category = LearningCategory.fromAgeGroup(age);
    ref.watch(learningPathPrefsProvider);
    final queue =
        ref.read(learningPathSessionProvider.notifier).buildQueue(category);

    final canStart = isPremium && queue.isNotEmpty;

    void start() {
      final ok = ref.read(learningPathSessionProvider.notifier).start(category);
      if (!ok) return;
      final first = ref.read(learningPathSessionProvider).currentGame;
      if (first == null) return;
      navigateToGameGuarded(context, ref, first);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7FA4F2), Color(0xFFC08AF0), Color(0xFFFFB79A)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A5BD8).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Stack(
          children: [
            // Soft glow behind the illustration.
            Positioned(
              right: -30,
              bottom: -10,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(right: 6, bottom: 10, child: HomeBooks(size: 150)),
            if (!isPremium)
              const Positioned(top: 12, right: 14, child: _PremiumBadge()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const HomeSprout(size: 48),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Learning Path',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'TinyThink can guide your child through selected '
                    '${category.label} games automatically — no need to return '
                    'home after each game.',
                    style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.96),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          queue.isEmpty
                              ? 'Enable games in Parent Controls to start.'
                              : '${queue.length} games ready in this path',
                          style: GoogleFonts.baloo2(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FractionallySizedBox(
                    widthFactor: 0.72,
                    child: GestureDetector(
                      onTap: canStart ? start : null,
                      child: Opacity(
                        opacity: canStart ? 1.0 : 0.92,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFE27A), Color(0xFFFFC53D)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE59A00).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Start Learning Path',
                                    style: GoogleFonts.baloo2(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF14224D),
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF14224D), size: 26),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FractionallySizedBox(
                    widthFactor: 0.72,
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.parentZone),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B3FA8).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Choose games in Parent Controls',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
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

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6A3FB0).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFFFCA28)),
          const SizedBox(width: 4),
          Text(
            'Premium coming soon',
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
