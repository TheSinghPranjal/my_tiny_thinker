import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/presentation/widgets/party_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class HungryTeddySetupScreen extends ConsumerWidget {
  const HungryTeddySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PartyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🧸🧁',
          emojiSize: 72,
          title: 'Hungry Teddy Cupcake Party',
          subtitle: 'Drag cupcakes to feed the hungry teddy!',
          skills: kHungryTeddySkills,
          skillChipColor: const Color(0xFFF48FB1).withValues(alpha: 0.35),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [Shadow(color: Color(0xFFAB47BC), blurRadius: 6)],
          onPlay: () => pushGameGuarded(context, ref, GameId.hungryTeddyCupcakeParty, AppRoutes.hungryTeddyGame),
        ),
      ),
    );
  }
}
