import 'dart:math' as math;

import 'package:flutter/material.dart';

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
    _drawSunRays(canvas, size);
    _drawClouds(canvas, size);
    _drawHills(canvas, size);
    _drawGround(canvas, size);
    _drawBushes(canvas, size);
    _drawPollen(canvas, size);
    if (!reducedMotion) {
      _drawButterfly(canvas, size, 0.2, 0.35, const Color(0xFFEC407A));
      _drawButterfly(canvas, size, 0.7, 0.28, const Color(0xFF42A5F5));
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFA5D6A7), Color(0xFF66BB6A)],
        ).createShader(rect),
    );
  }

  void _drawSunRays(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.82, size.height * 0.1);
    canvas.drawCircle(sun, 34, Paint()..color = const Color(0xFFFFF176));
    for (var i = 0; i < 6; i++) {
      final angle = t * math.pi * 2 + i * math.pi / 3;
      final end = sun + Offset(math.cos(angle) * 80, math.sin(angle) * 80);
      canvas.drawLine(
        sun,
        end,
        Paint()
          ..color = const Color(0xFFFFF59D).withValues(alpha: 0.15)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.05 + i * 0.28) + t * size.width * 0.04) %
          (size.width + 100);
      final y = size.height * (0.06 + i * 0.025);
      canvas.drawCircle(Offset(x, y), 22, paint);
      canvas.drawCircle(Offset(x + 24, y + 4), 18, paint);
      canvas.drawCircle(Offset(x - 18, y + 6), 16, paint);
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final hill = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.58,
        size.width * 0.55,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.78,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF388E3C));
  }

  void _drawGround(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
      Paint()..color = const Color(0xFF2E7D32),
    );
    for (var i = 0; i < 12; i++) {
      final gx = size.width * (i / 12) + math.sin(t * 6 + i) * 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(gx, size.height * 0.88),
          width: 28,
          height: 10,
        ),
        Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.7),
      );
    }
    _drawRock(canvas, Offset(size.width * 0.12, size.height * 0.86));
    _drawRock(canvas, Offset(size.width * 0.88, size.height * 0.84));
    _drawMushroom(canvas, Offset(size.width * 0.22, size.height * 0.87));
    _drawMushroom(canvas, Offset(size.width * 0.76, size.height * 0.88));
  }

  void _drawRock(Canvas canvas, Offset c) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 36, height: 22),
      Paint()..color = const Color(0xFF78909C),
    );
  }

  void _drawMushroom(Canvas canvas, Offset c) {
    canvas.drawRect(
      Rect.fromCenter(center: c + const Offset(0, 4), width: 8, height: 12),
      Paint()..color = const Color(0xFFEFEBE9),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c - const Offset(0, 4), width: 18, height: 12),
      Paint()..color = const Color(0xFFE53935),
    );
  }

  void _drawBushes(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final bx = size.width * (0.08 + i * 0.2);
      final by = size.height * 0.80;
      canvas.drawCircle(
        Offset(bx, by),
        18 + i * 2,
        Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.85),
      );
    }
  }

  void _drawPollen(Canvas canvas, Size size) {
    for (var i = 0; i < 20; i++) {
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

  void _drawButterfly(Canvas canvas, Size size, double nx, double ny, Color color) {
    final cx = size.width * nx + math.sin(t * 3 + nx * 10) * 30;
    final cy = size.height * ny + math.cos(t * 2.5) * 20;
    final flap = math.sin(t * 20 + nx * 5).abs() * 0.5 + 0.5;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(flap, 1);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, 0), width: 14, height: 18),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.scale(-1, 1);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, 0), width: 14, height: 18),
      Paint()..color = color.withValues(alpha: 0.85),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JunglePainter old) =>
      old.t != t || old.envPhase != envPhase;
}
