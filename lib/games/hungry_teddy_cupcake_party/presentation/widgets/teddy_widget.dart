import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

class TeddyWidget extends StatelessWidget {
  const TeddyWidget({
    super.key,
    required this.teddy,
    this.largerTouch = false,
  });

  final TeddyEntity teddy;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 220.0 : 200.0;
    final blink = (teddy.blinkTimer % 3.6) < 0.12;

    return Positioned(
      left: teddy.x - size / 2,
      top: teddy.y - size / 2,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _TeddyPainter(teddy: teddy, blink: blink),
          ),
        ),
      ),
    );
  }
}

class _TeddyPainter extends CustomPainter {
  _TeddyPainter({required this.teddy, required this.blink});

  final TeddyEntity teddy;
  final bool blink;

  static const fur = Color(0xFF8D6E63);
  static const furDark = Color(0xFF6D4C41);
  static const cream = Color(0xFFEFEBE9);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;
    final excited = teddy.excitedLevel;
    final celebrate = teddy.celebrateProgress;
    final eating = teddy.phase == TeddyPhase.eating;
    final receiving = teddy.phase == TeddyPhase.receiving;
    final celebrating = teddy.phase == TeddyPhase.celebrating ||
        teddy.phase == TeddyPhase.goldenCelebration;
    final clap = celebrating ? math.sin(teddy.actionTimer * 14).abs() : 0.0;

    final breathe = math.sin(teddy.animPhase * 2) * 2;
    final bounce = excited * math.sin(teddy.animPhase * 8) * 5 +
        (celebrating ? math.sin(teddy.actionTimer * 10) * 5 : 0) +
        (eating ? math.sin(teddy.eatProgress * math.pi * 10) * 4 : 0) +
        (receiving ? math.sin(teddy.actionTimer * 6) * 2 : 0);

    canvas.save();
    canvas.translate(0, breathe + bounce - celebrate * 5);

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 78), width: 90, height: 18),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    _drawLeg(canvas, cx - 26, cy + 62);
    _drawLeg(canvas, cx + 26, cy + 62);
    _drawBody(canvas, cx, cy);
    _drawArm(canvas, cx - 52, cy + 16, -0.5 - clap * 0.7 - excited * 0.4, left: true);
    _drawArm(canvas, cx + 52, cy + 16, 0.5 + clap * 0.7 + excited * 0.4, left: false);
    _drawHead(canvas, cx, cy, blink, eating, receiving);

    if (eating) {
      _drawCrumbs(canvas, cx, cy - 4);
    }

    if (teddy.phase == TeddyPhase.goldenCelebration) {
      for (var i = 0; i < 8; i++) {
        final a = teddy.actionTimer * 5 + i;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 62, cy - 20 + math.sin(a) * 40),
          4,
          Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.9),
        );
      }
    }

    if (celebrating) {
      _drawHearts(canvas, cx, cy);
    }

    canvas.restore();
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final body = Rect.fromCenter(center: Offset(cx, cy + 30), width: 96, height: 84);
    canvas.drawOval(
      body,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.3),
          colors: [Color(0xFFA1887F), fur, furDark],
          stops: [0.0, 0.55, 1.0],
        ).createShader(body),
    );
    // Tummy
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 38), width: 58, height: 48),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF8E1), cream],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy + 38), radius: 30)),
    );
  }

  void _drawHead(Canvas canvas, double cx, double cy, bool blink, bool eating, bool receiving) {
    final headCy = cy - 10;
    final angle = teddy.headAngle.clamp(-0.35, 0.35);

    canvas.save();
    canvas.translate(cx, headCy);
    canvas.rotate(angle);
    canvas.translate(-cx, -headCy);

    _drawEar(canvas, cx - 40, headCy - 22);
    _drawEar(canvas, cx + 40, headCy - 22);

    canvas.drawCircle(
      Offset(cx, headCy),
      44,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.25),
          colors: [Color(0xFFA1887F), fur, furDark],
        ).createShader(Rect.fromCircle(center: Offset(cx, headCy), radius: 44)),
    );

    // Snout
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCy + 14), width: 52, height: 40),
      Paint()..color = cream,
    );

    _drawFace(canvas, cx, headCy + 6, blink, eating, receiving);

    canvas.restore();
  }

  void _drawEar(Canvas canvas, double x, double y) {
    canvas.drawCircle(Offset(x, y), 18, Paint()..color = fur);
    canvas.drawCircle(Offset(x, y + 2), 11, Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.85));
  }

  void _drawArm(Canvas canvas, double x, double y, double angle, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-11, -8, 22, 44), const Radius.circular(11)),
      Paint()..color = fur,
    );
    canvas.drawCircle(const Offset(0, 40), 13, Paint()..color = furDark);
    // Paw pad
    canvas.drawCircle(const Offset(0, 40), 7, Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7));
    canvas.restore();
  }

  void _drawLeg(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 24, height: 32),
        const Radius.circular(10),
      ),
      Paint()..color = furDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 18), width: 28, height: 14),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawCircle(Offset(x, y + 16), 6, Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.5));
  }

  void _drawFace(Canvas canvas, double cx, double cy, bool blink, bool eating, bool receiving) {
    // Eyes
    if (blink) {
      for (final ox in [-16.0, 16.0]) {
        canvas.drawLine(
          Offset(cx + ox - 6, cy + 2),
          Offset(cx + ox + 6, cy + 2),
          Paint()
            ..color = const Color(0xFF3E2723)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    } else {
      final happy = eating || receiving || teddy.excitedLevel > 0.5;
      for (final ox in [-16.0, 16.0]) {
        canvas.drawCircle(Offset(cx + ox, cy + 2), 8, Paint()..color = Colors.white);
        canvas.drawCircle(
          Offset(cx + ox + (happy ? 1.5 : 0), cy + 2.5),
          5,
          Paint()..color = const Color(0xFF3E2723),
        );
        canvas.drawCircle(
          Offset(cx + ox + 2.5, cy),
          2,
          Paint()..color = Colors.white,
        );
        if (happy) {
          // Happy squint arcs
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx + ox, cy - 6), width: 14, height: 8),
            math.pi + 0.2,
            math.pi - 0.4,
            false,
            Paint()
              ..color = const Color(0xFF5D4037).withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }

    // Cheeks
    canvas.drawCircle(
      Offset(cx - 28, cy + 14),
      9,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.65),
    );
    canvas.drawCircle(
      Offset(cx + 28, cy + 14),
      9,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.65),
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 14, height: 10),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawCircle(Offset(cx - 2, cy + 8), 2, Paint()..color = Colors.white.withValues(alpha: 0.5));

    final mouthOpen = teddy.mouthOpen;
    if (eating || mouthOpen > 0.15) {
      final w = 16 + mouthOpen * 18;
      final h = 10 + mouthOpen * 14;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 26), width: w, height: h),
        Paint()..color = const Color(0xFF4E342E),
      );
      // Tongue
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 28 + mouthOpen * 2), width: w * 0.55, height: h * 0.4),
        Paint()..color = const Color(0xFFFF8A80),
      );
      // Cupcake crumbs in mouth while eating
      if (eating) {
        canvas.drawCircle(Offset(cx - 4, cy + 24), 3, Paint()..color = const Color(0xFFF48FB1));
        canvas.drawCircle(Offset(cx + 5, cy + 26), 2.5, Paint()..color = const Color(0xFFFFF176));
      }
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + 20), width: 20, height: 14),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF5D4037)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCrumbs(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 5; i++) {
      final a = teddy.eatProgress * 8 + i * 1.1;
      canvas.drawCircle(
        Offset(cx + math.cos(a) * 28, cy + 20 + math.sin(a * 1.3) * 10),
        2.5,
        Paint()
          ..color = Color([0xFFF48FB1, 0xFFFFF176, 0xFFFFAB91, 0xFFCE93D8, 0xFFA5D6A7][i])
              .withValues(alpha: 0.85),
      );
    }
  }

  void _drawHearts(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 3; i++) {
      final t = teddy.actionTimer * 2 + i;
      final hx = cx - 40 + i * 40 + math.sin(t) * 6;
      final hy = cy - 50 - (t % 2) * 10;
      canvas.drawCircle(Offset(hx - 4, hy), 5, Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.8));
      canvas.drawCircle(Offset(hx + 4, hy), 5, Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.8));
      canvas.drawPath(
        Path()
          ..moveTo(hx - 8, hy + 2)
          ..lineTo(hx, hy + 12)
          ..lineTo(hx + 8, hy + 2),
        Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TeddyPainter old) =>
      old.teddy != teddy || old.blink != blink;
}
