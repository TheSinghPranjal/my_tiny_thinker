import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

class LearnToSortFoodSetupScreen extends ConsumerWidget {
  const LearnToSortFoodSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🥗🍎🍔',
          emojiSize: 72,
          title: 'Learn to Sort Food',
          subtitle:
              'Catch the floating foods and drop them in the right basket!',
          skills: kFoodSortSkills,
          skillChipColor: const Color(0xFFA5D6A7).withValues(alpha: 0.45),
          titleColor: const Color(0xFF2E7D32),
          subtitleColor: const Color(0xFF1B5E20),
          titleShadows: const [
            Shadow(color: Colors.white, blurRadius: 8),
          ],
          onPlay: () => pushGameGuarded(
            context,
            ref,
            GameId.learnToSortFood,
            AppRoutes.learnToSortFoodGame,
          ),
        ),
      );
  }
}
