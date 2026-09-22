import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Brown monkey with a curled tail, drawn from plain state so it can be
/// reused wherever a monkey character is needed. Currently used by Hungry
/// Monkey Banana Adventure.
class MonkeyCharacter extends StatelessWidget {
  const MonkeyCharacter({
    super.key,
    required this.animPhase,
    this.blink = false,
    this.eating = false,
    this.clapping = false,
    this.reaching = false,
    this.catching = false,
    this.idleScratching = false,
    this.reachProgress = 0,
    this.sadProgress = 0,
    this.eatProgress = 0,
    this.actionTimer = 0,
    this.tailWag = 0,
    this.headShake = 0,
    this.earDroop = 0,
    this.size = 140,
  });

  final double animPhase;
  final bool blink;
  final bool eating;
  final bool clapping;
  final bool reaching;
  final bool catching;

  /// True while idly scratching its head (one of the idle fidgets).
  final bool idleScratching;
  final double reachProgress;
  final double sadProgress;
  final double eatProgress;
  final double actionTimer;
  final double tailWag;
  final double headShake;
  final double earDroop;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MonkeyPainter(
          animPhase: animPhase,
          blink: blink,
          eating: eating,
          clapping: clapping,
          reaching: reaching,
          catching: catching,
          idleScratching: idleScratching,
          reachProgress: reachProgress,
          sadProgress: sadProgress,
          eatProgress: eatProgress,
          actionTimer: actionTimer,
          tailWag: tailWag,
          headShake: headShake,
          earDroop: earDroop,
        ),
      ),
    );
  }
}

class MonkeyPainter extends CustomPainter {
  MonkeyPainter({
    required this.animPhase,
    required this.blink,
    required this.eating,
    required this.clapping,
    required this.reaching,
    required this.catching,
    required this.idleScratching,
    required this.reachProgress,
    required this.sadProgress,
    required this.eatProgress,
    required this.actionTimer,
    required this.tailWag,
    required this.headShake,
    required this.earDroop,
  });

  final double animPhase;
  final bool blink;
  final bool eating;
  final bool clapping;
  final bool reaching;
  final bool catching;
  final bool idleScratching;
  final double reachProgress;
  final double sadProgress;
  final double eatProgress;
  final double actionTimer;
  final double tailWag;
  final double headShake;
  final double earDroop;

  static const _fur = Color(0xFF8B5A3C);
  static const _furLight = Color(0xFFA26D4A);
  static const _furDark = Color(0xFF6B4229);
  static const _skin = Color(0xFFF7DDB8);
  static const _skinShade = Color(0xFFE9C79B);
  static const _ink = Color(0xFF2E1B12);

  Paint _furFill(Rect r) => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.3, -0.5),
      radius: 1.05,
      colors: [_furLight, _fur, _furDark],
      stops: [0.0, 0.6, 1.0],
    ).createShader(r);

  Paint get _line => Paint()
    ..color = _furDark.withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 - 4;
    final cy = size.height / 2 + 6;

    // Eased poses: the reach overshoots slightly and settles, like a real pop.
    final reach = Curves.easeOutBack.transform(reachProgress.clamp(0.0, 1.0));
    // 0..1 beat used for the celebratory clap and hop.
    final clap = clapping ? math.sin(actionTimer * 14).abs() : 0.0;
    // Chewing rhythm while eating.
    final chew = eating ? (math.sin(eatProgress * math.pi * 8) + 1) / 2 : 0.0;

    final breathe = math.sin(animPhase * 2) * 1.6;
    final hop = -clap * 7 - reach * 4;
    final wag = math.sin(tailWag * (clapping ? 1.8 : 1)) * (8 + clap * 8);

    // Squash and stretch about the feet: stretch on the reach, squash on chew.
    final stretch = 1 + reach * 0.05 - chew * 0.025 + clap * 0.03;
    final widen = 1 - (stretch - 1) * 0.6;

    // Soft ground shadow (shrinks while hopping)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 66),
        width: 96 - clap * 12 - reach * 8,
        height: 14,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.14 - clap * 0.03),
    );

    canvas.save();
    canvas.translate(0, breathe + hop);
    canvas.translate(cx, cy + 68);
    canvas.scale(widen, stretch);
    canvas.translate(-cx, -(cy + 68));

    _drawTail(canvas, cx, cy, wag);
    _drawBody(canvas, cx, cy);
    _drawLegs(canvas, cx, cy);
    _drawArm(canvas, cx - 27, cy + 20, 0.2 + reach * 2.3 - clap * 0.9, left: true);
    _drawArm(canvas, cx + 27, cy + 20, -(0.2 + reach * 2.3 - clap * 0.9), left: false);
    _drawHead(canvas, cx, cy, sadProgress, eatProgress, reach: reach, chew: chew, happy: clapping);

    if (idleScratching) {
      // Hand scratching the head.
      canvas.drawCircle(Offset(cx + 26, cy - 44), 8, Paint()..color = _skin);
      canvas.drawCircle(Offset(cx + 26, cy - 44), 8, _line);
    }

    canvas.restore();
  }

  void _drawTail(Canvas canvas, double cx, double cy, double wag) {
    final path = Path()
      ..moveTo(cx + 30, cy + 50)
      ..cubicTo(cx + 64 + wag, cy + 56, cx + 78 + wag, cy + 26, cx + 60 + wag, cy + 20)
      ..cubicTo(cx + 52 + wag, cy + 18, cx + 50 + wag, cy + 30, cx + 58 + wag, cy + 32);
    canvas.drawPath(
      path,
      Paint()
        ..color = _furDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _fur
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBody(Canvas canvas, double cx, double cy) {
    final body = Rect.fromCenter(center: Offset(cx, cy + 32), width: 68, height: 66);
    canvas.drawOval(body, _furFill(body));
    canvas.drawOval(body, _line);
    final belly = Rect.fromCenter(center: Offset(cx, cy + 38), width: 42, height: 44);
    canvas.drawOval(
      belly,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.4),
          colors: [Color(0xFFFFEBCB), _skin, _skinShade],
          stops: [0.0, 0.6, 1.0],
        ).createShader(belly),
    );
  }

  void _drawLegs(Canvas canvas, double cx, double cy) {
    for (final dir in [-1.0, 1.0]) {
      final thigh = Rect.fromCenter(center: Offset(cx + dir * 27, cy + 52), width: 34, height: 28);
      canvas.drawOval(thigh, _furFill(thigh));
      canvas.drawOval(thigh, _line);
      // Foot with cream sole and toes.
      final foot = Rect.fromCenter(center: Offset(cx + dir * 31, cy + 64), width: 32, height: 17);
      canvas.drawOval(foot, Paint()..color = _skin);
      canvas.drawOval(foot, _line..color = _skinShade);
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(cx + dir * (31 + (i - 1) * 8) + dir * 2, cy + 58),
          3.2,
          Paint()..color = _skin,
        );
      }
    }
  }

  void _drawArm(Canvas canvas, double x, double y, double angle, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final arm = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, -4, 14, 32),
      const Radius.circular(7),
    );
    canvas.drawRRect(arm, _furFill(const Rect.fromLTWH(-7, -4, 14, 32)));
    canvas.drawRRect(arm, _line);
    canvas.drawCircle(const Offset(0, 30), 8.5, Paint()..color = _skin);
    canvas.drawCircle(const Offset(0, 30), 8.5, _line..color = _skinShade);
    canvas.restore();
  }

  void _drawHead(
    Canvas canvas,
    double cx,
    double cy,
    double sad,
    double eat, {
    required double reach,
    required double chew,
    required bool happy,
  }) {
    canvas.save();
    // Look up while reaching, bob while chewing, tilt when celebrating.
    canvas.translate(
      cx + headShake * 18,
      cy - 12 - reach * 3 + chew * 1.5,
    );
    if (happy) {
      canvas.rotate(math.sin(actionTimer * 7) * 0.06);
    }
    final droop = -earDroop * 6;

    // Ears
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(dir * 38, -6 - droop * 0.4);
      canvas.rotate(dir * droop * 0.06);
      canvas.drawCircle(Offset.zero, 15, _furFill(Rect.fromCircle(center: Offset.zero, radius: 15)));
      canvas.drawCircle(Offset.zero, 15, _line);
      canvas.drawCircle(const Offset(0, 1), 9, Paint()..color = const Color(0xFFFFC9B0));
      canvas.restore();
    }

    // Head
    final head = Rect.fromCenter(center: const Offset(0, 0), width: 88, height: 80);
    canvas.drawOval(head, _furFill(head));
    canvas.drawOval(head, _line);
    // Tuft
    canvas.drawPath(
      Path()
        ..moveTo(-3, -38)
        ..quadraticBezierTo(-8, -50, 2, -50)
        ..quadraticBezierTo(8, -50, 6, -40),
      Paint()
        ..color = _furDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Face patch (two brow bumps plus muzzle)
    final patch = Path()
      ..addOval(Rect.fromCenter(center: const Offset(-15, -4), width: 38, height: 40))
      ..addOval(Rect.fromCenter(center: const Offset(15, -4), width: 38, height: 40))
      ..addOval(Rect.fromCenter(center: const Offset(0, 14), width: 56, height: 40));
    canvas.drawPath(patch, Paint()..color = _skin);

    // Cheeks (puff out a little while chewing)
    final cheek = Paint()..color = const Color(0xFFFF9AA2).withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(-28, 12), 6.5 + chew * 1.8, cheek);
    canvas.drawCircle(const Offset(28, 12), 6.5 + chew * 1.8, cheek);

    _drawEyes(canvas, look: reach, happy: happy);

    // Nose
    final nose = Paint()..color = _furDark.withValues(alpha: 0.75);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-3, 6), width: 3.4, height: 2.6), nose);
    canvas.drawOval(Rect.fromCenter(center: const Offset(3, 6), width: 3.4, height: 2.6), nose);

    _drawMouth(canvas, sad, eat, chew);
    canvas.restore();
  }

  void _drawEyes(Canvas canvas, {required double look, required bool happy}) {
    for (final dir in [-1.0, 1.0]) {
      final c = Offset(dir * 15, -6);
      if (blink || happy) {
        // Closed, curved eyes: a quick blink, or a happy squint when clapping.
        canvas.drawArc(
          Rect.fromCenter(center: c + const Offset(0, 2), width: 14, height: 10),
          math.pi + 0.2,
          math.pi - 0.4,
          false,
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final e = c + Offset(0, -look * 2);
      canvas.drawOval(Rect.fromCenter(center: e, width: 14, height: 17), Paint()..color = _ink);
      canvas.drawCircle(e + const Offset(2, -3.4), 3.2, Paint()..color = Colors.white);
      canvas.drawCircle(e + const Offset(-2, 3.4), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  void _drawMouth(Canvas canvas, double sad, double eat, double chew) {
    if (sad > 0.1) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, 22), width: 18, height: 10),
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
    if (eating) {
      // Chewing: the mouth opens and closes in a rhythm.
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, 19), width: 12 + chew * 6, height: 5 + chew * 11),
        Paint()..color = const Color(0xFF6D2B1F),
      );
      if (chew > 0.4) {
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 23), width: 8, height: 4),
          Paint()..color = const Color(0xFFFF6F7D),
        );
      }
      return;
    }
    if (reaching || catching) {
      // Small excited "oh!" as the banana comes down.
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 19), width: 12, height: 14),
        Paint()..color = const Color(0xFF6D2B1F),
      );
      return;
    }
    // Idle: big open smile with tongue.
    final mouth = Path()
      ..moveTo(-11, 15)
      ..quadraticBezierTo(0, 34, 11, 15)
      ..quadraticBezierTo(0, 12, -11, 15)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF6D2B1F));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 24), width: 12, height: 8),
      Paint()..color = const Color(0xFFFF6F7D),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MonkeyPainter old) =>
      old.animPhase != animPhase ||
      old.blink != blink ||
      old.eating != eating ||
      old.clapping != clapping ||
      old.reaching != reaching ||
      old.catching != catching ||
      old.idleScratching != idleScratching ||
      old.reachProgress != reachProgress ||
      old.sadProgress != sadProgress ||
      old.eatProgress != eatProgress ||
      old.actionTimer != actionTimer ||
      old.tailWag != tailWag ||
      old.headShake != headShake ||
      old.earDroop != earDroop;
}
