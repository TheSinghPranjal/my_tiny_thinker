import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/logic/shape_geometry.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

/// Draws a preschool-friendly shape filled with color, or a color splash circle.
class ShapeColorVisual extends StatelessWidget {
  const ShapeColorVisual({
    super.key,
    required this.mode,
    this.colorKind,
    this.shapeKind,
    this.size = 56,
    this.showFace = true,
  });

  final ColorShapeBridgeMode mode;
  final BridgeColorKind? colorKind;
  final BridgeShapeKind? shapeKind;
  final double size;
  final bool showFace;

  Color get _fillColor {
    if (colorKind != null) {
      return ColorShapeCatalog.color(colorKind!).color;
    }
    return const Color(0xFF7E57C2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapeColorPainter(
          mode: mode,
          fillColor: _fillColor,
          shapeKind: shapeKind ?? BridgeShapeKind.circle,
          showFace: showFace,
        ),
      ),
    );
  }
}

class _ShapeColorPainter extends CustomPainter {
  _ShapeColorPainter({
    required this.mode,
    required this.fillColor,
    required this.shapeKind,
    required this.showFace,
  });

  final ColorShapeBridgeMode mode;
  final Color fillColor;
  final BridgeShapeKind shapeKind;
  final bool showFace;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final accent = Color.lerp(fillColor, Colors.black, 0.12)!;

    if (mode == ColorShapeBridgeMode.color) {
      _drawColorSplash(canvas, bounds, fillColor, accent);
      if (showFace) _drawSmile(canvas, size);
      return;
    }

    final path = _pathFor(shapeKind, bounds.deflate(size.shortestSide * 0.08));
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fillColor, Colors.white, 0.28)!,
            fillColor,
            accent,
          ],
        ).createShader(bounds),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    if (showFace) _drawSmile(canvas, size);
  }

  void _drawColorSplash(Canvas canvas, Rect bounds, Color base, Color accent) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final r = bounds.shortestSide * 0.38;

    canvas.drawCircle(
      Offset(cx - r * 0.15, cy - r * 0.1),
      r * 1.05,
      Paint()..color = base.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.35)!,
            base,
            accent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.28, cy - r * 0.32),
      r * 0.14,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _drawSmile(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + size.shortestSide * 0.06;
    final eyeOffset = size.shortestSide * 0.14;
    final eyeR = size.shortestSide * 0.055;

    for (final ox in [-eyeOffset, eyeOffset]) {
      canvas.drawCircle(
        Offset(cx + ox, cy - size.shortestSide * 0.08),
        eyeR,
        Paint()..color = const Color(0xFF37474F).withValues(alpha: 0.75),
      );
    }

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy + size.shortestSide * 0.02),
        width: size.shortestSide * 0.28,
        height: size.shortestSide * 0.16,
      ),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF37474F).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _pathFor(BridgeShapeKind kind, Rect bounds) {
    final mapped = _toShapeKind(kind);
    if (mapped != null) {
      return ShapeGeometry.pathFor(mapped, bounds);
    }
    return switch (kind) {
      BridgeShapeKind.arrow => _arrow(bounds),
      BridgeShapeKind.cross => _cross(bounds),
      _ => Path()..addOval(bounds),
    };
  }

  ShapeKind? _toShapeKind(BridgeShapeKind kind) => switch (kind) {
        BridgeShapeKind.circle => ShapeKind.circle,
        BridgeShapeKind.triangle => ShapeKind.triangle,
        BridgeShapeKind.square => ShapeKind.square,
        BridgeShapeKind.rectangle => ShapeKind.rectangle,
        BridgeShapeKind.rhombus => ShapeKind.rhombus,
        BridgeShapeKind.pentagon => ShapeKind.pentagon,
        BridgeShapeKind.hexagon => ShapeKind.hexagon,
        BridgeShapeKind.octagon => ShapeKind.octagon,
        BridgeShapeKind.oval => ShapeKind.oval,
        BridgeShapeKind.heart => ShapeKind.heart,
        BridgeShapeKind.star => ShapeKind.star,
        BridgeShapeKind.crescent => ShapeKind.crescent,
        BridgeShapeKind.trapezium => ShapeKind.trapezium,
        BridgeShapeKind.parallelogram => ShapeKind.parallelogram,
        BridgeShapeKind.cylinder => ShapeKind.cylinder,
        BridgeShapeKind.cube => ShapeKind.cube,
        BridgeShapeKind.sphere => ShapeKind.sphere,
        BridgeShapeKind.arrow => null,
        BridgeShapeKind.cross => null,
      };

  Path _arrow(Rect bounds) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final w = bounds.width;
    final h = bounds.height;
    return Path()
      ..moveTo(bounds.left + w * 0.18, cy)
      ..lineTo(cx + w * 0.08, cy)
      ..lineTo(cx + w * 0.08, bounds.top + h * 0.22)
      ..lineTo(bounds.right - w * 0.12, cy)
      ..lineTo(cx + w * 0.08, bounds.bottom - h * 0.22)
      ..lineTo(cx + w * 0.08, cy)
      ..close();
  }

  Path _cross(Rect bounds) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final t = bounds.shortestSide * 0.14;
    final l = bounds.shortestSide * 0.42;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: t, height: l),
        Radius.circular(t * 0.35),
      ))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: l, height: t),
        Radius.circular(t * 0.35),
      ));
  }

  @override
  bool shouldRepaint(covariant _ShapeColorPainter old) =>
      old.mode != mode ||
      old.fillColor != fillColor ||
      old.shapeKind != shapeKind ||
      old.showFace != showFace;
}

abstract final class ColorShapeBridgePalette {
  static const colors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFFEC407A),
  ];

  static int colorKeyFor(String matchKey) =>
      matchKey.hashCode.abs() % colors.length;

  static Color colorFor(String matchKey) =>
      colors[colorKeyFor(matchKey) % colors.length];
}
