import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_tiny_thinker/core/learning_path/learning_path_provider.dart';
import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/core/rewards/reward_engine.dart';
import 'package:my_tiny_thinker/core/routing/app_router.dart';
import 'package:my_tiny_thinker/core/routing/game_navigation.dart';
import 'package:my_tiny_thinker/core/widgets/universal_celebration_dialog.dart';
import 'package:my_tiny_thinker/learning_path/presentation/learning_path_completion_screen.dart';

/// Shared post-game flow: celebration → learning path next game or home.
Future<void> finishGameSession(
  BuildContext context,
  WidgetRef ref, {
  required SessionRewardSummary summary,
  VoidCallback? onPlayAgain,
  int playSeconds = 0,
}) async {
  final path = ref.read(learningPathSessionProvider);
  final inPath = path.active;

  if (inPath) {
    ref.read(learningPathSessionProvider.notifier).recordGameResult(
          reward: summary.asGameReward,
          playSeconds: playSeconds,
          achievements: summary.unlockedAchievements,
        );
  }

  if (!context.mounted) return;

  await UniversalCelebrationDialog.show(
    context,
    summary: summary,
    continueLabel: inPath
        ? (path.hasNext ? 'Next Game' : 'See Journey')
        : 'Continue',
    onPlayAgain: inPath ? null : onPlayAgain,
    onContinue: () {
      if (!context.mounted) return;
      if (!inPath) {
        context.go(AppRoutes.home);
        return;
      }
      final next = ref.read(learningPathSessionProvider.notifier).advance();
      if (next != null) {
        navigateToGame(context, next);
        return;
      }
      final summarySession =
          ref.read(learningPathSessionProvider.notifier).takeSummaryAndEnd();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LearningPathCompletionScreen(summary: summarySession),
        ),
      );
    },
  );
}

/// Convert an existing [GameRewardResult] and finish the session.
Future<void> finishWithGameReward(
  BuildContext context,
  WidgetRef ref, {
  required GameId gameId,
  required GameRewardResult result,
  int totalScore = 0,
  int playSeconds = 0,
  VoidCallback? onPlayAgain,
}) async {
  final summary = await ref.read(rewardEngineProvider).commitGameRewardResult(
        gameId: gameId,
        result: result,
        totalScore: totalScore,
      );
  if (!context.mounted) return;
  await finishGameSession(
    context,
    ref,
    summary: summary,
    playSeconds: playSeconds,
    onPlayAgain: onPlayAgain,
  );
}
