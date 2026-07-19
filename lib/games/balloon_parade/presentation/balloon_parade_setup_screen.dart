import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/balloon_parade/models/balloon_parade_models.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_festival_background.dart';

class BalloonParadeSetupScreen extends ConsumerWidget {
  const BalloonParadeSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BalloonFestivalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🎈',
          emojiSize: 80,
          title: 'Balloon Parade',
          subtitle: 'Tap the balloons and watch them pop!',
          skills: kBalloonParadeSkills,
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF0277BD), blurRadius: 6),
          ],
          playLabel: 'Start Parade!',
          onPlay: () => context.push(AppRoutes.balloonParadeGame),
        ),
      ),
    );
  }
}
