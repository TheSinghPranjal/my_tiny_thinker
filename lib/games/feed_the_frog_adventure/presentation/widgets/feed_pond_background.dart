import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';

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
    _drawReflections(canvas, size);
    _drawFish(canvas, size);
    _drawLilyPads(canvas, size);
    _drawReeds(canvas, size);
    _drawShoreFlowers(canvas, size);
    _drawBubbles(canvas, size);
    _drawForeground(canvas, size);
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
            _lerp(const Color(0xFF5DB8F5), const Color(0xFF0D1B4C)),
            _lerp(const Color(0xFF8ED0F8), const Color(0xFF1A237E)),
            _lerp(const Color(0xFFBFE6FB), const Color(0xFF283593)),
            _lerp(const Color(0xFFDDF3FD), const Color(0xFF1B5E20)),
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
    paintSmilingSun(
      canvas,
      Offset(size.width * 0.19, size.height * 0.205),
      38,
      rayPhase: reducedMotion ? 0 : t * math.pi * 2,
      faceColor: const Color(0xFF8D5A2B),
      alpha: day,
    );
  }

  void _drawClouds(Canvas canvas, Size size, double day) {
    void cloud(Offset c, double s) {
      paintPuffyCloud(
        canvas,
        c,
        s,
        width: 100,
        highlight: true,
        shadeColor: const Color(0xFFBFDCF5),
        shadeAlpha: 0.9 * day,
        bodyAlpha: 0.97 * day,
      );
    }

    for (final (nx, ny, sc) in [
      (0.03, 0.27, 1.0),
      (0.65, 0.2, 0.95),
      (0.93, 0.31, 0.85),
      (0.45, 0.35, 0.7),
    ]) {
      final x = (size.width * nx + t * size.width * 0.05) % (size.width + 160) - 60;
      cloud(Offset(x, size.height * ny), sc);
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Distant teal mountains.
    final mtn = Path()
      ..moveTo(0, h * 0.42)
      ..quadraticBezierTo(w * 0.18, h * 0.32, w * 0.4, h * 0.4)
      ..quadraticBezierTo(w * 0.66, h * 0.31, w, h * 0.41)
      ..lineTo(w, h * 0.5)
      ..lineTo(0, h * 0.5)
      ..close();
    canvas.drawPath(
      mtn,
      Paint()..color = _lerp(const Color(0xFF7FC7B6), const Color(0xFF14403A)).withValues(alpha: 0.85),
    );

    final far = Path()
      ..moveTo(0, h * 0.43)
      ..quadraticBezierTo(w * 0.22, h * 0.38, w * 0.5, h * 0.43)
      ..quadraticBezierTo(w * 0.78, h * 0.47, w, h * 0.4)
      ..lineTo(w, h * 0.56)
      ..lineTo(0, h * 0.56)
      ..close();
    canvas.drawPath(
      far,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFFB6E36A), const Color(0xFF2A7A2E)),
            _lerp(const Color(0xFF8FCE52), const Color(0xFF1B5E20)),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.38, w, h * 0.18)),
    );

    // Round trees.
    for (final (nx, ny, sc) in [(0.055, 0.44, 1.0), (0.95, 0.4, 1.5), (0.84, 0.435, 0.85)]) {
      final base = Offset(w * nx, h * ny);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(base.dx - 3.5 * sc, base.dy - 14 * sc, 7 * sc, 20 * sc),
          Radius.circular(2 * sc),
        ),
        Paint()..color = _lerp(const Color(0xFF8D6E63), const Color(0xFF3E2723)),
      );
      final leaf = _lerp(const Color(0xFF5CB85C), const Color(0xFF1B5E20));
      canvas.drawCircle(base + Offset(0, -34 * sc), 24 * sc, Paint()..color = leaf);
      canvas.drawCircle(
        base + Offset(-7 * sc, -40 * sc),
        12 * sc,
        Paint()..color = _lerp(const Color(0xFF7CCB6E), const Color(0xFF2E7D32)),
      );
    }

    // Small wooden fence on the right hill.
    final wood = Paint()
      ..color = _lerp(const Color(0xFFB08968), const Color(0xFF3E2723))
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.74, h * 0.418), Offset(w * 0.96, h * 0.396), wood);
    canvas.drawLine(Offset(w * 0.74, h * 0.436), Offset(w * 0.96, h * 0.414), wood);
    for (var i = 0; i < 5; i++) {
      final x = w * (0.75 + i * 0.05);
      final y = h * (0.422 - i * 0.0043);
      canvas.drawLine(Offset(x, y - h * 0.018), Offset(x, y + h * 0.024), wood);
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final top = size.height * 0.53;
    final waterRect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFF69C7F0), const Color(0xFF01579B)),
            _lerp(const Color(0xFF4BB2EE), const Color(0xFF0277BD)),
            _lerp(const Color(0xFF3B9BE4), const Color(0xFF01579B)),
            _lerp(const Color(0xFF2E86D2), const Color(0xFF002171)),
          ],
          stops: const [0.0, 0.3, 0.65, 1.0],
        ).createShader(waterRect),
    );

    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.2 * (1 - night * 0.4))
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 7; i++) {
      final y = top + 40 + i * 42 + (reducedMotion ? 0 : math.sin(t * math.pi * 2 + i) * 3);
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 14) {
        path.lineTo(x, y + math.sin(x / 30 + t * math.pi * 2 + i) * 3.5);
      }
      canvas.drawPath(path, wave);
    }

    // Darker haze toward the bottom for depth.
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x00003C8F),
            const Color(0x33003C8F),
          ],
        ).createShader(Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2)),
    );
  }

  void _drawReflections(Canvas canvas, Size size) {
    // Wobbly green columns mirroring the reeds above.
    final top = size.height * 0.545;
    for (var i = 0; i < 22; i++) {
      final x = size.width * (0.02 + i * 0.046);
      final len = size.height * (0.07 + (i % 4) * 0.02);
      final path = Path()..moveTo(x, top);
      for (var y = 0.0; y <= len; y += 8) {
        path.lineTo(
          x + math.sin(y / 9 + i + (reducedMotion ? 0 : t * math.pi * 2)) * 2.5,
          top + y,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2E7D32).withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
    if (night > 0.4) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.width * 0.84, top + 60), width: 44, height: 12),
        Paint()..color = Colors.white.withValues(alpha: 0.12 * night),
      );
    }
  }

  void _drawLotus(Canvas canvas, Offset c, double scale) {
    Path petal(double len, double wid) => Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(wid, -len * 0.45, 0, -len)
      ..quadraticBezierTo(-wid, -len * 0.45, 0, 0)
      ..close();

    final back = Paint()..color = _lerp(const Color(0xFFE3EEF7), const Color(0xFF90A4AE));
    final front = Paint()..color = _lerp(Colors.white, const Color(0xFFCFD8DC));
    final edge = Paint()
      ..color = const Color(0xFFB7C9D9).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (final (ang, len, wid, paint) in [
      (-1.2, 30.0, 10.0, back),
      (1.2, 30.0, 10.0, back),
      (-0.7, 36.0, 12.0, back),
      (0.7, 36.0, 12.0, back),
      (-0.3, 38.0, 13.0, front),
      (0.3, 38.0, 13.0, front),
      (0.0, 40.0, 13.0, front),
    ]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(scale);
      canvas.rotate(ang);
      final path = petal(len, wid);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, edge);
      canvas.restore();
    }
    canvas.drawCircle(
      c + Offset(0, -6 * scale),
      6.5 * scale,
      Paint()..color = const Color(0xFFFFC928),
    );
    canvas.drawCircle(
      c + Offset(-1.5 * scale, -8 * scale),
      2.2 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawLilyPad(Canvas canvas, Offset c, double w, {double lotus = 0}) {
    // Soft ripple.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, w * 0.14), width: w * 1.3, height: w * 0.38),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    // Thick underside.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, w * 0.075), width: w, height: w * 0.36),
      Paint()..color = _lerp(const Color(0xFF3C9A3A), const Color(0xFF0D3B12)),
    );
    final top = Rect.fromCenter(center: c, width: w, height: w * 0.36);
    canvas.drawOval(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFFA3E06A), const Color(0xFF2E7D32)),
            _lerp(const Color(0xFF63BB47), const Color(0xFF1B5E20)),
          ],
        ).createShader(top),
    );
    canvas.drawLine(
      c + Offset(-w * 0.05, 0),
      c + Offset(w * 0.4, w * 0.04),
      Paint()
        ..color = _lerp(const Color(0xFF3E8E35), const Color(0xFF0D3B12)).withValues(alpha: 0.5)
        ..strokeWidth = 1.6,
    );
    if (lotus > 0) _drawLotus(canvas, c + Offset(-w * 0.02, -w * 0.02), lotus);
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final s = (reducedMotion ? 0.0 : math.sin(t * 2.5)) * 2 * intensity;
    _drawLilyPad(canvas, Offset(w * 0.28 - s, h * 0.577), 110);
    _drawLilyPad(canvas, Offset(w * 0.82 + s, h * 0.585), 120);
    _drawLilyPad(canvas, Offset(w * 0.1 + s, h * 0.622), 150, lotus: 0.9);
    _drawLilyPad(canvas, Offset(w * 0.9 - s, h * 0.675), 140, lotus: 0.95);
  }

  void _drawBlade(Canvas canvas, Offset base, double height, double lean, double width, Color color) {
    final tip = base + Offset(lean, -height);
    final path = Path()
      ..moveTo(base.dx - width, base.dy)
      ..quadraticBezierTo(base.dx - width * 0.6 + lean * 0.2, base.dy - height * 0.55, tip.dx, tip.dy)
      ..quadraticBezierTo(base.dx + width * 0.8 + lean * 0.5, base.dy - height * 0.5, base.dx + width, base.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - width * 0.1, base.dy)
        ..quadraticBezierTo(base.dx + lean * 0.3, base.dy - height * 0.55, tip.dx, tip.dy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawReeds(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final base = h * 0.545;
    final greens = [
      _lerp(const Color(0xFF2F8A32), const Color(0xFF123F16)),
      _lerp(const Color(0xFF3E9E3A), const Color(0xFF1B5E20)),
      _lerp(const Color(0xFF58B04A), const Color(0xFF256B2A)),
    ];
    // Back row of grass blades, then a fuller front row.
    for (var row = 0; row < 2; row++) {
      final count = row == 0 ? 42 : 30;
      for (var i = 0; i < count; i++) {
        final x = w * ((i + (row == 0 ? 0.2 : 0.6)) / count) + math.sin(i * 12.9 + row) * 5;
        final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 + i * 0.7) * 4 * intensity;
        final height = h * (0.075 + ((i * 7 + row * 3) % 6) * 0.014) * (row == 0 ? 1.0 : 0.82);
        final lean = ((i * 5) % 7 - 3) * 3.5 + sway;
        _drawBlade(
          canvas,
          Offset(x, base + (row == 0 ? 0 : 4)),
          height,
          lean,
          3.2,
          greens[(i + row) % 3],
        );
      }
    }
    // Cattails.
    for (var i = 0; i < 9; i++) {
      final x = w * (0.06 + i * 0.111);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 + i * 1.3) * 4 * intensity;
      final top = h * (0.4 + ((i * 5) % 4) * 0.022);
      canvas.drawPath(
        Path()
          ..moveTo(x, base + 6)
          ..quadraticBezierTo(x + sway * 0.4, (top + base) / 2, x + sway, top + 12),
        Paint()
          ..color = greens[0]
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      final head = Rect.fromCenter(center: Offset(x + sway, top - 6), width: 16, height: 46);
      canvas.drawRRect(
        RRect.fromRectAndRadius(head, const Radius.circular(8)),
        Paint()
          ..shader = LinearGradient(
            colors: [
              _lerp(const Color(0xFF6B4226), const Color(0xFF2A1810)),
              _lerp(const Color(0xFFA0683A), const Color(0xFF3E2723)),
              _lerp(const Color(0xFF6B4226), const Color(0xFF2A1810)),
            ],
          ).createShader(head),
      );
      canvas.drawLine(
        Offset(x + sway - 3, top - 24),
        Offset(x + sway - 3, top + 10),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(x + sway, top - 29),
        Offset(x + sway + 1, top - 36),
        Paint()
          ..color = _lerp(const Color(0xFF6B4226), const Color(0xFF2A1810))
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawShoreFlowers(Canvas canvas, Size size) {
    final scale = 1 - night * 0.25;
    final petal = Paint()..color = Color.lerp(Colors.white, const Color(0xFFB0BEC5), night * 0.6)!;
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.04 + i * 0.07 + ((i * 7) % 3) * 0.01);
      final y = size.height * (0.475 + ((i * 5) % 5) * 0.016);
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5 - math.pi / 2;
        canvas.drawCircle(
          Offset(x + math.cos(a) * 6 * scale, y + math.sin(a) * 6 * scale),
          4.6 * scale,
          petal,
        );
      }
      canvas.drawCircle(Offset(x, y), 3.4 * scale, Paint()..color = const Color(0xFFFFB300));
    }
  }

  void _drawFish(Canvas canvas, Size size) {
    // (x, y, colour, scale, phase offset)
    final fish = [
      (0.18, 0.685, 0xFFF26A4B, 1.15, 0.0),
      (0.1, 0.74, 0xFF4A90E2, 0.9, 1.7),
      (0.84, 0.735, 0xFFE8479A, 1.0, 3.1),
      (0.92, 0.775, 0xFF4A6FD8, 0.85, 4.4),
      (0.64, 0.9, 0xFF3F51B5, 1.05, 2.3),
    ];
    for (var i = 0; i < fish.length; i++) {
      final (nx, ny, col, sc, ph) = fish[i];
      final swim = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 + ph);
      final facingRight = math.cos(t * math.pi * 2 + ph) >= 0;
      final c = Color(col);
      canvas.save();
      canvas.translate(size.width * nx + swim * 16, size.height * ny + math.sin(ph) * 2);
      canvas.scale(sc * (facingRight ? 1 : -1), sc);
      // Shadow on the water below.
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 22), width: 34, height: 7),
        Paint()..color = const Color(0xFF01579B).withValues(alpha: 0.2),
      );
      canvas.drawPath(
        Path()
          ..moveTo(-12, 0)
          ..quadraticBezierTo(-20, -9, -27, -9)
          ..quadraticBezierTo(-22, 0, -27, 9)
          ..quadraticBezierTo(-20, 9, -12, 0)
          ..close(),
        Paint()..color = Color.lerp(c, Colors.white, 0.15)!,
      );
      final body = Rect.fromCenter(center: Offset.zero, width: 38, height: 19);
      canvas.drawOval(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(c, Colors.white, 0.35)!, c, Color.lerp(c, Colors.black, 0.2)!],
          ).createShader(body),
      );
      canvas.drawPath(
        Path()
          ..moveTo(-4, -8)
          ..quadraticBezierTo(2, -15, 9, -8)
          ..close(),
        Paint()..color = Color.lerp(c, Colors.black, 0.1)!,
      );
      canvas.drawCircle(const Offset(10, -2), 3, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(10.8, -2), 1.5, Paint()..color = const Color(0xFF212121));
      canvas.restore();
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final x = size.width * (0.06 + ((i * 37) % 88) / 100);
      final p = (reducedMotion ? i / 12 : (t * 2 + i * 0.083) % 1.0);
      final y = size.height * (0.93 - p * 0.3);
      final r = 3.0 + (i % 4) * 2.5;
      final c = Offset(x, y);
      canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.12));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
      canvas.drawCircle(c + Offset(-r * 0.35, -r * 0.35), r * 0.25, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  void _drawForeground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint underwater plants.
    for (var i = 0; i < 8; i++) {
      final left = i < 4;
      final x = left ? w * (0.03 + i * 0.04) : w * (0.86 + (i - 4) * 0.035);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 * 2 + i) * 5;
      canvas.drawPath(
        Path()
          ..moveTo(x, h * 0.95)
          ..quadraticBezierTo(x + 16 + sway, h * 0.88, x + 4 + sway, h * (0.78 + (i % 3) * 0.02)),
        Paint()
          ..color = const Color(0xFF2E7D6E).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }

    void leaf(Offset base, double length, double angle, Color light, Color dark) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.3, -length * 0.3, length, -length * 0.02)
        ..quadraticBezierTo(length * 0.4, length * 0.16, 0, 0)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(colors: [dark, light]).createShader(
            Rect.fromLTWH(0, -length * 0.3, length, length * 0.5),
          ),
      );
      canvas.drawLine(
        Offset.zero,
        Offset(length * 0.92, -length * 0.03),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.restore();
    }

    final l1 = _lerp(const Color(0xFF52A14A), const Color(0xFF1B5E20));
    final d1 = _lerp(const Color(0xFF2F7D32), const Color(0xFF0B2E10));
    final l2 = _lerp(const Color(0xFF3F8F3A), const Color(0xFF14481B));
    leaf(Offset(-8, h * 1.0), 230, -1.2, l1, d1);
    leaf(Offset(6, h * 1.02), 190, -0.55, l2, d1);
    leaf(Offset(w + 8, h * 1.0), 240, -math.pi + 1.2, l1, d1);
    leaf(Offset(w - 4, h * 1.02), 190, -math.pi + 0.5, l2, d1);
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
