import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

/// Pattern used on the shared wrapped-candy silhouette.
enum CandyPattern { swirl, stripes, stars, dots, hearts }

CandyPattern candyPatternFor(CandyColorKind kind) => switch (kind) {
      CandyColorKind.red || CandyColorKind.magenta => CandyPattern.swirl,
      CandyColorKind.blue ||
      CandyColorKind.navy ||
      CandyColorKind.skyBlue ||
      CandyColorKind.lightBlue =>
        CandyPattern.stripes,
      CandyColorKind.green || CandyColorKind.lightGreen => CandyPattern.stripes,
      CandyColorKind.yellow || CandyColorKind.gold => CandyPattern.dots,
      CandyColorKind.orange || CandyColorKind.brown => CandyPattern.stars,
      CandyColorKind.pink => CandyPattern.hearts,
      CandyColorKind.purple || CandyColorKind.lilac => CandyPattern.stars,
      CandyColorKind.black ||
      CandyColorKind.grey ||
      CandyColorKind.white ||
      CandyColorKind.silver =>
        CandyPattern.swirl,
    };

class CandyPieceWidget extends StatelessWidget {
  const CandyPieceWidget({
    super.key,
    required this.candy,
    required this.onTap,
    this.size = 100,
    this.showGlow = true,
    this.showMotionLines = false,
  });

  final CandyEntity candy;
  final VoidCallback onTap;
  final double size;
  final bool showGlow;
  final bool showMotionLines;

  @override
  Widget build(BuildContext context) {
    if (candy.eaten) return const SizedBox.shrink();

    final wiggle = math.sin(candy.wigglePhase) * 4;
    final bounce = math.cos(candy.wigglePhase * 1.2) * 3;
    final shake = candy.wrongShake ? math.sin(candy.wigglePhase * 12) * 8 : 0.0;
    final pulse =
        candy.pulseHint ? 1 + math.sin(candy.wigglePhase * 6) * 0.12 : 1.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(wiggle + shake, bounce),
        child: Transform.rotate(
          angle: candy.rotation,
          child: Transform.scale(
            scale: pulse,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: CandyPainter(
                  colorDef: candy.colorDef,
                  pattern: candyPatternFor(candy.colorKind),
                  pulseHint: candy.pulseHint,
                  showGlow: showGlow,
                  showMotionLines: showMotionLines,
                  motionPhase: candy.wigglePhase,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared painter for field candies and the thought-bubble preview.
class CandyPainter extends CustomPainter {
  CandyPainter({
    required this.colorDef,
    required this.pattern,
    this.pulseHint = false,
    this.showGlow = true,
    this.showMotionLines = false,
    this.motionPhase = 0,
  });

  final CandyColorDef colorDef;
  final CandyPattern pattern;
  final bool pulseHint;
  final bool showGlow;
  final bool showMotionLines;
  final double motionPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final bodyW = size.width * 0.52;
    final bodyH = size.height * 0.42;
    final wrapLen = size.width * 0.22;

    if (showGlow) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(0, size.height * 0.22),
          width: size.width * 0.72,
          height: size.height * 0.18,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    if (showMotionLines) {
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      final drift = math.sin(motionPhase) * 2;
      for (var i = 0; i < 3; i++) {
        final x = c.dx - 8 + i * 8 + drift;
        canvas.drawLine(
          Offset(x, c.dy - size.height * 0.42),
          Offset(x, c.dy - size.height * 0.28),
          linePaint,
        );
      }
    }

    // Twisted wrapper ends (same color family as candy).
    _drawWrapperEnd(
      canvas,
      Offset(c.dx - bodyW * 0.42, c.dy),
      wrapLen,
      bodyH * 0.95,
      facingRight: false,
    );
    _drawWrapperEnd(
      canvas,
      Offset(c.dx + bodyW * 0.42, c.dy),
      wrapLen,
      bodyH * 0.95,
      facingRight: true,
    );

    final bodyRect = Rect.fromCenter(center: c, width: bodyW, height: bodyH);
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(bodyH * 0.5),
    );

    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(colorDef.color, Colors.white, 0.28)!,
            colorDef.color,
            Color.lerp(colorDef.color, Colors.black, 0.12)!,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(bodyRect),
    );

    // Clip patterns into the candy body.
    canvas.save();
    canvas.clipRRect(bodyRRect);
    _paintPattern(canvas, bodyRect);
    // Soft top gloss.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - bodyW * 0.08, c.dy - bodyH * 0.18),
        width: bodyW * 0.42,
        height: bodyH * 0.28,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );
    canvas.restore();

    // Crisp candy outline.
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = Color.lerp(colorDef.color, Colors.black, 0.18)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.025),
    );

    if (pulseHint) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          bodyRect.inflate(size.width * 0.08),
          Radius.circular(bodyH * 0.55),
        ),
        Paint()
          ..color = colorDef.color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }
  }

  void _drawWrapperEnd(
    Canvas canvas,
    Offset joint,
    double length,
    double height, {
    required bool facingRight,
  }) {
    final dir = facingRight ? 1.0 : -1.0;
    final tip = Offset(joint.dx + dir * length, joint.dy);
    final path = Path()
      ..moveTo(joint.dx, joint.dy - height * 0.22)
      ..quadraticBezierTo(
        joint.dx + dir * length * 0.35,
        joint.dy - height * 0.55,
        tip.dx,
        tip.dy - height * 0.08,
      )
      ..quadraticBezierTo(
        joint.dx + dir * length * 0.7,
        joint.dy,
        tip.dx,
        tip.dy + height * 0.08,
      )
      ..quadraticBezierTo(
        joint.dx + dir * length * 0.35,
        joint.dy + height * 0.55,
        joint.dx,
        joint.dy + height * 0.22,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: facingRight ? Alignment.centerLeft : Alignment.centerRight,
          end: facingRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            colorDef.color,
            Color.lerp(colorDef.color, Colors.white, 0.35)!,
            colorDef.accent,
          ],
        ).createShader(Rect.fromCenter(
          center: joint,
          width: length * 2.2,
          height: height,
        )),
    );

    // Fan crease lines.
    final crease = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final t in [-0.35, 0.0, 0.35]) {
      canvas.drawLine(
        Offset(joint.dx + dir * 2, joint.dy + height * t * 0.35),
        Offset(tip.dx - dir * 2, tip.dy + height * t * 0.12),
        crease,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Color.lerp(colorDef.color, Colors.black, 0.15)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _paintPattern(Canvas canvas, Rect body) {
    final ink = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final accentInk = Paint()
      ..color = Color.lerp(colorDef.color, Colors.white, 0.55)!;

    switch (pattern) {
      case CandyPattern.swirl:
        final swirl = Paint()
          ..color = Colors.white.withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = body.width * 0.09
          ..strokeCap = StrokeCap.round;
        final path = Path();
        final c = body.center;
        for (var i = 0; i < 48; i++) {
          final a = i / 48 * math.pi * 3.2 - math.pi / 2;
          final r = body.width * 0.06 + i / 48 * body.width * 0.38;
          final p = c + Offset(math.cos(a) * r, math.sin(a) * r * 0.85);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(path, swirl);
      case CandyPattern.stripes:
        final stripe = Paint()
          ..color = Color.lerp(colorDef.color, Colors.white, 0.55)!
          ..strokeWidth = body.width * 0.09
          ..strokeCap = StrokeCap.round;
        for (var i = -2; i <= 2; i++) {
          final x = body.center.dx + i * body.width * 0.16;
          canvas.drawLine(
            Offset(x, body.top + 2),
            Offset(x, body.bottom - 2),
            stripe,
          );
        }
      case CandyPattern.stars:
        final starColor =
            (colorDef.kind == CandyColorKind.purple ||
                    colorDef.kind == CandyColorKind.lilac ||
                    colorDef.kind == CandyColorKind.orange)
                ? const Color(0xFFFFF176)
                : Color.lerp(colorDef.color, Colors.white, 0.7)!;
        for (final o in const [
          Offset(-0.18, -0.08),
          Offset(0.16, -0.12),
          Offset(0.0, 0.14),
          Offset(-0.2, 0.16),
          Offset(0.2, 0.1),
        ]) {
          _star(
            canvas,
            body.center + Offset(body.width * o.dx, body.height * o.dy),
            body.width * 0.09,
            Paint()..color = starColor,
          );
        }
      case CandyPattern.dots:
        final dot = Paint()
          ..color = Color.lerp(colorDef.color, const Color(0xFFE65100), 0.45)!;
        for (final o in const [
          Offset(-0.2, -0.12),
          Offset(0.18, -0.08),
          Offset(0.0, 0.05),
          Offset(-0.12, 0.18),
          Offset(0.2, 0.16),
          Offset(0.05, -0.2),
        ]) {
          canvas.drawCircle(
            body.center + Offset(body.width * o.dx, body.height * o.dy),
            body.width * 0.07,
            dot,
          );
        }
      case CandyPattern.hearts:
        for (final o in const [
          Offset(-0.16, -0.05),
          Offset(0.16, -0.1),
          Offset(0.0, 0.16),
        ]) {
          _heart(
            canvas,
            body.center + Offset(body.width * o.dx, body.height * o.dy),
            body.width * 0.12,
            Paint()..color = Color.lerp(colorDef.color, Colors.white, 0.35)!,
          );
        }
    }

    // Tiny sparkle accents.
    canvas.drawCircle(
      body.center + Offset(body.width * 0.22, -body.height * 0.12),
      2.2,
      ink,
    );
    canvas.drawCircle(
      body.center + Offset(-body.width * 0.24, body.height * 0.1),
      1.6,
      accentInk,
    );
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / 5;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      final b = a + math.pi / 5;
      final q = c + Offset(math.cos(b) * r * 0.42, math.sin(b) * r * 0.42);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _heart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r * 0.7)
      ..cubicTo(
        c.dx - r * 1.1,
        c.dy + r * 0.1,
        c.dx - r * 0.9,
        c.dy - r * 0.7,
        c.dx,
        c.dy - r * 0.25,
      )
      ..cubicTo(
        c.dx + r * 0.9,
        c.dy - r * 0.7,
        c.dx + r * 1.1,
        c.dy + r * 0.1,
        c.dx,
        c.dy + r * 0.7,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CandyPainter old) =>
      old.colorDef != colorDef ||
      old.pattern != pattern ||
      old.pulseHint != pulseHint ||
      old.showGlow != showGlow ||
      old.showMotionLines != showMotionLines ||
      old.motionPhase != motionPhase;
}
