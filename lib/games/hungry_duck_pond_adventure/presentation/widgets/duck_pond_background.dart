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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 24))
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
    _drawWater(canvas, size);
    _drawLilyPads(canvas, size);
    _drawReeds(canvas, size);
    _drawShore(canvas, size);
    _drawShoreDetails(canvas, size);
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
            _lerpSky(const Color(0xFF4FC3F7), const Color(0xFFFF8A65)),
            _lerpSky(const Color(0xFF81D4FA), const Color(0xFFFFAB91)),
            _lerpSky(const Color(0xFFB3E5FC), const Color(0xFFFFCCBC)),
          ],
        ).createShader(rect),
    );

    final sunY = size.height * (0.09 + sunset * 0.08);
    final sunCenter = Offset(size.width * 0.86, sunY);
    canvas.drawCircle(
      sunCenter,
      40,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFB74D), Color(0x00FFB74D)],
          stops: [0.15, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 40)),
    );
    canvas.drawCircle(sunCenter, 22 - sunset * 4, Paint()..color = const Color(0xFFFFF176));
  }

  void _drawHills(Canvas canvas, Size size) {
    final far = Path()
      ..moveTo(0, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.45, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.38, size.width, size.height * 0.26)
      ..lineTo(size.width, size.height * 0.36)
      ..lineTo(0, size.height * 0.36)
      ..close();
    canvas.drawPath(
      far,
      Paint()..color = _lerpSky(const Color(0xFF81C784), const Color(0xFF8D6E63)).withValues(alpha: 0.45),
    );

    final near = Path()
      ..moveTo(0, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.26, size.width * 0.55, size.height * 0.33)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.38, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.38)
      ..lineTo(0, size.height * 0.38)
      ..close();
    canvas.drawPath(
      near,
      Paint()..color = _lerpSky(const Color(0xFF66BB6A), const Color(0xFF6D4C41)).withValues(alpha: 0.55),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.88 - sunset * 0.25);
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.04 + i * 0.28) + t * size.width * 0.03) % (size.width + 100) - 40;
      final y = size.height * 0.05 + i * 7.0;
      canvas.drawCircle(Offset(x, y), 22, paint);
      canvas.drawCircle(Offset(x + 24, y + 3), 17, paint);
      canvas.drawCircle(Offset(x + 10, y - 10), 14, paint);
      canvas.drawCircle(Offset(x - 12, y + 2), 12, paint);
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterTop = size.height * 0.28;
    final waterRect = Rect.fromLTWH(0, waterTop, size.width, size.height * 0.48);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerpSky(const Color(0xFF4FC3F7), const Color(0xFFFF7043)).withValues(alpha: 0.82),
            _lerpSky(const Color(0xFF29B6F6), const Color(0xFF5C6BC0)).withValues(alpha: 0.9),
            _lerpSky(const Color(0xFF0288D1), const Color(0xFF4527A0)).withValues(alpha: 0.95),
            _lerpSky(const Color(0xFF01579B), const Color(0xFF311B92)),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ).createShader(waterRect),
    );

    // Surface shimmer
    canvas.drawRect(
      Rect.fromLTWH(0, waterTop, size.width, 10),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Animated ripples
    for (var layer = 0; layer < 5; layer++) {
      final yBase = waterTop + 18 + layer * 20;
      for (var i = 0; i < 6; i++) {
        final rx = size.width * (0.05 + i * 0.17) + layer * 10 + math.sin(t * 2 + i) * 6;
        final ry = yBase + math.sin(t * 3.5 + i + layer) * 3.5;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(rx, ry), width: 48 - layer * 5, height: 6),
          Paint()..color = Colors.white.withValues(alpha: 0.1 + layer * 0.012),
        );
      }
    }

    // Light caustic patches
    for (var i = 0; i < 5; i++) {
      final cx = size.width * (0.1 + i * 0.18) + math.sin(t * 2 + i) * 12;
      final cy = waterTop + 40 + (i % 3) * 28;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 12),
        Paint()..color = const Color(0xFFB3E5FC).withValues(alpha: 0.08),
      );
    }
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final pads = [
      (Offset(size.width * 0.14, size.height * 0.58), 38.0),
      (Offset(size.width * 0.82, size.height * 0.54), 44.0),
      (Offset(size.width * 0.52, size.height * 0.64), 34.0),
      (Offset(size.width * 0.32, size.height * 0.68), 28.0),
    ];
    for (final (p, w) in pads) {
      final sway = math.sin(t * 2.5 + p.dx) * 2.5;
      final center = p + Offset(sway, 0);
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(2, 3), width: w, height: w * 0.42),
        Paint()..color = const Color(0xFF01579B).withValues(alpha: 0.25),
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w, height: w * 0.4),
        Paint()..color = const Color(0xFF43A047),
      );
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(-2, -1), width: w * 0.72, height: w * 0.28),
        Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.7),
      );
      // Notch
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - w * 0.18)
          ..lineTo(center.dx + 7, center.dy)
          ..lineTo(center.dx, center.dy + 2)
          ..close(),
        Paint()..color = const Color(0xFF0277BD).withValues(alpha: 0.4),
      );
      // Flower
      final flower = center + Offset(4, -w * 0.22);
      for (var i = 0; i < 5; i++) {
        final a = i * math.pi * 2 / 5;
        canvas.drawCircle(
          flower + Offset(math.cos(a) * 5, math.sin(a) * 5),
          3.5,
          Paint()..color = Color([0xFFF48FB1, 0xFFFFEB3B, 0xFFFF8A65, 0xFFCE93D8, 0xFF81D4FA][i % 5]),
        );
      }
      canvas.drawCircle(flower, 3, Paint()..color = const Color(0xFFFFF176));
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.04 + i * 0.1);
      final sway = math.sin(t * 1.8 + i) * 6 * intensity;
      final top = size.height * (0.38 + (i % 3) * 0.035);
      final base = size.height * 0.72;
      final stem = Path()
        ..moveTo(x, base)
        ..quadraticBezierTo(x + sway * 0.4, (top + base) / 2, x + sway, top);
      canvas.drawPath(
        stem,
        Paint()
          ..color = Color.lerp(const Color(0xFF689F38), const Color(0xFF33691E), i / 10)!
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      // Leaf tip
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + sway + 4, top), width: 10, height: 16),
        Paint()..color = const Color(0xFF7CB342).withValues(alpha: 0.9),
      );
    }
  }

  void _drawShore(Canvas canvas, Size size) {
    final shoreTop = size.height * 0.72;
    final shorePath = Path()
      ..moveTo(0, shoreTop + 8)
      ..quadraticBezierTo(size.width * 0.2, shoreTop - 6, size.width * 0.4, shoreTop + 4)
      ..quadraticBezierTo(size.width * 0.65, shoreTop + 14, size.width * 0.85, shoreTop)
      ..quadraticBezierTo(size.width * 0.95, shoreTop - 4, size.width, shoreTop + 6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      shorePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerpSky(const Color(0xFF81C784), const Color(0xFF8D6E63)),
            _lerpSky(const Color(0xFF66BB6A), const Color(0xFF6D4C41)),
            _lerpSky(const Color(0xFF43A047), const Color(0xFF4E342E)),
          ],
        ).createShader(Rect.fromLTWH(0, shoreTop, size.width, size.height * 0.28)),
    );
  }

  void _drawShoreDetails(Canvas canvas, Size size) {
    final shoreTop = size.height * 0.74;

    // Grass blades
    for (var i = 0; i < 28; i++) {
      final x = size.width * ((i * 37) % 97) / 100;
      final h = 10.0 + (i % 5) * 3;
      final sway = math.sin(t * 3 + i) * 2 * intensity;
      canvas.drawLine(
        Offset(x, shoreTop + 6),
        Offset(x + sway, shoreTop + 6 - h),
        Paint()
          ..color = Color.lerp(const Color(0xFF9CCC65), const Color(0xFF558B2F), (i % 4) / 4)!
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Flowers on shore
    const flowerColors = [0xFFF48FB1, 0xFFFFEB3B, 0xFFFF7043, 0xFFCE93D8, 0xFF81D4FA, 0xFFFFCC80];
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 41 + 7) % 94) / 100;
      final y = shoreTop + 18 + (i % 3) * 14.0;
      final color = Color(flowerColors[i % flowerColors.length]);
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(x + math.cos(a) * 4, y + math.sin(a) * 4),
          3,
          Paint()..color = color,
        );
      }
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = const Color(0xFFFFF176));
      canvas.drawLine(
        Offset(x, y + 4),
        Offset(x, y + 12),
        Paint()
          ..color = const Color(0xFF66BB6A)
          ..strokeWidth = 1.5,
      );
    }

    // Pebbles
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.06 + i * 0.12);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, shoreTop + 10 + (i % 2) * 6),
          width: 10 + i % 3 * 2,
          height: 6,
        ),
        Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.4),
      );
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final bx = (size.width * 0.1 + i * 42 + t * 22) % size.width;
      final by = size.height * 0.42 + (envPhase * 14 + i * 22) % (size.height * 0.28);
      final r = 2.0 + i % 3;
      canvas.drawCircle(
        Offset(bx, by),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(
        Offset(bx - r * 0.25, by - r * 0.25),
        r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  void _drawFireflies(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final fx = (size.width * 0.08 + i * 50 + envPhase * 12) % size.width;
      final fy = size.height * 0.75 + math.sin(envPhase * 2 + i) * 12;
      canvas.drawCircle(
        Offset(fx, fy),
        3,
        Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DuckPondPainter old) =>
      old.t != t || old.sunset != sunset || old.envPhase != envPhase;
}
