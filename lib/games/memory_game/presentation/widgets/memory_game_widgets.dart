import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/core/widgets/tt_card.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';

class MemoryMiniGameCard extends StatelessWidget {
  const MemoryMiniGameCard({
    super.key,
    required this.gameType,
    required this.stats,
    required this.onPlay,
    this.onUnlock,
    this.isLocked = false,
  });

  final MemoryMiniGameType gameType;
  final MiniGameStats stats;
  final VoidCallback onPlay;
  final VoidCallback? onUnlock;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.gameCardColors[
        MemoryMiniGameType.values.indexOf(gameType) %
            AppColors.gameCardColors.length];

    return TTCard(
      onTap: isLocked ? onUnlock : onPlay,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.85),
          color,
          Color.lerp(color, AppColors.white, 0.25)!,
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          if (isLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, size: 18),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FloatingAnimation(
                    child: Text(gameType.emoji, style: const TextStyle(fontSize: 36)),
                  ),
                  const Spacer(),
                  if (stats.starsEarned > 0)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.sunYellow, size: 16),
                        Text(
                          '${stats.starsEarned}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Spacer(),
              Text(
                gameType.displayName,
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                isLocked
                    ? 'Unlock: ${gameType.unlockCost} coins'
                    : 'Best: ${stats.bestScore}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLocked ? Icons.lock_open_rounded : Icons.play_arrow_rounded,
                      color: color,
                      size: 18,
                    ),
                    Text(
                      isLocked ? 'Unlock' : 'Play',
                      style: context.textTheme.labelMedium?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MemoryCardWidget extends StatefulWidget {
  const MemoryCardWidget({
    super.key,
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
    this.isWrong = false,
  });

  final String emoji;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;
  final bool isWrong;

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    if (widget.isFlipped) _flipController.value = 1;
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, _) {
          final angle = _flipAnimation.value * math.pi;
          final isFront = angle < math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                gradient: isFront
                    ? AppGradients.bubblePurple
                    : AppGradients.welcomeCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: widget.isWrong
                    ? Border.all(color: AppColors.error, width: 3)
                    : widget.isMatched
                        ? Border.all(color: AppColors.mintGreen, width: 2)
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lavender.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isFront
                    ? const Icon(Icons.question_mark_rounded,
                        color: AppColors.white, size: 28)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SequenceTile extends StatelessWidget {
  const SequenceTile({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.8),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : null,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
        child: Center(
          child: emoji != null
              ? Text(emoji!, style: const TextStyle(fontSize: 28))
              : Text(
                  label[0],
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
        ),
      ),
    );
  }
}
