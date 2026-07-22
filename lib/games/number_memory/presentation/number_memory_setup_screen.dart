import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';
import 'package:my_tiny_thinker/games/number_memory/presentation/widgets/number_memory_background.dart';
import 'package:my_tiny_thinker/games/number_memory/repository/number_memory_settings_repository.dart';

class NumberMemorySetupScreen extends ConsumerWidget {
  const NumberMemorySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(numberMemorySettingsProvider);

    return NumberMemoryBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🔢🧠',
          emojiSize: 80,
          title: 'Number Memory',
          subtitle:
              'Remember the number, then type it back!\n'
              '${settings.digitCount} digits · keep going until time is up',
          skills: kNumberMemorySkills,
          skillChipColor: AppColors.softPurple,
          titleColor: const Color(0xFF4527A0),
          subtitleColor: const Color(0xFF5E35B1),
          titleShadows: const [
            Shadow(color: Colors.white, blurRadius: 8),
          ],
          playLabel: 'Play!',
          onPlay: () => context.push(AppRoutes.numberMemoryGame),
        ),
      ),
    );
  }
}
