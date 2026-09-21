import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Light sky with a smiling sun, clouds and pale hills with little sprouts.
class SettingsBackground extends StatelessWidget {
  const SettingsBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SettingsScenePainter(), child: child);
  }
}

class _SettingsScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF93D3F8), Color(0xFFBCE5FA), Color(0xFFDDF2FC)],
        ).createShader(r),
    );

    // Sun with a face
    final c = Offset(w * 0.845, h * 0.115);
    canvas.drawCircle(
      c,
      78,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99FFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: c, radius: 78)),
    );
    for (var i = 0; i < 14; i++) {
      final a = i * math.pi * 2 / 14;
      canvas.drawLine(
        c + Offset(math.cos(a) * 42, math.sin(a) * 42),
        c + Offset(math.cos(a) * 58, math.sin(a) * 58),
        Paint()
          ..color = const Color(0xFFFFD84A).withValues(alpha: 0.9)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 40, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(c + const Offset(-10, -10), 17, Paint()..color = Colors.white.withValues(alpha: 0.35));
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(c + const Offset(-12, -4), 3.2, face);
    canvas.drawCircle(c + const Offset(12, -4), 3.2, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 24, height: 15),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFFE4553A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.65);
    canvas.drawCircle(c + const Offset(-24, 6), 6, cheek);
    canvas.drawCircle(c + const Offset(24, 6), 6, cheek);

    void cloud(Offset o, double s, double a) {
      final p = Paint()..color = Colors.white.withValues(alpha: a);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: o + Offset(0, 12 * s), width: 96 * s, height: 26 * s),
          Radius.circular(13 * s),
        ),
        p,
      );
      canvas.drawCircle(o + Offset(-22 * s, 3 * s), 19 * s, p);
      canvas.drawCircle(o + Offset(4 * s, -8 * s), 25 * s, p);
      canvas.drawCircle(o + Offset(30 * s, 5 * s), 17 * s, p);
    }

    cloud(Offset(w * 0.04, h * 0.155), 1.25, 0.95);
    cloud(Offset(w * 0.27, h * 0.135), 1.0, 0.75);
    cloud(Offset(w * 0.5, h * 0.06), 0.9, 0.6);
    cloud(Offset(w * 0.9, h * 0.18), 1.0, 0.95);

    // Hills at the bottom
    final hill = Path()
      ..moveTo(0, h * 0.94)
      ..quadraticBezierTo(w * 0.28, h * 0.885, w * 0.5, h * 0.93)
      ..quadraticBezierTo(w * 0.78, h * 0.885, w, h * 0.925)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCDEBC4), Color(0xFFB0DDA2)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w, h * 0.12)),
    );

    void sprout(Offset base, double s) {
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(base.dx - 2 * s, base.dy - 30 * s, base.dx + 2 * s, base.dy - 52 * s),
        Paint()
          ..color = const Color(0xFF4E9A45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * s
          ..strokeCap = StrokeCap.round,
      );
      for (final (dx, dy, dir) in [(0.0, -48.0, -1.0), (2.0, -52.0, 1.0), (-1.0, -30.0, -1.0), (1.0, -26.0, 1.0)]) {
        final o = base + Offset(dx * s, dy * s);
        canvas.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..quadraticBezierTo(o.dx + dir * 14 * s, o.dy - 22 * s, o.dx + dir * 34 * s, o.dy - 10 * s)
            ..quadraticBezierTo(o.dx + dir * 24 * s, o.dy + 10 * s, o.dx, o.dy)
            ..close(),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF86D264), Color(0xFF3F9C45)],
            ).createShader(Rect.fromCircle(center: o, radius: 40 * s)),
        );
      }
    }

    sprout(Offset(w * 0.07, h * 0.965), 1.0);
    sprout(Offset(w * 0.94, h * 0.96), 1.15);
    sprout(Offset(w * 0.83, h * 0.985), 0.7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small golden crown with sparkles for the Premium card.
class SettingsCrown extends StatelessWidget {
  const SettingsCrown({super.key, this.size = 62});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrownPainter()),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 62;
    canvas.save();
    canvas.scale(s);

    void sparkle(Offset c, double r) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r),
        Paint()..color = const Color(0xFFFFC928),
      );
    }

    sparkle(const Offset(6, 12), 4);
    sparkle(const Offset(52, 8), 6);
    sparkle(const Offset(56, 22), 3);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(31, 56), width: 44, height: 8),
      Paint()..color = const Color(0xFFE6C98A).withValues(alpha: 0.5),
    );
    final crown = Path()
      ..moveTo(10, 48)
      ..lineTo(6, 22)
      ..lineTo(20, 33)
      ..lineTo(31, 14)
      ..lineTo(42, 33)
      ..lineTo(56, 22)
      ..lineTo(52, 48)
      ..close();
    canvas.drawPath(
      crown,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE680), Color(0xFFFFC21F), Color(0xFFE59F12)],
        ).createShader(const Rect.fromLTWH(6, 14, 50, 36)),
    );
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFC98A0F).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in [const Offset(6, 21), const Offset(31, 12), const Offset(56, 21)]) {
      canvas.drawCircle(p, 4.4, Paint()..color = const Color(0xFFFFD84A));
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(10, 42, 42, 8), const Radius.circular(4)),
      Paint()..color = const Color(0xFFF2AE1A),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
