import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';

class JungleBackground extends StatefulWidget {
  const JungleBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  State<JungleBackground> createState() => _JungleBackgroundState();
}

class _JungleBackgroundState extends State<JungleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.reducedMotion ? widget.envPhase * 0.1 : _controller.value;
    return CustomPaint(
      painter: _JunglePainter(
        t: t,
        envPhase: widget.envPhase,
        intensity: widget.intensity,
        reducedMotion: widget.reducedMotion,
      ),
      child: widget.child,
    );
  }
}

class _JunglePainter extends CustomPainter {
  _JunglePainter({
    required this.t,
    required this.envPhase,
    required this.intensity,
    required this.reducedMotion,
  });

  final double t;
  final double envPhase;
  final double intensity;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawHills(canvas, size);
    _drawBackBushes(canvas, size);
    _drawFence(canvas, size);
    _drawMeadow(canvas, size);
    _drawGrassTufts(canvas, size);
    _drawRock(canvas, Offset(size.width * 0.15, size.height * 0.825), 1.0);
    _drawRock(canvas, Offset(size.width * 0.84, size.height * 0.87), 1.15);
    _drawMushroom(canvas, Offset(size.width * 0.2, size.height * 0.875), 1.25);
    _drawMushroom(canvas, Offset(size.width * 0.75, size.height * 0.905), 0.85);
    _drawDaisies(canvas, size);
    _drawForeground(canvas, size);
    _drawPollen(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF63BAF5), Color(0xFF9AD5F8), Color(0xFFD3EEFB)],
          stops: [0.0, 0.45, 0.75],
        ).createShader(rect),
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    paintSmilingSun(
      canvas,
      Offset(size.width * 0.84, size.height * 0.195),
      40,
      rayPhase: reducedMotion ? 0 : t * math.pi * 2,
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    for (final (nx, ny, sc) in [
      (0.1, 0.19, 1.0),
      (0.96, 0.29, 0.7),
      (0.02, 0.6, 0.8),
      (0.95, 0.62, 0.9),
    ]) {
      final x = (size.width * nx + t * size.width * 0.04) % (size.width + 160) - 50;
      paintPuffyCloud(
        canvas,
        Offset(x, size.height * ny),
        sc,
        width: 100,
        highlight: true,
        shadeColor: const Color(0xFFC4DFF5),
      );
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final far = Path()
      ..moveTo(0, h * 0.7)
      ..quadraticBezierTo(w * 0.15, h * 0.6, w * 0.32, h * 0.66)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.66, h * 0.65)
      ..quadraticBezierTo(w * 0.85, h * 0.58, w, h * 0.63)
      ..lineTo(w, h * 0.78)
      ..lineTo(0, h * 0.78)
      ..close();
    canvas.drawPath(
      far,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9DDD7C), Color(0xFF7FCB62)],
        ).createShader(Rect.fromLTWH(0, h * 0.58, w, h * 0.2)),
    );
  }

  void _drawBackBushes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final side in [0.0, 1.0]) {
      for (var i = 0; i < 6; i++) {
        final nx = side == 0 ? 0.02 + i * 0.05 : 0.7 + i * 0.05;
        final ny = 0.72 + ((i * 3) % 4) * 0.007;
        final c = Offset(w * nx, h * ny);
        final r = 26.0 + (i % 3) * 6;
        canvas.drawCircle(c, r, Paint()..color = const Color(0xFF3F9C3F));
        canvas.drawCircle(
          c + Offset(-r * 0.25, -r * 0.3),
          r * 0.55,
          Paint()..color = const Color(0xFF63B94F).withValues(alpha: 0.8),
        );
      }
    }
  }

  void _drawFence(Canvas canvas, Size size) {
    final w = size.width;
    final y = size.height * 0.712;
    final wood = Paint()..color = const Color(0xFFD9A868);
    final woodDark = Paint()..color = const Color(0xFFB98649);
    for (final ry in [y + 12, y + 34]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, ry, w, 9), const Radius.circular(3)),
        wood,
      );
      canvas.drawRect(Rect.fromLTWH(0, ry + 6, w, 3), woodDark);
    }
    const n = 9;
    for (var i = 0; i < n; i++) {
      final x = w * (i + 0.5) / n;
      final post = Path()
        ..moveTo(x - 14, y + 60)
        ..lineTo(x - 14, y + 6)
        ..lineTo(x - 5, y - 6)
        ..lineTo(x + 5, y - 6)
        ..lineTo(x + 14, y + 6)
        ..lineTo(x + 14, y + 60)
        ..close();
      canvas.drawPath(
        post,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE3B778), Color(0xFFCB975A)],
          ).createShader(Rect.fromLTWH(x - 14, y - 6, 28, 66)),
      );
      canvas.drawPath(
        post,
        Paint()
          ..color = const Color(0xFF9C6B36).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(Offset(x, y + 12), 1.8, Paint()..color = const Color(0xFF7A5230));
    }
  }

  void _drawMeadow(Canvas canvas, Size size) {
    final top = size.height * 0.755;
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);
    final path = Path()
      ..moveTo(0, top + 8)
      ..quadraticBezierTo(size.width * 0.5, top - 10, size.width, top + 8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9BDB63), Color(0xFF76C449), Color(0xFF58AB3B)],
        ).createShader(rect),
    );
  }

  void _drawGrassTufts(Canvas canvas, Size size) {
    final green = [const Color(0xFF3F9C3F), const Color(0xFF58B04A), const Color(0xFF2E8B3A)];
    for (var i = 0; i < 16; i++) {
      final x = size.width * (((i * 41) % 94) + 3) / 100;
      final y = size.height * (0.79 + ((i * 17) % 20) / 100);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 * 2 + i) * 2;
      for (var b = -1; b <= 1; b++) {
        canvas.drawPath(
          Path()
            ..moveTo(x + b * 5, y)
            ..quadraticBezierTo(x + b * 8 + sway, y - 10, x + b * 11 + sway, y - 17 + b.abs() * 4),
          Paint()
            ..color = green[(i + b + 1) % 3]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.4
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawRock(Canvas canvas, Offset c, double s) {
    final rock = Path()
      ..moveTo(c.dx - 30 * s, c.dy + 10 * s)
      ..quadraticBezierTo(c.dx - 30 * s, c.dy - 24 * s, c.dx + 2 * s, c.dy - 22 * s)
      ..quadraticBezierTo(c.dx + 30 * s, c.dy - 20 * s, c.dx + 32 * s, c.dy + 10 * s)
      ..close();
    canvas.drawPath(
      rock,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9BA3AE), Color(0xFF69727E)],
        ).createShader(Rect.fromCenter(center: c, width: 64 * s, height: 34 * s)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-8 * s, -12 * s), width: 22 * s, height: 8 * s),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _drawMushroom(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, 8 * s), width: 12 * s, height: 20 * s),
        Radius.circular(5 * s),
      ),
      Paint()..color = const Color(0xFFF3ECDD),
    );
    final cap = Path()
      ..moveTo(c.dx - 20 * s, c.dy - 2 * s)
      ..quadraticBezierTo(c.dx - 20 * s, c.dy - 24 * s, c.dx, c.dy - 24 * s)
      ..quadraticBezierTo(c.dx + 20 * s, c.dy - 24 * s, c.dx + 20 * s, c.dy - 2 * s)
      ..close();
    canvas.drawPath(cap, Paint()..color = const Color(0xFFE53935));
    canvas.drawPath(
      cap,
      Paint()
        ..color = const Color(0xFFB71C1C).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    for (final (dx, dy, r) in [(-8.0, -12.0, 3.4), (5.0, -16.0, 3.0), (10.0, -8.0, 2.6), (-1.0, -7.0, 2.4)]) {
      canvas.drawCircle(c + Offset(dx * s, dy * s), r * s, Paint()..color = Colors.white);
    }
  }

  void _drawDaisies(Canvas canvas, Size size) {
    for (final (nx, ny) in [
      (0.09, 0.79),
      (0.9, 0.79),
      (0.5, 0.94),
      (0.33, 0.985),
      (0.11, 0.97),
      (0.88, 0.94),
    ]) {
      final c = Offset(size.width * nx, size.height * ny);
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 6.5, math.sin(a) * 6.5),
          4.6,
          Paint()..color = Colors.white,
        );
      }
      canvas.drawCircle(c, 3.6, Paint()..color = const Color(0xFFFFB300));
    }
  }

  void _drawForeground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (nx, ny, r, c) in [
      (0.02, 0.97, 60.0, 0xFF3B9440),
      (0.14, 1.02, 52.0, 0xFF2F8437),
      (0.98, 0.96, 66.0, 0xFF3B9440),
      (0.86, 1.02, 54.0, 0xFF2F8437),
    ]) {
      canvas.drawCircle(Offset(w * nx, h * ny), r, Paint()..color = Color(c));
    }
    void leaf(Offset base, double len, double ang, Color c) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(ang);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.3, -len * 0.3, len, 0)
        ..quadraticBezierTo(len * 0.3, len * 0.3, 0, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = c);
      canvas.drawLine(
        Offset.zero,
        Offset(len * 0.9, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..strokeWidth = 1.6,
      );
      canvas.restore();
    }

    const g1 = Color(0xFF4CAF50);
    const g2 = Color(0xFF2E7D32);
    leaf(Offset(w * 0.0, h * 0.99), 110, -1.1, g1);
    leaf(Offset(w * 0.06, h * 1.0), 96, -0.5, g2);
    leaf(Offset(w * 0.12, h * 1.0), 80, -1.5, g1);
    leaf(Offset(w * 1.0, h * 0.99), 110, -math.pi + 1.1, g1);
    leaf(Offset(w * 0.94, h * 1.0), 96, -math.pi + 0.5, g2);
    leaf(Offset(w * 0.88, h * 1.0), 80, -math.pi + 1.5, g1);
  }

  void _drawPollen(Canvas canvas, Size size) {
    for (var i = 0; i < 14; i++) {
      final px = (size.width * (i * 0.07) + t * 40 + envPhase * 10) % size.width;
      final py = size.height * (0.15 + (i % 7) * 0.08) +
          math.sin(t * 4 + i) * 8 * intensity;
      canvas.drawCircle(
        Offset(px, py),
        2,
        Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JunglePainter old) =>
      old.t != t || old.envPhase != envPhase;
}
