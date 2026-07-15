import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

class MonkeyWidget extends StatelessWidget {
  const MonkeyWidget({
    super.key,
    required this.monkey,
    this.largerTouch = false,
  });

  final MonkeyEntity monkey;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 160.0 : 140.0;
    final blink = (monkey.blinkTimer % 3.8) < 0.12;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MonkeyPainter(monkey: monkey, blink: blink),
      ),
    );
  }
}

class _MonkeyPainter extends CustomPainter {
  _MonkeyPainter({required this.monkey, required this.blink});

  final MonkeyEntity monkey;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    final reach = monkey.reachProgress;
    final eat = monkey.eatProgress;
    final sad = monkey.sadProgress;
    final clap = monkey.phase == MonkeyPhase.clapping
        ? math.sin(monkey.actionTimer * 14).abs()
        : 0.0;
    final breathe = math.sin(monkey.animPhase * 2) * 2;
    final tailWag = math.sin(monkey.tailWag) * 12;

    canvas.save();
    canvas.translate(0, breathe - reach * 14);

    _drawTail(canvas, cx + 38, cy + 20, tailWag);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 72, height: 64),
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 52, height: 38),
      Paint()..color = const Color(0xFFD7CCC8),
    );

    _drawArm(canvas, cx - 42, cy + 10, -0.4 - reach * 0.8 - clap * 0.5, const Color(0xFF795548));
    _drawArm(canvas, cx + 42, cy + 10, 0.4 + reach * 0.8 + clap * 0.5, const Color(0xFF795548));

    _drawLeg(canvas, cx - 18, cy + 48);
    _drawLeg(canvas, cx + 18, cy + 48);

    canvas.drawCircle(
      Offset(cx, cy - 8),
      34,
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 38, height: 30),
      Paint()..color = const Color(0xFFD7CCC8),
    );

    _drawEar(canvas, cx - 30, cy - 18, -monkey.earDroop * 8);
    _drawEar(canvas, cx + 30, cy - 18, -monkey.earDroop * 8);

    canvas.save();
    canvas.translate(monkey.headShake * 20, 0);
    _drawFace(canvas, cx, cy - 6, sad, eat);
    canvas.restore();

    if (monkey.phase == MonkeyPhase.eating || monkey.phase == MonkeyPhase.clapping) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + 8), width: 22, height: 14),
        0,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF5D4037)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    if (monkey.idleAction == 3 && monkey.phase == MonkeyPhase.idle) {
      canvas.drawCircle(
        Offset(cx + 28, cy - 30),
        8,
        Paint()..color = const Color(0xFF8D6E63),
      );
    }

    canvas.restore();
  }

  void _drawTail(Canvas canvas, double x, double y, double wag) {
    final path = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x + 20 + wag, y - 10, x + 35 + wag, y + 15);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawArm(Canvas canvas, double x, double y, double angle, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 0, 16, 38),
        const Radius.circular(8),
      ),
      Paint()..color = color,
    );
    canvas.drawCircle(const Offset(0, 40), 10, Paint()..color = color);
    canvas.restore();
  }

  void _drawLeg(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 18, height: 28),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 18), width: 24, height: 12),
      Paint()..color = const Color(0xFF5D4037),
    );
  }

  void _drawEar(Canvas canvas, double x, double y, double droop) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(droop * 0.08);
    canvas.drawCircle(const Offset(0, 0), 14, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(const Offset(2, 2), 8, Paint()..color = const Color(0xFFFFCCBC));
    canvas.restore();
  }

  void _drawFace(Canvas canvas, double cx, double cy, double sad, double eat) {
    final mouthY = cy + 12 + sad * 4;
    if (sad > 0.1) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, mouthY + 4), width: 18, height: 10),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF4E342E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    } else if (eat > 0) {
      canvas.drawCircle(
        Offset(cx, mouthY),
        6 + eat * 2,
        Paint()..color = const Color(0xFF4E342E),
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, mouthY - 2), width: 24, height: 14),
        0.1,
        math.pi - 0.2,
        false,
        Paint()
          ..color = const Color(0xFF4E342E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    if (blink) {
      canvas.drawLine(
        Offset(cx - 14, cy - 2),
        Offset(cx - 4, cy - 2),
        Paint()
          ..color = const Color(0xFF3E2723)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(cx + 4, cy - 2),
        Offset(cx + 14, cy - 2),
        Paint()
          ..color = const Color(0xFF3E2723)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawCircle(Offset(cx - 10, cy - 2), 5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx + 10, cy - 2), 5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx - 9, cy - 1), 3, Paint()..color = const Color(0xFF3E2723));
      canvas.drawCircle(Offset(cx + 11, cy - 1), 3, Paint()..color = const Color(0xFF3E2723));
    }
  }

  @override
  bool shouldRepaint(covariant _MonkeyPainter old) => old.monkey != monkey || old.blink != blink;
}
