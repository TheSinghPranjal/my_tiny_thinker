import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';

class ButterflyWebMatchingSetupScreen extends ConsumerWidget {
  const ButterflyWebMatchingSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🦋🕸️',
          emojiSize: 72,
          title: 'Butterfly Web Matching',
          subtitle:
              'Tap a butterfly, then find its matching friend on the magical web!',
          skills: kButterflyWebSkills,
          skillChipColor: const Color(0xFFF8BBD0).withValues(alpha: 0.55),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF1B5E20), blurRadius: 6),
          ],
          onPlay: () => pushGameGuarded(
            context,
            ref,
            GameId.butterflyWebMatching,
            AppRoutes.butterflyWebMatchingGame,
          ),
        ),
      );
  }
}
