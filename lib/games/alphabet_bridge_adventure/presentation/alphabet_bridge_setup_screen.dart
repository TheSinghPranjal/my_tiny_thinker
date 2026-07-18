import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_garden_background.dart';

class AlphabetBridgeSetupScreen extends ConsumerWidget {
  const AlphabetBridgeSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlphabetGardenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔤🌉🌈',
          emojiSize: 72,
          title: 'Alphabet Bridge Adventure',
          subtitle: 'Draw a colorful line from little letters to big letters!',
          skills: kAlphabetBridgeSkills,
          skillChipColor: const Color(0xFFCE93D8),
          titleColor: const Color(0xFF5E35B1),
          subtitleColor: const Color(0xFF4527A0),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => context.push(AppRoutes.alphabetBridgeGame),
        ),
      ),
    );
  }
}
