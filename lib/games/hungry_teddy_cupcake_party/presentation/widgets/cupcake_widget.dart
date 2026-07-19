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
    final size = (largerTouch ? 100.0 : 90.0) * cupcake.scale;
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
    final cy = size.height / 2 + 4;
    final alpha = (1.0 - snapProgress * 0.4).clamp(0.3, 1.0);

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 32 + (dragging ? 4 : 0)),
        width: dragging ? 48 : 40,
        height: dragging ? 14 : 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: dragging ? 0.22 : 0.14),
    );

    if (glow > 0 || isGolden || dragging) {
      canvas.drawCircle(
        Offset(cx, cy - 4),
        size.width * 0.48,
        Paint()
          ..color = (isGolden ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB))
              .withValues(alpha: 0.22 + glow * 0.4),
      );
    }

    // Wrapper (cup)
    final frosting = Color(def.frostingColor);
    final wrapper = Color(def.wrapperColor);
    final liner = Path()
      ..moveTo(cx - 22, cy + 4)
      ..lineTo(cx - 28, cy + 34)
      ..quadraticBezierTo(cx, cy + 40, cx + 28, cy + 34)
      ..lineTo(cx + 22, cy + 4)
      ..close();
    canvas.drawPath(
      liner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(wrapper, Colors.white, 0.2)!,
            wrapper,
            Color.lerp(wrapper, Colors.black, 0.18)!,
          ],
        ).createShader(Rect.fromLTWH(cx - 28, cy + 4, 56, 36)),
    );

    // Wrapper pleats
    for (var i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(cx + i * 7, cy + 8),
        Offset(cx + i * 7.5 - 1, cy + 32),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Frosting base mound
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 52, height: 28),
      Paint()..color = frosting,
    );

    // Layered frosting swirls
    canvas.drawCircle(
      Offset(cx, cy - 8),
      22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(frosting, Colors.white, 0.35)!,
            frosting,
            Color.lerp(frosting, Colors.black, 0.12)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy - 8), radius: 22)),
    );
    canvas.drawCircle(
      Offset(cx - 2, cy - 18),
      14,
      Paint()..color = Color.lerp(frosting, Colors.white, 0.25)!,
    );
    canvas.drawCircle(
      Offset(cx + 4, cy - 26),
      9,
      Paint()..color = Color.lerp(frosting, Colors.white, 0.4)!,
    );

    // Swirl highlight
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 10), width: 28, height: 20),
      -0.8,
      2.2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    _drawTopping(canvas, cx, cy - 18, def.topping, def.accentColor);

    if (baking) {
      canvas.drawCircle(
        Offset(cx, cy - 10),
        32,
        Paint()
          ..color = const Color(0xFFFFF176)
              .withValues(alpha: 0.28 + math.sin(sparklePhase * 4) * 0.12),
      );
    }

    if (isGolden || dragging) {
      for (var i = 0; i < 6; i++) {
        final a = sparklePhase * 4 + i * 1.05;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 30, cy - 10 + math.sin(a) * 24),
          2.8,
          Paint()..color = const Color(0xFFFFF8E1).withValues(alpha: 0.95),
        );
      }
    }

    // Bite crumbs while snapping into mouth
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

  void _drawTopping(Canvas canvas, double cx, double cy, CupcakeTopping t, int accent) {
    switch (t) {
      case CupcakeTopping.cherry:
        canvas.drawCircle(Offset(cx, cy - 8), 8, Paint()..color = const Color(0xFFE53935));
        canvas.drawCircle(Offset(cx - 2, cy - 10), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.5));
        canvas.drawLine(
          Offset(cx, cy - 16),
          Offset(cx + 6, cy - 26),
          Paint()
            ..color = const Color(0xFF66BB6A)
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
      case CupcakeTopping.strawberry:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy - 6), width: 18, height: 20),
          Paint()..color = Color(accent),
        );
        canvas.drawCircle(Offset(cx, cy - 16), 4, Paint()..color = const Color(0xFF66BB6A));
      case CupcakeTopping.star:
        _drawStar(canvas, Offset(cx, cy - 8), 11, const Color(0xFFFFEB3B));
      case CupcakeTopping.heart:
        canvas.drawCircle(Offset(cx - 6, cy - 8), 6.5, Paint()..color = const Color(0xFFE91E63));
        canvas.drawCircle(Offset(cx + 6, cy - 8), 6.5, Paint()..color = const Color(0xFFE91E63));
        canvas.drawPath(
          Path()
            ..moveTo(cx - 12, cy - 5)
            ..lineTo(cx, cy + 8)
            ..lineTo(cx + 12, cy - 5),
          Paint()..color = const Color(0xFFE91E63),
        );
      case CupcakeTopping.sprinkles:
        for (var i = 0; i < 8; i++) {
          canvas.save();
          canvas.translate(cx - 12 + i * 3.5, cy - 2 - (i % 3) * 5);
          canvas.rotate(i * 0.5);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: 3.5, height: 9),
              const Radius.circular(1.5),
            ),
            Paint()
              ..color = Color([0xFFFF7043, 0xFF42A5F5, 0xFFAB47BC, 0xFFFFEE58, 0xFF66BB6A][i % 5]),
          );
          canvas.restore();
        }
      case CupcakeTopping.chocolateChip:
        for (var i = 0; i < 5; i++) {
          canvas.drawCircle(
            Offset(cx - 10 + i * 5, cy - (i % 2) * 6),
            4,
            Paint()..color = const Color(0xFF5D4037),
          );
        }
      case CupcakeTopping.whipped:
        canvas.drawCircle(Offset(cx, cy - 10), 12, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx - 10, cy - 2), 9, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + 10, cy - 2), 9, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx, cy - 18), 7, Paint()..color = Colors.white);
      case CupcakeTopping.rainbow:
        const colors = [0xFFE53935, 0xFFFF9800, 0xFFFFEB3B, 0xFF66BB6A, 0xFF42A5F5, 0xFFAB47BC];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx, cy), width: 34, height: 26),
            math.pi + i * 0.28,
            0.24,
            false,
            Paint()
              ..color = Color(colors[i])
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..strokeCap = StrokeCap.round,
          );
        }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final p = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFA000).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
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
