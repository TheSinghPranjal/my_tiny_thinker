import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/presentation/widgets/space_background.dart';

class MoonRescueSetupScreen extends ConsumerWidget {
  const MoonRescueSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🚀🌙🌍',
          emojiSize: 72,
          title: 'Moon Rescue Adventure',
          subtitle: 'Flick astronauts to the Moon and fill the rocket for liftoff!',
          skills: kMoonRescueSkills,
          skillChipColor: const Color(0xFFB39DDB),
          titleColor: Colors.white,
          subtitleColor: const Color(0xFFE1BEE7),
          titleShadows: const [
                      Shadow(color: Color(0xFF311B92), blurRadius: 8),
                    ],
          onPlay: () => context.push(AppRoutes.moonRescueGame),
        ),
      ),
    );
  }
}
