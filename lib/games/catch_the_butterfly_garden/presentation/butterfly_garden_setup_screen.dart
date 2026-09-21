import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

class ButterflyGardenSetupScreen extends ConsumerWidget {
  const ButterflyGardenSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🦋🌸',
          emojiSize: 72,
          title: 'Catch the Butterfly Garden',
          subtitle: 'Tap the butterflies and fill your basket!',
          skills: kButterflyGardenSkills,
          skillChipColor: const Color(0xFFCE93D8).withValues(alpha: 0.35),
          titleColor: const Color(0xFF7B1FA2),
          subtitleColor: const Color(0xFF4A148C),
          onPlay: () => pushGameGuarded(context, ref, GameId.catchTheButterflyGarden, AppRoutes.butterflyGardenGame),
        ),
      );
  }
}
