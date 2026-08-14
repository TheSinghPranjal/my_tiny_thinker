import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

class WhackProgressMeter extends StatelessWidget {
  const WhackProgressMeter({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: Colors.white.withValues(alpha: 0.45),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFCA28)),
            ),
          ),
        ],
      ),
    );
  }
}

class CheerAnimalWidget extends StatelessWidget {
  const CheerAnimalWidget({super.key, required this.cheer});

  final CheerEntity cheer;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (cheer.animal) {
      CheerAnimal.rabbit => '🐰',
      CheerAnimal.bird => '🐦',
      CheerAnimal.squirrel => '🐿️',
      CheerAnimal.hedgehog => '🦔',
      CheerAnimal.butterfly => '🦋',
      CheerAnimal.frog => '🐸',
    };
    final slide = cheer.side
        ? (1 - _ease(cheer.progress)) * 80
        : -(1 - _ease(cheer.progress)) * 80;
    final bounce = math.sin(cheer.progress * math.pi * 4) * 6;
    final opacity = cheer.progress < 0.15
        ? cheer.progress / 0.15
        : cheer.progress > 0.85
        ? (1 - cheer.progress) / 0.15
        : 1.0;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(slide, bounce),
        child: Text(emoji, style: const TextStyle(fontSize: 42)),
      ),
    );
  }

  double _ease(double t) => Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
}

class WhackVictoryOverlay extends StatelessWidget {
  const WhackVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final WhackAMoleResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (result.accuracy * 100).round();
    final reaction = result.fastestReactionMs > 0
        ? '${(result.fastestReactionMs / 1000).toStringAsFixed(2)}s'
        : '—';

    return GameCelebrationOverlay(
      title: 'Whack-a-Mole Celebration!',
      stats: [
        CelebrationStat(
          icon: '🐹',
          label: 'Moles Tapped',
          value: '${result.molesTapped}',
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
          label: 'Reward Points',
          value: '+${result.rewardPoints}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Highest Tap Streak',
          value: '${result.longestStreak}',
        ),
        CelebrationStat(icon: '⚡', label: 'Fastest Reaction', value: reaction),
        CelebrationStat(icon: '🎯', label: 'Accuracy', value: '$accuracyPct%'),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
