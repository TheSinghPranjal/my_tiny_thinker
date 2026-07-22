import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fixed-size bridge card. Scale/glow never change layout bounds.
class BridgeMatchCard extends StatelessWidget {
  const BridgeMatchCard({
    super.key,
    required this.size,
    required this.color,
    required this.child,
    this.width,
    this.selected = false,
    this.matched = false,
    this.shake = false,
    this.hintPulse = false,
    this.celebrate = false,
    this.shakePhase = 0,
    this.vividFill = false,
  });

  final double size;
  /// Optional wider card (word labels). Height stays [size].
  final double? width;
  final Color color;
  final Widget child;
  final bool selected;
  final bool matched;
  final bool shake;
  final bool hintPulse;
  final bool celebrate;
  final double shakePhase;
  /// Stronger solid color fill (word prompts that name a color).
  final bool vividFill;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final scale = selected || celebrate
        ? 1.05
        : (hintPulse ? 1.03 : 1.0);
    final shakeX = shake ? math.sin(shakePhase * 18) * 5 : 0.0;

    final gradientColors = vividFill
        ? <Color>[
            Color.lerp(color, Colors.white, 0.22)!,
            color,
            Color.lerp(color, Colors.black, 0.1)!,
          ]
        : <Color>[
            Colors.white,
            color.withValues(alpha: 0.85),
            color,
          ];

    // Outer box owns layout; transforms stay inside and cannot shift siblings.
    return SizedBox(
      width: w,
      height: size,
      child: Transform.translate(
        offset: Offset(shakeX, 0),
        child: Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: w,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: matched || selected || celebrate
                    ? Colors.white
                    : color.withValues(alpha: vividFill ? 1 : 0.9),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: celebrate || selected ? 0.55 : (vividFill ? 0.38 : 0.28),
                  ),
                  blurRadius: celebrate || selected ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
