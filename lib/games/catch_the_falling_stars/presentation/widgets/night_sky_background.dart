import 'dart:math' as math;

import 'package:flutter/material.dart';

class NightSkyBackground extends StatelessWidget {
  const NightSkyBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.moonCheer = 0,
    this.constellationEmoji,
    this.constellationPieces = 0,
    this.celebrate = false,
    this.twinkleIntensity = 0.7,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final double moonCheer;
  final String? constellationEmoji;
  final int constellationPieces;
  final bool celebrate;
  final double twinkleIntensity;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final phase = reducedMotion ? 0.0 : envPhase;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D1B4C),
                Color(0xFF1A237E),
                Color(0xFF283593),
                Color(0xFF3949AB),
                Color(0xFF5C6BC0),
              ],
              stops: [0, 0.25, 0.5, 0.75, 1],
            ),
          ),
        ),
        CustomPaint(
          painter: _NightSkyPainter(
            phase: phase,
            moonCheer: moonCheer,
            celebrate: celebrate,
            twinkleIntensity: twinkleIntensity,
            constellationPieces: constellationPieces,
          ),
          size: Size.infinite,
        ),
        if (constellationEmoji != null && constellationPieces > 0)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 88,
            right: 16,
            child: Opacity(
              opacity: (0.35 + constellationPieces * 0.12).clamp(0.0, 1.0),
              child: Text(
                constellationEmoji!,
                style: TextStyle(
                  fontSize: 28 + constellationPieces * 4.0,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  _NightSkyPainter({
    required this.phase,
    required this.moonCheer,
    required this.celebrate,
    required this.twinkleIntensity,
    required this.constellationPieces,
  });

  final double phase;
  final double moonCheer;
  final bool celebrate;
  final double twinkleIntensity;
  final int constellationPieces;

  @override
  void paint(Canvas canvas, Size size) {
    _drawAurora(canvas, size);
    _drawBgStars(canvas, size);
    _drawPlanets(canvas, size);
    _drawClouds(canvas, size);
    _drawFireflies(canvas, size);
    _drawShootingStars(canvas, size);
    _drawMoon(canvas, size);
    _drawTreeSilhouette(canvas, size);
    if (celebrate) _drawCelebration(canvas, size);
  }

  void _drawAurora(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.12 + i * 0.08);
      final wave = math.sin(phase * 0.4 + i) * 18;
      paint.color = [
        const Color(0xFF69F0AE),
        const Color(0xFF80D8FF),
        const Color(0xFFE040FB),
      ][i]
          .withValues(alpha: 0.07 + 0.03 * math.sin(phase + i));
      final path = Path()
        ..moveTo(0, y + wave)
        ..quadraticBezierTo(
          size.width * 0.25,
          y - 30 + wave,
          size.width * 0.5,
          y + 10 - wave,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          y + 40 + wave,
          size.width,
          y - 10 - wave,
        )
        ..lineTo(size.width, y + 60)
        ..lineTo(0, y + 60)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawBgStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 120; i++) {
      final x = (i * 97 % 1000) / 1000 * size.width;
      final y = (i * 53 % 900) / 1000 * size.height * 0.85;
      final twinkle =
          0.25 + 0.75 * (0.5 + 0.5 * math.sin(phase * 2.5 + i * 0.7));
      paint.color = Colors.white
          .withValues(alpha: (twinkle * twinkleIntensity).clamp(0.1, 1.0));
      canvas.drawCircle(Offset(x, y), 0.8 + (i % 4) * 0.55, paint);
    }
    // Soft constellation dots near top.
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.15 + constellationPieces * 0.05);
    for (var i = 0; i < constellationPieces.clamp(0, 5); i++) {
      final x = size.width * (0.55 + i * 0.06);
      final y = size.height * (0.14 + (i % 2) * 0.03);
      canvas.drawCircle(Offset(x, y), 3.5, glow);
    }
  }

  void _drawPlanets(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.82, size.height * 0.18);
    canvas.drawCircle(
      p1,
      18,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p1, width: 44, height: 10),
      Paint()
        ..color = const Color(0xFFFFCC80).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final p2 = Offset(size.width * 0.12, size.height * 0.28);
    canvas.drawCircle(
      p2,
      12,
      Paint()..color = const Color(0xFF80CBC4).withValues(alpha: 0.8),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    for (var i = 0; i < 4; i++) {
      final drift = (phase * (8 + i * 3) + i * 90) % (size.width + 120);
      final x = drift - 60;
      final y = size.height * (0.55 + i * 0.08);
      _cloud(canvas, Offset(x, y), 28 + i * 4.0, paint);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c.translate(-r * 0.7, 4), r * 0.7, paint);
    canvas.drawCircle(c.translate(r * 0.65, 6), r * 0.75, paint);
  }

  void _drawFireflies(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.05 + (i * 0.07) % 0.9) +
          math.sin(phase * 1.2 + i) * 10;
      final y = size.height * (0.55 + (i % 5) * 0.08) +
          math.cos(phase * 1.5 + i) * 8;
      final a = 0.3 + 0.5 * (0.5 + 0.5 * math.sin(phase * 4 + i));
      paint.color = const Color(0xFFFFF59D).withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), 2.2, paint);
    }
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    final t = (phase * 0.35) % 6;
    if (t > 1.2) return;
    final p = t / 1.2;
    final start = Offset(size.width * 0.1, size.height * 0.2);
    final end = Offset(size.width * 0.55, size.height * 0.45);
    final pos = Offset.lerp(start, end, p)!;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 1 - p)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pos, pos.translate(-28, -14), paint);
    canvas.drawCircle(pos, 2.5, paint);
  }

  void _drawMoon(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.18, size.height * 0.14);
    final r = size.width * 0.09;
    final bounce = moonCheer > 0 ? math.sin(moonCheer * math.pi) * 6 : 0.0;

    canvas.drawCircle(
      c.translate(0, bounce),
      r + 14,
      Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      c.translate(0, bounce),
      r,
      Paint()..color = const Color(0xFFFFF8E1),
    );
    // Cheeks.
    canvas.drawCircle(
      c.translate(-r * 0.42, r * 0.18 + bounce),
      r * 0.14,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      c.translate(r * 0.42, r * 0.18 + bounce),
      r * 0.14,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );
    // Eyes blink.
    final blink = (math.sin(phase * 0.7) + 1) / 2;
    final eyeH = blink > 0.92 ? 1.5 : r * 0.12;
    final eyePaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(-r * 0.28, -r * 0.08 + bounce),
        width: r * 0.16,
        height: eyeH,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(r * 0.28, -r * 0.08 + bounce),
        width: r * 0.16,
        height: eyeH,
      ),
      eyePaint,
    );
    // Smile.
    final smile = Path()
      ..moveTo(c.dx - r * 0.28, c.dy + r * 0.28 + bounce)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * (moonCheer > 0.3 ? 0.55 : 0.42) + bounce,
        c.dx + r * 0.28,
        c.dy + r * 0.28 + bounce,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    // Craters.
    canvas.drawCircle(
      c.translate(r * 0.2, -r * 0.35 + bounce),
      r * 0.1,
      Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.55),
    );
  }

  void _drawTreeSilhouette(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A1635).withValues(alpha: 0.55);
    final ground = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.88,
        size.width,
        size.height * 0.93,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(ground, paint);

    // Left tree + owl perch.
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.78, 10, size.height * 0.15),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.76),
      28,
      paint,
    );
    // Tiny owl emoji drawn as circles.
    final owl = Offset(size.width * 0.08, size.height * 0.74);
    canvas.drawCircle(owl, 8, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawCircle(
      owl.translate(-3, -1),
      2,
      Paint()..color = const Color(0xFFFFF59D),
    );
    canvas.drawCircle(
      owl.translate(3, -1),
      2,
      Paint()..color = const Color(0xFFFFF59D),
    );
  }

  void _drawCelebration(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      const Color(0xFFFF80AB),
      const Color(0xFF80D8FF),
      const Color(0xFFFFF59D),
      const Color(0xFFB388FF),
      const Color(0xFF69F0AE),
    ];
    for (var i = 0; i < 24; i++) {
      final a = (phase * 1.5 + i) % (math.pi * 2);
      final dist = 40 + (i % 6) * 28 + math.sin(phase * 3 + i) * 10;
      final x = size.width * 0.5 + math.cos(a) * dist;
      final y = size.height * 0.35 + math.sin(a) * dist * 0.7;
      paint.color = colors[i % colors.length].withValues(alpha: 0.75);
      canvas.drawCircle(Offset(x, y), 3 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter old) =>
      old.phase != phase ||
      old.moonCheer != moonCheer ||
      old.celebrate != celebrate ||
      old.twinkleIntensity != twinkleIntensity ||
      old.constellationPieces != constellationPieces;
}
