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
    final size = largerTouch ? 200.0 : 180.0;
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

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    final excited = teddy.excitedLevel;
    final celebrate = teddy.celebrateProgress;
    final clap = teddy.phase == TeddyPhase.celebrating || teddy.phase == TeddyPhase.goldenCelebration
        ? math.sin(teddy.actionTimer * 14).abs()
        : 0.0;

    // Visual-only motion — entity x/y stays fixed.
    final breathe = math.sin(teddy.animPhase * 2) * 2;
    final bounce = excited * math.sin(teddy.animPhase * 8) * 4 +
        (teddy.phase == TeddyPhase.goldenCelebration ? math.sin(teddy.actionTimer * 10) * 6 : 0) +
        (teddy.phase == TeddyPhase.celebrating ? math.sin(teddy.actionTimer * 10) * 3 : 0) +
        (teddy.phase == TeddyPhase.eating ? math.sin(teddy.eatProgress * math.pi * 8) * 3 : 0) +
        (teddy.phase == TeddyPhase.receiving ? math.sin(teddy.actionTimer * 6) * 2 : 0);

    canvas.save();
    canvas.translate(0, breathe + bounce - celebrate * 4);

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 88, height: 76),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFA1887F), Color(0xFF8D6E63)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy + 28), radius: 44)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 36), width: 56, height: 42),
      Paint()..color = const Color(0xFFD7CCC8),
    );

    _drawArm(canvas, cx - 48, cy + 18, -0.55 - clap * 0.65 - excited * 0.35);
    _drawArm(canvas, cx + 48, cy + 18, 0.55 + clap * 0.65 + excited * 0.35);
    _drawLeg(canvas, cx - 22, cy + 58);
    _drawLeg(canvas, cx + 22, cy + 58);

    _drawHead(canvas, cx, cy, blink);

    if (teddy.phase == TeddyPhase.goldenCelebration) {
      for (var i = 0; i < 6; i++) {
        final a = teddy.actionTimer * 5 + i;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 56, cy - 16 + math.sin(a) * 34),
          3.5,
          Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.9),
        );
      }
    }

    canvas.restore();
  }

  void _drawHead(Canvas canvas, double cx, double cy, bool blink) {
    const headCenterY = -6.0; // offset from cy
    final headCy = cy + headCenterY;
    final angle = teddy.headAngle.clamp(-0.35, 0.35);

    canvas.save();
    canvas.translate(cx, headCy);
    canvas.rotate(angle);
    canvas.translate(-cx, -headCy);

    canvas.drawCircle(Offset(cx, headCy), 40, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCy + 12), width: 46, height: 36),
      Paint()..color = const Color(0xFFD7CCC8),
    );

    _drawEar(canvas, cx - 36, headCy - 18);
    _drawEar(canvas, cx + 36, headCy - 18);
    _drawFace(canvas, cx, headCy + 6, blink);

    if (teddy.phase == TeddyPhase.eating || teddy.mouthOpen > 0.15) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, headCy + 22),
          width: 18 + teddy.mouthOpen * 14,
          height: 12 + teddy.mouthOpen * 8,
        ),
        Paint()..color = const Color(0xFF5D4037),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, headCy + 20),
          width: 14 + teddy.mouthOpen * 10,
          height: 6,
        ),
        Paint()..color = const Color(0xFFFFAB91),
      );
    }

    canvas.restore();
  }

  void _drawEar(Canvas canvas, double x, double y) {
    canvas.drawCircle(Offset(x, y), 16, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawCircle(Offset(x, y + 2), 9, Paint()..color = const Color(0xFFD7CCC8));
  }

  void _drawArm(Canvas canvas, double x, double y, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -7, 18, 38), const Radius.circular(9)),
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawCircle(const Offset(0, 34), 11, Paint()..color = const Color(0xFF795548));
    canvas.restore();
  }

  void _drawLeg(Canvas canvas, double x, double y) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 20, height: 28),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF795548),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 16), width: 24, height: 12),
      Paint()..color = const Color(0xFF5D4037),
    );
  }

  void _drawFace(Canvas canvas, double cx, double cy, bool blink) {
    canvas.drawCircle(Offset(cx - 14, cy + 4), 6, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(Offset(cx + 14, cy + 4), 6, Paint()..color = const Color(0xFF3E2723));
    if (!blink) {
      canvas.drawCircle(Offset(cx - 13, cy + 2), 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx + 15, cy + 2), 2.5, Paint()..color = Colors.white);
    } else {
      for (final ox in [-14.0, 14.0]) {
        canvas.drawLine(
          Offset(cx + ox - 5, cy + 4),
          Offset(cx + ox + 5, cy + 4),
          Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2.5,
        );
      }
    }

    canvas.drawCircle(
      Offset(cx - 24, cy + 12),
      7,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      Offset(cx + 24, cy + 12),
      7,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.6),
    );

    if (teddy.phase != TeddyPhase.eating && teddy.mouthOpen <= 0.15) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + 16), width: 18, height: 12),
        0.1,
        math.pi - 0.2,
        false,
        Paint()
          ..color = const Color(0xFF5D4037)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 12, height: 8),
      Paint()..color = const Color(0xFF8D6E63),
    );
  }

  @override
  bool shouldRepaint(covariant _TeddyPainter old) =>
      old.teddy != teddy || old.blink != blink;
}
