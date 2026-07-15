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
    final trunkTop = size.height * 0.38;
    final trunkBottom = size.height * 0.92;

    _drawTrunk(canvas, cx, trunkTop, trunkBottom, size);
    _drawVines(canvas, size);
    _drawCanopy(canvas, cx, trunkTop, size);
    _drawFlowers(canvas, size);
    if (!reducedMotion) _drawFallingLeaves(canvas, size);
  }

  void _drawTrunk(Canvas canvas, double cx, double top, double bottom, Size size) {
    final trunk = Path()
      ..moveTo(cx - 28, bottom)
      ..quadraticBezierTo(cx - 34, (top + bottom) / 2, cx - 18, top + 20)
      ..lineTo(cx + 18, top + 20)
      ..quadraticBezierTo(cx + 34, (top + bottom) / 2, cx + 28, bottom)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5D4037),
            const Color(0xFF8D6E63),
            const Color(0xFF4E342E),
          ],
        ).createShader(Rect.fromLTWH(cx - 34, top, 68, bottom - top)),
    );
    for (var i = 0; i < 5; i++) {
      final y = top + 40 + i * ((bottom - top - 60) / 5);
      canvas.drawLine(
        Offset(cx - 20 + i * 2, y),
        Offset(cx + 16 - i, y + 4),
        Paint()
          ..color = const Color(0xFF3E2723).withValues(alpha: 0.35)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawVines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF33691E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final startX = size.width * (0.35 + i * 0.15);
      final path = Path()
        ..moveTo(startX, size.height * 0.15)
        ..quadraticBezierTo(
          startX + math.sin(envPhase + i) * 12,
          size.height * 0.35,
          startX + 20,
          size.height * 0.55,
        );
      canvas.drawPath(path, paint);
    }
  }

  void _drawCanopy(Canvas canvas, double cx, double trunkTop, Size size) {
    final sway = reducedMotion ? 0.0 : math.sin(envPhase * 1.2) * 4;
    final leaves = [
      (cx - 90 + sway, trunkTop - 30, 55.0),
      (cx - 40 + sway * 0.5, trunkTop - 70, 65.0),
      (cx + 10, trunkTop - 85, 70.0),
      (cx + 55 - sway * 0.5, trunkTop - 65, 60.0),
      (cx + 95 - sway, trunkTop - 25, 50.0),
      (cx - 60, trunkTop - 10, 45.0),
      (cx + 70, trunkTop - 5, 42.0),
    ];
    for (final (lx, ly, r) in leaves) {
      canvas.drawCircle(
        Offset(lx, ly),
        r,
        Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.92),
      );
      canvas.drawCircle(
        Offset(lx + r * 0.25, ly - r * 0.15),
        r * 0.55,
        Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.85),
      );
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.28, size.height * 0.22),
      Offset(size.width * 0.72, size.height * 0.25),
      Offset(size.width * 0.58, size.height * 0.18),
    ];
    for (final spot in spots) {
      final sway = math.sin(envPhase * 2 + spot.dx) * 3;
      canvas.drawCircle(
        spot + Offset(sway, 0),
        6,
        Paint()..color = const Color(0xFFFF7043),
      );
      for (var i = 0; i < 5; i++) {
        final a = i * math.pi * 2 / 5;
        canvas.drawCircle(
          spot + Offset(sway + math.cos(a) * 10, math.sin(a) * 10),
          4,
          Paint()..color = const Color(0xFFFFAB91),
        );
      }
    }
  }

  void _drawFallingLeaves(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final lx = (size.width * 0.3 + i * 50 + envPhase * 20) % size.width;
      final ly = size.height * 0.2 + (envPhase * 30 + i * 40) % (size.height * 0.5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(lx, ly), width: 10, height: 6),
        Paint()..color = const Color(0xFF689F38).withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BananaTreePainter old) =>
      old.envPhase != envPhase || old.reducedMotion != reducedMotion;
}
