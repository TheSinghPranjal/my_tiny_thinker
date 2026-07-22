import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecallPictureBackground extends StatelessWidget {
  const RecallPictureBackground({super.key, required this.child});

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
                Color(0xFFFFF59D),
                Color(0xFFF8BBD0),
                Color(0xFFB39DDB),
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
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.78);
    void drawCloud(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), s * 0.45, cloud);
      canvas.drawCircle(Offset(x - s * 0.4, y + 4), s * 0.34, cloud);
      canvas.drawCircle(Offset(x + s * 0.38, y + 3), s * 0.36, cloud);
    }

    drawCloud(size.width * 0.12, size.height * 0.1, 42);
    drawCloud(size.width * 0.78, size.height * 0.09, 34);
    drawCloud(size.width * 0.5, size.height * 0.14, 26);

    final sun = Offset(size.width * 0.9, size.height * 0.12);
    canvas.drawCircle(
      sun,
      28,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      sun,
      40,
      Paint()..color = const Color(0xFFFFEE58).withValues(alpha: 0.28),
    );

    void balloon(Offset c, Color color) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 20, height: 26),
        Paint()..color = color.withValues(alpha: 0.55),
      );
      canvas.drawLine(
        Offset(c.dx, c.dy + 13),
        Offset(c.dx, c.dy + 34),
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1.5,
      );
    }

    balloon(Offset(size.width * 0.16, size.height * 0.28), const Color(0xFFFF8A80));
    balloon(Offset(size.width * 0.84, size.height * 0.3), const Color(0xFF80D8FF));
    balloon(Offset(size.width * 0.22, size.height * 0.36), const Color(0xFFFFE082));

    final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 14; i++) {
      final x = size.width * ((i * 0.13 + 0.07) % 1);
      final y = size.height * (0.18 + (i % 5) * 0.06);
      canvas.drawCircle(Offset(x, y), 2.0 + (i % 2), sparkle);
    }

    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.78,
        size.width * 0.52,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.93,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.88),
    );

    // Soft picture frames floating
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.55, 40, 36),
        const Radius.circular(6),
      ),
      framePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.88, size.height * 0.58, 36, 32),
        const Radius.circular(6),
      ),
      framePaint,
    );

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
        Rect.fromCircle(center: center, radius: size.width * 0.44 - i * 8),
        math.pi + 0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = rainbow[i].withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
