import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

class CatchTheFallingStarsSetupScreen extends ConsumerWidget {
  const CatchTheFallingStarsSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '⭐🌙',
          emojiSize: 72,
          title: 'Catch the Falling Stars',
          subtitle:
              'Tap smiling stars in the magical night sky — collect, sparkle, and shine!',
          skills: kCatchStarsSkills,
          skillChipColor: const Color(0xFF5C6BC0).withValues(alpha: 0.45),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF0D1B4C), blurRadius: 8),
          ],
          onPlay: () => pushGameGuarded(
            context,
            ref,
            GameId.catchTheFallingStars,
            AppRoutes.catchTheFallingStarsGame,
          ),
        ),
      );
  }
}
