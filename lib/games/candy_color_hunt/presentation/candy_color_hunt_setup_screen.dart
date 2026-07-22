import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_world_background.dart';

class CandyColorHuntSetupScreen extends ConsumerWidget {
  const CandyColorHuntSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyWorldBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐜🍬🌈',
          emojiSize: 72,
          title: 'Candy Color Hunt',
          subtitle: 'Help the hungry ant find candies of the right color!',
          skills: kCandyHuntSkills,
          skillChipColor: const Color(0xFFFFCC80).withValues(alpha: 0.45),
          titleColor: const Color(0xFFE65100),
          subtitleColor: const Color(0xFFBF360C),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => pushGameGuarded(context, ref, GameId.candyColorHunt, AppRoutes.candyColorHuntGame),
        ),
      ),
    );
  }
}
