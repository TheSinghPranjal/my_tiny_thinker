import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/presentation/widgets/jungle_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class HungryMonkeySetupScreen extends ConsumerWidget {
  const HungryMonkeySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JungleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐵🍌',
          emojiSize: 72,
          title: 'Hungry Monkey Banana Adventure',
          subtitle: 'Tap the bananas and feed the happy monkey!',
          skills: kHungryMonkeySkills,
          skillChipColor: const Color(0xFF81C784).withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF33691E), blurRadius: 6),
                    ],
          onPlay: () => context.push(AppRoutes.hungryMonkeyGame),
        ),
      ),
    );
  }
}
