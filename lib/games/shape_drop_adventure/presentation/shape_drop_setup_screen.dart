import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/widgets/classroom_background.dart';

class ShapeDropSetupScreen extends ConsumerWidget {
  const ShapeDropSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClassroomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔷⭐🌈',
          emojiSize: 72,
          title: 'Shape Drop Adventure',
          subtitle: 'Drag the matching shape into the dotted outline!',
          skills: kShapeDropSkills,
          skillChipColor: AppColors.lavender.withValues(alpha: 0.25),
          titleColor: const Color(0xFF6A1B9A),
          subtitleColor: const Color(0xFF4527A0),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => pushGameGuarded(context, ref, GameId.shapeDropAdventure, AppRoutes.shapeDropGame),
        ),
      ),
    );
  }
}
