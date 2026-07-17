import 'dart:math' as math;

import 'package:flutter/material.dart';

class FeedPondBackground extends StatefulWidget {
  const FeedPondBackground({
    super.key,
    required this.child,
    required this.nightFactor,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double nightFactor;
  final bool reducedMotion;
  final double intensity;

  @override
  State<FeedPondBackground> createState() => _FeedPondBackgroundState();
}

class _FeedPondBackgroundState extends State<FeedPondBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FeedPondPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            night: widget.nightFactor.clamp(0.0, 1.0),
            intensity: widget.intensity,
            reducedMotion: widget.reducedMotion,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _FeedPondPainter extends CustomPainter {
  _FeedPondPainter({
    required this.t,
    required this.night,
    required this.intensity,
    required this.reducedMotion,
  });

  final double t;
  final double night;
  final double intensity;
  final bool reducedMotion;

  Color _lerp(Color day, Color nite) => Color.lerp(day, nite, night)!;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);

    final day = (1 - night).clamp(0.0, 1.0);
    if (night > 0.15) _drawTwinklingStars(canvas, size);
    if (night > 0.3) _drawMoon(canvas, size);
    if (day > 0.2) _drawSun(canvas, size, day);
    if (day > 0.15) _drawClouds(canvas, size, day);

    _drawHills(canvas, size);
    _drawWater(canvas, size);
    _drawLilyPads(canvas, size);
    _drawReeds(canvas, size);
    _drawShoreFlowers(canvas, size);
    _drawFish(canvas, size);
    _drawBubbles(canvas, size);
    if (night > 0.4) _drawNightGlow(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFF4FC3F7), const Color(0xFF0D1B4C)),
            _lerp(const Color(0xFF81D4FA), const Color(0xFF1A237E)),
            _lerp(const Color(0xFFB3E5FC), const Color(0xFF283593)),
            _lerp(const Color(0xFFE1F5FE), const Color(0xFF1B5E20)),
          ],
          stops: const [0.0, 0.3, 0.55, 1.0],
        ).createShader(rect),
    );
  }

  void _drawTwinklingStars(Canvas canvas, Size size) {
    for (var i = 0; i < 36; i++) {
      final x = size.width * ((i * 47 + 13) % 97) / 100;
      final y = size.height * (0.03 + ((i * 31) % 38) / 100);
      final twinkle = 0.35 +
          (reducedMotion
              ? 0.4
              : (math.sin(t * math.pi * 4 + i * 1.7).abs() * 0.65));
      final r = 1.4 + (i % 4) * 0.7;
      canvas.drawCircle(
        Offset(x, y),
        r * twinkle,
        Paint()..color = Colors.white.withValues(alpha: twinkle * night),
      );
      // Soft glow on brighter stars
      if (i % 5 == 0) {
        canvas.drawCircle(
          Offset(x, y),
          r * 2.5,
          Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.15 * twinkle * night),
        );
      }
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    final moon = Offset(size.width * 0.84, size.height * 0.1);
    final alpha = ((night - 0.3) / 0.7).clamp(0.0, 1.0);
    canvas.drawCircle(
      moon,
      36,
      Paint()
        ..color = const Color(0xFFE3F2FD).withValues(alpha: 0.2 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(
      moon,
      26,
      Paint()..color = const Color(0xFFFFFDE7).withValues(alpha: alpha),
    );
    // Craters
    canvas.drawCircle(
      moon + const Offset(-6, -4),
      5,
      Paint()..color = const Color(0xFFE0E0E0).withValues(alpha: 0.45 * alpha),
    );
    canvas.drawCircle(
      moon + const Offset(8, 6),
      3.5,
      Paint()..color = const Color(0xFFE0E0E0).withValues(alpha: 0.35 * alpha),
    );
    canvas.drawCircle(
      moon + const Offset(4, -10),
      2.5,
      Paint()..color = const Color(0xFFE0E0E0).withValues(alpha: 0.3 * alpha),
    );
  }

  void _drawSun(Canvas canvas, Size size, double day) {
    final sun = Offset(size.width * 0.14, size.height * 0.1);
    canvas.drawCircle(
      sun,
      42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF59D).withValues(alpha: day),
            const Color(0xFFFFB74D).withValues(alpha: day * 0.6),
            const Color(0x00FFB74D),
          ],
          stops: const [0.2, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: sun, radius: 42)),
    );
    canvas.drawCircle(
      sun,
      22,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: day),
    );
    if (!reducedMotion) {
      for (var i = 0; i < 8; i++) {
        final a = t * math.pi * 2 + i * (math.pi / 4);
        canvas.drawLine(
          sun + Offset(math.cos(a) * 28, math.sin(a) * 28),
          sun + Offset(math.cos(a) * 40, math.sin(a) * 40),
          Paint()
            ..color = const Color(0xFFFFF59D).withValues(alpha: 0.55 * day)
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawClouds(Canvas canvas, Size size, double day) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9 * day);
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.08 + i * 0.26) + t * size.width * 0.04) %
              (size.width + 100) -
          40;
      final y = size.height * (0.07 + i * 0.025);
      canvas.drawCircle(Offset(x, y), 20, paint);
      canvas.drawCircle(Offset(x + 22, y + 3), 16, paint);
      canvas.drawCircle(Offset(x + 8, y - 10), 13, paint);
      canvas.drawCircle(Offset(x - 12, y + 2), 11, paint);
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final far = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.32, size.width * 0.5, size.height * 0.38)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.44, size.width, size.height * 0.36)
      ..lineTo(size.width, size.height * 0.48)
      ..lineTo(0, size.height * 0.48)
      ..close();
    canvas.drawPath(
      far,
      Paint()..color = _lerp(const Color(0xFF81C784), const Color(0xFF1B5E20)).withValues(alpha: 0.55),
    );

    final near = Path()
      ..moveTo(0, size.height * 0.44)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.38, size.width * 0.6, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.5, size.width, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.52)
      ..lineTo(0, size.height * 0.52)
      ..close();
    canvas.drawPath(
      near,
      Paint()..color = _lerp(const Color(0xFF66BB6A), const Color(0xFF2E7D32)),
    );
  }

  void _drawWater(Canvas canvas, Size size) {
    final top = size.height * 0.42;
    final waterRect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFF4FC3F7), const Color(0xFF01579B)).withValues(alpha: 0.88),
            _lerp(const Color(0xFF29B6F6), const Color(0xFF0277BD)).withValues(alpha: 0.92),
            _lerp(const Color(0xFF0288D1), const Color(0xFF002171)),
          ],
        ).createShader(waterRect),
    );

    // Surface shimmer
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, 10),
      Paint()..color = Colors.white.withValues(alpha: 0.18 * (1 - night * 0.5)),
    );

    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.12 * (1 - night * 0.4))
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final y = top + 20 + i * 26 + math.sin(t * math.pi * 2 + i) * 3;
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 18) {
        path.lineTo(x, y + math.sin(x / 34 + t * math.pi * 2 + i) * 4);
      }
      canvas.drawPath(path, wave);
    }

    // Moon / sun reflection
    if (night > 0.4) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.84, top + 40),
          width: 40,
          height: 12,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.12 * night),
      );
    } else if (night < 0.5) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.14, top + 36),
          width: 36,
          height: 10,
        ),
        Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.15 * (1 - night)),
      );
    }
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final pads = [
      (0.12, 0.58, 36.0),
      (0.88, 0.56, 42.0),
      (0.28, 0.68, 28.0),
      (0.72, 0.66, 30.0),
    ];
    for (final (nx, ny, w) in pads) {
      final sway = math.sin(t * 2.5 + nx * 8) * 2.5 * intensity;
      final c = Offset(size.width * nx + sway, size.height * ny);
      canvas.drawOval(
        Rect.fromCenter(center: c + const Offset(2, 3), width: w, height: w * 0.4),
        Paint()..color = const Color(0xFF01579B).withValues(alpha: 0.2),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c, width: w, height: w * 0.38),
        Paint()..color = _lerp(const Color(0xFF43A047), const Color(0xFF1B5E20)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + const Offset(-2, -1), width: w * 0.7, height: w * 0.26),
        Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.55),
      );
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.04 + i * 0.1);
      final sway = math.sin(t * math.pi * 2 + i) * 6 * intensity;
      final top = size.height * (0.36 + (i % 3) * 0.02);
      final base = size.height * 0.52;
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x + sway * 0.4, (top + base) / 2, x + sway, top),
        Paint()
          ..color = _lerp(const Color(0xFF689F38), const Color(0xFF33691E))
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + sway + 3, top), width: 9, height: 14),
        Paint()..color = const Color(0xFF7CB342).withValues(alpha: 0.85),
      );
    }
  }

  void _drawShoreFlowers(Canvas canvas, Size size) {
    const colors = [0xFFF48FB1, 0xFFFFEB3B, 0xFFFF7043, 0xFFCE93D8, 0xFF81D4FA];
    final scale = 1 - night * 0.25;
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.06 + i * 0.12);
      final y = size.height * 0.4 + math.sin(t * 2 + i) * 2;
      final color = Color(colors[i % colors.length]);
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(x + math.cos(a) * 5 * scale, y + math.sin(a) * 5 * scale),
          3.5 * scale,
          Paint()..color = color,
        );
      }
      canvas.drawCircle(Offset(x, y), 2.5 * scale, Paint()..color = const Color(0xFFFFF176));
    }
  }

  void _drawFish(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final x = ((0.15 + i * 0.22 + t * 0.12) % 1.0) * size.width;
      final y = size.height * (0.62 + (i % 2) * 0.08);
      final facing = (i % 2 == 0);
      canvas.save();
      canvas.translate(x, y);
      if (!facing) canvas.scale(-1, 1);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 10),
        Paint()..color = Color([0xFFFF7043, 0xFF42A5F5, 0xFFFFEE58, 0xFFAB47BC][i]).withValues(alpha: 0.55),
      );
      canvas.drawPath(
        Path()
          ..moveTo(-10, 0)
          ..lineTo(-16, -5)
          ..lineTo(-16, 5)
          ..close(),
        Paint()..color = Color([0xFFFF7043, 0xFF42A5F5, 0xFFFFEE58, 0xFFAB47BC][i]).withValues(alpha: 0.5),
      );
      canvas.restore();
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 0.09 + t * 0.12) % 1.0);
      final y = size.height * (0.52 + ((i * 0.07 + t * 0.15) % 0.35));
      final r = 2.0 + (i % 3);
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawNightGlow(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      size.width * 0.35,
      Paint()..color = const Color(0xFF1A237E).withValues(alpha: 0.08 * night),
    );
  }

  @override
  bool shouldRepaint(covariant _FeedPondPainter old) =>
      old.t != t || old.night != night || old.intensity != intensity;
}
