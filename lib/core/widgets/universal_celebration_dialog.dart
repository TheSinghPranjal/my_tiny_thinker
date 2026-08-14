import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/rewards/reward_engine.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';

class UniversalCelebrationDialog extends StatelessWidget {
  const UniversalCelebrationDialog({
    super.key,
    required this.summary,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.onPlayAgain,
  });

  final SessionRewardSummary summary;
  final VoidCallback onContinue;
  final String continueLabel;
  final VoidCallback? onPlayAgain;

  static Future<void> show(
    BuildContext context, {
    required SessionRewardSummary summary,
    required VoidCallback onContinue,
    String continueLabel = 'Continue',
    VoidCallback? onPlayAgain,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UniversalCelebrationDialog(
        summary: summary,
        onContinue: onContinue,
        continueLabel: continueLabel,
        onPlayAgain: onPlayAgain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final extra = <CelebrationStat>[
      if (s.isPerfect)
        const CelebrationStat(icon: '🎯', label: 'Session', value: 'Perfect'),
      if (s.isNewBest)
        const CelebrationStat(icon: '🏆', label: 'Record', value: 'New Best'),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: SingleChildScrollView(
        child: GameCelebrationCard(
          title: '${s.gameId.displayName} Celebration!',
          stats: [
            CelebrationStat(
              icon: '⭐',
              label: 'Score',
              value: '${s.totalScore}',
            ),
            CelebrationStat(
              icon: '🪙',
              label: 'Coins',
              value: '+${s.coins + s.bonusCoins}',
            ),
            CelebrationStat(icon: '✨', label: 'XP', value: '+${s.xp}'),
            CelebrationStat(
              icon: '🌟',
              label: 'Happy Stars',
              value: '+${s.stars}',
            ),
            CelebrationStat(
              icon: '🏅',
              label: 'Points',
              value: '+${s.achievementPoints}',
            ),
            ...extra,
          ],
          playAgainLabel: onPlayAgain != null ? 'Play Again!' : continueLabel,
          homeLabel: continueLabel,
          showHomeButton: onPlayAgain != null,
          onPlayAgain: () {
            Navigator.of(context).pop();
            if (onPlayAgain != null) {
              onPlayAgain!();
            } else {
              onContinue();
            }
          },
          onHome: () {
            Navigator.of(context).pop();
            onContinue();
          },
        ),
      ),
    );
  }
}
