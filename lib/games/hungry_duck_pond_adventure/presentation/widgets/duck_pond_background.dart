import 'dart:math' as math;

import 'package:flutter/material.dart';

class DuckPondBackground extends StatefulWidget {
  const DuckPondBackground({
    super.key,
    required this.child,
    this.sunsetFactor = 0,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double sunsetFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  State<DuckPondBackground> createState() => _DuckPondBackgroundState();
}

class _DuckPondBackgroundState extends State<DuckPondBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 28))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.reducedMotion ? widget.envPhase * 0.08 : _controller.value;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DuckPondPainter(
          t: t,
          sunset: widget.sunsetFactor,
          envPhase: widget.envPhase,
          intensity: widget.intensity,
        ),
        child: widget.child,
      ),
    );
  }
}

class _DuckPondPainter extends CustomPainter {
  _DuckPondPainter({
    required this.t,
    required this.sunset,
    required this.envPhase,
    required this.intensity,
  });

  final double t;
  final double sunset;
  final double envPhase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawHills(canvas, size);
    _drawClouds(canvas, size);
    _drawShore(canvas, size);
    _drawWater(canvas, size);
    _drawLilyPads(canvas, size);
    _drawReeds(canvas, size);
    _drawBubbles(canvas, size);
    if (sunset > 0.5) _drawFireflies(canvas, size);
  }

  Color _lerpSky(Color day, Color eve) => Color.lerp(day, eve, sunset)!;

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerpSky(const Color(0xFF64B5F6), const Color(0xFFFF8A65)),
            _lerpSky(const Color(0xFF90CAF9), const Color(0xFFFFAB91)),
            _lerpSky(const Color(0xFFA5D6A7), const Color(0xFFCE93D8)),
          ],
        ).createShader(rect),
    );

    final sunY = size.height * (0.1 + sunset * 0.08);
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF59D), Color(0xFFFFB74D), Color(0x00FFB74D)],
        stops: [0.2, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.84, sunY), radius: 42));
    canvas.drawCircle(Offset(size.width * 0.84, sunY), 28 - sunset * 6, sunPaint);
  }

  void _drawHills(Canvas canvas, Size size) {
    final hill = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.18, size.width * 0.5, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.36, size.width, size.height * 0.24)
      ..lineTo(size.width, size.height * 0.34)
      ..lineTo(0, size.height * 0.34)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = _lerpSky(const Color(0xFF81C784), const Color(0xFF8D6E63)).withValues(alpha: 0.55),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.82 - sunset * 0.25);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.06 + i * 0.34) + t * size.width * 0.025) % (size.width + 90);
      final y = size.height * 0.06 + i * 8;
      canvas.drawCircle(Offset(x, y), 24, paint);
      canvas.drawCircle(Offset(x + 26, y + 2), 18, paint);
      canvas.drawCircle(Offset(x + 12, y - 8), 14, paint);
    }
  }

  void _drawShore(Canvas canvas, Size size) {
    final shoreTop = size.height * 0.72;
    canvas.drawRect(
      Rect.fromLTWH(0, shoreTop, size.width, size.height * 0.28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerpSky(const Color(0xFF66BB6A), const Color(0xFF6D4C41)),
            _lerpSky(const Color(0xFF43A047), const Color(0xFF4E342E)),
          ],
        ).createShader(Rect.fromLTWH(0, shoreTop, size.width, size.height * 0.28)),
    );

    for (var i = 0; i < 6; i++) {
      final fx = size.width * (0.04 + i * 0.17);
      canvas.drawCircle(
        Offset(fx, shoreTop + 14),
        5 + i % 2,
        Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.35),
      );
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterTop = size.height * 0.28;
    final waterRect = Rect.fromLTWH(0, waterTop, size.width, size.height * 0.52);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerpSky(const Color(0xFF4FC3F7), const Color(0xFFFF7043)).withValues(alpha: 0.78),
            _lerpSky(const Color(0xFF0288D1), const Color(0xFF4527A0)).withValues(alpha: 0.92),
            _lerpSky(const Color(0xFF01579B), const Color(0xFF311B92)).withValues(alpha: 0.95),
          ],
        ).createShader(waterRect),
    );

    for (var layer = 0; layer < 4; layer++) {
      final yBase = waterTop + 24 + layer * 22;
      for (var i = 0; i < 5; i++) {
        final rx = size.width * (0.08 + i * 0.2) + layer * 12;
        final ry = yBase + math.sin(t * 3 + i + layer) * 3;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(rx, ry), width: 56 - layer * 6, height: 7),
          Paint()..color = Colors.white.withValues(alpha: 0.08 + layer * 0.015),
        );
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, waterTop, size.width, 8),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final pads = [
      Offset(size.width * 0.18, size.height * 0.61),
      Offset(size.width * 0.78, size.height * 0.57),
      Offset(size.width * 0.48, size.height * 0.67),
    ];
    for (final p in pads) {
      final sway = math.sin(t * 2.5 + p.dx) * 2.5;
      final center = p + Offset(sway, 0);
      final padRect = Rect.fromCenter(center: center, width: 40, height: 16);
      canvas.drawOval(padRect, Paint()..color = const Color(0xFF388E3C));
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(0, 2), width: 34, height: 12),
        Paint()..color = const Color(0xFF2E7D32),
      );
      final notch = Path()
        ..moveTo(center.dx, center.dy - 8)
        ..lineTo(center.dx + 6, center.dy)
        ..lineTo(center.dx, center.dy + 2)
        ..close();
      canvas.drawPath(notch, Paint()..color = const Color(0xFF0277BD).withValues(alpha: 0.35));
      canvas.drawCircle(
        center + Offset(5, -7),
        4.5,
        Paint()..color = const Color(0xFFEC407A),
      );
      canvas.drawCircle(
        center + Offset(6, -8),
        1.5,
        Paint()..color = const Color(0xFFFFCDD2),
      );
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.06 + i * 0.12);
      final sway = math.sin(t * 1.8 + i) * 5 * intensity;
      final top = size.height * (0.4 + (i % 3) * 0.03);
      final stem = Path()
        ..moveTo(x, size.height * 0.56)
        ..quadraticBezierTo(x + sway * 0.4, (top + size.height * 0.56) / 2, x + sway, top);
      canvas.drawPath(
        stem,
        Paint()
          ..color = Color.lerp(const Color(0xFF558B2F), const Color(0xFF33691E), i / 8)!
          ..strokeWidth = 2.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + sway + 3, top - 2), width: 8, height: 14),
        Paint()..color = const Color(0xFF689F38).withValues(alpha: 0.85),
      );
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 7; i++) {
      final bx = (size.width * 0.12 + i * 48 + t * 18) % size.width;
      final by = size.height * 0.44 + (envPhase * 12 + i * 24) % (size.height * 0.3);
      canvas.drawCircle(
        Offset(bx, by),
        1.8 + i % 2,
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }
  }

  void _drawFireflies(Canvas canvas, Size size) {
    for (var i = 0; i < 6; i++) {
      final fx = (size.width * 0.08 + i * 55 + envPhase * 10) % size.width;
      final fy = size.height * 0.73 + math.sin(envPhase * 2 + i) * 10;
      canvas.drawCircle(
        Offset(fx, fy),
        2.5,
        Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DuckPondPainter old) =>
      old.t != t || old.sunset != sunset || old.envPhase != envPhase;
}
