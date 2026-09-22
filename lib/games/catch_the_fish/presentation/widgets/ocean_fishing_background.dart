import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';

class OceanFishingBackground extends StatefulWidget {
  const OceanFishingBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.showCelebration = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;
  final bool showCelebration;

  @override
  State<OceanFishingBackground> createState() => _OceanFishingBackgroundState();
}

class _OceanFishingBackgroundState extends State<OceanFishingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    if (!widget.reducedMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant OceanFishingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.reducedMotion
        ? widget.envPhase * 0.08
        : _controller.value;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OceanFishingPainter(
            t: widget.reducedMotion ? t : _controller.value,
            envPhase: widget.envPhase,
            reducedMotion: widget.reducedMotion,
            showCelebration: widget.showCelebration,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _OceanFishingPainter extends CustomPainter {
  _OceanFishingPainter({
    required this.t,
    required this.envPhase,
    required this.reducedMotion,
    required this.showCelebration,
  });

  final double t;
  final double envPhase;
  final bool reducedMotion;
  final bool showCelebration;

  // Layout (fractions of the full screen height).
  static const _shoreY = 0.30;
  static const _surfaceY = 0.43;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    _drawHills(canvas, size);
    _drawWater(canvas, size);
    _drawLilyPads(canvas, size);
    _drawSurfaceLine(canvas, size);
    _drawLightRays(canvas, size);
    _drawSilhouettes(canvas, size);
    _drawSeaweed(canvas, size);
    _drawSeabed(canvas, size);
    _drawBubbles(canvas, size);
    if (showCelebration) _drawCelebrationSparkles(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * _shoreY + 20);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FB3F6), Color(0xFF8AD0FA), Color(0xFFCDEBFB)],
        ).createShader(rect),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.4;
    final cy = size.height * (_shoreY + 0.03);
    const colors = [
      Color(0xFFF48FB1),
      Color(0xFFFFCC80),
      Color(0xFFFFF59D),
      Color(0xFFA5D6A7),
      Color(0xFF81D4FA),
      Color(0xFFB39DDB),
    ];
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * 11.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width * 0.6 - shrink,
          height: size.height * 0.2 - shrink * 0.8,
        ),
        math.pi + 0.05,
        math.pi - 0.1,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    paintSmilingSun(
      canvas,
      Offset(size.width * 0.85, size.height * 0.055),
      32,
      rayPhase: t * math.pi * 2,
      rays: !reducedMotion,
      cheeks: false,
      faceColor: const Color(0xFFFF9800),
      rayColor: const Color(0xFFFFF59D),
      coreColor: const Color(0xFFFFF176),
    );
  }

  void _drawCloud(Canvas canvas, Offset c, double s) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, 8 * s), width: 74 * s, height: 22 * s),
        Radius.circular(12 * s),
      ),
      paint,
    );
    canvas.drawCircle(c + Offset(-14 * s, 0), 15 * s, paint);
    canvas.drawCircle(c + Offset(6 * s, -8 * s), 19 * s, paint);
    canvas.drawCircle(c + Offset(24 * s, 0), 13 * s, paint);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final drift = t * size.width * 0.04;
    for (final (nx, ny, sc) in [
      (0.1, 0.08, 1.1),
      (0.5, 0.075, 0.9),
      (0.05, 0.27, 0.8),
      (0.78, 0.25, 1.0),
      (0.4, 0.3, 0.7),
    ]) {
      final x = (size.width * nx + drift) % (size.width + 120) - 40;
      _drawCloud(canvas, Offset(x, size.height * ny), sc);
    }
  }

  void _drawTree(Canvas canvas, Offset base, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 3 * s, base.dy - 26 * s, 6 * s, 30 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    final leaf = Paint()..color = const Color(0xFF43A047);
    canvas.drawOval(
      Rect.fromCenter(center: base + Offset(0, -46 * s), width: 34 * s, height: 60 * s),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(center: base + Offset(-4 * s, -50 * s), width: 18 * s, height: 40 * s),
      Paint()..color = const Color(0xFF66BB6A),
    );
  }

  void _drawHills(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final shore = h * _shoreY;

    final far = Path()
      ..moveTo(0, shore - 30)
      ..quadraticBezierTo(w * 0.2, shore - 70, w * 0.45, shore - 28)
      ..quadraticBezierTo(w * 0.7, shore - 56, w, shore - 40)
      ..lineTo(w, shore + 10)
      ..lineTo(0, shore + 10)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF9CCC65));

    for (final (nx, ny, sc) in [(0.15, -34.0, 1.0), (0.93, -30.0, 1.1)]) {
      _drawTree(canvas, Offset(w * nx, shore + ny), sc);
    }

    final near = Path()
      ..moveTo(0, shore - 4)
      ..quadraticBezierTo(w * 0.28, shore - 34, w * 0.55, shore - 8)
      ..quadraticBezierTo(w * 0.82, shore - 24, w, shore - 6)
      ..lineTo(w, shore + 12)
      ..lineTo(0, shore + 12)
      ..close();
    canvas.drawPath(
      near,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8BC34A), Color(0xFF558B2F)],
        ).createShader(Rect.fromLTWH(0, shore - 34, w, 46)),
    );
    // Bank bushes.
    for (final nx in [0.03, 0.08, 0.9, 0.97]) {
      canvas.drawCircle(
        Offset(w * nx, shore - 4),
        14,
        Paint()..color = const Color(0xFF558B2F),
      );
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final top = size.height * _shoreY;
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5BC8F0),
            Color(0xFF3AB0E8),
            Color(0xFF2196D8),
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
          ],
          stops: [0.0, 0.25, 0.45, 0.75, 1.0],
        ).createShader(rect),
    );
    // Gentle ripples on the lake surface.
    for (var i = 0; i < 6; i++) {
      final y = top + 26 + i * 16.0;
      for (var j = 0; j < 4; j++) {
        final x = size.width * (0.12 + j * 0.26 + (i.isOdd ? 0.1 : 0)) +
            (reducedMotion ? 0 : math.sin(t * math.pi * 2 + i + j) * 8);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 60 - i * 4, height: 5),
          Paint()..color = Colors.white.withValues(alpha: 0.16),
        );
      }
    }
  }

  void _drawLilyPad(Canvas canvas, Offset c, double s, {bool flower = true}) {
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, 4 * s), width: 88 * s, height: 26 * s),
      Paint()..color = const Color(0xFF2E7D32),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 88 * s, height: 26 * s),
      Paint()..color = const Color(0xFF66BB6A),
    );
    if (!flower) return;
    for (final (dx, ang) in [(-12.0, -0.4), (12.0, 0.4), (0.0, 0.0)]) {
      canvas.save();
      canvas.translate(c.dx + dx * s, c.dy - 4 * s);
      canvas.rotate(ang);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -10 * s), width: 13 * s, height: 26 * s),
        Paint()..color = Colors.white,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      c + Offset(0, -5 * s),
      5 * s,
      Paint()..color = const Color(0xFFFFCA28),
    );
  }

  void _drawLilyPads(Canvas canvas, Size size) {
    final h = size.height;
    _drawLilyPad(canvas, Offset(size.width * 0.18, h * 0.365), 1.0);
    _drawLilyPad(canvas, Offset(size.width * 0.1, h * 0.335), 0.7, flower: false);
    _drawLilyPad(canvas, Offset(size.width * 0.86, h * 0.335), 0.8);
    _drawLilyPad(canvas, Offset(size.width * 0.92, h * 0.365), 0.7);
  }

  void _drawSurfaceLine(Canvas canvas, Size size) {
    final y0 = size.height * _surfaceY;
    final wave = Path();
    for (var x = 0.0; x <= size.width; x += 6) {
      final y = y0 +
          (reducedMotion ? 0 : math.sin(x * 0.03 + t * math.pi * 2 + envPhase) * 3);
      x == 0 ? wave.moveTo(x, y) : wave.lineTo(x, y);
    }
    canvas.drawPath(
      wave,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      wave.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLightRays(Canvas canvas, Size size) {
    final top = size.height * _surfaceY;
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.15 + i * 0.14);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 + i) * 10;
      final ray = Path()
        ..moveTo(x, top)
        ..lineTo(x + 26, top)
        ..lineTo(x + 90 + sway, top + size.height * 0.4)
        ..lineTo(x + 30 + sway, top + size.height * 0.4)
        ..close();
      canvas.drawPath(
        ray,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(x, top, 120, size.height * 0.4)),
      );
    }
  }

  void _drawSilhouettes(Canvas canvas, Size size) {
    for (final (nx, ny, sc) in [(0.5, 0.53, 1.0), (0.86, 0.615, 1.1)]) {
      final c = Offset(size.width * nx, size.height * ny);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(sc);
      final paint = Paint()..color = const Color(0xFF1E5FA8).withValues(alpha: 0.45);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 56, height: 32), paint);
      canvas.drawPath(
        Path()
          ..moveTo(24, 0)
          ..lineTo(46, -14)
          ..lineTo(46, 14)
          ..close(),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawSeaweed(Canvas canvas, Size size) {
    final base = size.height * 0.98;
    for (var i = 0; i < 16; i++) {
      final left = i < 8;
      final x = left
          ? size.width * (0.01 + i * 0.022)
          : size.width * (0.99 - (i - 8) * 0.022);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 2 * 2 + i + envPhase) * 8;
      final hgt = size.height * (0.22 + (i % 4) * 0.05);
      final lean = left ? 14.0 : -14.0;
      final path = Path()
        ..moveTo(x, base)
        ..cubicTo(
          x + sway - lean,
          base - hgt * 0.35,
          x - sway + lean,
          base - hgt * 0.7,
          x + sway * 0.5,
          base - hgt,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF1B7A3A),
            const Color(0xFF66BB6A),
            (i % 4) / 4,
          )!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9 - (i % 3) * 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
    // A short cluster in the middle.
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.31 + i * 0.03);
      final sway = reducedMotion ? 0.0 : math.sin(t * math.pi * 4 + i) * 6;
      canvas.drawPath(
        Path()
          ..moveTo(x, base)
          ..quadraticBezierTo(x + sway, base - 60, x + sway * 0.5 + (i - 1.5) * 6, base - 90 - i * 8),
        Paint()
          ..color = const Color(0xFF2E9F4A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawRock(Canvas canvas, Offset c, double w, double h) {
    final rock = Path()
      ..moveTo(c.dx - w / 2, c.dy)
      ..quadraticBezierTo(c.dx - w * 0.45, c.dy - h, c.dx, c.dy - h)
      ..quadraticBezierTo(c.dx + w * 0.45, c.dy - h, c.dx + w / 2, c.dy)
      ..close();
    canvas.drawPath(
      rock,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8C8FA8), Color(0xFF555872)],
        ).createShader(Rect.fromLTWH(c.dx - w / 2, c.dy - h, w, h)),
    );
  }

  void _drawCoral(Canvas canvas, Offset base, Color color, double s) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;
    for (final (dx, dy) in [(-14.0, -34.0), (0.0, -46.0), (14.0, -32.0)]) {
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(base.dx + dx * 0.4 * s, base.dy + dy * 0.5 * s, base.dx + dx * s, base.dy + dy * s),
        paint,
      );
    }
  }

  void _drawStarfish(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final outer = c + Offset(math.cos(a) * r, math.sin(a) * r);
      final inner = c + Offset(math.cos(a + math.pi / 5) * r * 0.45, math.sin(a + math.pi / 5) * r * 0.45);
      i == 0 ? path.moveTo(outer.dx, outer.dy) : path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF7043));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFAB91)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawSeabed(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sandTop = h * 0.945;
    final sand = Path()
      ..moveTo(0, sandTop)
      ..quadraticBezierTo(w * 0.3, h * 0.925, w * 0.55, sandTop)
      ..quadraticBezierTo(w * 0.8, h * 0.96, w, h * 0.935)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      sand,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8CD8F), Color(0xFFCCA560)],
        ).createShader(Rect.fromLTWH(0, h * 0.92, w, h * 0.08)),
    );

    _drawCoral(canvas, Offset(w * 0.27, h * 0.9), const Color(0xFFAB47BC), 1.0);
    _drawCoral(canvas, Offset(w * 0.75, h * 0.925), const Color(0xFFCE6FD6), 0.9);
    _drawCoral(canvas, Offset(w * 0.9, h * 0.93), const Color(0xFFEF5B7B), 1.1);
    _drawCoral(canvas, Offset(w * 0.46, h * 0.93), const Color(0xFFFFB300), 0.8);

    _drawRock(canvas, Offset(w * 0.06, h * 0.91), 130, 70);
    _drawRock(canvas, Offset(w * 0.93, h * 0.905), 150, 78);
    _drawRock(canvas, Offset(w * 0.34, h * 0.945), 100, 34);
    _drawRock(canvas, Offset(w * 0.72, h * 0.955), 70, 24);

    _drawStarfish(canvas, Offset(w * 0.12, h * 0.9), 28);
    _drawCrab(canvas, Offset(w * 0.11, h * 0.975));
  }

  void _drawCrab(Canvas canvas, Offset c) {
    final red = Paint()..color = const Color(0xFFE53935);
    canvas.drawOval(Rect.fromCenter(center: c, width: 26, height: 16), red);
    canvas.drawCircle(c + const Offset(-13, -6), 5, red);
    canvas.drawCircle(c + const Offset(13, -6), 5, red);
    canvas.drawCircle(c + const Offset(-4, -9), 3, Paint()..color = Colors.white);
    canvas.drawCircle(c + const Offset(4, -9), 3, Paint()..color = Colors.white);
    canvas.drawCircle(c + const Offset(-4, -9), 1.4, Paint()..color = Colors.black);
    canvas.drawCircle(c + const Offset(4, -9), 1.4, Paint()..color = Colors.black);
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final top = size.height * (_surfaceY + 0.03);
    final span = size.height * 0.88 - top;
    for (var i = 0; i < 20; i++) {
      final progress = reducedMotion
          ? (i / 20)
          : ((t * 2 + i * 0.053 + envPhase * 0.02) % 1.0);
      final x = size.width * (0.08 + (i * 37 % 84) / 100) +
          math.sin(progress * 8 + i) * 4;
      final y = top + span * (1 - progress);
      final r = 3.0 + (i % 5) * 2;
      final c = Offset(x, y);
      canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.14));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(
        c + Offset(-r * 0.35, -r * 0.35),
        r * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  void _drawCelebrationSparkles(Canvas canvas, Size size) {
    for (var i = 0; i < 18; i++) {
      final a = t * math.pi * 4 + i * (math.pi / 9);
      final r = 40.0 + (i % 5) * 18;
      final c = Offset(
        size.width * 0.5 + math.cos(a) * r,
        size.height * 0.35 + math.sin(a) * r * 0.6,
      );
      canvas.drawCircle(
        c,
        3 + (i % 3).toDouble(),
        Paint()
          ..color = Color(
            [0xFFFFEB3B, 0xFFFF80AB, 0xFF80D8FF, 0xFFB9F6CA][i % 4],
          ).withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OceanFishingPainter old) =>
      old.t != t ||
      old.envPhase != envPhase ||
      old.showCelebration != showCelebration ||
      old.reducedMotion != reducedMotion;
}
