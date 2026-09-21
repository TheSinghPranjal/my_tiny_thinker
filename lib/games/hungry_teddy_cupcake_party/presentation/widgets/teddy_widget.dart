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
    final size = largerTouch ? 250.0 : 230.0;
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

  static const fur = Color(0xFF8B5A3C);
  static const furLight = Color(0xFFA5714E);
  static const furDark = Color(0xFF6B4229);
  static const cream = Color(0xFFF7DDB8);
  static const creamShade = Color(0xFFEBC89B);
  static const pinkPad = Color(0xFFF3A08F);
  static const ink = Color(0xFF2E1B12);

  Paint _furFill(Rect r) => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.3, -0.5),
      radius: 1.05,
      colors: [furLight, fur, furDark],
      stops: [0.0, 0.6, 1.0],
    ).createShader(r);

  Paint get _line => Paint()
    ..color = furDark.withValues(alpha: 0.65)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;

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

    final breathe = math.sin(teddy.animPhase * 2) * 1.6;
    final bounce = excited * math.sin(teddy.animPhase * 8) * 4 +
        (celebrating ? math.sin(teddy.actionTimer * 10) * 4 : 0) +
        (eating ? math.sin(teddy.eatProgress * math.pi * 10) * 3 : 0) +
        (receiving ? math.sin(teddy.actionTimer * 6) * 2 : 0);

    // Soft shadow on the rug
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 84), width: 130, height: 20),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    canvas.save();
    canvas.translate(0, breathe + bounce - celebrate * 5);

    _drawFoot(canvas, cx - 46, cy + 70, left: true);
    _drawFoot(canvas, cx + 46, cy + 70, left: false);
    _drawBody(canvas, cx, cy);
    _drawBowTie(canvas, cx, cy + 4);
    // Arms lifted up and out like in a happy "hooray!"
    final lift = 2.05 + clap * 0.35 + excited * 0.2;
    _drawArm(canvas, cx - 46, cy + 4, lift, left: true);
    _drawArm(canvas, cx + 46, cy + 4, -lift, left: false);
    _drawHead(canvas, cx, cy, blink, eating, receiving);

    if (eating) {
      _drawCrumbs(canvas, cx, cy - 4);
    }

    if (teddy.phase == TeddyPhase.goldenCelebration) {
      for (var i = 0; i < 8; i++) {
        final a = teddy.actionTimer * 5 + i;
        canvas.drawCircle(
          Offset(cx + math.cos(a) * 78, cy - 20 + math.sin(a) * 54),
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
    final body = Rect.fromCenter(center: Offset(cx, cy + 36), width: 112, height: 98);
    canvas.drawOval(body, _furFill(body));
    canvas.drawOval(body, _line);
    final belly = Rect.fromCenter(center: Offset(cx, cy + 44), width: 66, height: 66);
    canvas.drawOval(
      belly,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.4),
          colors: [Color(0xFFFFEBCB), cream, creamShade],
          stops: [0.0, 0.6, 1.0],
        ).createShader(belly),
    );
  }

  void _drawBowTie(Canvas canvas, double cx, double cy) {
    const red = Color(0xFFE53935);
    const redDark = Color(0xFFB71C1C);
    for (final dir in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(cx + dir * 14, cy - 16, cx + dir * 30, cy - 12)
        ..quadraticBezierTo(cx + dir * 34, cy + 2, cx + dir * 30, cy + 14)
        ..quadraticBezierTo(cx + dir * 14, cy + 14, cx, cy)
        ..close();
      canvas.drawPath(wing, Paint()..color = red);
      canvas.drawPath(
        wing,
        Paint()
          ..color = redDark.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawPath(
        Path()
          ..moveTo(cx + dir * 6, cy - 2)
          ..quadraticBezierTo(cx + dir * 16, cy - 9, cx + dir * 24, cy - 7),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 18),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFD32F2F),
    );
  }

  void _drawHead(Canvas canvas, double cx, double cy, bool blink, bool eating, bool receiving) {
    final headCy = cy - 44;
    final angle = teddy.headAngle.clamp(-0.35, 0.35);

    canvas.save();
    canvas.translate(cx, headCy);
    canvas.rotate(angle);
    canvas.translate(-cx, -headCy);

    for (final dir in [-1.0, 1.0]) {
      _drawEar(canvas, cx + dir * 52, headCy - 32);
    }

    final head = Rect.fromCenter(center: Offset(cx, headCy), width: 122, height: 108);
    canvas.drawOval(head, _furFill(head));
    canvas.drawOval(head, _line);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 22, headCy - 38), width: 30, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Muzzle
    final muzzle = Rect.fromCenter(center: Offset(cx, headCy + 22), width: 74, height: 56);
    canvas.drawOval(
      muzzle,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.4),
          colors: [Color(0xFFFFEBCB), cream, creamShade],
          stops: [0.0, 0.65, 1.0],
        ).createShader(muzzle),
    );

    _drawFace(canvas, cx, headCy, blink, eating, receiving);
    canvas.restore();
  }

  void _drawEar(Canvas canvas, double x, double y) {
    final r = Rect.fromCircle(center: Offset(x, y), radius: 23);
    canvas.drawCircle(Offset(x, y), 23, _furFill(r));
    canvas.drawCircle(Offset(x, y), 23, _line);
    canvas.drawCircle(Offset(x, y + 2), 14, Paint()..color = const Color(0xFFF2A798));
  }

  void _drawArm(Canvas canvas, double x, double y, double angle, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final arm = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-14, -6, 28, 52),
      const Radius.circular(14),
    );
    canvas.drawRRect(arm, _furFill(const Rect.fromLTWH(-14, -6, 28, 52)));
    canvas.drawRRect(arm, _line);
    // Paw at the tip with a pink pad and three toe beans.
    final paw = Rect.fromCircle(center: const Offset(0, 50), radius: 17);
    canvas.drawCircle(const Offset(0, 50), 17, _furFill(paw));
    canvas.drawCircle(const Offset(0, 50), 17, _line);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 54), width: 17, height: 13),
      Paint()..color = pinkPad,
    );
    for (final dx in [-7.0, 0.0, 7.0]) {
      canvas.drawCircle(Offset(dx, 43 - (dx == 0 ? 2 : 0)), 3.3, Paint()..color = pinkPad);
    }
    canvas.restore();
  }

  void _drawFoot(Canvas canvas, double x, double y, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(left ? -0.25 : 0.25);
    final foot = Rect.fromCenter(center: Offset.zero, width: 62, height: 52);
    canvas.drawOval(foot, _furFill(foot));
    canvas.drawOval(foot, _line);
    // Big pink sole pad and toe beans
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 8), width: 32, height: 24),
      Paint()..color = pinkPad,
    );
    for (final (dx, dy) in [(-15.0, -8.0), (-5.0, -14.0), (5.0, -14.0), (15.0, -8.0)]) {
      canvas.drawCircle(Offset(dx, dy), 4.6, Paint()..color = pinkPad);
    }
    canvas.restore();
  }

  void _drawFace(Canvas canvas, double cx, double cy, bool blink, bool eating, bool receiving) {
    final happy = eating || receiving || teddy.excitedLevel > 0.5;

    // Cheeks
    final cheek = Paint()..color = const Color(0xFFFF8A94).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(cx - 46, cy + 16), 13, cheek);
    canvas.drawCircle(Offset(cx + 46, cy + 16), 13, cheek);

    // Eyes
    for (final ox in [-26.0, 26.0]) {
      final c = Offset(cx + ox, cy - 6);
      if (blink) {
        canvas.drawArc(
          Rect.fromCenter(center: c + const Offset(0, 2), width: 20, height: 13),
          math.pi + 0.2,
          math.pi - 0.4,
          false,
          Paint()
            ..color = ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.4
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      canvas.drawCircle(c, 15, Paint()..color = Colors.white);
      canvas.drawCircle(c, 15, Paint()
        ..color = furDark.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4);
      canvas.drawCircle(c + Offset(happy ? 1.2 : 0, 1), 10.5, Paint()..color = ink);
      canvas.drawCircle(c + const Offset(4, -4), 4, Paint()..color = Colors.white);
      canvas.drawCircle(c + const Offset(-3.5, 5), 2, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }

    // Nose
    final nose = Rect.fromCenter(center: Offset(cx, cy + 12), width: 22, height: 16);
    canvas.drawOval(nose, Paint()..color = const Color(0xFF4A2F22));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 4, cy + 9), width: 8, height: 4),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawLine(
      Offset(cx, cy + 20),
      Offset(cx, cy + 26),
      Paint()
        ..color = const Color(0xFF4A2F22)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Mouth: a big open smile by default, wider when eating.
    final mouthOpen = teddy.mouthOpen;
    final open = math.max(mouthOpen, eating ? 0.6 : 0.0);
    final w = 30 + open * 14;
    final depth = 22 + open * 16;
    final mouth = Path()
      ..moveTo(cx - w / 2, cy + 26)
      ..quadraticBezierTo(cx, cy + 26 + depth * 1.5, cx + w / 2, cy + 26)
      ..quadraticBezierTo(cx, cy + 22, cx - w / 2, cy + 26)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF6D2B1F));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 26 + depth * 0.95), width: w * 0.65, height: depth * 0.6),
      Paint()..color = const Color(0xFFFF7A86),
    );
    if (eating) {
      canvas.drawCircle(Offset(cx - 5, cy + 30), 3, Paint()..color = const Color(0xFFF48FB1));
      canvas.drawCircle(Offset(cx + 6, cy + 33), 2.5, Paint()..color = const Color(0xFFFFF176));
    }
    canvas.restore();
  }

  void _drawCrumbs(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 5; i++) {
      final a = teddy.eatProgress * 8 + i * 1.1;
      canvas.drawCircle(
        Offset(cx + math.cos(a) * 34, cy - 14 + math.sin(a * 1.3) * 12),
        2.8,
        Paint()
          ..color = Color([0xFFF48FB1, 0xFFFFF176, 0xFFFFAB91, 0xFFCE93D8, 0xFFA5D6A7][i])
              .withValues(alpha: 0.85),
      );
    }
  }

  void _drawHearts(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 3; i++) {
      final t = teddy.actionTimer * 2 + i;
      final hx = cx - 50 + i * 50 + math.sin(t) * 6;
      final hy = cy - 110 - (t % 2) * 10;
      final path = Path()
        ..moveTo(hx, hy + 8)
        ..cubicTo(hx - 12, hy - 2, hx - 7, hy - 10, hx, hy - 3)
        ..cubicTo(hx + 7, hy - 10, hx + 12, hy - 2, hx, hy + 8)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFFF6F9C).withValues(alpha: 0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _TeddyPainter old) =>
      old.teddy != teddy || old.blink != blink;
}
