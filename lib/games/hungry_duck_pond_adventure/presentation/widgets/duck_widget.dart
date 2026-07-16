import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

class DuckWidget extends StatelessWidget {
  const DuckWidget({super.key, required this.duck, this.largerTouch = false});

  final DuckEntity duck;
  final bool largerTouch;

  /// Visual size of the duck sprite; [duck.x]/[duck.y] is the center point.
  static double layoutSize(bool largerTouch) => largerTouch ? 118.0 : 108.0;

  @override
  Widget build(BuildContext context) {
    final size = layoutSize(largerTouch);
    final blink = (duck.blinkTimer % 3.5) < 0.12;
    final bob = duck.phase == DuckPhase.idleSwim
        ? math.sin(duck.animPhase * 2) * 3
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
    // Center the body in the canvas with a little extra room above for the head.
    final cy = size.height * 0.54;
    final eating = duck.phase == DuckPhase.eating;
    final celebrating = duck.phase == DuckPhase.celebrating;
    final chasing = duck.phase == DuckPhase.chasing;
    final flap = math.sin(duck.wingFlap) * (chasing ? 0.35 : 0.18);

    _drawRipples(canvas, cx, cy);
    _drawBody(canvas, cx, cy);
    _drawWing(canvas, cx - 20, cy + 2, -0.45 + flap, isNear: true);
    _drawWing(canvas, cx + 18, cy + 4, 0.35 - flap, isNear: false);
    _drawNeckAndHead(canvas, cx, cy, eating, celebrating);
    _drawTail(canvas, cx - 28, cy + 10);
    _drawBeak(canvas, cx, cy, eating, celebrating);
    _drawEye(canvas, cx, cy, blink);
  }

  void _drawRipples(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 2; i++) {
      final phase = duck.ripplePhase + i * 0.8;
      final alpha = (0.22 - i * 0.07).clamp(0.08, 0.22);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 30),
          width: 34 + math.sin(phase) * 6 + i * 8,
          height: 10 + i * 2,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 52, height: 34),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF176), Color(0xFFFFCA28), Color(0xFFFFB300)],
        ).createShader(bodyRect.outerRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 16), width: 38, height: 16),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
  }

  void _drawWing(Canvas canvas, double x, double y, double angle, {required bool isNear}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(8, -10, 22, -4)
      ..quadraticBezierTo(10, 2, 0, 0)
      ..close();
    canvas.drawPath(
      wing,
      Paint()
        ..color = Color(isNear ? 0xFFFFEE58 : 0xFFFFD54F).withValues(alpha: isNear ? 0.95 : 0.75),
    );
    canvas.drawPath(
      wing,
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  void _drawNeckAndHead(Canvas canvas, double cx, double cy, bool eating, bool celebrating) {
    canvas.drawPath(
      Path()
        ..moveTo(cx - 4, cy - 2)
        ..quadraticBezierTo(cx + 2, cy - 14, cx + 10, cy - 18),
      Paint()
        ..color = const Color(0xFFFFEB3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx + 14, cy - 20),
      15,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFCA28)],
        ).createShader(Rect.fromCircle(center: Offset(cx + 14, cy - 20), radius: 15)),
    );
    if (eating || celebrating) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 14, cy - 16), width: 10, height: 6),
        0.1,
        math.pi - 0.2,
        false,
        Paint()
          ..color = const Color(0xFFE65100).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawTail(Canvas canvas, double x, double y) {
    final tail = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x - 10, y - 8, x - 16, y - 2)
      ..quadraticBezierTo(x - 10, y + 4, x, y + 2)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawBeak(Canvas canvas, double cx, double cy, bool eating, bool celebrating) {
    final beak = Path()
      ..moveTo(cx + 26, cy - 20)
      ..lineTo(cx + 40, cy - 17)
      ..lineTo(cx + 26, cy - 14)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFF9800));
    canvas.drawPath(
      beak,
      Paint()
        ..color = const Color(0xFFE65100).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (eating || celebrating) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 30, cy - 17), width: 8, height: 5),
        0,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFBF360C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawEye(Canvas canvas, double cx, double cy, bool blink) {
    if (blink) {
      canvas.drawLine(
        Offset(cx + 8, cy - 24),
        Offset(cx + 16, cy - 24),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    canvas.drawCircle(Offset(cx + 12, cy - 24), 3.5, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + 13, cy - 25), 1.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.duck != duck || old.blink != blink;
}
