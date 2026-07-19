import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/pattern_match/models/pattern_match_models.dart';

class PatternMatchSetupScreen extends ConsumerWidget {
  const PatternMatchSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🧩🔢✨',
          emojiSize: 72,
          title: 'Pattern Match',
          subtitle: 'Look at the pattern and pick what comes next!',
          skills: kPatternMatchSkills,
          skillChipColor: AppColors.lavender.withValues(alpha: 0.25),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF5E35B1), blurRadius: 6),
          ],
          onPlay: () => context.push(AppRoutes.patternMatchGame),
        ),
      ),
    );
  }
}
