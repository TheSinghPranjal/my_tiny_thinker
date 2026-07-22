import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/models/classic_card_memory_models.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/presentation/widgets/classic_memory_background.dart';
import 'package:my_tiny_thinker/games/classic_card_memory/repository/classic_card_memory_settings_repository.dart';

class ClassicCardMemorySetupScreen extends ConsumerWidget {
  const ClassicCardMemorySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(classicCardMemorySettingsProvider);

    return ClassicMemoryPlaygroundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🃏🧠',
          emojiSize: 80,
          title: 'Classic Card Memory',
          subtitle:
              'Flip cards and find matching pairs!\n${settings.pairCount} pairs · keep going until time is up',
          skills: kClassicMemorySkills,
          skillChipColor: AppColors.softPurple,
          titleColor: const Color(0xFF4527A0),
          subtitleColor: const Color(0xFF5E35B1),
          titleShadows: const [
            Shadow(color: Colors.white, blurRadius: 8),
          ],
          playLabel: 'Play!',
          onPlay: () => pushGameGuarded(context, ref, GameId.classicCardMemory, AppRoutes.classicCardMemoryGame),
        ),
      ),
    );
  }
}
