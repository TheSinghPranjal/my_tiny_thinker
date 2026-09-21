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
    _drawSkyGlow(canvas, size);
    _drawBgStars(canvas, size);
    _drawFourPointStars(canvas, size);
    _drawShootingStars(canvas, size);
    _drawPlanet(canvas, size);
    _drawMoon(canvas, size);
    _drawClouds(canvas, size);
    _drawLandscape(canvas, size);
    _drawFireflies(canvas, size);
    if (celebrate) _drawCelebration(canvas, size);
  }

  void _drawSkyGlow(Canvas canvas, Size size) {
    // Deep navy that lifts to a soft indigo haze near the horizon.
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1550), Color(0xFF1B2A86), Color(0xFF2A3AA0), Color(0xFF26358F)],
          stops: [0.0, 0.4, 0.75, 1.0],
        ).createShader(r),
    );
  }

  void _drawBgStars(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 150; i++) {
      final x = (i * 97 % 1000) / 1000 * size.width;
      final y = (i * 53 % 900) / 1000 * size.height * 0.82;
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase * 1.6 + i * 1.3)) * twinkleIntensity;
      paint.color = Colors.white.withValues(alpha: (0.25 + twinkle * 0.55).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 0.7 + (i % 4) * 0.35, paint);
    }
  }

  void _sparkle(Canvas canvas, Offset c, double r, Color color, double alpha) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
    canvas.drawCircle(
      c,
      r * 1.4,
      Paint()
        ..color = color.withValues(alpha: alpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
  }

  void _drawFourPointStars(Canvas canvas, Size size) {
    const spots = <(double, double, double)>[
      (0.61, 0.253, 15), (0.1, 0.35, 9), (0.61, 0.42, 11), (0.11, 0.54, 17),
      (0.2, 0.65, 8), (0.66, 0.62, 8), (0.49, 0.71, 17), (0.2, 0.74, 8),
      (0.61, 0.77, 8), (0.9, 0.42, 7), (0.03, 0.25, 6),
    ];
    for (var i = 0; i < spots.length; i++) {
      final (nx, ny, r) = spots[i];
      final pulse = 0.7 + 0.3 * math.sin(phase * 1.8 + i);
      _sparkle(
        canvas,
        Offset(size.width * nx, size.height * ny),
        r * (0.85 + 0.15 * pulse),
        const Color(0xFFFFE066),
        0.85 * pulse,
      );
    }
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    for (final (nx, ny, len) in [(0.36, 0.245, 110.0), (0.7, 0.53, 130.0)]) {
      final head = Offset(size.width * nx, size.height * ny);
      final tail = head + Offset(len * 0.8, -len * 0.6);
      canvas.drawLine(
        head,
        tail,
        Paint()
          ..shader = LinearGradient(
            colors: [const Color(0xFF6FA8FF).withValues(alpha: 0.9), Colors.transparent],
          ).createShader(Rect.fromPoints(head, tail))
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
      _sparkle(canvas, head, 9, const Color(0xFFFFE066), 1.0);
    }
  }

  void _drawPlanet(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.82, size.height * 0.272);
    canvas.drawCircle(
      c,
      46,
      Paint()
        ..color = const Color(0xFF5C6BC0).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Back half of ring, planet, then front half of ring.
    final ring = Rect.fromCenter(center: c, width: 128, height: 32);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.28);
    canvas.translate(-c.dx, -c.dy);
    final ringPaint = Paint()
      ..color = const Color(0xFF9FA8DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawArc(ring, math.pi, math.pi, false, ringPaint);
    final r = Rect.fromCircle(center: c, radius: 32);
    canvas.drawCircle(
      c,
      32,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.5),
          colors: [Color(0xFF6E8BE8), Color(0xFF4A63C8), Color(0xFF2E3F9E)],
        ).createShader(r),
    );
    canvas.drawArc(ring, 0, math.pi, false, ringPaint);
    canvas.restore();
  }

  void _drawMoon(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.15, size.height * 0.235);
    final cheer = 1 + moonCheer * 0.06;
    final r = 62.0 * cheer;
    canvas.drawCircle(
      c,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFF3B0).withValues(alpha: 0.35), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.6)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Color(0xFFFFF6C8), Color(0xFFFCE9A0), Color(0xFFF2D77C)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final crater = Paint()..color = const Color(0xFFE6C876).withValues(alpha: 0.6);
    for (final (dx, dy, cr) in [(-0.35, -0.3, 0.18), (0.3, -0.05, 0.14), (-0.1, 0.4, 0.2), (0.4, 0.4, 0.1)]) {
      canvas.drawCircle(c + Offset(dx * r, dy * r), cr * r, crater);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Soft dark-blue night clouds along the edges.
    void cloud(Offset c, double s, Color color) {
      final p = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 16 * s), width: 170 * s, height: 44 * s),
          Radius.circular(22 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-46 * s, 4 * s), 30 * s, p);
      canvas.drawCircle(c + Offset(-6 * s, -14 * s), 42 * s, p);
      canvas.drawCircle(c + Offset(44 * s, 2 * s), 32 * s, p);
    }

    const dark = Color(0xFF2B3A9A);
    const mid = Color(0xFF34449F);
    final drift = reducedMotionShift();
    cloud(Offset(w * 0.08 + drift, h * 0.29), 1.0, dark);
    cloud(Offset(w * 0.97 - drift, h * 0.31), 0.6, dark);
    cloud(Offset(w * 0.02, h * 0.43), 0.6, dark);
    cloud(Offset(w * 0.04 + drift, h * 0.7), 1.1, mid);
    cloud(Offset(w * 0.98 - drift, h * 0.72), 0.95, mid);
    cloud(Offset(w * 0.06, h * 0.55), 0.7, dark);
    cloud(Offset(w * 0.98, h * 0.55), 0.6, dark);
    cloud(Offset(w * 0.3, h * 0.82), 1.3, dark.withValues(alpha: 0.8));
  }

  double reducedMotionShift() => math.sin(phase * 0.3) * 4;

  void _drawLandscape(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Distant mountains
    final mtn = Path()
      ..moveTo(w * 0.22, h * 0.885)
      ..lineTo(w * 0.42, h * 0.835)
      ..lineTo(w * 0.55, h * 0.87)
      ..lineTo(w * 0.72, h * 0.83)
      ..lineTo(w * 0.95, h * 0.885)
      ..close();
    canvas.drawPath(mtn, Paint()..color = const Color(0xFF1B2A70));
    // Lake
    canvas.drawRect(
      Rect.fromLTWH(w * 0.2, h * 0.885, w * 0.6, h * 0.03),
      Paint()..color = const Color(0xFF2A47A8),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * 0.42 + i * 6, h * 0.893 + i * 5),
        Offset(w * 0.62 - i * 6, h * 0.893 + i * 5),
        Paint()
          ..color = const Color(0xFF6F9BFF).withValues(alpha: 0.5)
          ..strokeWidth = 2,
      );
    }
    // Rolling dark hills and bushes
    final hill = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.3, h * 0.885, w * 0.6, h * 0.93)
      ..quadraticBezierTo(w * 0.85, h * 0.89, w, h * 0.92)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E3A6E), Color(0xFF16305A)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w, h * 0.12)),
    );
    void bush(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..color = color);
      canvas.drawCircle(c + Offset(-r * 0.6, r * 0.2), r * 0.7, Paint()..color = color);
      canvas.drawCircle(c + Offset(r * 0.6, r * 0.25), r * 0.7, Paint()..color = color);
    }

    const b1 = Color(0xFF14284F);
    const b2 = Color(0xFF0F1F42);
    bush(Offset(w * 0.02, h * 0.87), 52, b2);
    bush(Offset(w * 0.11, h * 0.93), 44, b1);
    bush(Offset(w * 0.27, h * 0.905), 28, b1);
    bush(Offset(w * 0.68, h * 0.905), 30, b1);
    bush(Offset(w * 0.98, h * 0.88), 56, b2);
    bush(Offset(w * 0.88, h * 0.94), 46, b1);
    bush(Offset(w * 0.05, h * 0.99), 60, b2);
    bush(Offset(w * 0.96, h * 1.0), 60, b2);
  }

  void _drawFireflies(Canvas canvas, Size size) {
    const spots = <(double, double)>[
      (0.07, 0.91), (0.14, 0.955), (0.2, 0.975), (0.32, 0.98),
      (0.55, 0.985), (0.86, 0.945), (0.92, 0.905), (0.05, 0.965),
    ];
    for (var i = 0; i < spots.length; i++) {
      final (nx, ny) = spots[i];
      final pulse = 0.55 + 0.45 * math.sin(phase * 2 + i * 1.7);
      final c = Offset(
        size.width * nx + math.sin(phase * 0.8 + i) * 3,
        size.height * ny + math.cos(phase * 0.7 + i) * 3,
      );
      canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = const Color(0xFFFFEE58).withValues(alpha: 0.45 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(c, 3, Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.6 + 0.4 * pulse));
    }
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
