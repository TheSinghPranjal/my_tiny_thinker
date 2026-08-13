import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

/// A glossy woven basket that food bubbles are dragged into.
class FoodBasketWidget extends StatelessWidget {
  const FoodBasketWidget({
    super.key,
    required this.basket,
    required this.size,
    this.hovering = false,
  });

  final SortBasket basket;
  final double size;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    final accent = basket.isHealthy
        ? const Color(0xFF43A047)
        : const Color(0xFFFB8C00);
    final highlighted = hovering || basket.glow || basket.hintPulse;

    // Idle breathing, an eager lift while hovered, a bounce on a correct match
    // and a soft side-to-side wobble on a wrong one.
    final idle = 1 + math.sin(basket.idlePhase) * 0.015;
    final scale = idle * (highlighted ? 1.06 : 1.0);
    final lift = basket.happy ? -math.sin(basket.idlePhase * 3).abs() * 10 : 0.0;
    final wobble = basket.wobble ? math.sin(basket.idlePhase * 9) * 0.05 : 0.0;

    return Transform.translate(
      offset: Offset(0, lift),
      child: Transform.rotate(
        angle: wobble,
        child: Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Label(text: basket.label, accent: accent, size: size),
              SizedBox(height: size * 0.04),
              SizedBox(
                width: size,
                height: size * 0.56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size, size * 0.56),
                      painter: _BasketPainter(
                        accent: accent,
                        highlighted: highlighted,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size * 0.08),
                      child: Text(
                        basket.iconEmoji,
                        style: TextStyle(fontSize: size * 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.accent, required this.size});

  final String text;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.09,
        vertical: size * 0.03,
      ),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size * 0.088,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BasketPainter extends CustomPainter {
  const _BasketPainter({required this.accent, required this.highlighted});

  final Color accent;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rimHeight = h * 0.17;
    final bodyTop = rimHeight * 0.55;

    // Tapered basket body.
    final body = Path()
      ..moveTo(w * 0.10, bodyTop)
      ..lineTo(w * 0.90, bodyTop)
      ..lineTo(w * 0.80, h * 0.84)
      ..quadraticBezierTo(w * 0.78, h, w * 0.60, h)
      ..lineTo(w * 0.40, h)
      ..quadraticBezierTo(w * 0.22, h, w * 0.20, h * 0.84)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD79A5B),
            const Color(0xFFB4753C),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    _paintWeave(canvas, size, body, bodyTop);

    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF8D5524),
    );

    _paintRim(canvas, size, rimHeight);

    if (highlighted) {
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = accent.withValues(alpha: 0.85),
      );
    }
  }

  void _paintWeave(Canvas canvas, Size size, Path body, double bodyTop) {
    final w = size.width;
    final h = size.height;
    final weave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF8D5524).withValues(alpha: 0.35);

    canvas.save();
    canvas.clipPath(body);
    for (var i = 1; i < 4; i++) {
      final y = bodyTop + (h - bodyTop) * (i / 4);
      canvas.drawLine(Offset(w * 0.1, y), Offset(w * 0.9, y), weave);
    }
    for (var i = 1; i < 6; i++) {
      final x = w * (0.12 + 0.152 * i);
      canvas.drawLine(Offset(x, bodyTop), Offset(x, h), weave);
    }
    canvas.restore();
  }

  void _paintRim(Canvas canvas, Size size, double rimHeight) {
    final w = size.width;
    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, rimHeight),
      Radius.circular(rimHeight),
    );

    canvas.drawRRect(
      rim,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9B278), Color(0xFFC98A46)],
        ).createShader(Rect.fromLTWH(0, 0, w, rimHeight)),
    );
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF8D5524),
    );

    // Glossy highlight along the top of the rim.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, rimHeight * 0.2, w * 0.34, rimHeight * 0.26),
        Radius.circular(rimHeight),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_BasketPainter old) =>
      old.accent != accent || old.highlighted != highlighted;
}
