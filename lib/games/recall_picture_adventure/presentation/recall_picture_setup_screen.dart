import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/presentation/widgets/recall_picture_background.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/repository/recall_picture_settings_repository.dart';

class RecallPictureSetupScreen extends ConsumerWidget {
  const RecallPictureSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(recallPictureSettingsProvider);
    final mins = (settings.sessionSeconds / 60).round();

    return RecallPictureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GameSetupScaffold(
          emoji: '🖼️🎈',
          emojiSize: 80,
          title: 'Recall Picture Adventure',
          subtitle:
              'Look at the picture, then answer!\n'
              '$mins min · keep going until time is up',
          skills: kRecallPictureSkills,
          skillChipColor: AppColors.softPurple,
          titleColor: const Color(0xFF4527A0),
          subtitleColor: const Color(0xFF5E35B1),
          titleShadows: const [
            Shadow(color: Colors.white, blurRadius: 8),
          ],
          playLabel: 'Play!',
          onPlay: () => context.push(AppRoutes.recallPictureGame),
        ),
      ),
    );
  }
}
