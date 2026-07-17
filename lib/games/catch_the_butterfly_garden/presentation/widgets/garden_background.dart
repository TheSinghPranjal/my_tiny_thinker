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
      duration: const Duration(seconds: 22),
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
    _drawHills(canvas, size);
    _drawClouds(canvas, size);
    _drawSun(canvas, size);
    _drawGrass(canvas, size);
    _drawFence(canvas, size);
    _drawFlowers(canvas, size);
    _drawPond(canvas, size);
    _drawBushes(canvas, size);
    if (!reducedMotion) {
      _drawDandelion(canvas, size);
      _drawLadybug(canvas, size, 0.14, 0.76);
      _drawLadybug(canvas, size, 0.84, 0.79);
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
          colors: [
            Color(0xFF81D4FA),
            Color(0xFFB3E5FC),
            Color(0xFFE1F5FE),
            Color(0xFFC8E6C9),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(rect),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.58;
    const colors = [
      Color(0xFFEF5350),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFF7E57C2),
      Color(0xFFEC407A),
    ];
    final baseW = size.width * 1.05;
    final baseH = size.height * 0.52;
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * 14.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseW - shrink,
          height: baseH - shrink * 0.55,
        ),
        math.pi + 0.08,
        math.pi - 0.16,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final far = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.52, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.68, size.width, size.height * 0.56)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(0, size.height * 0.72)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.55));

    final near = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.62, size.width * 0.55, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.74, size.width, size.height * 0.66)
      ..lineTo(size.width, size.height * 0.74)
      ..lineTo(0, size.height * 0.74)
      ..close();
    canvas.drawPath(near, Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.65));
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.05 + i * 0.28) + t * size.width * 0.03) % (size.width + 100) - 40;
      final y = size.height * 0.06 + i * 7.0;
      canvas.drawCircle(Offset(x, y), 22, paint);
      canvas.drawCircle(Offset(x + 24, y + 3), 17, paint);
      canvas.drawCircle(Offset(x + 10, y - 10), 14, paint);
      canvas.drawCircle(Offset(x - 14, y + 2), 12, paint);
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.88, size.height * 0.1);
    canvas.drawCircle(
      sun,
      40,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFB74D), Color(0x00FFB74D)],
          stops: [0.2, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: sun, radius: 40)),
    );
    canvas.drawCircle(sun, 22, Paint()..color = const Color(0xFFFFF176));
    if (!reducedMotion) {
      for (var i = 0; i < 8; i++) {
        final a = t * math.pi * 2 + i * (math.pi / 4);
        canvas.drawLine(
          sun + Offset(math.cos(a) * 28, math.sin(a) * 28),
          sun + Offset(math.cos(a) * 42, math.sin(a) * 42),
          Paint()
            ..color = const Color(0xFFFFF59D).withValues(alpha: 0.55)
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawFence(Canvas canvas, Size size) {
    final y = size.height * 0.71;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(0, y + 14),
      Offset(size.width, y + 14),
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 4,
    );
    for (var i = 0; i < 18; i++) {
      final x = size.width * i / 17;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, y - 8, 6, 36),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFA1887F),
      );
    }
  }

  void _drawGrass(Canvas canvas, Size size) {
    final grassTop = size.height * 0.72;
    canvas.drawRect(
      Rect.fromLTWH(0, grassTop, size.width, size.height * 0.28),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81C784), Color(0xFF66BB6A), Color(0xFF43A047)],
        ).createShader(Rect.fromLTWH(0, grassTop, size.width, size.height * 0.28)),
    );

    for (var i = 0; i < 32; i++) {
      final gx = size.width * ((i * 37) % 100) / 100;
      final sway = math.sin(t * 4 + i + envPhase) * 3.5 * intensity;
      final h = 10.0 + (i % 4) * 4;
      canvas.drawLine(
        Offset(gx, grassTop + 8),
        Offset(gx + sway, grassTop + 8 - h),
        Paint()
          ..color = Color.lerp(const Color(0xFF9CCC65), const Color(0xFF2E7D32), (i % 5) / 5)!
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      (0.08, 0.80, 0xFFEC407A),
      (0.18, 0.86, 0xFFFFB74D),
      (0.30, 0.79, 0xFFAB47BC),
      (0.42, 0.85, 0xFF42A5F5),
      (0.55, 0.78, 0xFFFFEE58),
      (0.68, 0.84, 0xFFEF5350),
      (0.80, 0.80, 0xFF66BB6A),
      (0.92, 0.86, 0xFFF48FB1),
      (0.24, 0.92, 0xFFCE93D8),
      (0.72, 0.92, 0xFFFFCC80),
    ];
    for (final (nx, ny, color) in spots) {
      final sway = math.sin(t * 3 + nx * 10) * 3 * intensity;
      final c = Offset(size.width * nx + sway, size.height * ny);
      canvas.drawLine(
        c,
        c + const Offset(0, 16),
        Paint()
          ..color = const Color(0xFF388E3C)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 10, math.sin(a) * 10 - 6),
          6,
          Paint()..color = Color(color),
        );
      }
      canvas.drawCircle(c + const Offset(0, -6), 5, Paint()..color = const Color(0xFFFFEB3B));
    }
  }

  void _drawPond(Canvas canvas, Size size) {
    for (final (nx, ny, w, h) in [
      (0.16, 0.90, 90.0, 32.0),
      (0.88, 0.91, 70.0, 26.0),
    ]) {
      final c = Offset(size.width * nx, size.height * ny);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: w, height: h),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)],
          ).createShader(Rect.fromCenter(center: c, width: w, height: h)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + const Offset(-8, -4), width: w * 0.35, height: h * 0.3),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  void _drawBushes(Canvas canvas, Size size) {
    for (final (nx, ny) in [(0.05, 0.74), (0.95, 0.75)]) {
      final c = Offset(size.width * nx, size.height * ny);
      for (final o in [
        const Offset(0, 0),
        const Offset(-14, 4),
        const Offset(14, 4),
        const Offset(0, -10),
      ]) {
        canvas.drawCircle(c + o, 16, Paint()..color = const Color(0xFF558B2F));
      }
    }
  }

  void _drawDandelion(Canvas canvas, Size size) {
    for (var i = 0; i < 14; i++) {
      final px = (size.width * 0.08 + i * 32 + t * 28) % size.width;
      final py = size.height * (0.18 + (i % 5) * 0.08) + math.sin(t * 2 + i) * 5;
      canvas.drawCircle(Offset(px, py), 2, Paint()..color = Colors.white.withValues(alpha: 0.65));
    }
  }

  void _drawLadybug(Canvas canvas, Size size, double nx, double ny) {
    final c = Offset(size.width * nx + math.sin(t * 2 + nx) * 8, size.height * ny);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 16, height: 13),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawLine(
      c + const Offset(0, -6),
      c + const Offset(0, 6),
      Paint()
        ..color = const Color(0xFF212121)
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c + const Offset(-3.5, -1), 2, Paint()..color = Colors.black);
    canvas.drawCircle(c + const Offset(3.5, -1), 2, Paint()..color = Colors.black);
    canvas.drawCircle(c + const Offset(0, -7), 3.5, Paint()..color = const Color(0xFF37474F));
  }

  @override
  bool shouldRepaint(covariant _GardenPainter old) =>
      old.t != t || old.envPhase != envPhase;
}
