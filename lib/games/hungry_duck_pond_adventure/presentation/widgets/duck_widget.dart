import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

class DuckWidget extends StatelessWidget {
  const DuckWidget({super.key, required this.duck, this.largerTouch = false});

  final DuckEntity duck;
  final bool largerTouch;

  /// Visual size of the duck sprite; [duck.x]/[duck.y] is the center point.
  static double layoutSize(bool largerTouch) => largerTouch ? 128.0 : 116.0;

  @override
  Widget build(BuildContext context) {
    final size = layoutSize(largerTouch);
    final blink = (duck.blinkTimer % 3.5) < 0.12;
    final bob = duck.phase == DuckPhase.idleSwim
        ? math.sin(duck.animPhase * 2) * 3.5
        : duck.phase == DuckPhase.celebrating
            ? math.sin(duck.animPhase * 8) * 4
            : 0.0;

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Transform.scale(
          scaleX: duck.facingRight ? 1 : -1,
          child: CustomPaint(
            size: Size(size, size),
            painter: _DuckPainter(duck: duck, blink: blink),
          ),
        ),
      ),
    );
  }
}

class _DuckPainter extends CustomPainter {
  _DuckPainter({required this.duck, required this.blink});

  final DuckEntity duck;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.56;
    final eating = duck.phase == DuckPhase.eating;
    final celebrating = duck.phase == DuckPhase.celebrating;
    final chasing = duck.phase == DuckPhase.chasing;
    final flap = math.sin(duck.wingFlap) * (chasing ? 0.55 : celebrating ? 0.4 : 0.22);

    _drawRipples(canvas, cx, cy);
    _drawTail(canvas, cx, cy);
    _drawBody(canvas, cx, cy);
    _drawFarWing(canvas, cx, cy, flap);
    _drawNearWing(canvas, cx, cy, flap);
    _drawHead(canvas, cx, cy, eating, celebrating);
    _drawBeak(canvas, cx, cy, eating, celebrating);
    _drawEye(canvas, cx, cy, blink);
    _drawCheek(canvas, cx, cy);
  }

  void _drawRipples(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 3; i++) {
      final phase = duck.ripplePhase + i * 0.9;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 34 + i * 2),
          width: 40 + math.sin(phase) * 8 + i * 10,
          height: 11 + i * 2,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22 - i * 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final bodyRect = Rect.fromCenter(center: Offset(cx + 2, cy + 8), width: 58, height: 40);
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFFFEB3B), Color(0xFFFFC107)],
        ).createShader(bodyRect),
    );
    // Soft belly
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 4, cy + 16), width: 40, height: 20),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawFarWing(Canvas canvas, double cx, double cy, double flap) {
    canvas.save();
    canvas.translate(cx - 6, cy + 2);
    canvas.rotate(-0.55 - flap * 0.5);
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-6, -14, 8, -22)
      ..quadraticBezierTo(22, -14, 18, -2)
      ..quadraticBezierTo(10, 4, 0, 0)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.85));
    canvas.drawPath(
      wing,
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Feather lines
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(4.0 + i * 4, -4),
        Offset(2.0 + i * 3, -14 - i.toDouble()),
        Paint()
          ..color = const Color(0xFFFFB300).withValues(alpha: 0.45)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  void _drawNearWing(Canvas canvas, double cx, double cy, double flap) {
    canvas.save();
    canvas.translate(cx + 10, cy + 4);
    canvas.rotate(0.25 + flap);
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(4, -16, 20, -20)
      ..quadraticBezierTo(32, -10, 26, 2)
      ..quadraticBezierTo(14, 8, 0, 0)
      ..close();
    canvas.drawPath(
      wing,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF176), Color(0xFFFFCA28)],
        ).createShader(const Rect.fromLTWH(0, -22, 32, 30)),
    );
    canvas.drawPath(
      wing,
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(6.0 + i * 4, -2),
        Offset(8.0 + i * 4, -14 - i * 1.5),
        Paint()
          ..color = const Color(0xFFFFA000).withValues(alpha: 0.55)
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  void _drawTail(Canvas canvas, double cx, double cy) {
    // Fan of three feathers
    for (var i = 0; i < 3; i++) {
      final angle = -0.55 + i * 0.35;
      canvas.save();
      canvas.translate(cx - 26, cy + 6);
      canvas.rotate(angle);
      final feather = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-10, -8, -22, -4)
        ..quadraticBezierTo(-12, 4, 0, 4)
        ..close();
      canvas.drawPath(
        feather,
        Paint()..color = Color.lerp(const Color(0xFFFFCA28), const Color(0xFFFFA000), i / 3)!,
      );
      canvas.restore();
    }
  }

  void _drawHead(Canvas canvas, double cx, double cy, bool eating, bool celebrating) {
    // Neck
    canvas.drawPath(
      Path()
        ..moveTo(cx + 2, cy - 4)
        ..quadraticBezierTo(cx + 8, cy - 16, cx + 16, cy - 22),
      Paint()
        ..color = const Color(0xFFFFEB3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    final headCenter = Offset(cx + 18, cy - 26);
    canvas.drawCircle(
      headCenter,
      18,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFEB3B), Color(0xFFFFC107)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: headCenter, radius: 18)),
    );

    // Tiny tuft on head
    canvas.drawPath(
      Path()
        ..moveTo(headCenter.dx - 2, headCenter.dy - 16)
        ..quadraticBezierTo(headCenter.dx, headCenter.dy - 26, headCenter.dx + 6, headCenter.dy - 16),
      Paint()
        ..color = const Color(0xFFFFCA28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    if (eating || celebrating) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(headCenter.dx, headCenter.dy + 6), width: 12, height: 8),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFFE65100).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  void _drawBeak(Canvas canvas, double cx, double cy, bool eating, bool celebrating) {
    final open = eating || celebrating ? 3.0 : 0.0;
    // Upper beak
    final upper = Path()
      ..moveTo(cx + 30, cy - 28)
      ..lineTo(cx + 48, cy - 26)
      ..lineTo(cx + 30, cy - 22)
      ..close();
    canvas.drawPath(upper, Paint()..color = const Color(0xFFFF9800));
    canvas.drawPath(
      upper,
      Paint()
        ..color = const Color(0xFFE65100).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Lower beak
    final lower = Path()
      ..moveTo(cx + 30, cy - 22 + open)
      ..lineTo(cx + 44, cy - 20 + open)
      ..lineTo(cx + 30, cy - 18 + open)
      ..close();
    canvas.drawPath(lower, Paint()..color = const Color(0xFFFF6D00));
    // Nostril
    canvas.drawCircle(Offset(cx + 36, cy - 26), 1.4, Paint()..color = const Color(0xFFE65100));
  }

  void _drawEye(Canvas canvas, double cx, double cy, bool blink) {
    final eye = Offset(cx + 14, cy - 30);
    if (blink) {
      canvas.drawLine(
        Offset(eye.dx - 5, eye.dy),
        Offset(eye.dx + 5, eye.dy),
        Paint()
          ..color = const Color(0xFF3E2723)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    canvas.drawCircle(eye, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(eye.dx + 1.2, eye.dy), 3.4, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(Offset(eye.dx + 2.2, eye.dy - 1.4), 1.4, Paint()..color = Colors.white);
  }

  void _drawCheek(Canvas canvas, double cx, double cy) {
    canvas.drawCircle(
      Offset(cx + 22, cy - 20),
      4,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.duck != duck || old.blink != blink;
}
