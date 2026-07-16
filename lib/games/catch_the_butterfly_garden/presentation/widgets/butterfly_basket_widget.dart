import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

class ButterflyBasketWidget extends StatelessWidget {
  const ButterflyBasketWidget({
    super.key,
    required this.basket,
    this.largerTouch = false,
  });

  final BasketEntity basket;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final w = largerTouch ? 120.0 : 100.0;
    final h = largerTouch ? 90.0 : 76.0;
    final bounce = math.sin(basket.bouncePhase) * 2;

    return Transform.translate(
      offset: Offset(0, bounce),
      child: CustomPaint(
        size: Size(w, h),
        painter: _BasketPainter(
          lidOpen: basket.lidOpen,
          count: basket.totalCollected,
        ),
      ),
    );
  }
}

class _BasketPainter extends CustomPainter {
  _BasketPainter({required this.lidOpen, required this.count});

  final double lidOpen;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.55;

    final body = Path()
      ..moveTo(cx - 38, baseY)
      ..quadraticBezierTo(cx - 42, size.height, cx, size.height - 4)
      ..quadraticBezierTo(cx + 42, size.height, cx + 38, baseY)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + i * 12, baseY + 4),
        Offset(cx + i * 10, size.height - 6),
        Paint()
          ..color = const Color(0xFF6D4C41).withValues(alpha: 0.5)
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, baseY - 2), width: 82, height: 28),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFA1887F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    canvas.save();
    canvas.translate(cx - 38, baseY - 4);
    canvas.rotate(-lidOpen * 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -8, 76, 14),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFBCAAA4),
    );
    canvas.restore();

    if (count > 0) {
      canvas.drawCircle(
        Offset(cx + 32, baseY - 18),
        12,
        Paint()..color = const Color(0xFFEC407A),
      );
      final text = TextPainter(
        text: TextSpan(
          text: '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(cx + 32 - text.width / 2, baseY - 23));
    }
  }

  @override
  bool shouldRepaint(covariant _BasketPainter old) =>
      old.lidOpen != lidOpen || old.count != count;
}
