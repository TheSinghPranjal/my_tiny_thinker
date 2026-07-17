import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

class CandyAntWidget extends StatelessWidget {
  const CandyAntWidget({
    super.key,
    required this.mood,
    required this.animPhase,
    required this.blinkTimer,
    this.size = 140,
  });

  final AntMood mood;
  final double animPhase;
  final double blinkTimer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final breath = 1 + math.sin(animPhase) * 0.03;
    final bounce = math.sin(animPhase * 1.3) * 4;
    final dance =
        mood == AntMood.happy || mood == AntMood.eating
            ? math.sin(animPhase * 6) * 8
            : 0.0;
    final shake =
        mood == AntMood.shakeNo ? math.sin(animPhase * 10) * 10 : 0.0;

    return Transform.translate(
      offset: Offset(shake + dance, bounce),
      child: Transform.scale(
        scale: breath,
        child: CustomPaint(
          size: Size(size, size * 1.15),
          painter: _AntPainter(
            mood: mood,
            animPhase: animPhase,
            blinkTimer: blinkTimer,
          ),
        ),
      ),
    );
  }
}

class _AntPainter extends CustomPainter {
  _AntPainter({
    required this.mood,
    required this.animPhase,
    required this.blinkTimer,
  });

  final AntMood mood;
  final double animPhase;
  final double blinkTimer;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
      ).createShader(Offset.zero & size);

    // Ground legs (4)
    final legPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final legBounce = math.sin(animPhase * 2) * 2;
    for (final dx in [-22.0, -10.0, 10.0, 22.0]) {
      canvas.drawLine(
        Offset(cx + dx * 0.35, size.height * 0.62),
        Offset(cx + dx, size.height * 0.92 + legBounce),
        legPaint,
      );
    }

    // Body segments (3 ovals)
    final abdomen = Offset(cx, size.height * 0.72);
    final thorax = Offset(cx, size.height * 0.52);
    final head = Offset(cx, size.height * 0.32);

    canvas.drawOval(
      Rect.fromCenter(center: abdomen, width: size.width * 0.42, height: size.height * 0.28),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: thorax, width: size.width * 0.34, height: size.height * 0.22),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: head, width: size.width * 0.38, height: size.height * 0.28),
      body,
    );

    // Soft highlights
    final gloss = Paint()..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: head + Offset(-6, -6),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      gloss,
    );

    // Arms (front legs)
    final armSwing = mood == AntMood.eating || mood == AntMood.happy
        ? math.sin(animPhase * 8) * 18
        : math.sin(animPhase) * 6;
    canvas.drawLine(
      thorax + const Offset(-16, 0),
      thorax + Offset(-34, 10 + armSwing),
      legPaint,
    );
    canvas.drawLine(
      thorax + const Offset(16, 0),
      thorax + Offset(34, 10 - armSwing),
      legPaint,
    );

    // Antennae
    final antSway = math.sin(animPhase * 1.6) * 8;
    final antPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final a1 = Path()
      ..moveTo(head.dx - 10, head.dy - 18)
      ..quadraticBezierTo(
        head.dx - 28 + antSway,
        head.dy - 48,
        head.dx - 18 + antSway,
        head.dy - 58,
      );
    final a2 = Path()
      ..moveTo(head.dx + 10, head.dy - 18)
      ..quadraticBezierTo(
        head.dx + 28 - antSway,
        head.dy - 48,
        head.dx + 18 - antSway,
        head.dy - 58,
      );
    canvas.drawPath(a1, antPaint);
    canvas.drawPath(a2, antPaint);
    canvas.drawCircle(
      Offset(head.dx - 18 + antSway, head.dy - 58),
      4,
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawCircle(
      Offset(head.dx + 18 - antSway, head.dy - 58),
      4,
      Paint()..color = const Color(0xFF6D4C41),
    );

    // Eyes look toward bowl (down-right) then player
    final look = mood == AntMood.looking
        ? Offset(math.sin(animPhase * 0.7) * 3, 2 + math.cos(animPhase * 0.5))
        : Offset.zero;
    final blink = (blinkTimer % 3.2) > 3.0;
    _eye(canvas, head + Offset(-12, -2) + look, blink);
    _eye(canvas, head + Offset(12, -2) + look, blink);

    // Eyebrows
    final browY = mood == AntMood.shakeNo ? -2.0 : -8.0;
    canvas.drawLine(
      head + Offset(-18, browY),
      head + Offset(-6, browY - 2),
      Paint()
        ..color = const Color(0xFF3E2723)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      head + Offset(6, browY - 2),
      head + Offset(18, browY),
      Paint()
        ..color = const Color(0xFF3E2723)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (mood == AntMood.shakeNo) {
      canvas.drawArc(
        Rect.fromCenter(center: head + const Offset(0, 12), width: 22, height: 14),
        0.3,
        math.pi - 0.6,
        false,
        smilePaint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(
          center: head + Offset(0, mood == AntMood.happy ? 10 : 12),
          width: mood == AntMood.happy ? 28 : 22,
          height: mood == AntMood.happy ? 18 : 14,
        ),
        0.15,
        math.pi - 0.3,
        false,
        smilePaint,
      );
    }

    // Cheeks
    canvas.drawCircle(
      head + const Offset(-20, 8),
      5,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      head + const Offset(20, 8),
      5,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );
  }

  void _eye(Canvas canvas, Offset c, bool blink) {
    if (blink) {
      canvas.drawLine(
        c + const Offset(-7, 0),
        c + const Offset(7, 0),
        Paint()
          ..color = const Color(0xFF212121)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 18, height: 20),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(c + const Offset(1, 2), 6, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(
      c + const Offset(-2, -2),
      2.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _AntPainter old) =>
      old.mood != mood ||
      old.animPhase != animPhase ||
      old.blinkTimer != blinkTimer;
}
