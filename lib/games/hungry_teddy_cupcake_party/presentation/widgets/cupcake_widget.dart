import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/shared/cupcake_varieties.dart';

class CupcakeWidget extends StatelessWidget {
  const CupcakeWidget({
    super.key,
    required this.cupcake,
    this.largerTouch = false,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final CupcakeEntity cupcake;
  final bool largerTouch;
  final void Function(DragStartDetails details)? onDragStart;
  final void Function(DragUpdateDetails details)? onDragUpdate;
  final void Function(DragEndDetails details)? onDragEnd;

  @override
  Widget build(BuildContext context) {
    if (cupcake.phase == CupcakePhase.gone) return const SizedBox.shrink();

    final def = CupcakeVarieties.byIndex(cupcake.varietyIndex, isGolden: cupcake.isGolden);
    final size = (largerTouch ? 108.0 : 98.0) * cupcake.scale;
    final touchPad = size * 1.35;
    final isDragging = cupcake.phase == CupcakePhase.dragging;
    final isSnapping = cupcake.phase == CupcakePhase.snapping;
    final displayX = isDragging || isSnapping ? (isDragging ? cupcake.dragX : cupcake.x) : cupcake.x;
    final displayY = isDragging || isSnapping ? (isDragging ? cupcake.dragY : cupcake.y) : cupcake.y;
    final snapScale = isSnapping ? (1.0 - cupcake.snapProgress * 0.55) : 1.0;

    return Positioned(
      left: displayX - touchPad / 2,
      top: displayY - touchPad / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: cupcake.canDrag ? onDragStart : null,
        onPanUpdate: isDragging ? onDragUpdate : null,
        onPanEnd: isDragging ? onDragEnd : null,
        child: SizedBox(
          width: touchPad,
          height: touchPad,
          child: Center(
            child: Transform.scale(
              scale: (isDragging ? 1.2 : cupcake.scale) * snapScale,
              child: Transform.rotate(
                angle: isDragging ? math.sin(cupcake.sparklePhase) * 0.08 : 0,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _CupcakePainter(
                      def: def,
                      isGolden: cupcake.isGolden,
                      glow: cupcake.glow,
                      sparklePhase: cupcake.sparklePhase,
                      baking: cupcake.phase == CupcakePhase.baking,
                      dragging: isDragging,
                      snapProgress: isSnapping ? cupcake.snapProgress : 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupcakePainter extends CustomPainter {
  _CupcakePainter({
    required this.def,
    required this.isGolden,
    required this.glow,
    required this.sparklePhase,
    required this.baking,
    required this.dragging,
    required this.snapProgress,
  });

  final CupcakeDef def;
  final bool isGolden;
  final double glow;
  final double sparklePhase;
  final bool baking;
  final bool dragging;
  final double snapProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;
    final alpha = (1.0 - snapProgress * 0.4).clamp(0.3, 1.0);

    canvas.saveLayer(
      (Offset.zero & size).inflate(28),
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );

    // Shadow on the floor, a little below the cupcake
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 46 + (dragging ? 6 : 0)),
        width: dragging ? 66 : 58,
        height: dragging ? 14 : 12,
      ),
      Paint()..color = Colors.black.withValues(alpha: dragging ? 0.2 : 0.12),
    );

    if (glow > 0 || isGolden || dragging) {
      canvas.drawCircle(
        Offset(cx, cy - 4),
        size.width * 0.52,
        Paint()
          ..color = (isGolden ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB))
              .withValues(alpha: 0.2 + glow * 0.4),
      );
    }

    final frosting = Color(def.frostingColor);
    final wrapper = Color(def.wrapperColor);

    _drawLiner(canvas, cx, cy, wrapper);
    _drawFrosting(canvas, cx, cy, frosting);
    _drawTopping(canvas, cx, cy - 34, def.topping, def.accentColor);

    if (baking) {
      canvas.drawCircle(
        Offset(cx, cy - 10),
        38,
        Paint()
          ..color = const Color(0xFFFFF176)
              .withValues(alpha: 0.28 + math.sin(sparklePhase * 4) * 0.12),
      );
    }

    if (isGolden || dragging) {
      for (var i = 0; i < 6; i++) {
        final a = sparklePhase * 4 + i * 1.05;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 36, cy - 12 + math.sin(a) * 30),
          2.8,
          Paint()..color = const Color(0xFFFFF8E1).withValues(alpha: 0.95),
        );
      }
    }

    // Bite crumbs while snapping into the mouth
    if (snapProgress > 0.4) {
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(cx - 10 + i * 7, cy + 8 + snapProgress * 10),
          2,
          Paint()..color = frosting.withValues(alpha: 0.7),
        );
      }
    }

    canvas.restore();
  }

  void _drawLiner(Canvas canvas, double cx, double cy, Color wrapper) {
    final dark = Color.lerp(wrapper, Colors.black, 0.2)!;
    final light = Color.lerp(wrapper, Colors.white, 0.28)!;
    final liner = Path()
      ..moveTo(cx - 32, cy + 6)
      ..lineTo(cx - 25, cy + 40)
      ..quadraticBezierTo(cx, cy + 47, cx + 25, cy + 40)
      ..lineTo(cx + 32, cy + 6)
      ..close();
    final rect = Rect.fromLTWH(cx - 32, cy + 6, 64, 42);
    canvas.drawPath(
      liner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, wrapper, dark],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    // Pleats: alternating light/dark ribs
    canvas.save();
    canvas.clipPath(liner);
    for (var i = -4; i <= 4; i++) {
      final x0 = cx + i * 7.6;
      final x1 = cx + i * 6.0;
      canvas.drawLine(
        Offset(x0, cy + 8),
        Offset(x1, cy + 46),
        Paint()
          ..color = (i.isEven ? Colors.white.withValues(alpha: 0.32) : dark.withValues(alpha: 0.4))
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
    canvas.drawPath(
      liner,
      Paint()
        ..color = dark.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
    // Rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 6), width: 68, height: 9),
        const Radius.circular(5),
      ),
      Paint()..color = light,
    );
  }

  void _drawFrosting(Canvas canvas, double cx, double cy, Color frosting) {
    final hi = Color.lerp(frosting, Colors.white, 0.45)!;
    final lo = Color.lerp(frosting, Colors.black, 0.14)!;
    final edge = Color.lerp(frosting, Colors.black, 0.25)!.withValues(alpha: 0.5);

    void tier(Offset c, double w, double h) {
      final r = Rect.fromCenter(center: c, width: w, height: h);
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.5),
            radius: 1.0,
            colors: [hi, frosting, lo],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(r),
      );
      canvas.drawOval(
        r,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    tier(Offset(cx, cy - 2), 70, 30);
    tier(Offset(cx, cy - 14), 54, 26);
    tier(Offset(cx, cy - 25), 38, 22);
    // Glossy highlight on the swirl
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 2, cy - 14), width: 46, height: 26),
      -2.6,
      1.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTopping(Canvas canvas, double cx, double cy, CupcakeTopping t, int accent) {
    switch (t) {
      case CupcakeTopping.cherry:
        // Cherry with a curved green stem and leaf.
        canvas.drawPath(
          Path()
            ..moveTo(cx, cy - 4)
            ..quadraticBezierTo(cx + 6, cy - 22, cx + 12, cy - 26),
          Paint()
            ..color = const Color(0xFF4E8F3A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round,
        );
        final cherry = Rect.fromCircle(center: Offset(cx, cy + 2), radius: 11);
        canvas.drawCircle(
          Offset(cx, cy + 2),
          11,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.4, -0.5),
              colors: [Color(0xFFFF6B6B), Color(0xFFE53935), Color(0xFFB71C1C)],
              stops: [0.0, 0.55, 1.0],
            ).createShader(cherry),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 4, cy - 2), width: 5, height: 8),
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      case CupcakeTopping.strawberry:
        _strawberry(canvas, Offset(cx, cy + 2), Color(accent));
      case CupcakeTopping.star:
        _drawStar(canvas, Offset(cx, cy), 15, const Color(0xFFFFD84A));
      case CupcakeTopping.heart:
        final path = Path()
          ..moveTo(cx, cy + 12)
          ..cubicTo(cx - 24, cy - 2, cx - 12, cy - 22, cx, cy - 8)
          ..cubicTo(cx + 12, cy - 22, cx + 24, cy - 2, cx, cy + 12)
          ..close();
        final r = Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 26);
        canvas.drawPath(
          path,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.4, -0.5),
              colors: [Color(0xFFFF5C8A), Color(0xFFE91E63), Color(0xFFB0124F)],
              stops: [0.0, 0.55, 1.0],
            ).createShader(r),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 7, cy - 6), width: 6, height: 8),
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
      case CupcakeTopping.sprinkles:
        const colors = [0xFFFF7043, 0xFF42A5F5, 0xFFAB47BC, 0xFFFFEE58, 0xFF66BB6A, 0xFFF06292];
        final spots = [
          const Offset(-12, 8), const Offset(-4, -2), const Offset(6, 6), const Offset(13, 12),
          const Offset(-7, 14), const Offset(2, 16), const Offset(10, 0), const Offset(-1, 8),
        ];
        for (var i = 0; i < spots.length; i++) {
          canvas.save();
          canvas.translate(cx + spots[i].dx, cy + spots[i].dy - 6);
          canvas.rotate(i * 0.9);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: 3.6, height: 10),
              const Radius.circular(1.8),
            ),
            Paint()..color = Color(colors[i % colors.length]),
          );
          canvas.restore();
        }
      case CupcakeTopping.chocolateChip:
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(
            Offset(cx - 12 + i * 6, cy + 4 - (i % 2) * 8),
            4.2,
            Paint()..color = const Color(0xFF5D4037),
          );
        }
      case CupcakeTopping.whipped:
        // Cream frosting topped with a strawberry and pink sprinkle dots.
        for (final (dx, dy) in [(-13.0, 10.0), (-4.0, 14.0), (8.0, 12.0), (14.0, 6.0), (-8.0, 2.0)]) {
          canvas.drawCircle(Offset(cx + dx, cy + dy), 2.2, Paint()..color = const Color(0xFFF06292));
        }
        _strawberry(canvas, Offset(cx - 2, cy - 4), const Color(0xFFE53935));
      case CupcakeTopping.rainbow:
        const colors = [0xFFE53935, 0xFFFF9800, 0xFFFFEB3B, 0xFF66BB6A, 0xFF42A5F5, 0xFFAB47BC];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx, cy + 8), width: 40 - i * 2.0, height: 28 - i * 1.5),
            math.pi + 0.2,
            math.pi - 0.4,
            false,
            Paint()
              ..color = Color(colors[i])
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round,
          );
        }
    }
  }

  void _strawberry(Canvas canvas, Offset c, Color color) {
    final body = Path()
      ..moveTo(c.dx, c.dy + 14)
      ..cubicTo(c.dx - 16, c.dy + 6, c.dx - 14, c.dy - 12, c.dx, c.dy - 10)
      ..cubicTo(c.dx + 14, c.dy - 12, c.dx + 16, c.dy + 6, c.dx, c.dy + 14)
      ..close();
    final r = Rect.fromCenter(center: c, width: 30, height: 26);
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [Color.lerp(color, Colors.white, 0.3)!, color, Color.lerp(color, Colors.black, 0.25)!],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(r),
    );
    for (final (dx, dy) in [(-6.0, 0.0), (0.0, -3.0), (6.0, 0.0), (-3.0, 6.0), (4.0, 6.0)]) {
      canvas.drawOval(
        Rect.fromCenter(center: c + Offset(dx, dy), width: 2.2, height: 3.2),
        Paint()..color = const Color(0xFFFFE9A8),
      );
    }
    // Leaf cap
    for (final dir in [-1.0, 0.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 10)
          ..quadraticBezierTo(c.dx + dir * 8, c.dy - 18, c.dx + dir * 11, c.dy - 10)
          ..quadraticBezierTo(c.dx + dir * 5, c.dy - 8, c.dx, c.dy - 10)
          ..close(),
        Paint()..color = const Color(0xFF4E9A3A),
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? r : r * 0.5;
      final p = Offset(center.dx + math.cos(a) * rad, center.dy + math.sin(a) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [const Color(0xFFFFF59D), color, const Color(0xFFFFB300)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE59A00).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CupcakePainter old) =>
      old.glow != glow ||
      old.sparklePhase != sparklePhase ||
      old.baking != baking ||
      old.dragging != dragging ||
      old.snapProgress != snapProgress;
}
