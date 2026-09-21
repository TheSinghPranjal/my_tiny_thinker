import 'dart:math' as math;

import 'package:flutter/material.dart';

class BananaTreeWidget extends StatelessWidget {
  const BananaTreeWidget({
    super.key,
    required this.width,
    required this.height,
    this.envPhase = 0,
    this.reducedMotion = false,
  });

  final double width;
  final double height;
  final double envPhase;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _BananaTreePainter(
        envPhase: envPhase,
        reducedMotion: reducedMotion,
      ),
    );
  }
}

class _BananaTreePainter extends CustomPainter {
  _BananaTreePainter({required this.envPhase, required this.reducedMotion});

  final double envPhase;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    // The canopy fills the upper play area; the trunk grows out beneath it.
    final trunkTop = size.height * 0.38;
    final trunkBottom = size.height * 0.95;

    _drawTrunk(canvas, cx, trunkTop, trunkBottom, size);
    _drawCanopy(canvas, cx, size);
    _drawLeaves(canvas, size);
    _drawFlowers(canvas, size);
    if (!reducedMotion) _drawFallingLeaves(canvas, size);
  }

  void _drawTrunk(Canvas canvas, double cx, double top, double bottom, Size size) {
    final w = size.width;
    final trunk = Path()
      ..moveTo(cx - w * 0.15, bottom)
      // left root flare
      ..quadraticBezierTo(cx - w * 0.07, bottom - (bottom - top) * 0.12, cx - w * 0.085, bottom - (bottom - top) * 0.32)
      ..quadraticBezierTo(cx - w * 0.075, (top + bottom) / 2, cx - w * 0.08, top)
      ..lineTo(cx + w * 0.08, top)
      ..quadraticBezierTo(cx + w * 0.08, (top + bottom) / 2, cx + w * 0.085, bottom - (bottom - top) * 0.32)
      ..quadraticBezierTo(cx + w * 0.07, bottom - (bottom - top) * 0.12, cx + w * 0.15, bottom)
      ..close();
    final rect = Rect.fromLTWH(cx - w * 0.15, top, w * 0.3, bottom - top);
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF7A4B2F), Color(0xFFA5714B), Color(0xFF93613F), Color(0xFF6B4028)],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(trunk);
    // Bark marks.
    final bark = Paint()
      ..color = const Color(0xFF4E2E1B).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final y = top + 30 + i * ((bottom - top - 60) / 6);
      final x = cx + ((i * 37) % 5 - 2) * w * 0.02;
      canvas.drawPath(
        Path()
          ..moveTo(x - w * 0.05, y)
          ..quadraticBezierTo(x, y + 12, x + w * 0.04, y + 2)
          ..quadraticBezierTo(x + w * 0.06, y - 4, x + w * 0.07, y + 8),
        bark,
      );
    }
    canvas.drawLine(
      Offset(cx - w * 0.03, top),
      Offset(cx - w * 0.045, bottom - 30),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  /// Big puffy canopy: a scalloped silhouette, then layered clumps for depth.
  void _drawCanopy(Canvas canvas, double cx, Size size) {
    final sway = reducedMotion ? 0.0 : math.sin(envPhase * 1.2) * 3;
    final w = size.width;
    final h = size.height;
    final center = Offset(cx, h * 0.2);
    final rx = w * 0.5;
    final ry = h * 0.24;

    // Scalloped silhouette: circles round the edge of an ellipse.
    const n = 30;
    for (var pass = 0; pass < 3; pass++) {
      final color = [
        const Color(0xFF276B2C),
        const Color(0xFF348A38),
        const Color(0xFF3F9C3F),
      ][pass];
      final inset = [1.0, 0.98, 0.94][pass];
      final dy = [7.0, 3.0, 0.0][pass];
      for (var i = 0; i < n; i++) {
        final a = i * math.pi * 2 / n;
        final r = w * (0.085 + 0.022 * math.sin(i * 2.3 + 1)) * (pass == 2 ? 0.95 : 1.0);
        final c = center + Offset(math.cos(a) * rx * 0.92 * inset + sway, math.sin(a) * ry * 0.92 * inset + dy);
        canvas.drawCircle(c, r, Paint()..color = color);
      }
      canvas.drawOval(
        Rect.fromCenter(center: center + Offset(0, dy), width: rx * 1.7, height: ry * 1.7),
        Paint()..color = color,
      );
    }

    // Interior clumps: light puff highlights and dark crescents for texture.
    for (var i = 0; i < 44; i++) {
      final a = i * 2.399;
      final rr = math.sqrt((i + 1) / 45);
      final c = center + Offset(math.cos(a) * rx * 0.82 * rr + sway, math.sin(a) * ry * 0.82 * rr);
      final r = w * (0.06 + 0.03 * ((i * 7) % 5) / 4);
      final clump = Rect.fromCircle(center: c, radius: r);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.45),
            colors: [Color(0xFF66BC52), Color(0xFF3F9C3F), Color(0xFF2F8434)],
            stops: [0.0, 0.6, 1.0],
          ).createShader(clump),
      );
      canvas.drawArc(
        clump.deflate(1),
        0.3,
        math.pi * 0.7,
        false,
        Paint()
          ..color = const Color(0xFF1F6A29).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _leaf(Canvas canvas, Offset c, double len, double angle, {Color? color}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(-len / 2, 0)
      ..quadraticBezierTo(0, -len * 0.42, len / 2, 0)
      ..quadraticBezierTo(0, len * 0.42, -len / 2, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color ?? const Color(0xFF8ED66B),
            Color.lerp(color ?? const Color(0xFF8ED66B), const Color(0xFF3F9C3F), 0.6)!,
          ],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: len, height: len * 0.6)),
    );
    canvas.drawLine(
      Offset(-len / 2, 0),
      Offset(len / 2 - 2, 0),
      Paint()
        ..color = const Color(0xFF2F8434).withValues(alpha: 0.6)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _drawLeaves(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const spots = <(double, double, double, double)>[
      (0.16, 0.06, 34, -0.5),
      (0.3, 0.02, 30, 0.4),
      (0.45, 0.06, 36, -0.2),
      (0.62, 0.03, 32, 0.5),
      (0.8, 0.09, 30, -0.4),
      (0.06, 0.2, 34, 0.7),
      (0.13, 0.32, 36, -0.3),
      (0.9, 0.24, 32, 0.5),
      (0.24, 0.2, 30, -0.8),
      (0.72, 0.17, 30, 0.7),
      (0.52, 0.22, 34, -0.5),
      (0.38, 0.33, 32, 0.3),
      (0.65, 0.35, 34, -0.3),
      (0.84, 0.37, 30, 0.6),
      (0.2, 0.4, 30, -0.6),
      (0.5, 0.4, 32, 0.4),
      (0.95, 0.1, 28, -0.7),
      (0.34, 0.14, 28, 0.9),
    ];
    for (var i = 0; i < spots.length; i++) {
      final (nx, ny, len, ang) = spots[i];
      final sway = reducedMotion ? 0.0 : math.sin(envPhase * 2 + i) * 0.05;
      _leaf(canvas, Offset(w * nx, h * ny), len, ang + sway,
          color: i.isEven ? const Color(0xFF8ED66B) : const Color(0xFF6BC24F));
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.44, size.height * 0.04),
      Offset(size.width * 0.19, size.height * 0.17),
      Offset(size.width * 0.44, size.height * 0.2),
      Offset(size.width * 0.72, size.height * 0.19),
      Offset(size.width * 0.23, size.height * 0.33),
      Offset(size.width * 0.75, size.height * 0.34),
    ];
    for (final spot in spots) {
      final sway = reducedMotion ? 0.0 : math.sin(envPhase * 2 + spot.dx) * 1.5;
      final c = spot + Offset(sway, 0);
      for (var i = 0; i < 5; i++) {
        final a = i * math.pi * 2 / 5 - math.pi / 2;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 9, math.sin(a) * 9),
          7,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          c + Offset(math.cos(a) * 9, math.sin(a) * 9 + 1.5),
          7,
          Paint()..color = const Color(0xFFDDE7EE).withValues(alpha: 0.5),
        );
      }
      canvas.drawCircle(c, 6, Paint()..color = const Color(0xFFFFC107));
      canvas.drawCircle(
        c + const Offset(-1.5, -1.5),
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  void _drawFallingLeaves(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final lx = (size.width * 0.2 + i * 90 + envPhase * 20) % size.width;
      final ly = size.height * 0.1 + (envPhase * 30 + i * 60) % (size.height * 0.4);
      _leaf(canvas, Offset(lx, ly), 16, envPhase + i, color: const Color(0xFF7CCB5B));
    }
  }

  @override
  bool shouldRepaint(covariant _BananaTreePainter old) =>
      old.envPhase != envPhase || old.reducedMotion != reducedMotion;
}
