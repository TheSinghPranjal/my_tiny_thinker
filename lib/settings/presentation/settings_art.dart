import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';

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
    paintSmilingSun(canvas, Offset(w * 0.845, h * 0.115), 40, rayCount: 14, rayColor: SharedArtColors.sparkle);

    paintPuffyCloud(canvas, Offset(w * 0.04, h * 0.155), 1.25, shaded: false, bodyAlpha: 0.95);
    paintPuffyCloud(canvas, Offset(w * 0.27, h * 0.135), 1.0, shaded: false, bodyAlpha: 0.75);
    paintPuffyCloud(canvas, Offset(w * 0.5, h * 0.06), 0.9, shaded: false, bodyAlpha: 0.6);
    paintPuffyCloud(canvas, Offset(w * 0.9, h * 0.18), 1.0, shaded: false, bodyAlpha: 0.95);

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
