import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/animated_sky_background.dart';
import 'package:my_tiny_thinker/core/widgets/game_setup_scaffold.dart';
import 'package:my_tiny_thinker/games/ascending_descending/controllers/bubble_game_controller.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';
import 'package:my_tiny_thinker/games/ascending_descending/repository/bubble_pop_settings_repository.dart';

class BubbleGameSetupScreen extends ConsumerWidget {
  const BubbleGameSetupScreen({super.key, required this.gameId});

  final GameId gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = _metaFor(gameId);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedSkyBackground(
        showElements: true,
        showGrass: gameId == GameId.bubbleNumberPop,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GameSetupScaffold(
            emoji: meta.emoji,
            emojiSize: 80,
            title: meta.title,
            subtitle: meta.subtitle,
            titleColor: AppColors.white,
            subtitleColor: AppColors.white,
            titleShadows: const [
              Shadow(color: AppColors.skyBlueDark, blurRadius: 6),
            ],
            playLabel: 'Play!',
            onPlay: () {
              ref
                  .read(bubbleGameControllerProvider.notifier)
                  .updateConfig(_configFor(ref, gameId));
              context.push(_playRouteFor(gameId));
            },
          ),
        ),
      ),
    );
  }

  BubbleGameConfig _configFor(WidgetRef ref, GameId id) {
    return switch (id) {
      GameId.bubbleNumberPop => BubbleGameConfig.littleExplorers(
          timerSeconds: ref.read(bubbleNumberPopSettingsProvider).sessionSeconds,
        ),
      GameId.ascendingBubbleNumberPop => () {
          final s = ref.read(ascendingBubblePopSettingsProvider);
          return BubbleGameConfig.ascending(
            timerSeconds: s.sessionSeconds,
            minValue: s.minValue,
            maxValue: s.maxValue,
            bubbleCount: s.bubbleCount,
            randomNumbers: s.randomNumbers,
          );
        }(),
      GameId.descendingNumberPop => () {
          final s = ref.read(descendingNumberPopSettingsProvider);
          return BubbleGameConfig.descending(
            timerSeconds: s.sessionSeconds,
            minValue: s.minValue,
            maxValue: s.maxValue,
            bubbleCount: s.bubbleCount,
            randomNumbers: s.randomNumbers,
          );
        }(),
      GameId.numberWordPop => () {
          final s = ref.read(numberWordPopSettingsProvider);
          return BubbleGameConfig.numberWord(
            timerSeconds: s.sessionSeconds,
            minValue: s.minValue,
            maxValue: s.maxValue,
            bubbleCount: s.bubbleCount,
            randomNumbers: s.randomNumbers,
          );
        }(),
      _ => const BubbleGameConfig(),
    };
  }

  String _playRouteFor(GameId id) => switch (id) {
        GameId.bubbleNumberPop => AppRoutes.bubbleGame,
        GameId.ascendingBubbleNumberPop => AppRoutes.ascendingBubbleGame,
        GameId.descendingNumberPop => AppRoutes.descendingBubbleGame,
        GameId.numberWordPop => AppRoutes.numberWordPopGame,
        _ => AppRoutes.bubbleGame,
      };

  ({String emoji, String title, String subtitle}) _metaFor(GameId id) {
    return switch (id) {
      GameId.bubbleNumberPop => (
          emoji: '🫧🔢',
          title: 'Bubble Number Pop',
          subtitle: 'Tap the number you see!',
        ),
      GameId.ascendingBubbleNumberPop => (
          emoji: '🔵↑',
          title: 'Ascending Bubble Number Pop',
          subtitle: 'Pop numbers from smallest to biggest!',
        ),
      GameId.descendingNumberPop => (
          emoji: '🔻↓',
          title: 'Descending Number Pop',
          subtitle: 'Pop numbers from biggest to smallest!',
        ),
      GameId.numberWordPop => (
          emoji: '🔤🫧',
          title: 'Number Word Pop',
          subtitle: 'Read the word and pop that number!',
        ),
      _ => (
          emoji: '🔵',
          title: 'Bubble Pop',
          subtitle: 'Pop the bubbles!',
        ),
    };
  }
}
