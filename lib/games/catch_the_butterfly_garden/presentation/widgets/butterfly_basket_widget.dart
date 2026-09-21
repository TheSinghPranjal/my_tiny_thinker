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
    final rimY = size.height * 0.36;
    final bottom = size.height - 8;
    final topHalf = 54.0;
    final botHalf = 44.0;

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 3), width: 110, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    // Handle (behind the rim)
    final handleRect = Rect.fromCenter(
      center: Offset(cx, rimY),
      width: topHalf * 1.7,
      height: 78,
    );
    canvas.drawArc(
      handleRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFA57C52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      handleRect,
      math.pi + 0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFFE2BC8A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Body
    final body = Path()
      ..moveTo(cx - topHalf, rimY)
      ..quadraticBezierTo(cx - topHalf - 2, size.height * 0.7, cx - botHalf, bottom)
      ..quadraticBezierTo(cx, bottom + 8, cx + botHalf, bottom)
      ..quadraticBezierTo(cx + topHalf + 2, size.height * 0.7, cx + topHalf, rimY)
      ..close();
    final bodyBounds = Rect.fromLTWH(cx - topHalf, rimY, topHalf * 2, bottom - rimY);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9C79A), Color(0xFFD4A76A), Color(0xFFB98650)],
        ).createShader(bodyBounds),
    );

    // Woven texture (clipped to the body)
    canvas.save();
    canvas.clipPath(body);
    final weave = Paint()
      ..color = const Color(0xFF8D5E32).withValues(alpha: 0.4)
      ..strokeWidth = 1.8;
    const cell = 14.0;
    for (var y = rimY + 10; y < bottom + 4; y += cell) {
      canvas.drawLine(Offset(cx - topHalf - 4, y), Offset(cx + topHalf + 4, y), weave);
    }
    var row = 0;
    for (var y = rimY + 10; y < bottom + 4; y += cell) {
      final off = row.isEven ? 0.0 : cell / 2;
      for (var x = cx - topHalf - 4 + off; x < cx + topHalf + 4; x += cell) {
        canvas.drawLine(Offset(x, y), Offset(x, y + cell), weave);
      }
      row++;
    }
    canvas.restore();

    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF8D5E32).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rim
    final rim = Rect.fromCenter(center: Offset(cx, rimY), width: topHalf * 2 + 8, height: 24);
    canvas.drawOval(rim, Paint()..color = const Color(0xFFB98650));
    canvas.drawOval(
      rim.deflate(4),
      Paint()..color = const Color(0xFF7A5230).withValues(alpha: 0.75),
    );
    canvas.drawArc(
      rim,
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFFE9C79A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Pink bow (bounces slightly while the basket is catching)
    final bow = Offset(cx, rimY + 24 - lidOpen * 3);
    final bowPaint = Paint()..color = const Color(0xFFEC407A);
    final bowLight = Paint()..color = const Color(0xFFF48FB1);
    for (final dir in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(bow.dx, bow.dy)
        ..quadraticBezierTo(bow.dx + dir * 14, bow.dy - 16, bow.dx + dir * 24, bow.dy - 6)
        ..quadraticBezierTo(bow.dx + dir * 26, bow.dy + 8, bow.dx + dir * 20, bow.dy + 12)
        ..quadraticBezierTo(bow.dx + dir * 10, bow.dy + 8, bow.dx, bow.dy)
        ..close();
      canvas.drawPath(wing, bowPaint);
      canvas.drawPath(
        Path()
          ..moveTo(bow.dx + dir * 4, bow.dy - 1)
          ..quadraticBezierTo(bow.dx + dir * 14, bow.dy - 10, bow.dx + dir * 20, bow.dy - 4),
        Paint()
          ..color = bowLight.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
    for (final dir in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(bow.dx, bow.dy + 4)
          ..lineTo(bow.dx + dir * 7, bow.dy + 22)
          ..lineTo(bow.dx + dir * 1, bow.dy + 18)
          ..close(),
        Paint()..color = const Color(0xFFD81B60),
      );
    }
    canvas.drawCircle(bow, 6.5, Paint()..color = const Color(0xFFD81B60));
    canvas.drawCircle(bow + const Offset(-1.5, -1.5), 2.5, bowLight);

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
