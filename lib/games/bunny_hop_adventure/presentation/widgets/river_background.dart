import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the meadow pond scene sized to the play area so grass, water, and pads align.
class RiverPlayScene extends StatelessWidget {
  const RiverPlayScene({
    super.key,
    required this.envPhase,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RiverPlayScenePainter(
        envPhase: envPhase,
        reducedMotion: reducedMotion,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _RiverPlayScenePainter extends CustomPainter {
  _RiverPlayScenePainter({
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawHills(canvas, size);
    _drawFenceAndBushes(canvas, size);
    _drawMeadow(canvas, size);
    _drawPond(canvas, size);
    _drawPillars(canvas, size);
    _drawForegroundFlowers(canvas, size);
    _drawFrog(canvas, size);
    _drawLotus(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64B5F6), Color(0xFF90CAF9), Color(0xFFBBDEFB)],
        ).createShader(Offset.zero & size),
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.86, size.height * 0.11);
    canvas.drawCircle(
      c,
      34,
      Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      c,
      24,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFEE58), Color(0xFFFDD835)],
        ).createShader(Rect.fromCircle(center: c, radius: 24)),
    );
    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, 4), width: 16, height: 10),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFFF9A825)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c.translate(-6, -2), 2.2, Paint()..color = const Color(0xFFF9A825));
    canvas.drawCircle(c.translate(6, -2), 2.2, Paint()..color = const Color(0xFFF9A825));
  }

  void _drawClouds(Canvas canvas, Size size) {
    void cloud(double x, double y, double s) {
      final p = Paint()..color = Colors.white.withValues(alpha: 0.95);
      canvas.drawCircle(Offset(x, y), 16 * s, p);
      canvas.drawCircle(Offset(x + 18 * s, y - 4 * s), 20 * s, p);
      canvas.drawCircle(Offset(x + 38 * s, y), 15 * s, p);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + 18 * s, y + 8 * s), width: 56 * s, height: 22 * s),
        p,
      );
    }

    final drift = reducedMotion ? 0.0 : envPhase * 8;
    cloud((size.width * 0.08 + drift) % (size.width + 80) - 40, size.height * 0.08, 1.1);
    cloud((size.width * 0.42 + drift * 0.7) % (size.width + 80) - 40, size.height * 0.05, 0.85);
    cloud((size.width * 0.62 + drift * 0.5) % (size.width + 80) - 40, size.height * 0.13, 0.7);
  }

  void _drawHills(Canvas canvas, Size size) {
    final hillTop = size.height * 0.22;
    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, hillTop + 40)
      ..quadraticBezierTo(size.width * 0.18, hillTop - 10, size.width * 0.38, hillTop + 28)
      ..quadraticBezierTo(size.width * 0.58, hillTop + 8, size.width * 0.78, hillTop + 32)
      ..quadraticBezierTo(size.width * 0.92, hillTop + 18, size.width, hillTop + 36)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFAED581), Color(0xFF81C784), Color(0xFF66BB6A)],
        ).createShader(Rect.fromLTWH(0, hillTop, size.width, size.height)),
    );
  }

  void _drawFenceAndBushes(Canvas canvas, Size size) {
    final y = size.height * 0.30;
    final fencePaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.18 + i * 0.048);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 7, height: 28),
          const Radius.circular(3),
        ),
        fencePaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.16, y - 2, size.width * 0.68, 5),
        const Radius.circular(2),
      ),
      fencePaint,
    );

    final bushY = y + 10;
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.16 + i * 0.07);
      canvas.drawCircle(
        Offset(x, bushY),
        16 + (i % 3) * 2,
        Paint()..color = Color(i.isEven ? 0xFF7CB342 : 0xFF9CCC65),
      );
      if (i % 2 == 0) {
        canvas.drawCircle(Offset(x - 4, bushY - 4), 3.2, Paint()..color = const Color(0xFFF48FB1));
      } else {
        canvas.drawCircle(Offset(x + 3, bushY - 5), 2.8, Paint()..color = const Color(0xFFFFEB3B));
      }
    }
  }

  void _drawMeadow(Canvas canvas, Size size) {
    final top = size.height * 0.58;
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, size.height - top),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CCC65), Color(0xFF7CB342), Color(0xFF66BB6A)],
        ).createShader(Rect.fromLTWH(0, top, size.width, size.height - top)),
    );
  }

  void _drawPond(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.50),
      width: size.width * 0.92,
      height: size.height * 0.28,
    );
    final pond = Path()..addOval(rect);

    canvas.drawOval(
      rect.translate(0, 8),
      Paint()..color = const Color(0xFF0277BD).withValues(alpha: 0.22),
    );
    canvas.drawPath(
      pond,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFF29B6F6), Color(0xFF0288D1)],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.44),
        width: size.width * 0.38,
        height: size.height * 0.07,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    if (!reducedMotion) {
      for (var i = 0; i < 5; i++) {
        final t = (envPhase * 0.35 + i * 0.7) % 1.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * (0.22 + i * 0.14), size.height * 0.52),
            width: 18 + t * 10,
            height: 5,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.16),
        );
      }
    }

    // Rocks around the pond
    const rocks = [
      Offset(0.10, 0.40),
      Offset(0.16, 0.60),
      Offset(0.84, 0.41),
      Offset(0.90, 0.58),
      Offset(0.22, 0.62),
      Offset(0.78, 0.62),
    ];
    for (final r in rocks) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * r.dx, size.height * r.dy),
          width: 22,
          height: 14,
        ),
        Paint()..color = const Color(0xFF90A4AE),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * r.dx - 3, size.height * r.dy - 2),
          width: 10,
          height: 5,
        ),
        Paint()..color = const Color(0xFFCFD8DC),
      );
    }
  }

  void _drawPillars(Canvas canvas, Size size) {
    void pillar(double cx) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.34),
          width: size.width * 0.20,
          height: size.height * 0.28,
        ),
        const Radius.circular(28),
      );
      canvas.drawRRect(
        rect.shift(const Offset(0, 6)),
        Paint()..color = const Color(0xFF33691E).withValues(alpha: 0.22),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFAED581), Color(0xFF7CB342), Color(0xFF558B2F)],
          ).createShader(rect.outerRect),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left + 10, rect.top + 10, 16, rect.height * 0.45),
          const Radius.circular(10),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }

    pillar(size.width * 0.10);
    pillar(size.width * 0.90);
  }

  void _drawForegroundFlowers(Canvas canvas, Size size) {
    const petals = [
      Color(0xFFF48FB1),
      Color(0xFFCE93D8),
      Color(0xFFFFEB3B),
      Color(0xFFFFB74D),
      Color(0xFF81D4FA),
    ];
    for (var i = 0; i < 18; i++) {
      final x = size.width * ((8 + i * 17) % 94) / 100;
      final y = size.height * (0.70 + (i % 5) * 0.055);
      final color = petals[i % petals.length];
      canvas.drawCircle(Offset(x, y), 5.5, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = const Color(0xFFFFF59D));
    }
  }

  void _drawFrog(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.12, size.height * 0.86);
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 16), width: 46, height: 16),
      Paint()..color = const Color(0xFF689F38),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 42, height: 30),
      Paint()..color = const Color(0xFF8BC34A),
    );
    canvas.drawCircle(c.translate(-10, -14), 9, Paint()..color = const Color(0xFF9CCC65));
    canvas.drawCircle(c.translate(10, -14), 9, Paint()..color = const Color(0xFF9CCC65));
    canvas.drawCircle(c.translate(-10, -14), 3.4, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(c.translate(10, -14), 3.4, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(c.translate(-11, -15), 1.1, Paint()..color = Colors.white);
    canvas.drawCircle(c.translate(9, -15), 1.1, Paint()..color = Colors.white);
    canvas.drawArc(
      Rect.fromCenter(center: c.translate(0, 2), width: 14, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF33691E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLotus(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.88, size.height * 0.86);
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 16), width: 52, height: 16),
      Paint()..color = const Color(0xFF689F38),
    );
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 - math.pi / 2;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + math.cos(a) * 12, c.dy + math.sin(a) * 10),
          width: 18,
          height: 26,
        ),
        Paint()..color = Color(i.isEven ? 0xFFF48FB1 : 0xFFF8BBD0),
      );
    }
    canvas.drawCircle(c, 8, Paint()..color = const Color(0xFFFFF176));
  }

  @override
  bool shouldRepaint(covariant _RiverPlayScenePainter old) =>
      old.envPhase != envPhase || old.reducedMotion != reducedMotion;
}

/// Full-screen wrapper for setup screens and outer shell.
class RiverBackground extends StatelessWidget {
  const RiverBackground({
    super.key,
    this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget? child;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RiverPlayScene(
          envPhase: envPhase,
          reducedMotion: reducedMotion,
          intensity: intensity,
        ),
        ?child,
      ],
    );
  }
}
