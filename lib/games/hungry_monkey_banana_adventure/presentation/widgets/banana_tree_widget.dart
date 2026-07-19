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
    // Canopy fills most of the upper play area; trunk meets its underside.
    final trunkTop = size.height * 0.48;
    final trunkBottom = size.height * 0.94;

    _drawTrunk(canvas, cx, trunkTop, trunkBottom, size);
    _drawCanopy(canvas, cx, size);
    _drawVines(canvas, size);
    _drawFlowers(canvas, size);
    if (!reducedMotion) _drawFallingLeaves(canvas, size);
  }

  void _drawTrunk(Canvas canvas, double cx, double top, double bottom, Size size) {
    final trunk = Path()
      ..moveTo(cx - 28, bottom)
      ..quadraticBezierTo(cx - 34, (top + bottom) / 2, cx - 20, top + 10)
      ..lineTo(cx + 20, top + 10)
      ..quadraticBezierTo(cx + 34, (top + bottom) / 2, cx + 28, bottom)
      ..close();
    canvas.drawPath(
      trunk,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF5D4037),
            Color(0xFF8D6E63),
            Color(0xFF4E342E),
          ],
        ).createShader(Rect.fromLTWH(cx - 34, top, 68, bottom - top)),
    );
    for (var i = 0; i < 5; i++) {
      final y = top + 30 + i * ((bottom - top - 50) / 5);
      canvas.drawLine(
        Offset(cx - 20 + i * 2, y),
        Offset(cx + 16 - i, y + 4),
        Paint()
          ..color = const Color(0xFF3E2723).withValues(alpha: 0.35)
          ..strokeWidth = 2,
      );
    }
  }

  /// Large leafy canopy spanning the fruit zone (wide + tall).
  void _drawCanopy(Canvas canvas, double cx, Size size) {
    final sway = reducedMotion ? 0.0 : math.sin(envPhase * 1.2) * 6;
    final w = size.width;
    final h = size.height;

    // Overlapping leaf blobs — sized as fractions of the tree widget so
    // fruits across the upper screen sit inside the green top.
    final leaves = <(double, double, double)>[
      // Outer left / right lobes
      (cx - w * 0.38 + sway, h * 0.22, w * 0.22),
      (cx + w * 0.38 - sway, h * 0.22, w * 0.22),
      // Upper crown
      (cx - w * 0.22 + sway * 0.5, h * 0.08, w * 0.24),
      (cx + w * 0.02, h * 0.04, w * 0.28),
      (cx + w * 0.24 - sway * 0.5, h * 0.08, w * 0.24),
      // Mid band (main fruit belt)
      (cx - w * 0.30 + sway * 0.4, h * 0.18, w * 0.26),
      (cx, h * 0.16, w * 0.30),
      (cx + w * 0.30 - sway * 0.4, h * 0.18, w * 0.26),
      // Lower canopy edge above trunk
      (cx - w * 0.26, h * 0.32, w * 0.24),
      (cx - w * 0.05, h * 0.36, w * 0.26),
      (cx + w * 0.18, h * 0.34, w * 0.24),
      (cx + w * 0.34, h * 0.30, w * 0.20),
      // Fill gaps
      (cx - w * 0.14, h * 0.24, w * 0.22),
      (cx + w * 0.14, h * 0.24, w * 0.22),
      (cx - w * 0.36, h * 0.12, w * 0.18),
      (cx + w * 0.36, h * 0.12, w * 0.18),
    ];

    for (final (lx, ly, r) in leaves) {
      canvas.drawCircle(
        Offset(lx, ly),
        r,
        Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.94),
      );
      canvas.drawCircle(
        Offset(lx + r * 0.22, ly - r * 0.18),
        r * 0.55,
        Paint()..color = const Color(0xFF43A047).withValues(alpha: 0.88),
      );
      canvas.drawCircle(
        Offset(lx - r * 0.18, ly + r * 0.12),
        r * 0.35,
        Paint()..color = const Color(0xFF1B5E20).withValues(alpha: 0.35),
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
      final startX = size.width * (0.32 + i * 0.18);
      final path = Path()
        ..moveTo(startX, size.height * 0.28)
        ..quadraticBezierTo(
          startX + math.sin(envPhase + i) * 14,
          size.height * 0.42,
          startX + 18,
          size.height * 0.55,
        );
      canvas.drawPath(path, paint);
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.18, size.height * 0.14),
      Offset(size.width * 0.82, size.height * 0.16),
      Offset(size.width * 0.50, size.height * 0.10),
      Offset(size.width * 0.34, size.height * 0.28),
      Offset(size.width * 0.68, size.height * 0.30),
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
      final lx = (size.width * 0.2 + i * 50 + envPhase * 20) % size.width;
      final ly = size.height * 0.12 + (envPhase * 30 + i * 40) % (size.height * 0.35);
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
