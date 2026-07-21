import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawRainbow(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawBirds(canvas, size);
    _drawIslands(canvas, size);
    _drawOcean(canvas, size);
    _drawWaves(canvas, size);
    _drawUnderwater(canvas, size);
    if (showCelebration) _drawCelebrationSparkles(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyH = size.height * 0.20;
    final rect = Rect.fromLTWH(0, 0, size.width, skyH);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FC3F7),
            Color(0xFF81D4FA),
            Color(0xFFFFF59D),
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.42;
    final cy = size.height * 0.22;
    const colors = [
      Color(0xFFEF5350),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFF7E57C2),
      Color(0xFFEC407A),
    ];
    final baseW = size.width * 0.85;
    final baseH = size.height * 0.28;
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * 11.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseW - shrink,
          height: baseH - shrink * 0.5,
        ),
        math.pi + 0.08,
        math.pi - 0.16,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.88, size.height * 0.07);
    canvas.drawCircle(
      sun,
      36,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFB74D), Color(0x00FFB74D)],
          stops: [0.2, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: sun, radius: 36)),
    );
    canvas.drawCircle(sun, 20, Paint()..color = const Color(0xFFFFF176));

    // Smiling face
    canvas.drawCircle(
      sun + const Offset(-6, -2),
      2.2,
      Paint()..color = const Color(0xFFF57F17),
    );
    canvas.drawCircle(
      sun + const Offset(6, -2),
      2.2,
      Paint()..color = const Color(0xFFF57F17),
    );
    canvas.drawArc(
      Rect.fromCenter(center: sun + const Offset(0, 4), width: 14, height: 10),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFFF57F17)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    if (!reducedMotion) {
      for (var i = 0; i < 8; i++) {
        final a = t * math.pi * 2 + i * (math.pi / 4);
        canvas.drawLine(
          sun + Offset(math.cos(a) * 26, math.sin(a) * 26),
          sun + Offset(math.cos(a) * 38, math.sin(a) * 38),
          Paint()
            ..color = const Color(0xFFFFF59D).withValues(alpha: 0.6)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    for (var i = 0; i < 4; i++) {
      final x =
          (size.width * (0.04 + i * 0.26) + t * size.width * 0.04) %
              (size.width + 100) -
          40;
      final y = size.height * 0.04 + i * 5.0;
      canvas.drawCircle(Offset(x, y), 18, paint);
      canvas.drawCircle(Offset(x + 20, y + 2), 14, paint);
      canvas.drawCircle(Offset(x + 8, y - 8), 12, paint);
      canvas.drawCircle(Offset(x - 12, y + 2), 10, paint);
    }
  }

  void _drawBirds(Canvas canvas, Size size) {
    if (reducedMotion) return;
    final paint = Paint()
      ..color = const Color(0xFF455A64).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final bx =
          (size.width * (0.1 + i * 0.18) + t * size.width * 0.06) % size.width;
      final by = size.height * (0.05 + (i % 3) * 0.025) +
          math.sin(t * 4 + i) * 3;
      final flap = math.sin(t * 10 + i) * 0.35;
      final path = Path()
        ..moveTo(bx - 7, by + flap * 2)
        ..quadraticBezierTo(bx - 3, by - 4 - flap, bx, by)
        ..quadraticBezierTo(bx + 3, by - 4 - flap, bx + 7, by + flap * 2);
      canvas.drawPath(path, paint);
    }
  }

  void _drawIslands(Canvas canvas, Size size) {
    final horizon = size.height * 0.18;
    for (final (nx, w, h, green) in [
      (0.12, 70.0, 22.0, 0xFF81C784),
      (0.35, 50.0, 16.0, 0xFF66BB6A),
      (0.72, 80.0, 24.0, 0xFF7CB342),
      (0.92, 40.0, 14.0, 0xFF9CCC65),
    ]) {
      final c = Offset(size.width * nx, horizon);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: w, height: h),
        Paint()..color = Color(green).withValues(alpha: 0.75),
      );
      // Tiny palm hint
      canvas.drawLine(
        c + Offset(0, -h * 0.2),
        c + Offset(4, -h * 0.9),
        Paint()
          ..color = const Color(0xFF558B2F)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawOcean(Canvas canvas, Size size) {
    final oceanTop = size.height * 0.20;
    final rect = Rect.fromLTWH(0, oceanTop, size.width, size.height - oceanTop);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4DD0E1),
            Color(0xFF26C6DA),
            Color(0xFF0288D1),
            Color(0xFF01579B),
            Color(0xFF0D47A1),
          ],
          stops: [0.0, 0.15, 0.4, 0.7, 1.0],
        ).createShader(rect),
    );
  }

  void _drawWaves(Canvas canvas, Size size) {
    final oceanTop = size.height * 0.20;
    final wave = Path()..moveTo(0, oceanTop);
    for (var x = 0.0; x <= size.width; x += 16) {
      final y = oceanTop +
          math.sin(x * 0.04 + t * math.pi * 2 + envPhase) * 5 -
          2;
      wave.lineTo(x, y);
    }
    wave
      ..lineTo(size.width, oceanTop + 18)
      ..lineTo(0, oceanTop + 18)
      ..close();
    canvas.drawPath(
      wave,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Soft secondary ripple
    for (var i = 0; i < 6; i++) {
      final y = oceanTop + 14 + i * 10.0;
      for (var j = 0; j < 5; j++) {
        final x = size.width * (0.08 + j * 0.2) +
            math.sin(t * 3 + i + j) * 8;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 36 - i * 3,
            height: 5,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.08),
        );
      }
    }
  }

  void _drawUnderwater(Canvas canvas, Size size) {
    _drawCoral(canvas, size);
    _drawSeaweed(canvas, size);
    _drawRocks(canvas, size);
    _drawStarfish(canvas, size);
    _drawShells(canvas, size);
    _drawTreasure(canvas, size);
    _drawCrabs(canvas, size);
    _drawBubbles(canvas, size);
  }

  void _drawCoral(Canvas canvas, Size size) {
    final spots = [
      (0.08, 0.78, 0xFFFF8A65, 22.0),
      (0.18, 0.88, 0xFFEC407A, 18.0),
      (0.82, 0.80, 0xFFFF7043, 24.0),
      (0.92, 0.90, 0xFFF48FB1, 16.0),
      (0.55, 0.92, 0xFFFFAB91, 14.0),
    ];
    for (final (nx, ny, color, r) in spots) {
      final c = Offset(size.width * nx, size.height * ny);
      canvas.drawCircle(c, r, Paint()..color = Color(color).withValues(alpha: 0.85));
      canvas.drawCircle(
        c + Offset(-r * 0.45, -r * 0.3),
        r * 0.55,
        Paint()..color = Color(color),
      );
      canvas.drawCircle(
        c + Offset(r * 0.4, -r * 0.35),
        r * 0.5,
        Paint()..color = Color(color).withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        c + Offset(0, -r * 0.55),
        r * 0.4,
        Paint()..color = Color.lerp(Color(color), Colors.white, 0.25)!,
      );
    }
  }

  void _drawSeaweed(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.05 + i * 0.1);
      final baseY = size.height * 0.98;
      final sway = math.sin(t * 3 + i + envPhase) * 10;
      final path = Path()..moveTo(x, baseY);
      path.quadraticBezierTo(
        x + sway,
        baseY - 40,
        x + sway * 0.4,
        baseY - 70 - (i % 3) * 12,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF2E7D32),
            const Color(0xFF66BB6A),
            (i % 4) / 4,
          )!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawRocks(Canvas canvas, Size size) {
    for (final (nx, ny, w, h) in [
      (0.28, 0.94, 40.0, 18.0),
      (0.48, 0.96, 55.0, 22.0),
      (0.68, 0.93, 36.0, 16.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * nx, size.height * ny),
          width: w,
          height: h,
        ),
        Paint()..color = const Color(0xFF78909C).withValues(alpha: 0.75),
      );
    }
  }

  void _drawStarfish(Canvas canvas, Size size) {
    for (final (nx, ny, color) in [
      (0.22, 0.86, 0xFFFF7043),
      (0.78, 0.88, 0xFFFFCA28),
    ]) {
      final c = Offset(size.width * nx, size.height * ny);
      final path = Path();
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / 5;
        final outer = Offset(c.dx + math.cos(a) * 12, c.dy + math.sin(a) * 12);
        final midA = a + math.pi / 5;
        final inner =
            Offset(c.dx + math.cos(midA) * 5, c.dy + math.sin(midA) * 5);
        if (i == 0) {
          path.moveTo(outer.dx, outer.dy);
        } else {
          path.lineTo(outer.dx, outer.dy);
        }
        path.lineTo(inner.dx, inner.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Color(color));
    }
  }

  void _drawShells(Canvas canvas, Size size) {
    for (final (nx, ny) in [(0.38, 0.90), (0.62, 0.88)]) {
      final c = Offset(size.width * nx, size.height * ny);
      canvas.drawArc(
        Rect.fromCenter(center: c, width: 22, height: 16),
        math.pi,
        math.pi,
        true,
        Paint()..color = const Color(0xFFFFCC80),
      );
      canvas.drawArc(
        Rect.fromCenter(center: c, width: 22, height: 16),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFFFA726)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawTreasure(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.94);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 36, height: 22),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, -10), width: 38, height: 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawCircle(
      c + const Offset(0, -4),
      4,
      Paint()..color = const Color(0xFFFFD54F),
    );
    // Glints
    canvas.drawCircle(
      c + const Offset(-8, 2),
      2.5,
      Paint()..color = const Color(0xFFFFEB3B),
    );
    canvas.drawCircle(
      c + const Offset(8, 3),
      2,
      Paint()..color = const Color(0xFFFFEB3B),
    );
  }

  void _drawCrabs(Canvas canvas, Size size) {
    for (final (nx, ny) in [(0.14, 0.93), (0.86, 0.94)]) {
      final c = Offset(
        size.width * nx + (reducedMotion ? 0 : math.sin(t * 2 + nx) * 4),
        size.height * ny,
      );
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 16, height: 10),
        Paint()..color = const Color(0xFFEF5350),
      );
      canvas.drawCircle(c + const Offset(-4, -2), 2, Paint()..color = Colors.black);
      canvas.drawCircle(c + const Offset(4, -2), 2, Paint()..color = Colors.black);
      // Claws
      canvas.drawArc(
        Rect.fromCenter(center: c + const Offset(-10, -2), width: 10, height: 8),
        math.pi * 0.2,
        math.pi * 0.8,
        false,
        Paint()
          ..color = const Color(0xFFE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawArc(
        Rect.fromCenter(center: c + const Offset(10, -2), width: 10, height: 8),
        math.pi * 0.0,
        math.pi * 0.8,
        false,
        Paint()
          ..color = const Color(0xFFE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 16; i++) {
      final progress = reducedMotion
          ? (i / 16)
          : ((t + i * 0.07 + envPhase * 0.02) % 1.0);
      final x = size.width * ((0.1 + (i * 37 % 80) / 100));
      final y = size.height * (0.95 - progress * 0.7);
      final r = 2.0 + (i % 4);
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        Offset(x - r * 0.3, y - r * 0.3),
        r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
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
