import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

abstract final class ShapeGeometry {
  static Path pathFor(ShapeKind kind, Rect bounds) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final w = bounds.width;
    final h = bounds.height;

    switch (kind) {
      case ShapeKind.circle:
      case ShapeKind.sphere:
        return Path()..addOval(bounds.deflate(w * 0.06));
      case ShapeKind.oval:
        return Path()
          ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.72, height: h * 0.95));
      case ShapeKind.semicircle:
        return Path()
          ..moveTo(bounds.left + 8, cy)
          ..arcTo(
            Rect.fromCenter(center: Offset(cx, cy), width: w - 16, height: h - 8),
            math.pi,
            math.pi,
            false,
          )
          ..close();
      case ShapeKind.triangle:
        return Path()
          ..moveTo(cx, bounds.top + 8)
          ..lineTo(bounds.right - 10, bounds.bottom - 10)
          ..lineTo(bounds.left + 10, bounds.bottom - 10)
          ..close();
      case ShapeKind.square:
        final s = math.min(w, h) * 0.78;
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: s, height: s),
            const Radius.circular(10),
          ));
      case ShapeKind.rectangle:
      case ShapeKind.cuboid:
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: w * 0.88, height: h * 0.58),
            const Radius.circular(10),
          ));
      case ShapeKind.star:
        return _star(Offset(cx, cy), w * 0.42, w * 0.18, 5);
      case ShapeKind.heart:
        return _heart(Offset(cx, cy), w * 0.4);
      case ShapeKind.diamond:
      case ShapeKind.rhombus:
        return Path()
          ..moveTo(cx, bounds.top + 8)
          ..lineTo(bounds.right - 12, cy)
          ..lineTo(cx, bounds.bottom - 8)
          ..lineTo(bounds.left + 12, cy)
          ..close();
      case ShapeKind.pentagon:
        return _regularPolygon(Offset(cx, cy), w * 0.4, 5, -math.pi / 2);
      case ShapeKind.hexagon:
        return _regularPolygon(Offset(cx, cy), w * 0.4, 6, 0);
      case ShapeKind.heptagon:
        return _regularPolygon(Offset(cx, cy), w * 0.4, 7, -math.pi / 2);
      case ShapeKind.octagon:
        return _regularPolygon(Offset(cx, cy), w * 0.4, 8, math.pi / 8);
      case ShapeKind.parallelogram:
        return Path()
          ..moveTo(bounds.left + w * 0.28, bounds.top + 12)
          ..lineTo(bounds.right - 10, bounds.top + 12)
          ..lineTo(bounds.right - w * 0.28, bounds.bottom - 12)
          ..lineTo(bounds.left + 10, bounds.bottom - 12)
          ..close();
      case ShapeKind.trapezium:
        return Path()
          ..moveTo(bounds.left + w * 0.22, bounds.top + 14)
          ..lineTo(bounds.right - w * 0.22, bounds.top + 14)
          ..lineTo(bounds.right - 10, bounds.bottom - 12)
          ..lineTo(bounds.left + 10, bounds.bottom - 12)
          ..close();
      case ShapeKind.crescent:
        final outer = Path()..addOval(bounds.deflate(8));
        final inner = Path()
          ..addOval(Rect.fromCenter(
            center: Offset(cx + w * 0.18, cy - h * 0.05),
            width: w * 0.72,
            height: h * 0.78,
          ));
        return Path.combine(PathOperation.difference, outer, inner);
      case ShapeKind.cone:
        return Path()
          ..moveTo(cx, bounds.top + 8)
          ..lineTo(bounds.right - 14, bounds.bottom - 18)
          ..quadraticBezierTo(cx, bounds.bottom - 4, bounds.left + 14, bounds.bottom - 18)
          ..close();
      case ShapeKind.cube:
        return _cube(bounds);
      case ShapeKind.cylinder:
        return _cylinder(bounds);
    }
  }

  static Path _regularPolygon(Offset c, double r, int sides, double start) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = start + i * 2 * math.pi / sides;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static Path _star(Offset c, double outer, double inner, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static Path _heart(Offset c, double r) {
    final path = Path();
    path.moveTo(c.dx, c.dy + r * 0.7);
    path.cubicTo(
      c.dx - r * 1.2,
      c.dy + r * 0.1,
      c.dx - r,
      c.dy - r * 0.7,
      c.dx,
      c.dy - r * 0.25,
    );
    path.cubicTo(
      c.dx + r,
      c.dy - r * 0.7,
      c.dx + r * 1.2,
      c.dy + r * 0.1,
      c.dx,
      c.dy + r * 0.7,
    );
    path.close();
    return path;
  }

  static Path _cube(Rect bounds) {
    final l = bounds.left + 14;
    final t = bounds.top + 22;
    final s = math.min(bounds.width, bounds.height) * 0.55;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(l, t, s, s),
        const Radius.circular(6),
      ));
    path.moveTo(l + s * 0.25, t);
    path.lineTo(l + s * 0.25 + s * 0.28, t - s * 0.22);
    path.lineTo(l + s + s * 0.28, t - s * 0.22);
    path.lineTo(l + s, t);
    path.close();
    path.moveTo(l + s, t);
    path.lineTo(l + s + s * 0.28, t - s * 0.22);
    path.lineTo(l + s + s * 0.28, t + s - s * 0.22);
    path.lineTo(l + s, t + s);
    path.close();
    return path;
  }

  static Path _cylinder(Rect bounds) {
    final path = Path();
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: bounds.center,
        width: bounds.width * 0.55,
        height: bounds.height * 0.72,
      ),
      const Radius.circular(18),
    );
    path.addRRect(body);
    path.addOval(Rect.fromCenter(
      center: Offset(bounds.center.dx, bounds.top + bounds.height * 0.22),
      width: bounds.width * 0.55,
      height: 16,
    ));
    return path;
  }
}
