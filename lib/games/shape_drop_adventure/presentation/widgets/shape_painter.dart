import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/logic/shape_geometry.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';

class FriendlyShapeView extends StatelessWidget {
  const FriendlyShapeView({
    super.key,
    required this.def,
    this.size = 88,
    this.showFace = true,
    this.outlineOnly = false,
    this.filled = false,
    this.glow = false,
    this.pastelTint = false,
    this.blink = false,
    this.showObjectEmoji = true,
  });

  final ShapeDef def;
  final double size;
  final bool showFace;
  final bool outlineOnly;
  final bool filled;
  final bool glow;
  final bool pastelTint;
  final bool blink;
  final bool showObjectEmoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow)
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(def.color).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _FriendlyShapePainter(
              def: def,
              showFace: showFace && !outlineOnly,
              outlineOnly: outlineOnly,
              filled: filled,
              pastelTint: pastelTint,
              blink: blink,
            ),
          ),
          if (showObjectEmoji &&
              def.objectEmoji != null &&
              !outlineOnly &&
              !filled)
            Positioned(
              bottom: 4,
              child: Text(def.objectEmoji!, style: TextStyle(fontSize: size * 0.22)),
            ),
        ],
      ),
    );
  }
}

class _FriendlyShapePainter extends CustomPainter {
  _FriendlyShapePainter({
    required this.def,
    required this.showFace,
    required this.outlineOnly,
    required this.filled,
    required this.pastelTint,
    required this.blink,
  });

  final ShapeDef def;
  final bool showFace;
  final bool outlineOnly;
  final bool filled;
  final bool pastelTint;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final path = ShapeGeometry.pathFor(def.kind, bounds.deflate(4));
    final base = Color(def.color);
    final accent = Color(def.accent);

    if (pastelTint && !filled) {
      canvas.drawPath(
        path,
        Paint()..color = base.withValues(alpha: 0.18),
      );
    }

    if (outlineOnly) {
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      return;
    }

    if (filled || !pastelTint) {
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(base, Colors.white, 0.25)!,
              base,
              accent,
            ],
          ).createShader(bounds),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (showFace) {
      _drawFace(canvas, size);
    }
  }

  void _drawFace(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 2;

    // Cheeks
    canvas.drawCircle(
      Offset(cx - 18, cy + 6),
      5,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(cx + 18, cy + 6),
      5,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55),
    );

    // Eyes
    if (blink) {
      for (final ox in [-10.0, 10.0]) {
        canvas.drawLine(
          Offset(cx + ox - 5, cy - 4),
          Offset(cx + ox + 5, cy - 4),
          Paint()
            ..color = const Color(0xFF37474F)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      }
    } else {
      for (final ox in [-10.0, 10.0]) {
        canvas.drawCircle(Offset(cx + ox, cy - 4), 6, Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(cx + ox + 1, cy - 3),
          3.2,
          Paint()..color = const Color(0xFF37474F),
        );
        canvas.drawCircle(
          Offset(cx + ox + 2, cy - 4.5),
          1.2,
          Paint()..color = Colors.white,
        );
      }
    }

    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 18, height: 12),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 10.0;
      const gap = 7.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FriendlyShapePainter old) =>
      old.def != def ||
      old.showFace != showFace ||
      old.outlineOnly != outlineOnly ||
      old.filled != filled ||
      old.pastelTint != pastelTint ||
      old.blink != blink;
}
