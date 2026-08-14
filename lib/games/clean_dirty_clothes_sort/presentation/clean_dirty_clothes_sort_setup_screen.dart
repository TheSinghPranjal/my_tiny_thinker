import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

class CleanDirtyClothesSortSetupScreen extends ConsumerWidget {
  const CleanDirtyClothesSortSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '👕🧺',
          emojiSize: 72,
          title: 'Clean & Dirty Clothes Sort',
          subtitle: 'Sort clothes into the washer or cupboard!',
          skills: kLaundrySortSkills,
          skillChipColor: const Color(0xFFB3E5FC).withValues(alpha: 0.5),
          titleColor: const Color(0xFF1565C0),
          subtitleColor: const Color(0xFF0D47A1),
          titleShadows: const [
            Shadow(color: Colors.white, blurRadius: 8),
          ],
          onPlay: () => pushGameGuarded(
            context,
            ref,
            GameId.cleanDirtyClothesSort,
            AppRoutes.cleanDirtyClothesSortGame,
          ),
        ),
      );
  }
}
