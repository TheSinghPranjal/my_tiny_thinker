import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/playground_background.dart';

class ColorSchoolBagsSetupScreen extends ConsumerWidget {
  const ColorSchoolBagsSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaygroundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🎒📚🌈',
          emojiSize: 72,
          title: 'Color School Bags',
          subtitle: 'Drag each colorful book into the matching backpack!',
          skills: kSortBagsSkills,
          skillChipColor: const Color(0xFF90CAF9).withValues(alpha: 0.4),
          titleColor: const Color(0xFF1565C0),
          subtitleColor: const Color(0xFF0D47A1),
          titleShadows: const [
                      Shadow(color: Colors.white, blurRadius: 8),
                    ],
          onPlay: () => context.push(AppRoutes.colorSchoolBagsGame),
        ),
      ),
    );
  }
}
