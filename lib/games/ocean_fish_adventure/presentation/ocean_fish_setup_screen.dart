import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/presentation/widgets/ocean_background.dart';

class OceanFishSetupScreen extends ConsumerWidget {
  const OceanFishSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐠',
          emojiSize: 80,
          title: 'Ocean Fish Adventure',
          subtitle: 'Tap the fish and watch them swim!',
          skills: const [],

          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [
                      Shadow(color: Color(0xFF01579B), blurRadius: 6),
                    ],
          playLabel: 'Dive In!',
          onPlay: () => pushGameGuarded(context, ref, GameId.oceanFishAdventure, AppRoutes.oceanFishGame),
        ),
      ),
    );
  }
}
