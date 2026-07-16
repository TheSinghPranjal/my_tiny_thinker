import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/shared/cupcake_varieties.dart';

class CupcakeTableWidget extends StatelessWidget {
  const CupcakeTableWidget({super.key, this.eveningFactor = 0});

  final double eveningFactor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TablePainter(eveningFactor: eveningFactor),
      size: Size.infinite,
    );
  }
}

class _TablePainter extends CustomPainter {
  _TablePainter({required this.eveningFactor});

  final double eveningFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final tableLeft = size.width * 0.04;
    final tableWidth = size.width * 0.52;
    final tableTop = size.height * 0.46;
    final tableDepth = size.height * 0.34;
    final wood = Color.lerp(const Color(0xFF8D6E63), const Color(0xFF5D4037), eveningFactor * 0.3)!;
    final cloth = Color.lerp(const Color(0xFFFCE4EC), const Color(0xFFF8BBD0), eveningFactor * 0.2)!;

    // Teddy rug
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.74, size.height * 0.68),
        width: size.width * 0.28,
        height: size.height * 0.12,
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFCE93D8).withValues(alpha: 0.5),
            const Color(0xFFAB47BC).withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.74, size.height * 0.68),
          radius: size.width * 0.14,
        )),
    );

    // Table legs
    for (var i = 0; i < 3; i++) {
      final lx = tableLeft + tableWidth * (0.15 + i * 0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(lx, tableTop + tableDepth + 28),
            width: 16,
            height: 56,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF6D4C41),
      );
    }

    // Table body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tableLeft, tableTop + 8, tableWidth, tableDepth),
        const Radius.circular(10),
      ),
      Paint()..color = wood,
    );

    // Tablecloth
    final clothRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tableLeft - 4, tableTop, tableWidth + 8, 28),
      const Radius.circular(14),
    );
    canvas.drawRRect(clothRect, Paint()..color = cloth);
    canvas.drawRRect(
      clothRect,
      Paint()
        ..color = const Color(0xFFF48FB1).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Cloth scallops
    for (var i = 0; i < 7; i++) {
      final sx = tableLeft + i * (tableWidth / 6);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(sx, tableTop + 26), width: 18, height: 12),
        0,
        math.pi,
        false,
        Paint()..color = cloth.withValues(alpha: 0.9),
      );
    }

    // Plate spots removed — cupcakes fill the grid slots directly.
  }

  @override
  bool shouldRepaint(covariant _TablePainter old) => old.eveningFactor != eveningFactor;
}

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
    final def = CupcakeVarieties.byIndex(cupcake.varietyIndex, isGolden: cupcake.isGolden);
    final size = (largerTouch ? 92.0 : 82.0) * cupcake.scale;
    final touchPad = size * 1.15;
    final isDragging = cupcake.phase == CupcakePhase.dragging;
    final displayX = isDragging ? cupcake.dragX : cupcake.x;
    final displayY = isDragging ? cupcake.dragY : cupcake.y;

    return Positioned(
      left: displayX - touchPad / 2,
      top: displayY - touchPad / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: cupcake.canDrag ? onDragStart : null,
        onPanUpdate: cupcake.phase == CupcakePhase.dragging ? onDragUpdate : null,
        onPanEnd: cupcake.phase == CupcakePhase.dragging ? onDragEnd : null,
        child: SizedBox(
          width: touchPad,
          height: touchPad,
          child: Center(
            child: Transform.scale(
              scale: isDragging ? 1.15 : cupcake.scale,
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
  });

  final CupcakeDef def;
  final bool isGolden;
  final double glow;
  final double sparklePhase;
  final bool baking;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 40, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    if (glow > 0 || isGolden) {
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.46,
        Paint()
          ..color = (isGolden ? const Color(0xFFFFD54F) : const Color(0xFFF48FB1))
              .withValues(alpha: 0.2 + glow * 0.35),
      );
    }

    // Cup liner
    final liner = Path()
      ..moveTo(cx - 20, cy + 6)
      ..lineTo(cx - 24, cy + 30)
      ..lineTo(cx + 24, cy + 30)
      ..lineTo(cx + 20, cy + 6)
      ..close();
    canvas.drawPath(
      liner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(def.wrapperColor), Color.lerp(Color(def.wrapperColor), Colors.black, 0.15)!],
        ).createShader(Rect.fromLTWH(cx - 24, cy + 6, 48, 24)),
    );

    // Pleats
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + i * 8, cy + 10),
        Offset(cx + i * 8 - 2, cy + 28),
        Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 1.2,
      );
    }

    // Frosting mound
    canvas.drawCircle(
      Offset(cx, cy - 2),
      24,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(Color(def.frostingColor), Colors.white, 0.25)!,
            Color(def.frostingColor),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy - 2), radius: 24)),
    );

    // Frosting swirl
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 4), width: 18, height: 14),
      -0.5,
      2.8,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    _drawTopping(canvas, cx, cy - 10, def.topping, def.accentColor);

    if (baking) {
      canvas.drawCircle(
        Offset(cx, cy - 8),
        28,
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.25 + math.sin(sparklePhase * 4) * 0.1),
      );
    }

    if (isGolden) {
      for (var i = 0; i < 5; i++) {
        final a = sparklePhase * 4 + i * 1.2;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 26, cy - 8 + math.sin(a) * 20),
          2.5,
          Paint()..color = const Color(0xFFFFF8E1).withValues(alpha: 0.9),
        );
      }
    }
  }

  void _drawTopping(Canvas canvas, double cx, double cy, CupcakeTopping t, int accent) {
    switch (t) {
      case CupcakeTopping.cherry:
        canvas.drawCircle(Offset(cx, cy - 10), 7, Paint()..color = const Color(0xFFE53935));
        canvas.drawLine(
          Offset(cx, cy - 17),
          Offset(cx + 5, cy - 24),
          Paint()..color = const Color(0xFF66BB6A)..strokeWidth = 2.5,
        );
      case CupcakeTopping.strawberry:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy - 8), width: 16, height: 18),
          Paint()..color = Color(accent),
        );
      case CupcakeTopping.star:
        _drawStar(canvas, Offset(cx, cy - 10), 9, const Color(0xFFFFEB3B));
      case CupcakeTopping.heart:
        canvas.drawCircle(Offset(cx - 5, cy - 10), 5.5, Paint()..color = const Color(0xFFE91E63));
        canvas.drawCircle(Offset(cx + 5, cy - 10), 5.5, Paint()..color = const Color(0xFFE91E63));
      case CupcakeTopping.sprinkles:
        for (var i = 0; i < 6; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(cx - 10 + i * 4, cy - 4 - (i % 2) * 4),
                width: 3,
                height: 7,
              ),
              const Radius.circular(1),
            ),
            Paint()..color = Color([0xFFFF7043, 0xFF42A5F5, 0xFFAB47BC, 0xFFFFEE58][i % 4]),
          );
        }
      case CupcakeTopping.chocolateChip:
        for (var i = 0; i < 4; i++) {
          canvas.drawCircle(
            Offset(cx - 8 + i * 5, cy - 2 - (i % 2) * 5),
            3.5,
            Paint()..color = const Color(0xFF5D4037),
          );
        }
      case CupcakeTopping.whipped:
        canvas.drawCircle(Offset(cx, cy - 12), 11, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx - 9, cy - 6), 8, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + 9, cy - 6), 8, Paint()..color = Colors.white);
      case CupcakeTopping.rainbow:
        const colors = [0xFFE53935, 0xFFFF9800, 0xFFFFEB3B, 0xFF66BB6A, 0xFF42A5F5, 0xFFAB47BC];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx, cy - 4), width: 30, height: 22),
            math.pi + i * 0.28,
            0.25,
            false,
            Paint()
              ..color = Color(colors[i])
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
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
  }

  @override
  bool shouldRepaint(covariant _CupcakePainter old) =>
      old.glow != glow || old.sparklePhase != sparklePhase || old.baking != baking;
}
