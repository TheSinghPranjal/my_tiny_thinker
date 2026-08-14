import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/extensions/context_extensions.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/number_memory/models/number_memory_models.dart';

class NumberMemoryBoard extends StatelessWidget {
  const NumberMemoryBoard({
    super.key,
    required this.phase,
    required this.targetNumber,
    required this.input,
    required this.digitCount,
    required this.showShake,
    required this.showErrorBorder,
    required this.celebrating,
    required this.onDigit,
    required this.onClear,
    required this.onSubmit,
  });

  final NumberMemoryPhase phase;
  final String targetNumber;
  final String input;
  final int digitCount;
  final bool showShake;
  final bool showErrorBorder;
  final bool celebrating;
  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final showing = phase == NumberMemoryPhase.showing;
    final inputPhase =
        phase == NumberMemoryPhase.input ||
        phase == NumberMemoryPhase.celebrating;

    return Column(
      children: [
        const Spacer(flex: 1),
        if (showing) ...[
          Text(
            'Remember this!',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4527A0),
              shadows: const [Shadow(color: Colors.white, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NumberMemoryDisplay(
            value: targetNumber,
            celebrating: celebrating,
            highlight: true,
          ),
        ],
        if (inputPhase) ...[
          Text(
            celebrating ? 'Nice!' : 'What was the number?',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4527A0),
              shadows: const [Shadow(color: Colors.white, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          NumberMemoryInputField(
            value: input,
            digitCount: digitCount,
            shake: showShake,
            errorBorder: showErrorBorder,
          ),
          const SizedBox(height: AppSpacing.lg),
          NumberMemoryKeypad(
            enabled: phase == NumberMemoryPhase.input,
            onDigit: onDigit,
            onClear: onClear,
            onSubmit: onSubmit,
          ),
        ],
        const Spacer(flex: 2),
      ],
    );
  }
}

class NumberMemoryDisplay extends StatelessWidget {
  const NumberMemoryDisplay({
    super.key,
    required this.value,
    this.celebrating = false,
    this.highlight = false,
  });

  final String value;
  final bool celebrating;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0.85, end: celebrating ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE8EAF6)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: highlight ? AppColors.softPurple : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softPurple.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: value.length > 6 ? 36 : 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            color: const Color(0xFF4527A0),
          ),
        ),
      ),
    );
  }
}

class NumberMemoryInputField extends StatefulWidget {
  const NumberMemoryInputField({
    super.key,
    required this.value,
    required this.digitCount,
    this.shake = false,
    this.errorBorder = false,
  });

  final String value;
  final int digitCount;
  final bool shake;
  final bool errorBorder;

  @override
  State<NumberMemoryInputField> createState() => _NumberMemoryInputFieldState();
}

class _NumberMemoryInputFieldState extends State<NumberMemoryInputField>
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
  void didUpdateWidget(covariant NumberMemoryInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
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
    final display = widget.value.padRight(widget.digitCount, '·');
    final borderColor = widget.errorBorder
        ? AppColors.error
        : AppColors.softPurple;

    return AnimatedBuilder(
      animation: _wobble,
      builder: (context, child) {
        final shake =
            math.sin(_wobble.value * math.pi * 6) * 8 * (1 - _wobble.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: widget.errorBorder ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          display,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.digitCount > 6 ? 28 : 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: const Color(0xFF4527A0),
          ),
        ),
      ),
    );
  }
}

class NumberMemoryKeypad extends StatelessWidget {
  const NumberMemoryKeypad({
    super.key,
    required this.onDigit,
    required this.onClear,
    required this.onSubmit,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final bool enabled;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', '✓'],
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Column(
        children: [
          for (final row in _keys) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final key in row) ...[
                  _KeypadButton(
                    label: key,
                    enabled: enabled,
                    onTap: () {
                      if (!enabled) return;
                      if (key == 'C') {
                        onClear();
                      } else if (key == '✓') {
                        onSubmit();
                      } else {
                        onDigit(key);
                      }
                    },
                  ),
                  if (key != row.last) const SizedBox(width: 12),
                ],
              ],
            ),
            if (row != _keys.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isClear = label == 'C';
    final isSubmit = label == '✓';
    final colors = isSubmit
        ? const [Color(0xFF66BB6A), Color(0xFF43A047)]
        : isClear
        ? const [Color(0xFFFF8A80), Color(0xFFEF5350)]
        : const [Color(0xFFB39DDB), Color(0xFF7E57C2)];

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 72,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(colors[0], Colors.white, 0.2)!, colors[1]],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[1].withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSubmit ? 28 : 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
      ),
    );
  }
}

class NumberMemoryVictoryOverlay extends StatelessWidget {
  const NumberMemoryVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final NumberMemoryResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Number Memory Celebration!',
      stats: [
        CelebrationStat(icon: '⭐', label: 'Score', value: '${result.score}'),
        CelebrationStat(
          icon: '✅',
          label: 'Correct',
          value: '${result.correctCount}',
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
