import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PartyBackground extends StatelessWidget {
  const PartyBackground({
    super.key,
    required this.child,
    this.eveningFactor = 0,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _PartyRoomPainter(
            eveningFactor: eveningFactor,
            envPhase: envPhase,
            reducedMotion: reducedMotion,
            intensity: intensity,
          ),
        ),
        child,
      ],
    );
  }
}

class _PartyRoomPainter extends CustomPainter {
  _PartyRoomPainter({
    required this.eveningFactor,
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  static const _balloonColors = [
    0xFFF48FB1,
    0xFF81D4FA,
    0xFFFFF176,
    0xFFCE93D8,
    0xFFA5D6A7,
    0xFFFFAB91,
    0xFF80DEEA,
    0xFFFF8A65,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final evening = eveningFactor.clamp(0.0, 1.0);
    _drawWall(canvas, size, evening);
    _drawFloor(canvas, size, evening);
    _drawWallpaperDots(canvas, size);
    _drawWindow(canvas, size, evening);
    _drawBirthdayBanner(canvas, size);
    _drawFairyLights(canvas, size, evening);
    _drawBunting(canvas, size);
    _drawBalloons(canvas, size);
    _drawGiftBoxes(canvas, size);
    _drawConfetti(canvas, size);
    if (evening > 0.15) _drawWarmGlow(canvas, size, evening);
  }

  void _drawWall(Canvas canvas, Size size, double evening) {
    final wallTop = Color.lerp(const Color(0xFFFFF3E0), const Color(0xFF5D4037), evening * 0.45)!;
    final wallMid = Color.lerp(const Color(0xFFFFE0B2), const Color(0xFF4E342E), evening * 0.5)!;
    final wallBottom = Color.lerp(const Color(0xFFFFCCBC), const Color(0xFF3E2723), evening * 0.55)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.78),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [wallTop, wallMid, wallBottom],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.78)),
    );
  }

  void _drawFloor(Canvas canvas, Size size, double evening) {
    final floorTop = Color.lerp(const Color(0xFFFFE0B2), const Color(0xFF6D4C41), evening * 0.4)!;
    final floorBottom = Color.lerp(const Color(0xFFFFCC80), const Color(0xFF4E342E), evening * 0.45)!;
    final floorRect = Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22);
    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [floorTop, floorBottom],
        ).createShader(floorRect),
    );
    // Soft wood planks
    for (var i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(0, size.height * 0.78 + i * size.height * 0.028),
        Offset(size.width, size.height * 0.78 + i * size.height * 0.028),
        Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.12),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.775, size.width, 8),
      Paint()..color = const Color(0xFFEC407A).withValues(alpha: 0.55),
    );
  }

  void _drawWallpaperDots(Canvas canvas, Size size) {
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 10; col++) {
        final x = size.width * (0.06 + col * 0.1) + (row.isOdd ? 18 : 0);
        final y = size.height * (0.12 + row * 0.1);
        if (y > size.height * 0.72) continue;
        canvas.drawCircle(
          Offset(x, y),
          3.5,
          Paint()..color = const Color(0xFFF48FB1).withValues(alpha: 0.18),
        );
      }
    }
  }

  void _drawBirthdayBanner(Canvas canvas, Size size) {
    final bannerY = size.height * 0.02;
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, bannerY + 28),
        width: size.width * 0.72,
        height: 44,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF4081), Color(0xFFF50057)],
        ).createShader(bannerRect.outerRect),
    );
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Ribbon ties
    for (final side in [-1.0, 1.0]) {
      final sx = size.width * 0.5 + side * size.width * 0.36;
      canvas.drawCircle(Offset(sx, bannerY + 28), 6, Paint()..color = const Color(0xFFFFEB3B));
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: '🎉 Happy Birthday Teddy! 🎉',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.66);
    tp.paint(
      canvas,
      Offset(size.width * 0.5 - tp.width / 2, bannerY + 28 - tp.height / 2),
    );
  }

  void _drawBunting(Canvas canvas, Size size) {
    final y = size.height * 0.095;
    final rope = Paint()
      ..color = const Color(0xFFFF7043)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(size.width * 0.02, y + 4);
    for (var i = 0; i <= 9; i++) {
      final x = size.width * (0.02 + i * 0.11);
      path.quadraticBezierTo(
        x + size.width * 0.055,
        y + (i.isEven ? 14 : 4),
        x + size.width * 0.11,
        y + 4,
      );
    }
    canvas.drawPath(path, rope);

    const flagColors = [
      0xFFF48FB1,
      0xFF81D4FA,
      0xFFFFF176,
      0xFFCE93D8,
      0xFFA5D6A7,
      0xFFFFAB91,
      0xFF80DEEA,
      0xFFFF8A65,
    ];
    for (var i = 0; i < 9; i++) {
      final fx = size.width * (0.06 + i * 0.1);
      final fy = y + (i.isEven ? 10 : 2);
      final flag = Path()
        ..moveTo(fx, fy)
        ..lineTo(fx + 12, fy + 22)
        ..lineTo(fx - 12, fy + 22)
        ..close();
      canvas.drawPath(flag, Paint()..color = Color(flagColors[i % flagColors.length]));
      canvas.drawPath(
        flag,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawFairyLights(Canvas canvas, Size size, double evening) {
    final glow = 0.55 + evening * 0.4;
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.03 + i * 0.07);
      final y = size.height * 0.13 + math.sin(envPhase * 2.2 + i) * 3 * intensity;
      final colors = [0xFFFFEB3B, 0xFFFF4081, 0xFF69F0AE, 0xFF40C4FF, 0xFFE040FB];
      final c = Color(colors[i % colors.length]);
      canvas.drawCircle(
        Offset(x, y),
        7,
        Paint()..color = c.withValues(alpha: glow * 0.35),
      );
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = c.withValues(alpha: glow));
      canvas.drawCircle(
        Offset(x - 1, y - 1),
        1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  void _drawBalloons(Canvas canvas, Size size) {
    final balloons = [
      (0.06, 0.28, 0, 36.0, 46.0),
      (0.12, 0.36, 1, 30.0, 40.0),
      (0.04, 0.42, 2, 28.0, 36.0),
      (0.88, 0.26, 3, 38.0, 48.0),
      (0.94, 0.34, 4, 32.0, 42.0),
      (0.90, 0.44, 5, 28.0, 36.0),
      (0.18, 0.22, 6, 26.0, 34.0),
      (0.82, 0.20, 7, 26.0, 34.0),
    ];
    for (final (nx, ny, colorIdx, w, h) in balloons) {
      final sway = reducedMotion ? 0.0 : math.sin(envPhase * 1.4 + nx * 8) * 6 * intensity;
      final bob = reducedMotion ? 0.0 : math.cos(envPhase * 1.1 + ny * 6) * 4 * intensity;
      final x = size.width * nx + sway;
      final y = size.height * ny + bob;
      final color = Color(_balloonColors[colorIdx % _balloonColors.length]);

      // String
      canvas.drawPath(
        Path()
          ..moveTo(x, y + h * 0.48)
          ..quadraticBezierTo(x - 4, y + h * 0.75, x + 2, y + h * 0.95),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

      final oval = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
      canvas.drawOval(
        oval,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            colors: [
              Color.lerp(color, Colors.white, 0.45)!,
              color,
              Color.lerp(color, Colors.black, 0.18)!,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(oval),
      );
      // Highlight
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - w * 0.18, y - h * 0.22), width: w * 0.22, height: h * 0.18),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
      // Knot
      canvas.drawCircle(Offset(x, y + h * 0.48), 3.5, Paint()..color = color);
    }
  }

  void _drawGiftBoxes(Canvas canvas, Size size) {
    _gift(canvas, Offset(size.width * 0.08, size.height * 0.86), 36, 28, const Color(0xFFEC407A), const Color(0xFFFFEB3B));
    _gift(canvas, Offset(size.width * 0.92, size.height * 0.88), 32, 26, const Color(0xFF42A5F5), const Color(0xFFFF80AB));
    _gift(canvas, Offset(size.width * 0.16, size.height * 0.90), 24, 20, const Color(0xFFAB47BC), const Color(0xFFFFF176));
  }

  void _gift(Canvas canvas, Offset c, double w, double h, Color box, Color ribbon) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: h),
        const Radius.circular(4),
      ),
      Paint()..color = box,
    );
    canvas.drawRect(
      Rect.fromCenter(center: c, width: 6, height: h),
      Paint()..color = ribbon,
    );
    canvas.drawRect(
      Rect.fromCenter(center: c, width: w, height: 6),
      Paint()..color = ribbon,
    );
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.55), 5, Paint()..color = ribbon);
  }

  void _drawWindow(Canvas canvas, Size size, double evening) {
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.58, size.height * 0.155, size.width * 0.22, size.height * 0.14),
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRRect(
      frame.deflate(5),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF81D4FA), const Color(0xFF1A237E), evening * 0.55)!,
            Color.lerp(const Color(0xFF4FC3F7), const Color(0xFF283593), evening * 0.55)!,
          ],
        ).createShader(frame.outerRect),
    );
    final inner = frame.deflate(5);
    canvas.drawLine(
      Offset(inner.left + inner.width / 2, inner.top),
      Offset(inner.left + inner.width / 2, inner.bottom),
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(inner.left, inner.top + inner.height / 2),
      Offset(inner.right, inner.top + inner.height / 2),
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 3,
    );
    // Curtains
    for (final left in [true, false]) {
      final cx = left ? size.width * 0.56 : size.width * 0.78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx, size.height * 0.145, size.width * 0.05, size.height * 0.16),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.85),
      );
    }
  }

  void _drawConfetti(Canvas canvas, Size size) {
    if (reducedMotion) return;
    for (var i = 0; i < 18; i++) {
      final x = (size.width * ((i * 47) % 100) / 100 + envPhase * 20) % size.width;
      final y = size.height * (0.15 + ((i * 31) % 55) / 100) + math.sin(envPhase * 2 + i) * 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 6, height: 4),
          const Radius.circular(1),
        ),
        Paint()..color = Color(_balloonColors[i % _balloonColors.length]).withValues(alpha: 0.55),
      );
    }
  }

  void _drawWarmGlow(Canvas canvas, Size size, double evening) {
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.5,
      Paint()..color = const Color(0xFFFFB74D).withValues(alpha: 0.08 * evening),
    );
  }

  @override
  bool shouldRepaint(covariant _PartyRoomPainter old) =>
      old.eveningFactor != eveningFactor ||
      old.envPhase != envPhase ||
      old.reducedMotion != reducedMotion;
}
