import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';

class NumberBridgeSetupScreen extends StatelessWidget {
  const NumberBridgeSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlphabetGardenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔢🌉🌈',
          emojiSize: 72,
          title: 'Number Bridge Adventure',
          subtitle: 'Draw a line from digits to number words!',
          skills: kNumberBridgeSkills,
          skillChipColor: const Color(0xFF81D4FA),
          titleColor: const Color(0xFF0277BD),
          subtitleColor: const Color(0xFF01579B),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => context.push(AppRoutes.numberBridgeGame),
        ),
      ),
    );
  }
}
