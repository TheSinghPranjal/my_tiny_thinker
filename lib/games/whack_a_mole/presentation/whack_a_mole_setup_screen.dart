import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

class WhackAMoleSetupScreen extends ConsumerWidget {
  const WhackAMoleSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔨🐹',
          emojiSize: 72,
          title: 'Whack-a-Mole',
          subtitle: 'Tap the friendly moles as they pop up in the meadow!',
          skills: kWhackAMoleSkills,
          skillChipColor: AppColors.grassGreen.withValues(alpha: 0.3),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
            Shadow(color: Color(0xFF1B5E20), blurRadius: 6),
          ],
          onPlay: () => pushGameGuarded(
            context,
            ref,
            GameId.whackAMole,
            AppRoutes.whackAMoleGame,
          ),
        ),
      );
  }
}
