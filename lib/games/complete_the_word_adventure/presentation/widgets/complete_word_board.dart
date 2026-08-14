import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/complete_the_word_adventure/models/complete_word_models.dart';

class WordIllustrationBanner extends StatelessWidget {
  const WordIllustrationBanner({
    super.key,
    required this.emoji,
    this.celebrating = false,
  });

  final String emoji;
  final bool celebrating;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$emoji-$celebrating'),
      tween: Tween(begin: 0.85, end: celebrating ? 1.12 : 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)],
          ),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.softPurple.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 64)),
      ),
    );
  }
}

class WordBlankRow extends StatelessWidget {
  const WordBlankRow({
    super.key,
    required this.filled,
    required this.nextIndex,
  });

  final List<String> filled;
  final int nextIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < filled.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _BlankSlot(
            letter: filled[i],
            isNext: i == nextIndex && filled[i].isEmpty,
          ),
        ],
      ],
    );
  }
}

class _BlankSlot extends StatelessWidget {
  const _BlankSlot({required this.letter, required this.isNext});

  final String letter;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final filled = letter.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 54,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFFE8F5E9)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled
              ? AppColors.mintGreen
              : isNext
              ? AppColors.softPurple
              : Colors.white70,
          width: isNext ? 3.5 : 2.5,
        ),
        boxShadow: [
          if (isNext)
            BoxShadow(
              color: AppColors.softPurple.withValues(alpha: 0.45),
              blurRadius: 12,
            ),
        ],
      ),
      child: filled
          ? TweenAnimationBuilder<double>(
              key: ValueKey(letter),
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4527A0),
                ),
              ),
            )
          : Text(
              '_',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
    );
  }
}

class AlphabetOptionTile extends StatefulWidget {
  const AlphabetOptionTile({
    super.key,
    required this.tile,
    required this.onTap,
    this.isHint = false,
    this.isWrong = false,
  });

  final LetterTile tile;
  final VoidCallback onTap;
  final bool isHint;
  final bool isWrong;

  @override
  State<AlphabetOptionTile> createState() => _AlphabetOptionTileState();
}

class _AlphabetOptionTileState extends State<AlphabetOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobble;

  @override
  void initState() {
    super.initState();
    _wobble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant AlphabetOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWrong && !oldWidget.isWrong) {
      _wobble.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.used) {
      return const SizedBox(width: 72, height: 72);
    }

    final colors = [
      const Color(0xFFEF5350),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFFCA28),
      const Color(0xFFAB47BC),
      const Color(0xFFFF7043),
    ];
    final color = colors[widget.tile.letter.codeUnitAt(0) % colors.length];

    return AnimatedBuilder(
      animation: _wobble,
      builder: (context, child) {
        final shake =
            math.sin(_wobble.value * math.pi * 6) * 6 * (1 - _wobble.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.isHint ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(color, Colors.white, 0.25)!, color],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isHint
                    ? Colors.white
                    : color.withValues(alpha: 0.9),
                width: widget.isHint ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: widget.isHint ? 0.55 : 0.35),
                  blurRadius: widget.isHint ? 16 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.tile.letter,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompleteWordVictoryOverlay extends StatelessWidget {
  const CompleteWordVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final CompleteWordResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Complete the Word Celebration!',
      stats: [
        CelebrationStat(
          icon: '✏️',
          label: 'Words Completed',
          value: '${result.wordsCompleted}',
        ),
        CelebrationStat(
          icon: '🔤',
          label: 'Letters Correct',
          value: '${result.lettersCorrect}',
        ),
        CelebrationStat(
          icon: '🎯',
          label: 'Accuracy',
          value: '${(result.accuracy * 100).round()}%',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(icon: '✨', label: 'XP', value: '+${result.xp}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Best Combo',
          value: '${result.maxCombo}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
