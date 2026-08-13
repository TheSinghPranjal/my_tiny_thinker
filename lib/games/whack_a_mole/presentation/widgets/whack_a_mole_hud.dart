import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';
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

    return Container(
      color: const Color(0xFF2E7D32).withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎈🐹🌈✨', style: TextStyle(fontSize: 48)),
                const MascotWidget(size: 96, waving: true),
                Text(
                  result.encouragement,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      _Row('🐹 Moles Tapped', '${result.molesTapped}'),
                      _Row('🪙 Coins Earned', '+${result.coins}'),
                      _Row('⭐ Stars Collected', '+${result.stars}'),
                      _Row('✨ Experience Points', '+${result.xp}'),
                      _Row('🏅 Reward Points', '+${result.rewardPoints}'),
                      _Row('🔥 Highest Tap Streak', '${result.longestStreak}'),
                      _Row('⚡ Fastest Reaction', reaction),
                      _Row('🎯 Accuracy', '$accuracyPct%'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TTButton(
                  label: 'Play Again!',
                  expanded: true,
                  size: TTButtonSize.large,
                  onPressed: onPlayAgain,
                ),
                const SizedBox(height: AppSpacing.sm),
                TTButton(
                  label: 'Home',
                  variant: TTButtonVariant.ghost,
                  expanded: true,
                  onPressed: onHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(color: AppColors.white),
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(color: AppColors.sunYellow),
          ),
        ],
      ),
    );
  }
}
