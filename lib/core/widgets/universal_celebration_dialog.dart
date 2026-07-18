import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/rewards/reward_engine.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/mascot_widget.dart';
import 'package:my_tiny_thinker/core/widgets/particle_system.dart';
import 'package:my_tiny_thinker/core/widgets/tt_button.dart';

class UniversalCelebrationDialog extends StatefulWidget {
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
  State<UniversalCelebrationDialog> createState() =>
      _UniversalCelebrationDialogState();
}

class _UniversalCelebrationDialogState extends State<UniversalCelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _pop;
  final _particleKey = GlobalKey<ParticleSystemState>();

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _particleKey.currentState?.emit();
    });
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleSystem(
                key: _particleKey,
                particleCount: 48,
                autoStart: false,
              ),
            ),
          ),
          ScaleTransition(
            scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF8E7),
                    Color(0xFFE3F2FD),
                    Color(0xFFF3E5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softPurple.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MascotWidget(size: 72, waving: true),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s.message,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.softPurple,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${s.gameId.emoji} ${s.gameId.displayName}',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _RewardPill(
                        emoji: '🪙',
                        label: 'Coins',
                        value: s.coins + s.bonusCoins,
                        color: AppColors.sunYellow,
                      ),
                      _RewardPill(
                        emoji: '⚡',
                        label: 'XP',
                        value: s.xp,
                        color: AppColors.skyBlue,
                      ),
                      _RewardPill(
                        emoji: '⭐',
                        label: 'Stars',
                        value: s.stars,
                        color: AppColors.orange,
                      ),
                      _RewardPill(
                        emoji: '🏆',
                        label: 'Score',
                        value: s.totalScore,
                        color: AppColors.mintGreen,
                      ),
                      _RewardPill(
                        emoji: '🎯',
                        label: 'Points',
                        value: s.achievementPoints,
                        color: AppColors.softPurple,
                      ),
                    ],
                  ),
                  if (s.isPerfect || s.isNewBest) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      [
                        if (s.isPerfect) 'Perfect session!',
                        if (s.isNewBest) 'New best score!',
                      ].join(' · '),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.grassGreen,
                      ),
                    ),
                  ],
                  if (s.unlockedAchievements.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Unlocked: ${s.unlockedAchievements.join(', ')}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  TTButton(
                    label: widget.continueLabel,
                    expanded: true,
                    size: TTButtonSize.large,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onContinue();
                    },
                  ),
                  if (widget.onPlayAgain != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TTButton(
                      label: 'Play Again',
                      expanded: true,
                      variant: TTButtonVariant.ghost,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onPlayAgain!();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + Random().nextInt(400)),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.scale(scale: t, child: child),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
