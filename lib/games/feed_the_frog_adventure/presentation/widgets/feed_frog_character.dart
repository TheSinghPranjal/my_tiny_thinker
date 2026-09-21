import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The friendly green frog for Feed the Frog: bulging eyes, rosy cheeks,
/// an open smile, a cream belly and webbed hands and feet.
///
/// Drawn in a square box; the frog's origin sits slightly below centre so the
/// mouth lines up with where the tongue starts (see `FrogTonguePainter`).
class FeedFrogCharacter extends StatelessWidget {
  const FeedFrogCharacter({
    super.key,
    required this.animPhase,
    this.blink = false,
    this.chew = false,
    this.feeding = false,
    this.size = 168,
  });

  final double animPhase;
  final bool blink;
  final bool chew;
  final bool feeding;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: FeedFrogPainter(
        animPhase: animPhase,
        blink: blink,
        chew: chew,
        feeding: feeding,
      ),
    );
  }
}

class FeedFrogPainter extends CustomPainter {
  FeedFrogPainter({
    required this.animPhase,
    required this.blink,
    required this.chew,
    required this.feeding,
  });

  final double animPhase;
  final bool blink;
  final bool chew;
  final bool feeding;

  static const _light = Color(0xFF9BDF66);
  static const _green = Color(0xFF67BD43);
  static const _dark = Color(0xFF3F9A2E);
  static const _outline = Color(0xFF35852A);
  static const _belly = Color(0xFFF5EBC4);
  static const _bellyShade = Color(0xFFE6D8A2);

  Paint get _line => Paint()
    ..color = _outline.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round;

  Paint _fill(Rect r, {Color top = _light, Color mid = _green, Color bottom = _dark}) =>
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.55),
          radius: 1.05,
          colors: [top, mid, bottom],
          stops: const [0.0, 0.62, 1.0],
        ).createShader(r);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 8);
    final s = size.width / 168;
    canvas.scale(s);

    _hindLegs(canvas);
    _body(canvas);
    _belly_(canvas);
    _hands(canvas);
    _feet(canvas);
    _head(canvas);
    if (chew) _crumbs(canvas);

    canvas.restore();
  }

  // --- Body parts ---------------------------------------------------------

  void _hindLegs(Canvas canvas) {
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(dir * 39, 26);
      canvas.rotate(dir * 0.22);
      final r = Rect.fromCenter(center: Offset.zero, width: 56, height: 64);
      canvas.drawOval(r, _fill(r));
      canvas.drawOval(r, _line);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-5, -14), width: 22, height: 14),
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
      canvas.restore();
    }
  }

  void _body(Canvas canvas) {
    final r = Rect.fromCenter(center: const Offset(0, 10), width: 84, height: 84);
    canvas.drawOval(r, _fill(r));
    canvas.drawOval(r, _line);
  }

  void _belly_(Canvas canvas) {
    final r = Rect.fromCenter(center: const Offset(0, 22), width: 50, height: 56);
    canvas.drawOval(
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.15, -0.35),
          colors: [Color(0xFFFFF9DE), _belly, _bellyShade],
          stops: [0.0, 0.62, 1.0],
        ).createShader(r),
    );
    canvas.drawOval(
      r,
      Paint()
        ..color = const Color(0xFFD9C98A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _hands(Canvas canvas) {
    for (final dir in [-1.0, 1.0]) {
      // Arm: a tapered limb from the shoulder down to the pad.
      final arm = Path()
        ..moveTo(dir * 22, 8)
        ..quadraticBezierTo(dir * 36, 26, dir * 32, 52)
        ..lineTo(dir * 22, 52)
        ..quadraticBezierTo(dir * 25, 28, dir * 14, 12)
        ..close();
      final bounds = Rect.fromLTRB(-40, 8, 40, 54);
      canvas.drawPath(arm, _fill(bounds));
      canvas.drawPath(arm, _line);
      _webbedHand(canvas, Offset(dir * 29, 56), dir);
    }
  }

  void _webbedHand(Canvas canvas, Offset c, double dir) {
    for (var i = 0; i < 3; i++) {
      final tip = c + Offset(dir * (3 + i * 7.5), 6 + (i == 1 ? 1.5 : 0));
      canvas.drawCircle(tip, 4.6, Paint()..color = _green);
      canvas.drawCircle(tip, 4.6, _line);
      canvas.drawCircle(
        tip + const Offset(-0.8, -1.2),
        1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
    final palm = Rect.fromCenter(center: c + Offset(dir * 6, 0), width: 22, height: 13);
    canvas.drawOval(palm, _fill(palm));
    canvas.drawOval(palm, _line);
  }

  void _feet(Canvas canvas) {
    for (final dir in [-1.0, 1.0]) {
      final c = Offset(dir * 47, 55);
      for (var i = 0; i < 3; i++) {
        final tip = c + Offset(dir * (12 + i * 6), 1 + (i - 1).abs() * 3.0 - (i == 2 ? 1 : 0));
        final web = Path()
          ..moveTo(c.dx, c.dy - 4)
          ..lineTo(tip.dx, tip.dy - 4)
          ..lineTo(tip.dx, tip.dy + 4)
          ..lineTo(c.dx, c.dy + 6)
          ..close();
        canvas.drawPath(web, Paint()..color = _green);
        canvas.drawCircle(tip, 5.6, Paint()..color = _green);
        canvas.drawCircle(tip, 5.6, _line);
        canvas.drawCircle(
          tip + const Offset(-1.4, -1.8),
          1.8,
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        );
      }
      final heel = Rect.fromCenter(center: c, width: 30, height: 18);
      canvas.drawOval(heel, _fill(heel));
      canvas.drawOval(heel, _line);
    }
  }

  void _head(Canvas canvas) {
    const headRect = Rect.fromLTWH(-46, -60, 92, 62);
    // Eye domes sit on top of the head.
    for (final dir in [-1.0, 1.0]) {
      final dome = Offset(dir * 25, -46);
      canvas.drawCircle(dome, 21, Paint()..color = _green);
      canvas.drawCircle(dome, 21, _line);
    }
    canvas.drawOval(headRect, _fill(headRect));
    canvas.drawOval(headRect, _line);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, -50), width: 26, height: 9),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    // Cheeks
    final cheek = Paint()..color = const Color(0xFFFF8F9C).withValues(alpha: 0.7);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-32, -22), width: 19, height: 15), cheek);
    canvas.drawOval(Rect.fromCenter(center: const Offset(32, -22), width: 19, height: 15), cheek);

    _eye(canvas, const Offset(-25, -46));
    _eye(canvas, const Offset(25, -46));

    // Nostrils
    final nostril = Paint()..color = _outline.withValues(alpha: 0.7);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-5, -33), width: 3.4, height: 2.4), nostril);
    canvas.drawOval(Rect.fromCenter(center: const Offset(5, -33), width: 3.4, height: 2.4), nostril);

    _mouth(canvas);
  }

  void _eye(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 17, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      17,
      Paint()
        ..color = const Color(0xFFCFE6C2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    if (blink) {
      canvas.drawArc(
        Rect.fromCenter(center: c + const Offset(0, 2), width: 20, height: 12),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF3E6B2A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final iris = Rect.fromCircle(center: c + const Offset(0, 1), radius: 12);
    canvas.drawCircle(
      c + const Offset(0, 1),
      12,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF9A5A2C), Color(0xFF5E3018)],
        ).createShader(iris),
    );
    canvas.drawCircle(c + const Offset(0, 1.5), 7.4, Paint()..color = const Color(0xFF1A0E08));
    canvas.drawCircle(c + const Offset(4.5, -4), 4.2, Paint()..color = Colors.white);
    canvas.drawCircle(c + const Offset(-4.5, 6.5), 2.2, Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  void _mouth(Canvas canvas) {
    // Corners sit at y = -22; tongue starts near y = -20 in the game.
    if (feeding) {
      final oval = Rect.fromCenter(center: const Offset(0, -15), width: 30, height: 22);
      canvas.drawOval(oval, Paint()..color = const Color(0xFF7A2A1F));
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -9), width: 18, height: 9),
        Paint()..color = const Color(0xFFFF6F7D),
      );
      return;
    }

    final depth = chew ? 8.0 + math.sin(animPhase * 12).abs() * 8 : 24.0;
    final mouth = Path()
      ..moveTo(-18, -22)
      ..quadraticBezierTo(0, -22 + depth * 1.7, 18, -22)
      ..quadraticBezierTo(0, -22 - 4, -18, -22)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF7A2A1F));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -22 + depth * 0.95), width: 22, height: depth * 0.6),
      Paint()..color = const Color(0xFFFF6F7D),
    );
    canvas.restore();
    canvas.drawPath(
      mouth,
      Paint()
        ..color = const Color(0xFF5B1E15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _crumbs(Canvas canvas) {
    const colors = [0xFFEC407A, 0xFFFFEE58, 0xFF42A5F5, 0xFFAB47BC];
    for (var i = 0; i < 4; i++) {
      final a = animPhase * 6 + i;
      canvas.drawCircle(
        Offset(math.cos(a) * 30, -24 + math.sin(a * 1.2) * 8),
        2.5,
        Paint()..color = Color(colors[i]),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FeedFrogPainter old) =>
      old.animPhase != animPhase ||
      old.blink != blink ||
      old.chew != chew ||
      old.feeding != feeding;
}
