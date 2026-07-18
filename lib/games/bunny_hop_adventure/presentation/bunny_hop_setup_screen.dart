import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/presentation/widgets/river_background.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class BunnyHopSetupScreen extends ConsumerWidget {
  const BunnyHopSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RiverBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🐰🥕',
          emojiSize: 72,
          title: 'Bunny Hop Adventure',
          subtitle: 'Tap to help the bunny hop across the river!',
          skills: kBunnyHopSkills,
          skillChipColor: const Color(0xFFA5D6A7).withValues(alpha: 0.4),
          titleColor: AppColors.white,
          subtitleColor: AppColors.white.withValues(alpha: 0.95),
          titleShadows: const [Shadow(color: Color(0xFF43A047), blurRadius: 6)],
          onPlay: () => context.push(AppRoutes.bunnyHopGame),
        ),
      ),
    );
  }
}
