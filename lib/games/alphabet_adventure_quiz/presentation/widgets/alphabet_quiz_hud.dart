import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/alphabet_adventure_quiz/models/alphabet_quiz_models.dart';

class AlphabetQuizVictoryOverlay extends StatelessWidget {
  const AlphabetQuizVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final AlphabetQuizResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    return GameCelebrationOverlay(
      title: 'Alphabet Adventure Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '✅',
          label: 'Correct',
          value: '${result.correctAnswers}',
        ),
        CelebrationStat(
          icon: '🔤',
          label: 'Letters',
          value: '${result.lettersCompleted}',
        ),
        CelebrationStat(icon: '🎯', label: 'Accuracy', value: '$accuracyPct%'),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Streak',
          value: '${result.maxStreak}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
