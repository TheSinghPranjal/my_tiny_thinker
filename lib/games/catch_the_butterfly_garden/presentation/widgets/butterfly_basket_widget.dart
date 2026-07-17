import 'dart:math' as math;
import 'dart:ui' as ui;

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

  static double layoutWidth(bool largerTouch) => largerTouch ? 160.0 : 140.0;
  static double layoutHeight(bool largerTouch) => largerTouch ? 120.0 : 108.0;

  @override
  Widget build(BuildContext context) {
    final w = layoutWidth(largerTouch);
    final h = layoutHeight(largerTouch);
    final bounce = math.sin(basket.bouncePhase) * 3;

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
    final rimY = size.height * 0.38;

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 4), width: 100, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Basket body
    final body = Path()
      ..moveTo(cx - 52, rimY)
      ..quadraticBezierTo(cx - 58, size.height * 0.7, cx - 48, size.height - 8)
      ..quadraticBezierTo(cx, size.height + 4, cx + 48, size.height - 8)
      ..quadraticBezierTo(cx + 58, size.height * 0.7, cx + 52, rimY)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63), Color(0xFF6D4C41)],
        ).createShader(Rect.fromLTWH(cx - 58, rimY, 116, size.height - rimY)),
    );

    // Weave lines
    for (var i = 0; i < 5; i++) {
      final y = rimY + 14 + i * 12.0;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, y), width: 96 - i * 4, height: 18),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF5D4037).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(cx + i * 14, rimY + 6),
        Offset(cx + i * 12, size.height - 10),
        Paint()
          ..color = const Color(0xFF6D4C41).withValues(alpha: 0.4)
          ..strokeWidth = 2,
      );
    }

    // Rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, rimY), width: 110, height: 28),
      Paint()..color = const Color(0xFFA1887F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, rimY), width: 100, height: 22),
      Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.35),
    );

    // Handle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, rimY - 4), width: 88, height: 48),
      math.pi + 0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, rimY - 4), width: 88, height: 48),
      math.pi + 0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = const Color(0xFFD7CCC8).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Lid (opens when catching)
    canvas.save();
    canvas.translate(cx - 50, rimY - 2);
    canvas.rotate(-lidOpen * 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -12, 100, 18),
        const Radius.circular(8),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD7CCC8), Color(0xFFA1887F)],
        ).createShader(const Rect.fromLTWH(0, -12, 100, 18)),
    );
    // Bow on lid
    canvas.drawCircle(const Offset(50, -4), 5, Paint()..color = const Color(0xFFEC407A));
    canvas.drawCircle(const Offset(44, -6), 4, Paint()..color = const Color(0xFFF48FB1));
    canvas.drawCircle(const Offset(56, -6), 4, Paint()..color = const Color(0xFFF48FB1));
    canvas.restore();

    // Butterflies peeking when collected
    if (count > 0) {
      final peek = math.min(count, 3);
      for (var i = 0; i < peek; i++) {
        final px = cx - 16 + i * 16.0;
        canvas.drawCircle(Offset(px, rimY - 6 - lidOpen * 8), 5, Paint()..color = Color(
          [0xFF42A5F5, 0xFFFFEE58, 0xFFEC407A][i],
        ));
      }
    }

    // Count badge
    if (count > 0) {
      final badge = Offset(cx + 42, rimY - 22);
      canvas.drawCircle(badge, 16, Paint()..color = const Color(0xFFEC407A));
      canvas.drawCircle(badge, 16, Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      final text = TextPainter(
        text: TextSpan(
          text: '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(badge.dx - text.width / 2, badge.dy - text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BasketPainter old) =>
      old.lidOpen != lidOpen || old.count != count;
}
