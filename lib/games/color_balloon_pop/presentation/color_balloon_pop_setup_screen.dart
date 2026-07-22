import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/color_balloon_pop/models/color_balloon_pop_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_festival_background.dart';

class ColorBalloonPopSetupScreen extends ConsumerWidget {
  const ColorBalloonPopSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BalloonFestivalBackground(
      showKites: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🎨',
          emojiSize: 80,
          title: 'Color Balloon Pop',
          subtitle: 'Find and pop the color you hear!',
          skills: kColorBalloonSkills,
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF6A1B9A), blurRadius: 6),
          ],
          playLabel: 'Find Colors!',
          onPlay: () => pushGameGuarded(context, ref, GameId.colorBalloonPop, AppRoutes.colorBalloonPopGame),
        ),
      ),
    );
  }
}
