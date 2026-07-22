import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompleteWordAdventureBackground extends StatelessWidget {
  const CompleteWordAdventureBackground({super.key, required this.child});

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
        CustomPaint(painter: _ClassroomAdventurePainter(), size: Size.infinite),
        child,
      ],
    );
  }
}

class _ClassroomAdventurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft clouds
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.78);
    void drawCloud(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), s * 0.45, cloud);
      canvas.drawCircle(Offset(x - s * 0.4, y + 4), s * 0.34, cloud);
      canvas.drawCircle(Offset(x + s * 0.38, y + 3), s * 0.36, cloud);
    }

    drawCloud(size.width * 0.14, size.height * 0.1, 44);
    drawCloud(size.width * 0.78, size.height * 0.08, 36);
    drawCloud(size.width * 0.48, size.height * 0.15, 28);

    // Sun
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

    // Floating books / pencils (simple shapes)
    final book = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.62, 36, 28),
      const Radius.circular(4),
    );
    canvas.drawRRect(book, Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.68, 32, 24),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF42A5F5).withValues(alpha: 0.5),
    );

    // Pencil
    final pencil = Paint()
      ..color = const Color(0xFFFFCA28).withValues(alpha: 0.6)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.88, size.height * 0.64),
      Offset(size.width * 0.94, size.height * 0.74),
      pencil,
    );

    // Balloons
    void balloon(Offset c, Color color) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 22, height: 28),
        Paint()..color = color.withValues(alpha: 0.55),
      );
      canvas.drawLine(
        Offset(c.dx, c.dy + 14),
        Offset(c.dx, c.dy + 36),
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1.5,
      );
    }

    balloon(Offset(size.width * 0.18, size.height * 0.28), const Color(0xFFFF8A80));
    balloon(Offset(size.width * 0.82, size.height * 0.3), const Color(0xFF80D8FF));

    // Stars / sparkles
    final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 0.15 + 0.08) % 1);
      final y = size.height * (0.2 + (i % 4) * 0.07);
      canvas.drawCircle(Offset(x, y), 2.2 + (i % 2), sparkle);
    }

    // Hills
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
    canvas.drawPath(hill, Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.85));

    // Soft rainbow
    final rainbow = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFCC80),
      const Color(0xFFFFF59D),
      const Color(0xFFA5D6A7),
      const Color(0xFF90CAF9),
      const Color(0xFFCE93D8),
    ];
    final center = Offset(size.width * 0.5, size.height * 0.48);
    for (var i = 0; i < rainbow.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.46 - i * 8),
        math.pi + 0.18,
        math.pi - 0.36,
        false,
        Paint()
          ..color = rainbow[i].withValues(alpha: 0.26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
