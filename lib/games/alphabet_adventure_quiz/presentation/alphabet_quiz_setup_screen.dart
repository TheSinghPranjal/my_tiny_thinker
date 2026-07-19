import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';

class AlphabetQuizSetupScreen extends ConsumerWidget {
  const AlphabetQuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSkyBackground(
      showGrass: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔤📚',
          emojiSize: 72,
          title: 'Alphabet Adventure Quiz',
          subtitle: 'Find the picture that matches the letter!',
          skills: kAlphabetSkills,
          skillChipColor: AppColors.sunYellow.withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFFE65100), blurRadius: 6),
          ],
          onPlay: () => context.push(AppRoutes.alphabetQuizGame),
        ),
      ),
    );
  }
}
