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

/// Stack of colourful books topped with a sprout, plus sparkles.
class HomeBooks extends StatelessWidget {
  const HomeBooks({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BooksPainter()),
    );
  }
}

class _BooksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 150;
    canvas.save();
    canvas.scale(s);

    void sparkle(Offset c, double r, double a) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r),
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }

    sparkle(const Offset(118, 22), 9, 0.95);
    sparkle(const Offset(32, 70), 13, 0.95);
    sparkle(const Offset(138, 62), 6, 0.8);
    sparkle(const Offset(14, 108), 5, 0.7);
    sparkle(const Offset(146, 92), 5, 0.6);

    void book(double y, double w, double h, Color cover, Color coverDark, double dx) {
      final r = Rect.fromLTWH(20 + dx, y, w, h);
      // Cover
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(9)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cover, coverDark],
          ).createShader(r),
      );
      // Pages on the right
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left + 24, r.top + 5, r.width - 20, r.height - 10),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFFFF7EA),
      );
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(
          Offset(r.left + 26, r.top + 5 + i * (r.height - 10) / 3),
          Offset(r.right - 2, r.top + 5 + i * (r.height - 10) / 3),
          Paint()
            ..color = const Color(0xFFE6D6BF)
            ..strokeWidth = 1.2,
        );
      }
      // Spine highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left + 3, r.top + 3, 12, r.height - 6),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.22),
      );
    }

    book(96, 112, 28, const Color(0xFFF06FA6), const Color(0xFFD5498A), 8);
    book(68, 108, 28, const Color(0xFFFFB443), const Color(0xFFF08F1D), 2);
    book(40, 96, 28, const Color(0xFF5B9CF0), const Color(0xFF3B7CD8), 10);

    // Sprout on top
    canvas.save();
    canvas.translate(68, 40);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-1, -14, 2, -26),
      Paint()
        ..color = const Color(0xFF4E8F3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    for (final dir in [-1.0, 1.0]) {
      final leaf = Path()
        ..moveTo(2, -24)
        ..quadraticBezierTo(2 + dir * 6, -46, 2 + dir * 30, -40)
        ..quadraticBezierTo(2 + dir * 28, -22, 2, -24)
        ..close();
      canvas.drawPath(
        leaf,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF86D264), Color(0xFF3F9C45)],
          ).createShader(const Rect.fromLTWH(-28, -46, 60, 26)),
      );
    }
    canvas.restore();
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
