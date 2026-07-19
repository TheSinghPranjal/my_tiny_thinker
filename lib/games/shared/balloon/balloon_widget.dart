import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/shared/balloon/balloon_models.dart';

class BalloonWidget extends StatelessWidget {
  const BalloonWidget({
    super.key,
    required this.balloon,
    required this.onTap,
    this.highContrast = false,
    this.glow = false,
  });

  final BalloonEntity balloon;
  final VoidCallback onTap;
  final bool highContrast;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    if (balloon.phase == BalloonPhase.gone) {
      return const SizedBox.shrink();
    }

    final touch = balloon.size * 1.45;
    final opacity = balloon.phase == BalloonPhase.popping
        ? (1 - balloon.popProgress).clamp(0.0, 1.0)
        : 1.0;

    return Positioned(
      left: balloon.x - touch / 2,
      top: balloon.y - touch / 2,
      width: touch,
      height: touch * 1.25,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: balloon.isTappable ? onTap : null,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: balloon.scale,
            child: Transform.rotate(
              angle: balloon.wave
                  ? math.sin(balloon.swayPhase * 2) * 0.12
                  : math.sin(balloon.swayPhase) * 0.04,
              child: CustomPaint(
                size: Size(touch, touch * 1.25),
                painter: BalloonPainter(
                  hue: balloon.hue,
                  pattern: balloon.pattern,
                  face: balloon.face,
                  ribbon: balloon.ribbon,
                  shineSeed: balloon.shineSeed,
                  highContrast: highContrast,
                  glow: glow,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  BalloonPainter({
    required this.hue,
    required this.pattern,
    required this.face,
    required this.ribbon,
    required this.shineSeed,
    this.highContrast = false,
    this.glow = false,
  });

  final BalloonHue hue;
  final BalloonPattern pattern;
  final BalloonFace face;
  final BalloonRibbon ribbon;
  final double shineSeed;
  final bool highContrast;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyH = size.height * 0.62;
    final bodyW = size.width * 0.72;
    final bodyCy = size.height * 0.38;
    final body = Rect.fromCenter(
      center: Offset(cx, bodyCy),
      width: bodyW,
      height: bodyH,
    );

    if (glow) {
      canvas.drawOval(
        body.inflate(10),
        Paint()
          ..color = hue.primaryColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    _drawBody(canvas, body);
    _drawPattern(canvas, body);
    _drawShine(canvas, body);
    _drawFace(canvas, body);
    _drawKnot(canvas, cx, body.bottom);
    _drawRibbon(canvas, cx, body.bottom + size.height * 0.02, size.height * 0.28);
  }

  void _drawBody(Canvas canvas, Rect body) {
    if (hue == BalloonHue.rainbow) {
      final shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEF5350),
          Color(0xFFFFA726),
          Color(0xFFFFEE58),
          Color(0xFF66BB6A),
          Color(0xFF42A5F5),
          Color(0xFFAB47BC),
        ],
      ).createShader(body);
      canvas.drawOval(body, Paint()..shader = shader);
    } else {
      final shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(hue.primaryColor, Colors.white, highContrast ? 0.15 : 0.35)!,
          hue.primaryColor,
          hue.accentColor,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(body);
      canvas.drawOval(body, Paint()..shader = shader);
    }

    canvas.drawOval(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = highContrast ? 3 : 1.5
        ..color = hue.accentColor.withValues(alpha: 0.35),
    );
  }

  void _drawPattern(Canvas canvas, Rect body) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: highContrast ? 0.45 : 0.28);
    final rng = math.Random((shineSeed * 10000).toInt());

    switch (pattern) {
      case BalloonPattern.solid:
        break;
      case BalloonPattern.polkaDots:
        for (var i = 0; i < 8; i++) {
          final px = body.left + body.width * (0.2 + rng.nextDouble() * 0.6);
          final py = body.top + body.height * (0.2 + rng.nextDouble() * 0.55);
          canvas.drawCircle(Offset(px, py), body.width * 0.06, paint);
        }
      case BalloonPattern.stars:
        for (var i = 0; i < 5; i++) {
          final px = body.left + body.width * (0.25 + rng.nextDouble() * 0.5);
          final py = body.top + body.height * (0.2 + rng.nextDouble() * 0.5);
          _star(canvas, Offset(px, py), body.width * 0.07, paint);
        }
      case BalloonPattern.hearts:
        for (var i = 0; i < 4; i++) {
          final px = body.left + body.width * (0.28 + rng.nextDouble() * 0.45);
          final py = body.top + body.height * (0.25 + rng.nextDouble() * 0.45);
          _heart(canvas, Offset(px, py), body.width * 0.08, paint);
        }
      case BalloonPattern.confetti:
        for (var i = 0; i < 10; i++) {
          final px = body.left + body.width * (0.2 + rng.nextDouble() * 0.6);
          final py = body.top + body.height * (0.2 + rng.nextDouble() * 0.55);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(px, py),
                width: body.width * 0.08,
                height: body.width * 0.035,
              ),
              const Radius.circular(2),
            ),
            paint
              ..color = [
                const Color(0xFFFF7043),
                const Color(0xFF42A5F5),
                const Color(0xFFFFEE58),
                const Color(0xFF66BB6A),
              ][i % 4]
                  .withValues(alpha: 0.55),
          );
        }
      case BalloonPattern.stripes:
        for (var i = 0; i < 4; i++) {
          final y = body.top + body.height * (0.25 + i * 0.15);
          canvas.drawLine(
            Offset(body.left + body.width * 0.18, y),
            Offset(body.right - body.width * 0.18, y),
            paint
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round,
          );
        }
    }
  }

  void _drawShine(Canvas canvas, Rect body) {
    final shine = Rect.fromLTWH(
      body.left + body.width * (0.22 + shineSeed * 0.08),
      body.top + body.height * 0.18,
      body.width * 0.22,
      body.height * 0.28,
    );
    canvas.drawOval(
      shine,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.05),
          ],
        ).createShader(shine),
    );
  }

  void _drawFace(Canvas canvas, Rect body) {
    final eyeY = body.center.dy - body.height * 0.02;
    final eyeDx = body.width * 0.14;
    final eyeR = body.width * 0.045;
    final eyePaint = Paint()..color = const Color(0xFF37474F);

    if (face == BalloonFace.wink) {
      canvas.drawCircle(Offset(body.center.dx - eyeDx, eyeY), eyeR, eyePaint);
      canvas.drawLine(
        Offset(body.center.dx + eyeDx - eyeR, eyeY),
        Offset(body.center.dx + eyeDx + eyeR, eyeY),
        eyePaint
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    } else if (face == BalloonFace.starEyes) {
      _star(canvas, Offset(body.center.dx - eyeDx, eyeY), eyeR * 1.4, eyePaint);
      _star(canvas, Offset(body.center.dx + eyeDx, eyeY), eyeR * 1.4, eyePaint);
    } else {
      canvas.drawCircle(Offset(body.center.dx - eyeDx, eyeY), eyeR, eyePaint);
      canvas.drawCircle(Offset(body.center.dx + eyeDx, eyeY), eyeR, eyePaint);
      canvas.drawCircle(
        Offset(body.center.dx - eyeDx + eyeR * 0.3, eyeY - eyeR * 0.3),
        eyeR * 0.35,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(body.center.dx + eyeDx + eyeR * 0.3, eyeY - eyeR * 0.3),
        eyeR * 0.35,
        Paint()..color = Colors.white,
      );
    }

    final smile = Path();
    final smileY = eyeY + body.height * 0.12;
    if (face == BalloonFace.happy) {
      smile
        ..moveTo(body.center.dx - body.width * 0.14, smileY)
        ..quadraticBezierTo(
          body.center.dx,
          smileY + body.height * 0.12,
          body.center.dx + body.width * 0.14,
          smileY,
        );
    } else {
      smile
        ..moveTo(body.center.dx - body.width * 0.12, smileY)
        ..quadraticBezierTo(
          body.center.dx,
          smileY + body.height * 0.08,
          body.center.dx + body.width * 0.12,
          smileY,
        );
    }
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawKnot(Canvas canvas, double cx, double top) {
    final knot = Path()
      ..moveTo(cx, top)
      ..lineTo(cx - 6, top + 10)
      ..lineTo(cx + 6, top + 10)
      ..close();
    canvas.drawPath(knot, Paint()..color = hue.accentColor);
  }

  void _drawRibbon(Canvas canvas, double cx, double top, double length) {
    final paint = Paint()
      ..color = hue.accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(cx, top);
    switch (ribbon) {
      case BalloonRibbon.straight:
        path.lineTo(cx, top + length);
      case BalloonRibbon.curly:
        for (var i = 1; i <= 6; i++) {
          final t = i / 6;
          path.quadraticBezierTo(
            cx + (i.isEven ? 10 : -10),
            top + length * (t - 0.08),
            cx,
            top + length * t,
          );
        }
      case BalloonRibbon.zigZag:
        for (var i = 1; i <= 5; i++) {
          path.lineTo(
            cx + (i.isEven ? 8 : -8),
            top + length * (i / 5),
          );
        }
    }
    canvas.drawPath(path, paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _heart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r * 0.35)
      ..cubicTo(
        c.dx - r,
        c.dy - r * 0.2,
        c.dx - r * 0.5,
        c.dy - r,
        c.dx,
        c.dy - r * 0.35,
      )
      ..cubicTo(
        c.dx + r * 0.5,
        c.dy - r,
        c.dx + r,
        c.dy - r * 0.2,
        c.dx,
        c.dy + r * 0.35,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) =>
      oldDelegate.hue != hue ||
      oldDelegate.pattern != pattern ||
      oldDelegate.face != face ||
      oldDelegate.ribbon != ribbon ||
      oldDelegate.glow != glow ||
      oldDelegate.highContrast != highContrast;
}
