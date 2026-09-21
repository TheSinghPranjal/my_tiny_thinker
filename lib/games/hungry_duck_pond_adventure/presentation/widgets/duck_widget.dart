import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

class DuckWidget extends StatelessWidget {
  const DuckWidget({super.key, required this.duck, this.largerTouch = false});

  final DuckEntity duck;
  final bool largerTouch;

  /// Visual size of the duck sprite; [duck.x]/[duck.y] is the center point.
  static double layoutSize(bool largerTouch) => largerTouch ? 128.0 : 116.0;

  @override
  Widget build(BuildContext context) {
    final size = layoutSize(largerTouch);
    final blink = (duck.blinkTimer % 3.5) < 0.12;
    final bob = duck.phase == DuckPhase.idleSwim
        ? math.sin(duck.animPhase * 2) * 3.5
        : duck.phase == DuckPhase.celebrating
            ? math.sin(duck.animPhase * 8) * 4
            : 0.0;

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Transform.scale(
          scaleX: duck.facingRight ? 1 : -1,
          child: CustomPaint(
            size: Size(size, size),
            painter: _DuckPainter(duck: duck, blink: blink),
          ),
        ),
      ),
    );
  }
}

class _DuckPainter extends CustomPainter {
  _DuckPainter({required this.duck, required this.blink});

  final DuckEntity duck;
  final bool blink;

  static const _yellowLight = Color(0xFFFFF59D);
  static const _yellow = Color(0xFFFFDE3B);
  static const _yellowDark = Color(0xFFFFB92E);
  static const _outline = Color(0xFFE8A31A);
  static const _beak = Color(0xFFFF9A1F);
  static const _beakDark = Color(0xFFF07A0A);
  static const _ink = Color(0xFF3E2723);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 - 4;
    final cy = size.height * 0.56;
    final eating = duck.phase == DuckPhase.eating;
    final celebrating = duck.phase == DuckPhase.celebrating;
    final chasing = duck.phase == DuckPhase.chasing;
    final flap = math.sin(duck.wingFlap) * (chasing ? 0.55 : celebrating ? 0.4 : 0.22);

    _drawRipples(canvas, cx, cy);
    _drawTail(canvas, cx, cy);
    _drawBody(canvas, cx, cy);
    _drawWing(canvas, cx, cy, flap);
    _drawHead(canvas, cx, cy);
    _drawBeak(canvas, cx, cy, eating || celebrating);
    _drawCheek(canvas, cx, cy);
    _drawEye(canvas, cx, cy, blink);
    _drawWaterline(canvas, cx, cy);
  }

  Paint _yellowFill(Rect r) => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.3, -0.6),
      radius: 1.05,
      colors: [_yellowLight, _yellow, _yellowDark],
      stops: [0.0, 0.6, 1.0],
    ).createShader(r);

  Paint get _line => Paint()
    ..color = _outline.withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeJoin = StrokeJoin.round;

  void _drawRipples(Canvas canvas, double cx, double cy) {
    for (var i = 0; i < 3; i++) {
      final phase = duck.ripplePhase + i * 0.9;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 32 + i * 2),
          width: 62 + math.sin(phase) * 8 + i * 14,
          height: 12 + i * 2,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3 - i * 0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawTail(Canvas canvas, double cx, double cy) {
    final tail = Path()
      ..moveTo(cx - 28, cy + 6)
      ..quadraticBezierTo(cx - 42, cy - 2, cx - 46, cy - 16)
      ..quadraticBezierTo(cx - 34, cy - 12, cx - 20, cy - 4)
      ..close();
    canvas.drawPath(tail, Paint()..color = _yellowDark);
    canvas.drawPath(tail, _line);
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final body = Rect.fromCenter(center: Offset(cx, cy + 10), width: 76, height: 54);
    canvas.drawOval(body, _yellowFill(body));
    canvas.drawOval(body, _line);
    // Soft belly glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 4, cy + 22), width: 44, height: 18),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  void _drawWing(Canvas canvas, double cx, double cy, double flap) {
    canvas.save();
    canvas.translate(cx + 2, cy + 4);
    canvas.rotate(-flap * 0.7);
    final wing = Path()
      ..moveTo(4, -6)
      ..quadraticBezierTo(-8, -18, -28, -6)
      ..quadraticBezierTo(-32, 12, -10, 18)
      ..quadraticBezierTo(6, 14, 4, -6)
      ..close();
    final r = const Rect.fromLTWH(-32, -18, 38, 38);
    canvas.drawPath(
      wing,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE566), Color(0xFFFFC42B)],
        ).createShader(r),
    );
    canvas.drawPath(wing, _line);
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-6.0 - i * 6, 2 + i * 2),
        Offset(-14.0 - i * 6, 8 + i * 2),
        Paint()
          ..color = _outline.withValues(alpha: 0.5)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  void _drawHead(Canvas canvas, double cx, double cy) {
    final c = Offset(cx + 18, cy - 20);
    final r = Rect.fromCircle(center: c, radius: 25);
    // Little tuft
    for (final (dx, dy, tx) in [(-4.0, -22.0, -8.0), (2.0, -24.0, 2.0), (8.0, -21.0, 12.0)]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + dx, c.dy + dy + 4)
          ..quadraticBezierTo(c.dx + dx + 1, c.dy + dy - 6, c.dx + tx, c.dy + dy - 8),
        Paint()
          ..color = _yellowDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 25, _yellowFill(r));
    canvas.drawCircle(c, 25, _line);
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(-6, -14), width: 20, height: 8),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawBeak(Canvas canvas, double cx, double cy, bool open) {
    final o = open ? 5.0 : 0.0;
    final base = Offset(cx + 38, cy - 20);
    // Lower beak (drawn first so the upper overlaps it)
    final lower = Path()
      ..moveTo(base.dx - 4, base.dy + 1 + o)
      ..quadraticBezierTo(base.dx + 12, base.dy + 3 + o, base.dx + 18, base.dy + 1 + o)
      ..quadraticBezierTo(base.dx + 14, base.dy + 9 + o, base.dx - 2, base.dy + 8 + o)
      ..close();
    if (open) {
      canvas.drawPath(lower, Paint()..color = _beakDark);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(base.dx + 8, base.dy + 4 + o), width: 12, height: 5),
        Paint()..color = const Color(0xFFFF6F7D),
      );
    } else {
      canvas.drawPath(lower, Paint()..color = _beakDark);
    }
    canvas.drawPath(lower, _line..color = _beakDark.withValues(alpha: 0.6));
    final upper = Path()
      ..moveTo(base.dx - 4, base.dy - 8)
      ..quadraticBezierTo(base.dx + 12, base.dy - 12, base.dx + 21, base.dy - 3)
      ..quadraticBezierTo(base.dx + 22, base.dy + 1, base.dx + 14, base.dy + 1)
      ..lineTo(base.dx - 4, base.dy + 1)
      ..close();
    canvas.drawPath(upper, Paint()..color = _beak);
    canvas.drawPath(upper, _line..color = _beakDark.withValues(alpha: 0.7));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx + 9, base.dy - 7), width: 9, height: 3),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    canvas.drawCircle(Offset(base.dx + 12, base.dy - 4), 1.3, Paint()..color = _beakDark);
  }

  void _drawEye(Canvas canvas, double cx, double cy, bool blink) {
    final eye = Offset(cx + 24, cy - 26);
    if (blink) {
      canvas.drawArc(
        Rect.fromCenter(center: eye + const Offset(0, 1), width: 13, height: 9),
        math.pi + 0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    canvas.drawCircle(eye, 7.5, Paint()..color = Colors.white);
    canvas.drawCircle(eye, 7.5, Paint()
      ..color = _outline.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawCircle(eye + const Offset(1.6, 0.6), 5, Paint()..color = _ink);
    canvas.drawCircle(eye + const Offset(3.2, -1.6), 1.9, Paint()..color = Colors.white);
    canvas.drawCircle(eye + const Offset(0.4, 2.6), 1, Paint()..color = Colors.white.withValues(alpha: 0.7));
  }

  void _drawCheek(Canvas canvas, double cx, double cy) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 17, cy - 12), width: 12, height: 8),
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6),
    );
  }

  /// A thin watery edge so the duck looks like it is floating, not pasted on.
  void _drawWaterline(Canvas canvas, double cx, double cy) {
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 32), width: 82, height: 16),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.duck != duck || old.blink != blink;
}
