import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/presentation/widgets/duck_pond_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class HungryDuckSetupScreen extends ConsumerWidget {
  const HungryDuckSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DuckPondBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🦆🐟',
          emojiSize: 72,
          title: 'Hungry Duck Pond Adventure',
          subtitle: 'Tap the fish and feed the hungry duck!',
          skills: kHungryDuckSkills,
          skillChipColor: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [Shadow(color: Color(0xFF0277BD), blurRadius: 6)],
          onPlay: () => pushGameGuarded(context, ref, GameId.hungryDuckPondAdventure, AppRoutes.hungryDuckGame),
        ),
      ),
    );
  }
}
