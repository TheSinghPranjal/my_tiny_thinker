import 'dart:math' as math;

import 'package:flutter/material.dart';

class AlphabetGardenBackground extends StatelessWidget {
  const AlphabetGardenBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81D4FA),
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE),
                Color(0xFFC8E6C9),
              ],
              stops: [0, 0.35, 0.72, 1],
            ),
          ),
        ),
        CustomPaint(
          painter: _GardenPainter(
            phase: reducedMotion ? 0 : envPhase,
          ),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

class _GardenPainter extends CustomPainter {
  _GardenPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    _drawGrass(canvas, size);
    _drawDecor(canvas, size);
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFCC80),
      const Color(0xFFFFF59D),
      const Color(0xFFA5D6A7),
      const Color(0xFF90CAF9),
      const Color(0xFFCE93D8),
    ];
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final outer = size.width * 0.42;
    final band = 10.0;
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outer - i * band),
        math.pi + 0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band * 0.9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    void cloud(double x, double y, double s) {
      final drift = math.sin(phase * 0.4 + x) * 8;
      final c = Offset(x + drift, y);
      canvas.drawCircle(c, s * 0.45, paint);
      canvas.drawCircle(c.translate(-s * 0.4, s * 0.08), s * 0.34, paint);
      canvas.drawCircle(c.translate(s * 0.38, s * 0.06), s * 0.36, paint);
    }

    cloud(size.width * 0.15, size.height * 0.12, 42);
    cloud(size.width * 0.72, size.height * 0.09, 36);
    cloud(size.width * 0.48, size.height * 0.18, 28);
  }

  void _drawGrass(Canvas canvas, Size size) {
    final base = size.height * 0.88;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, base)
      ..quadraticBezierTo(
        size.width * 0.25,
        base - 18 + math.sin(phase) * 4,
        size.width * 0.5,
        base - 8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        base - 20 + math.cos(phase * 1.1) * 4,
        size.width,
        base,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF66BB6A),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF81C784).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  void _drawDecor(Canvas canvas, Size size) {
    // Floating alphabet blocks / crayons (subtle)
    final blockPaint = Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.55);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          size.width * 0.08,
          size.height * 0.72 + math.sin(phase * 1.3) * 4,
        ),
        width: 28,
        height: 28,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(r, blockPaint);

    final crayon = Paint()
      ..color = const Color(0xFFEF5350).withValues(alpha: 0.5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.94, size.height * 0.78),
      crayon,
    );

    // Sparkles
    final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 8; i++) {
      final x = size.width * ((i * 0.13 + 0.05) % 1);
      final y = size.height * (0.25 + (i % 4) * 0.08) +
          math.sin(phase * 2 + i) * 6;
      canvas.drawCircle(Offset(x, y), 2.2, sparkle);
    }
  }

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
