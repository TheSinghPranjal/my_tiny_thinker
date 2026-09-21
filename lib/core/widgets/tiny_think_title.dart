import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

/// Rainbow “TinyThink” wordmark with a thick white outline (home header).
class TinyThinkTitle extends StatelessWidget {
  const TinyThinkTitle({
    super.key,
    this.fontSize = 42,
    this.showTagline = false,
  });

  final double fontSize;

  /// Adds the sparkle burst and "Play • Learn • Grow" line (home header).
  final bool showTagline;

  static const _gradientColors = [
    Color(0xFF3FA9F5),
    Color(0xFF6C7BFF),
    Color(0xFFB055F0),
    Color(0xFFFF5FA8),
    Color(0xFFFF9F3A),
    Color(0xFFFFC72E),
    Color(0xFF6FCB4A),
  ];

  TextStyle _baseStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
      fontFamily: 'Baloo2',
      height: 1.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = 'TinyThink';
    final style = _baseStyle();
    final strokeWidth = (fontSize * 0.2).clamp(7.0, 14.0);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    final wordmark = Padding(
      padding: EdgeInsets.fromLTRB(
        strokeWidth * 0.15,
        strokeWidth * 0.1,
        strokeWidth * 0.35,
        strokeWidth * 0.15,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            text,
            style: style.copyWith(
              foreground: strokePaint,
              shadows: const [
                Shadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 2.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          GradientText(
            text,
            style: style,
            colors: _gradientColors,
          ),
        ],
      ),
    );

    if (!showTagline) return wordmark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            wordmark,
            Positioned(
              right: -fontSize * 0.28,
              top: -fontSize * 0.05,
              child: SizedBox(
                width: fontSize * 0.5,
                height: fontSize * 0.5,
                child: CustomPaint(painter: _SparkBurstPainter()),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: fontSize * 0.5),
          child: Text(
            'Play  •  Learn  •  Grow',
            style: GoogleFonts.fredoka(
              fontSize: fontSize * 0.36,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E5FB8),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _SparkBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFC928)
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width * 0.2, size.height * 0.85);
    for (final a in [-1.55, -1.0, -0.45]) {
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * size.width * 0.3, c + d * size.width * 0.8, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
