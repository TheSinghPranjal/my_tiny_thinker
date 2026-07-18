import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

class SpaceBackground extends StatelessWidget {
  const SpaceBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.showEarthCelebration = false,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final bool showEarthCelebration;
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
                MoonRescuePalette.spaceTop,
                MoonRescuePalette.spaceMid,
                MoonRescuePalette.spaceBottom,
                Color(0xFF1A237E),
              ],
              stops: [0, 0.35, 0.7, 1],
            ),
          ),
        ),
        CustomPaint(
          painter: _SpacePainter(
            phase: reducedMotion ? 0 : envPhase,
            celebrate: showEarthCelebration,
          ),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

class _SpacePainter extends CustomPainter {
  _SpacePainter({required this.phase, required this.celebrate});

  final double phase;
  final bool celebrate;

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);
    _drawNebula(canvas, size);
    _drawEarth(canvas, size);
    _drawMoon(canvas, size);
    if (celebrate) _drawFireworks(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var i = 0; i < 60; i++) {
      final x = (i * 97 % 1000) / 1000 * size.width;
      final y = (i * 53 % 700) / 1000 * size.height * 0.75;
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(phase * 3 + i));
      paint.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.6, paint);
    }
  }

  void _drawNebula(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.25),
      size.width * 0.22,
      Paint()..color = const Color(0xFF7E57C2).withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.35),
      size.width * 0.18,
      Paint()..color = const Color(0xFF26C6DA).withValues(alpha: 0.12),
    );
  }

  void _drawEarth(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.12);
    final r = size.width * 0.09;
    canvas.drawCircle(
      c,
      r + 6,
      Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.35),
    );
    canvas.drawCircle(c, r, Paint()..color = MoonRescuePalette.earthBlue);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(phase * 0.15);
    final land = Paint()..color = MoonRescuePalette.earthGreen;
    canvas.drawOval(Rect.fromCenter(center: const Offset(-8, -4), width: 22, height: 14), land);
    canvas.drawOval(Rect.fromCenter(center: const Offset(10, 6), width: 16, height: 12), land);
    canvas.restore();
    canvas.drawCircle(
      c.translate(-r * 0.25, -r * 0.3),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawMoon(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.68,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = MoonRescuePalette.moon);
    canvas.drawPath(
      path,
      Paint()
        ..color = MoonRescuePalette.moonShadow.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Craters
    final crater = Paint()..color = MoonRescuePalette.moonShadow.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.86), 18, crater);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.88), 14, crater);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.9), 10, crater);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.84), 12, crater);

    // Tiny flag
    final flagBase = Offset(size.width * 0.18, size.height * 0.8);
    canvas.drawLine(
      flagBase,
      flagBase.translate(0, -28),
      Paint()
        ..color = const Color(0xFF78909C)
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(flagBase.dx, flagBase.dy - 28, 16, 10),
      Paint()..color = const Color(0xFFEF5350),
    );
  }

  void _drawFireworks(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.12);
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2 + phase * 4;
      final len = 18.0 + (i % 3) * 6;
      canvas.drawLine(
        c,
        c + Offset(math.cos(a) * len, math.sin(a) * len),
        Paint()
          ..color = [
            const Color(0xFFFFEB3B),
            const Color(0xFFFF80AB),
            const Color(0xFF80D8FF),
          ][i % 3]
              .withValues(alpha: 0.85)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.celebrate != celebrate;
}
