import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

class CatchStarsProgressMeter extends StatelessWidget {
  const CatchStarsProgressMeter({
    super.key,
    required this.progress,
    required this.constellationEmoji,
    required this.pieces,
  });

  final double progress;
  final String constellationEmoji;
  final int pieces;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$constellationEmoji $pieces/5',
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

class CatchStarsVictoryOverlay extends StatelessWidget {
  const CatchStarsVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final CatchTheFallingStarsResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Catch the Falling Stars Celebration!',
      stats: [
        CelebrationStat(
          icon: '⭐',
          label: 'Stars Collected',
          value: '${result.starsCollected}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(
          icon: '🏅',
          label: 'TinyThink Points',
          value: '+${result.rewardPoints}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Highest Streak',
          value: '${result.longestStreak}',
        ),
        CelebrationStat(
          icon: '🌌',
          label: 'Longest Constellation',
          value: '${result.longestConstellation}',
        ),
        CelebrationStat(
          icon: '🧩',
          label: 'Constellation Pieces',
          value: '${result.constellationPieces}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
