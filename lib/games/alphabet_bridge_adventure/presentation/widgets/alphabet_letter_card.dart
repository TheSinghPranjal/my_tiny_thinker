import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';

/// Pastel "stitched" letter tile. Scale and glow stay inside the fixed slot,
/// so they never shift the board layout.
class AlphabetLetterCard extends StatelessWidget {
  const AlphabetLetterCard({
    super.key,
    required this.card,
    this.size = 72,
    this.selected = false,
    this.highlighted = false,
  });

  final BridgeCard card;
  final double size;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final base = card.color;
    final isSelected = selected || card.selected;
    final pulse = card.hintPulse || highlighted;
    final glow = isSelected || card.celebrate || highlighted;
    final scale = isSelected || card.celebrate ? 1.06 : (pulse ? 1.03 : 1.0);
    final shakeX = card.shake ? math.sin(card.floatPhase * 18) * 5 : 0.0;

    final top = Color.lerp(base, Colors.white, 0.55)!;
    final bottom = Color.lerp(base, Colors.white, 0.15)!;
    final radius = size * 0.26;

    return SizedBox(
      width: size,
      height: size,
      child: Transform.translate(
        offset: Offset(shakeX, 0),
        child: Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
              border: Border.all(color: Colors.white, width: size * 0.05),
              boxShadow: [
                BoxShadow(
                  color: base.withValues(alpha: glow ? 0.7 : 0.4),
                  blurRadius: glow ? 18 : 10,
                  spreadRadius: glow ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _StitchPainter(radius: radius - 6),
              child: Center(
                child: Text(
                  card.glyph,
                  style: TextStyle(
                    fontSize: size * 0.56,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1F3F),
                    fontFamily: 'Baloo2',
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed white inner border that makes the tile look stitched.
class _StitchPainter extends CustomPainter {
  _StitchPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius + 6),
    ).deflate(7);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StitchPainter old) => old.radius != radius;
}
