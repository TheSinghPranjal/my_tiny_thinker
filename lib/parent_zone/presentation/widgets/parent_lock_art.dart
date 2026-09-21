import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sunny sky behind the Parent Zone lock screen: smiling sun, clouds, a
/// butterfly, birds, balloons, a pastel rainbow, a bee and grassy hills.
class ParentLockBackground extends StatelessWidget {
  const ParentLockBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LockScenePainter(), child: child);
  }
}

class _LockScenePainter extends CustomPainter {
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
          colors: [Color(0xFF8FD0F6), Color(0xFFB9E3FA), Color(0xFFDDF2FC)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(r),
    );

    _sun(canvas, Offset(w * 0.845, h * 0.105));
    for (final (nx, ny, s) in [
      (0.09, 0.195, 0.85),
      (0.24, 0.115, 0.95),
      (0.52, 0.2, 0.9),
      (0.92, 0.2, 1.0),
    ]) {
      _cloud(canvas, Offset(w * nx, h * ny), s);
    }
    _butterfly(canvas, Offset(w * 0.25, h * 0.185));
    _bird(canvas, Offset(w * 0.19, h * 0.238), 1.0);
    _bird(canvas, Offset(w * 0.75, h * 0.198), 0.9);
    _rainbow(canvas, size);
    _balloons(canvas, size);
    _bee(canvas, Offset(w * 0.84, h * 0.3));
    _hills(canvas, size);
  }

  void _sun(Canvas canvas, Offset c) {
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
    canvas.drawCircle(
      c + const Offset(-10, -10),
      17,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(c + const Offset(-12, -4), 3.2, face);
    canvas.drawCircle(c + const Offset(12, -4), 3.2, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 24, height: 15),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawCircle(c + const Offset(-24, 6), 6, cheek);
    canvas.drawCircle(c + const Offset(24, 6), 6, cheek);
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final shade = Paint()..color = const Color(0xFFC9E3F5);
    final body = Paint()..color = Colors.white.withValues(alpha: 0.97);
    void puffs(Paint p, double dy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 12 * s + dy), width: 96 * s, height: 26 * s),
          Radius.circular(13 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-22 * s, 3 * s + dy), 19 * s, p);
      canvas.drawCircle(c + Offset(4 * s, -8 * s + dy), 25 * s, p);
      canvas.drawCircle(c + Offset(30 * s, 5 * s + dy), 17 * s, p);
    }

    puffs(shade, 3 * s);
    puffs(body, 0);
  }

  void _butterfly(Canvas canvas, Offset c) {
    for (final dir in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(dir * 9, -6), width: 16, height: 20),
        Paint()..color = const Color(0xFFFF8A3D),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(dir * 8, 8), width: 12, height: 14),
        Paint()..color = const Color(0xFFF2604A),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, 1), width: 4, height: 24),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A2F22),
    );
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        c + const Offset(0, -10),
        c + Offset(dir * 7, -20),
        Paint()
          ..color = const Color(0xFF4A2F22)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _bird(Canvas canvas, Offset c, double s) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 24 * s, c.dy + 6 * s)
        ..quadraticBezierTo(c.dx - 12 * s, c.dy - 10 * s, c.dx, c.dy)
        ..quadraticBezierTo(c.dx + 12 * s, c.dy - 12 * s, c.dx + 26 * s, c.dy - 2 * s),
      Paint()
        ..color = const Color(0xFF4A5468)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * s
        ..strokeCap = StrokeCap.round,
    );
  }

  void _rainbow(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.665;
    const colors = [
      Color(0xFFF7B2C4),
      Color(0xFFFBD9A8),
      Color(0xFFF6F2A5),
      Color(0xFFB9EBC0),
      Color(0xFFB7DDF8),
      Color(0xFFC9BDF3),
    ];
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * 56.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width * 1.16 - shrink,
          height: size.height * 0.68 - shrink * 1.2,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 58,
      );
    }
  }

  void _balloons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (nx, ny, col, sw) in [
      (0.072, 0.302, 0xFFF3789B, 0.03),
      (0.195, 0.298, 0xFF5AA8F0, -0.02),
    ]) {
      final c = Offset(w * nx, h * ny);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy + 30)
          ..quadraticBezierTo(c.dx + w * sw * 2, c.dy + 60, c.dx + w * sw, c.dy + 110),
        Paint()
          ..color = const Color(0xFF9DB0C8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      final oval = Rect.fromCenter(center: c, width: 50, height: 62);
      canvas.drawOval(
        oval,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.45),
            colors: [
              Color.lerp(Color(col), Colors.white, 0.5)!,
              Color(col),
              Color.lerp(Color(col), Colors.black, 0.15)!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(oval),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c + const Offset(-10, -14), width: 10, height: 14),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  void _bee(Canvas canvas, Offset c) {
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(-4, -12), width: 16, height: 20),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    final body = Rect.fromCenter(center: c, width: 40, height: 28);
    canvas.drawOval(body, Paint()..color = const Color(0xFFFFD23F));
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    for (final dx in [-6.0, 6.0]) {
      canvas.drawRect(
        Rect.fromCenter(center: c + Offset(dx, 0), width: 7, height: 30),
        Paint()..color = const Color(0xFF3B2A18),
      );
    }
    canvas.restore();
    canvas.drawCircle(c + const Offset(-16, -1), 3, Paint()..color = const Color(0xFF3B2A18));
    // Dotted flight trail
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + 22, c.dy + 12)
        ..quadraticBezierTo(c.dx + 36, c.dy + 4, c.dx + 30, c.dy + 22),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _hills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hill = Path()
      ..moveTo(0, h * 0.925)
      ..quadraticBezierTo(w * 0.5, h * 0.865, w, h * 0.92)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA8DF72), Color(0xFF78C24C)],
        ).createShader(Rect.fromLTWH(0, h * 0.86, w, h * 0.14)),
    );
    // Bushes on both sides
    for (final side in [0.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final nx = side == 0 ? 0.0 + i * 0.085 : 1.0 - i * 0.085;
        final c = Offset(w * nx, h * (0.9 - (i % 2) * 0.012 - (i == 0 ? 0.02 : 0)));
        final rad = 52.0 - i * 6;
        canvas.drawCircle(c, rad, Paint()..color = const Color(0xFF3F9C45));
        canvas.drawCircle(
          c + Offset(-rad * 0.25, -rad * 0.3),
          rad * 0.55,
          Paint()..color = const Color(0xFF67BC58).withValues(alpha: 0.8),
        );
      }
    }
    // Daisies
    for (final (nx, ny, rad) in [(0.1, 0.95, 11.0), (0.9, 0.945, 11.0), (0.75, 0.985, 10.0), (0.36, 0.993, 7.0)]) {
      final c = Offset(w * nx, h * ny);
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawCircle(c + Offset(math.cos(a) * rad, math.sin(a) * rad), rad * 0.68, Paint()..color = Colors.white);
      }
      canvas.drawCircle(c, rad * 0.55, Paint()..color = const Color(0xFFFFB300));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Golden padlock with a keyhole and little sparkle dashes.
class GoldPadlock extends StatelessWidget {
  const GoldPadlock({super.key, this.size = 110});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.6,
      height: size,
      child: CustomPaint(painter: _PadlockPainter()),
    );
  }
}

class _PadlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 110;
    canvas.save();
    canvas.translate(size.width / 2, 0);
    canvas.scale(s);

    // Sparkle dashes
    final dash = Paint()
      ..color = const Color(0xFFFFD84A)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-58, 34), const Offset(-70, 30), dash);
    canvas.drawLine(const Offset(-52, 18), const Offset(-62, 8), dash);
    canvas.drawLine(const Offset(52, 18), const Offset(62, 8), dash);
    canvas.drawLine(const Offset(58, 34), const Offset(70, 30), dash);
    canvas.drawLine(const Offset(-56, 54), const Offset(-72, 54), dash);

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 104), width: 82, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    // Shackle
    final shackle = Path()
      ..moveTo(-24, 50)
      ..lineTo(-24, 28)
      ..arcToPoint(const Offset(24, 28), radius: const Radius.circular(24), clockwise: true)
      ..lineTo(24, 50);
    canvas.drawPath(
      shackle,
      Paint()
        ..color = const Color(0xFFD9A11E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      shackle,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFE27A), Color(0xFFFFC21F), Color(0xFFE59F12)],
        ).createShader(const Rect.fromLTWH(-30, 0, 60, 60))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );

    // Body
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-42, 44, 84, 58),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE680), Color(0xFFFFC21F), Color(0xFFE59F12)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(const Rect.fromLTWH(-42, 44, 84, 58)),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = const Color(0xFFC98A0F).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Highlights
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-34, 50, 68, 12), const Radius.circular(7)),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-38, 60, 7, 30), const Radius.circular(4)),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Keyhole
    final key = Paint()..color = const Color(0xFF5A3A08);
    canvas.drawCircle(const Offset(0, 68), 8, key);
    canvas.drawPath(
      Path()
        ..moveTo(-4.5, 72)
        ..lineTo(4.5, 72)
        ..lineTo(6, 90)
        ..lineTo(-6, 90)
        ..close(),
      key,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
