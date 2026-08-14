import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';

class ButterflyWebProgressBar extends StatelessWidget {
  const ButterflyWebProgressBar({
    super.key,
    required this.pairsMatched,
    required this.pairCount,
    required this.gardenBloom,
  });

  final int pairsMatched;
  final int pairCount;
  final double gardenBloom;

  @override
  Widget build(BuildContext context) {
    final boardProgress = pairCount <= 0
        ? 0.0
        : (pairsMatched % pairCount) / pairCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: gardenBloom.clamp(0.0, 1.0),
                minHeight: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFEC407A)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '🦋 $pairsMatched  ·  ${(boardProgress * pairCount).round()}/$pairCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButterflyWebVictoryOverlay extends StatelessWidget {
  const ButterflyWebVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final ButterflyWebMatchingResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Butterfly Web Celebration!',
      stats: [
        CelebrationStat(
          icon: '🦋',
          label: 'Pairs Matched',
          value: '${result.pairsMatched}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '🏅',
          label: 'TinyThink Points',
          value: '+${result.rewardPoints}',
        ),
        CelebrationStat(
          icon: '🌈',
          label: 'Rainbow Tokens',
          value: '+${result.rainbowTokens}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Highest Streak',
          value: '${result.longestStreak}',
        ),
        CelebrationStat(
          icon: '🌺',
          label: 'Boards Cleared',
          value: '${result.boardsCleared}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
