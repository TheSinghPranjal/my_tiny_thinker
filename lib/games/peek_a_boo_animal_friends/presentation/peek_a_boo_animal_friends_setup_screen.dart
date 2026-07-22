import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/presentation/widgets/peek_a_boo_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class PeekABooSetupScreen extends ConsumerWidget {
  const PeekABooSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PeekABooBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐾🌿',
          emojiSize: 72,
          title: 'Peek-a-Boo Animal Friends',
          subtitle: 'Tap the bushes and find the hidden animals!',
          skills: kPeekABooSkills,
          skillChipColor: AppColors.skyBlue.withValues(alpha: 0.25),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF1565C0), blurRadius: 6),
                    ],
          onPlay: () => pushGameGuarded(context, ref, GameId.peekABooAnimalFriends, AppRoutes.peekABooGame),
        ),
      ),
    );
  }
}
