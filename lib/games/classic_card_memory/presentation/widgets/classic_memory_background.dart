import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Playful sky + candy hills background for Classic Card Memory.
class ClassicMemoryPlaygroundBackground extends StatelessWidget {
  const ClassicMemoryPlaygroundBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81D4FA),
                Color(0xFFFFE082),
                Color(0xFFF8BBD0),
                Color(0xFFCE93D8),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _PlaygroundPainter(), size: Size.infinite),
        child,
      ],
    );
  }
}

class _PlaygroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft clouds
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.75);
    void drawCloud(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), s * 0.45, cloud);
      canvas.drawCircle(Offset(x - s * 0.4, y + 4), s * 0.34, cloud);
      canvas.drawCircle(Offset(x + s * 0.38, y + 3), s * 0.36, cloud);
    }

    drawCloud(size.width * 0.18, size.height * 0.1, 46);
    drawCloud(size.width * 0.72, size.height * 0.08, 38);
    drawCloud(size.width * 0.5, size.height * 0.16, 30);

    // Candy sun
    final sunCenter = Offset(size.width * 0.88, size.height * 0.12);
    canvas.drawCircle(
      sunCenter,
      34,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      sunCenter,
      42,
      Paint()..color = const Color(0xFFFFEE58).withValues(alpha: 0.35),
    );

    // Rolling hills
    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.74,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.86,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF81C784));

    final front = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.84,
        size.width,
        size.height * 0.9,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF66BB6A));

    // Floating confetti dots
    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFF80D8FF),
      const Color(0xFFFFF59D),
      const Color(0xFFCE93D8),
      const Color(0xFFA5D6A7),
    ];
    for (var i = 0; i < 14; i++) {
      final x = size.width * ((i * 0.17 + 0.05) % 1);
      final y = size.height * (0.22 + (i % 5) * 0.08);
      canvas.drawCircle(
        Offset(x, y),
        3.5 + (i % 3).toDouble(),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.55),
      );
    }

    // Soft rainbow arc
    final rainbow = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFCC80),
      const Color(0xFFFFF59D),
      const Color(0xFFA5D6A7),
      const Color(0xFF90CAF9),
      const Color(0xFFCE93D8),
    ];
    final center = Offset(size.width * 0.5, size.height * 0.55);
    for (var i = 0; i < rainbow.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.48 - i * 9),
        math.pi + 0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = rainbow[i].withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
