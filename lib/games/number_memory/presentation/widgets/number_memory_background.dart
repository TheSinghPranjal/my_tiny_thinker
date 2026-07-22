import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Playful sky + number-sparkle playground for Number Memory.
class NumberMemoryBackground extends StatelessWidget {
  const NumberMemoryBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF81D4FA),
                Color(0xFFFFE082),
                Color(0xFFCE93D8),
                Color(0xFFA5D6A7),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _NumberMemoryPainter(), size: Size.infinite),
        child,
      ],
    );
  }
}

class _NumberMemoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.78);
    void drawCloud(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), s * 0.45, cloud);
      canvas.drawCircle(Offset(x - s * 0.4, y + 4), s * 0.34, cloud);
      canvas.drawCircle(Offset(x + s * 0.38, y + 3), s * 0.36, cloud);
    }

    drawCloud(size.width * 0.16, size.height * 0.1, 44);
    drawCloud(size.width * 0.74, size.height * 0.08, 36);
    drawCloud(size.width * 0.48, size.height * 0.15, 28);

    final sun = Offset(size.width * 0.9, size.height * 0.11);
    canvas.drawCircle(
      sun,
      30,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      sun,
      40,
      Paint()..color = const Color(0xFFFFEE58).withValues(alpha: 0.3),
    );

    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.8,
        size.width * 0.55,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.92,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.85),
    );

    final front = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.86,
        size.width,
        size.height * 0.92,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF66BB6A));

    final digitPaint = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final digits = ['1', '2', '3', '5', '7', '8', '9'];
    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFF80D8FF),
      const Color(0xFFFFF59D),
      const Color(0xFFCE93D8),
      const Color(0xFFA5D6A7),
      const Color(0xFFFFCC80),
    ];
    for (var i = 0; i < digits.length; i++) {
      final x = size.width * ((i * 0.14 + 0.08) % 1);
      final y = size.height * (0.22 + (i % 4) * 0.1);
      digitPaint.text = TextSpan(
        text: digits[i],
        style: TextStyle(
          fontSize: 22 + (i % 3) * 4,
          fontWeight: FontWeight.w900,
          color: colors[i % colors.length].withValues(alpha: 0.35),
        ),
      );
      digitPaint.layout();
      digitPaint.paint(canvas, Offset(x, y));
    }

    final rainbow = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFCC80),
      const Color(0xFFFFF59D),
      const Color(0xFFA5D6A7),
      const Color(0xFF90CAF9),
      const Color(0xFFCE93D8),
    ];
    final center = Offset(size.width * 0.5, size.height * 0.5);
    for (var i = 0; i < rainbow.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.46 - i * 8),
        math.pi + 0.18,
        math.pi - 0.36,
        false,
        Paint()
          ..color = rainbow[i].withValues(alpha: 0.24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
