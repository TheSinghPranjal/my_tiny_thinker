import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A tiny green sprout (used beside "Learning Path").
class HomeSprout extends StatelessWidget {
  const HomeSprout({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SproutPainter()),
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 46;
    canvas.save();
    canvas.scale(s);
    canvas.drawPath(
      Path()
        ..moveTo(23, 44)
        ..quadraticBezierTo(22, 30, 24, 18),
      Paint()
        ..color = const Color(0xFF4E8F3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    for (final dir in [-1.0, 1.0]) {
      final leaf = Path()
        ..moveTo(24, 20)
        ..quadraticBezierTo(24 + dir * 4, 4, 24 + dir * 20, 8)
        ..quadraticBezierTo(24 + dir * 18, 24, 24, 20)
        ..close();
      canvas.drawPath(
        leaf,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF7BCB5B), Color(0xFF3F9C45)],
          ).createShader(const Rect.fromLTWH(4, 4, 40, 20)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Little yellow burst of lines used beside the title and speech bubble.
class HomeBurst extends StatelessWidget {
  const HomeBurst({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BurstPainter()),
    );
  }
}

class _BurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFC928)
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width * 0.15, size.height * 0.9);
    for (final a in [-1.5, -0.95, -0.4]) {
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * size.width * 0.35, c + d * size.width * 0.8, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
