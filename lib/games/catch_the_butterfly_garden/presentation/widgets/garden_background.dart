import 'dart:math' as math;

import 'package:flutter/material.dart';

class GardenBackground extends StatefulWidget {
  const GardenBackground({
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
  State<GardenBackground> createState() => _GardenBackgroundState();
}

class _GardenBackgroundState extends State<GardenBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.reducedMotion ? widget.envPhase * 0.08 : _controller.value;
    return CustomPaint(
      painter: _GardenPainter(
        t: t,
        envPhase: widget.envPhase,
        intensity: widget.intensity,
        reducedMotion: widget.reducedMotion,
      ),
      child: widget.child,
    );
  }
}

class _GardenPainter extends CustomPainter {
  _GardenPainter({
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
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    _drawSunRays(canvas, size);
    _drawGrass(canvas, size);
    _drawFlowers(canvas, size);
    _drawPond(canvas, size);
    _drawDandelion(canvas, size);
    if (!reducedMotion) {
      _drawLadybug(canvas, size, 0.15, 0.75);
      _drawLadybug(canvas, size, 0.82, 0.78);
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
          colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE), Color(0xFFC8E6C9)],
        ).createShader(rect),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.55;
    const colors = [
      Color(0x44EF5350),
      Color(0x44FFB74D),
      Color(0x44FFEE58),
      Color(0x4466BB6A),
      Color(0x4442A5F5),
      Color(0x44AB47BC),
    ];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: size.width * 1.1, height: size.height * 0.5),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.1 + i * 0.32) + t * size.width * 0.035) % (size.width + 90);
      canvas.drawCircle(Offset(x, size.height * 0.08 + i * 8), 24, paint);
      canvas.drawCircle(Offset(x + 26, size.height * 0.09 + i * 8), 18, paint);
    }
  }

  void _drawSunRays(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.88, size.height * 0.11);
    canvas.drawCircle(sun, 28, Paint()..color = const Color(0xFFFFF176));
    for (var i = 0; i < 5; i++) {
      final a = t * math.pi * 2 + i * 1.2;
      canvas.drawLine(
        sun,
        sun + Offset(math.cos(a) * 70, math.sin(a) * 70),
        Paint()
          ..color = const Color(0xFFFFF59D).withValues(alpha: 0.12)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawGrass(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      Paint()..color = const Color(0xFF43A047),
    );
    for (var i = 0; i < 16; i++) {
      final gx = size.width * i / 16;
      final sway = math.sin(t * 4 + i + envPhase) * 3 * intensity;
      canvas.drawLine(
        Offset(gx, size.height * 0.74),
        Offset(gx + sway, size.height * 0.68),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      (0.12, 0.80, 0xFFEC407A),
      (0.28, 0.84, 0xFFFFB74D),
      (0.45, 0.79, 0xFFAB47BC),
      (0.62, 0.83, 0xFF42A5F5),
      (0.78, 0.80, 0xFFFFEE58),
      (0.90, 0.85, 0xFFEF5350),
    ];
    for (final (nx, ny, color) in spots) {
      final sway = math.sin(t * 3 + nx * 10) * 4;
      final c = Offset(size.width * nx + sway, size.height * ny);
      canvas.drawLine(c, c + const Offset(0, 18), Paint()..color = const Color(0xFF388E3C)..strokeWidth = 2);
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 9, math.sin(a) * 9 - 8),
          5,
          Paint()..color = Color(color),
        );
      }
      canvas.drawCircle(c + const Offset(0, -8), 4, Paint()..color = const Color(0xFFFFEB3B));
    }
  }

  void _drawPond(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.18, size.height * 0.88),
        width: 70,
        height: 28,
      ),
      Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.65),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.85, size.height * 0.90),
        width: 55,
        height: 22,
      ),
      Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.55),
    );
  }

  void _drawDandelion(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final px = (size.width * 0.1 + i * 28 + t * 30) % size.width;
      final py = size.height * (0.2 + (i % 5) * 0.1) + math.sin(t * 2 + i) * 6;
      canvas.drawCircle(Offset(px, py), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }

  void _drawLadybug(Canvas canvas, Size size, double nx, double ny) {
    final c = Offset(size.width * nx, size.height * ny);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 14, height: 12),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawLine(c, c + const Offset(0, -8), Paint()..color = const Color(0xFF37474F)..strokeWidth = 1.5);
    canvas.drawCircle(c + const Offset(-3, 0), 1.5, Paint()..color = Colors.black);
    canvas.drawCircle(c + const Offset(3, 0), 1.5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _GardenPainter old) =>
      old.t != t || old.envPhase != envPhase;
}
