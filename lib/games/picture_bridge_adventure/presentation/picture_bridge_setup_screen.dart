import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';

class PictureBridgeSetupScreen extends StatelessWidget {
  const PictureBridgeSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlphabetGardenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🖼️🌉🌈',
          emojiSize: 72,
          title: 'Picture Bridge Adventure',
          subtitle: 'Draw a line from pictures to their words!',
          skills: kPictureBridgeSkills,
          skillChipColor: const Color(0xFFCE93D8),
          titleColor: const Color(0xFF5E35B1),
          subtitleColor: const Color(0xFF4527A0),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => context.push(AppRoutes.pictureBridgeGame),
        ),
      ),
    );
  }
}
