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
    _drawSun(canvas, size);
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    _drawMountains(canvas, size);
    _drawHills(canvas, size);
    _drawTrees(canvas, size);
    _drawGrass(canvas, size);
    _drawFence(canvas, size);
    _drawBushes(canvas, size);
    _drawPond(canvas, size);
    _drawFlowers(canvas, size);
    if (!reducedMotion) {
      _drawDandelion(canvas, size);
      _drawLadybug(canvas, size, 0.18, 0.77);
      _drawLadybug(canvas, size, 0.83, 0.79);
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
            Color(0xFF64B5F6),
            Color(0xFF90CAF9),
            Color(0xFFBBDEFB),
            Color(0xFFE1F5FE),
          ],
          stops: [0.0, 0.3, 0.55, 1.0],
        ).createShader(rect),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.6;
    const colors = [
      Color(0xFFF06292),
      Color(0xFFFF8A65),
      Color(0xFFFFD54F),
      Color(0xFF9CCC65),
      Color(0xFF4FC3F7),
      Color(0xFF7986CB),
      Color(0xFFBA68C8),
    ];
    final baseW = size.width * 1.12;
    final baseH = size.height * 0.62;
    const band = 13.0;
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * (band * 2 - 2);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseW - shrink,
          height: baseH - shrink * 0.9,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band + 1,
      );
    }
    // Soft highlight along the top of the outer band.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: baseW - 6,
        height: baseH - 5,
      ),
      math.pi + 0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawMountains(Canvas canvas, Size size) {
    final base = size.height * 0.64;
    final path = Path()
      ..moveTo(size.width * 0.15, base)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.52, size.width * 0.42, base,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF80CBC4).withValues(alpha: 0.6));
    final path2 = Path()
      ..moveTo(size.width * 0.55, base)
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.5, size.width * 0.95, base,
      )
      ..close();
    canvas.drawPath(path2, Paint()..color = const Color(0xFF7FB8C8).withValues(alpha: 0.55));
  }

  void _drawHills(Canvas canvas, Size size) {
    final far = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.22, size.height * 0.55, size.width * 0.48, size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.69, size.width, size.height * 0.6,
      )
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(0, size.height * 0.75)
      ..close();
    canvas.drawPath(
      far,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5D6A7), Color(0xFF81C784)],
        ).createShader(Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.2)),
    );

    final near = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.62, size.width * 0.58, size.height * 0.69,
      )
      ..quadraticBezierTo(
        size.width * 0.82, size.height * 0.74, size.width, size.height * 0.66,
      )
      ..lineTo(size.width, size.height * 0.76)
      ..lineTo(0, size.height * 0.76)
      ..close();
    canvas.drawPath(
      near,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CCC65), Color(0xFF66BB6A)],
        ).createShader(Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.14)),
    );
  }

  void _drawTree(Canvas canvas, Offset base, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 3 * s, base.dy - 14 * s, 6 * s, 16 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    for (final (dx, dy, r, c) in [
      (-10.0, -22.0, 12.0, 0xFF43A047),
      (10.0, -22.0, 12.0, 0xFF43A047),
      (0.0, -30.0, 14.0, 0xFF66BB6A),
      (-3.0, -26.0, 9.0, 0xFF81C784),
    ]) {
      canvas.drawCircle(
        base + Offset(dx * s, dy * s),
        r * s,
        Paint()..color = Color(c),
      );
    }
  }

  void _drawTrees(Canvas canvas, Size size) {
    for (final (nx, ny, s) in [
      (0.06, 0.68, 1.5),
      (0.16, 0.7, 1.0),
      (0.3, 0.665, 0.7),
      (0.62, 0.67, 0.75),
      (0.78, 0.7, 1.0),
      (0.93, 0.68, 1.55),
    ]) {
      _drawTree(canvas, Offset(size.width * nx, size.height * ny), s);
    }
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
    for (final (nx, ny, s) in [
      (0.16, 0.18, 1.1),
      (0.62, 0.2, 1.0),
      (0.95, 0.3, 1.2),
      (0.06, 0.6, 0.9),
      (0.9, 0.62, 0.9),
    ]) {
      final x = (size.width * nx + drift) % (size.width + 120) - 40;
      _drawCloud(canvas, Offset(x, size.height * ny), s);
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.84, size.height * 0.13);
    canvas.drawCircle(
      sun,
      62,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99FFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: sun, radius: 62)),
    );
    if (!reducedMotion) {
      for (var i = 0; i < 12; i++) {
        final a = t * math.pi * 2 + i * (math.pi / 6);
        canvas.drawLine(
          sun + Offset(math.cos(a) * 34, math.sin(a) * 34),
          sun + Offset(math.cos(a) * 50, math.sin(a) * 50),
          Paint()
            ..color = const Color(0xFFFFF176).withValues(alpha: 0.75)
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    canvas.drawCircle(sun, 30, Paint()..color = const Color(0xFFFFF176));
    canvas.drawCircle(sun + const Offset(-8, -8), 14, Paint()..color = Colors.white.withValues(alpha: 0.35));
    // Face
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(sun + const Offset(-9, -3), 2.4, face);
    canvas.drawCircle(sun + const Offset(9, -3), 2.4, face);
    canvas.drawArc(
      Rect.fromCenter(center: sun + const Offset(0, 5), width: 16, height: 11),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawCircle(sun + const Offset(-16, 4), 4, cheek);
    canvas.drawCircle(sun + const Offset(16, 4), 4, cheek);
  }

  void _drawFence(Canvas canvas, Size size) {
    final y = size.height * 0.71;
    final rail = Paint()..color = const Color(0xFF8D6E63);
    for (final ry in [y + 4, y + 20]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, ry, size.width, 5),
          const Radius.circular(2),
        ),
        rail,
      );
    }
    const n = 18;
    for (var i = 0; i < n; i++) {
      final x = size.width * (i + 0.5) / n;
      final post = Path()
        ..moveTo(x - 6, y + 34)
        ..lineTo(x - 6, y - 4)
        ..lineTo(x, y - 12)
        ..lineTo(x + 6, y - 4)
        ..lineTo(x + 6, y + 34)
        ..close();
      canvas.drawPath(post, Paint()..color = const Color(0xFFA1887F));
      canvas.drawLine(
        Offset(x + 3, y - 4),
        Offset(x + 3, y + 34),
        Paint()
          ..color = const Color(0xFF6D4C41).withValues(alpha: 0.25)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawGrass(Canvas canvas, Size size) {
    final grassTop = size.height * 0.73;
    final rect = Rect.fromLTWH(0, grassTop, size.width, size.height - grassTop);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CCC65), Color(0xFF7CB342), Color(0xFF558B2F)],
        ).createShader(rect),
    );

    for (var i = 0; i < 40; i++) {
      final gx = size.width * ((i * 37) % 100) / 100;
      final gy = grassTop + 10 + ((i * 53) % 100) / 100 * (size.height - grassTop - 20);
      final sway = math.sin(t * 4 + i + envPhase) * 3 * intensity;
      final h = 9.0 + (i % 4) * 3;
      canvas.drawLine(
        Offset(gx, gy),
        Offset(gx + sway, gy - h),
        Paint()
          ..color = Color.lerp(const Color(0xFFAED581), const Color(0xFF33691E), (i % 5) / 5)!
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawFlower(Canvas canvas, Offset c, Color petal, {double r = 1}) {
    canvas.drawLine(
      c,
      c + Offset(0, 22 * r),
      Paint()
        ..color = const Color(0xFF388E3C)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(8 * r, 16 * r), width: 12 * r, height: 6 * r),
      Paint()..color = const Color(0xFF66BB6A),
    );
    final shade = Paint()..color = Color.lerp(petal, Colors.black, 0.12)!;
    for (var p = 0; p < 5; p++) {
      final a = p * math.pi * 2 / 5 - math.pi / 2;
      final pc = c + Offset(math.cos(a) * 11 * r, math.sin(a) * 11 * r);
      canvas.drawCircle(pc + const Offset(0, 1.5), 9 * r, shade);
    }
    for (var p = 0; p < 5; p++) {
      final a = p * math.pi * 2 / 5 - math.pi / 2;
      final pc = c + Offset(math.cos(a) * 11 * r, math.sin(a) * 11 * r);
      canvas.drawCircle(pc, 9 * r, Paint()..color = petal);
      canvas.drawCircle(
        pc + Offset(-2 * r, -2 * r),
        3.5 * r,
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }
    canvas.drawCircle(c, 6.5 * r, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(
      c + Offset(-1.5 * r, -1.5 * r),
      2.5 * r,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      (0.10, 0.8, 0xFFEC407A, 1.0),
      (0.05, 0.9, 0xFFFFFFFF, 0.9),
      (0.22, 0.85, 0xFFAB47BC, 1.0),
      (0.16, 0.93, 0xFFFFCA28, 1.1),
      (0.53, 0.77, 0xFFFFFFFF, 0.9),
      (0.70, 0.83, 0xFFFF7043, 1.0),
      (0.80, 0.78, 0xFF81C784, 0.9),
      (0.90, 0.87, 0xFFF48FB1, 1.0),
      (0.60, 0.92, 0xFFFFF176, 0.9),
      (0.93, 0.96, 0xFFFFCA28, 1.0),
      (0.08, 0.97, 0xFFCE93D8, 1.0),
    ];
    for (final (nx, ny, color, r) in spots) {
      final sway = math.sin(t * 3 + nx * 10) * 3 * intensity;
      _drawFlower(
        canvas,
        Offset(size.width * nx + sway, size.height * ny),
        Color(color),
        r: r,
      );
    }
  }

  void _drawPond(Canvas canvas, Size size) {
    for (final (nx, ny, w, h) in [
      (0.1, 0.9, 130.0, 42.0),
      (0.9, 0.91, 110.0, 36.0),
    ]) {
      final c = Offset(size.width * nx, size.height * ny);
      final rect = Rect.fromCenter(center: c, width: w, height: h);
      canvas.drawOval(
        rect.inflate(3),
        Paint()..color = const Color(0xFF4E7F3A).withValues(alpha: 0.5),
      );
      canvas.drawOval(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81D4FA), Color(0xFF29B6F6)],
          ).createShader(rect),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(-w * 0.15, -h * 0.15), width: w * 0.35, height: h * 0.25),
        Paint()..color = Colors.white.withValues(alpha: 0.4),
      );
      for (final (ox, oy, rw) in [(-0.48, 0.2, 16.0), (-0.36, 0.34, 11.0), (0.44, 0.28, 14.0)]) {
        canvas.drawOval(
          Rect.fromCenter(center: c + Offset(w * ox, h * oy), width: rw, height: rw * 0.7),
          Paint()..color = const Color(0xFF9E9E9E),
        );
      }
    }
  }

  void _drawBushes(Canvas canvas, Size size) {
    for (final (nx, ny, s) in [(0.03, 0.76, 1.5), (0.97, 0.77, 1.5)]) {
      final c = Offset(size.width * nx, size.height * ny);
      for (final (o, shade) in [
        (const Offset(0, 0), 0xFF558B2F),
        (const Offset(-14, 4), 0xFF689F38),
        (const Offset(14, 4), 0xFF689F38),
        (const Offset(0, -10), 0xFF7CB342),
      ]) {
        canvas.drawCircle(c + o * s, 16 * s, Paint()..color = Color(shade));
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
