import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';

class FeedFrogHero extends StatelessWidget {
  const FeedFrogHero({
    super.key,
    required this.frogX,
    required this.frogY,
    required this.animPhase,
    required this.blinkTimer,
    required this.phase,
    this.highContrast = false,
  });

  final double frogX;
  final double frogY;
  final double animPhase;
  final double blinkTimer;
  final FrogFeedPhase phase;
  final bool highContrast;

  static const frogSize = 168.0;

  @override
  Widget build(BuildContext context) {
    final blink = (blinkTimer % 3.8) < 0.12;
    final chew = phase == FrogFeedPhase.chewing;
    final feeding = phase == FrogFeedPhase.tongueExtend ||
        phase == FrogFeedPhase.tongueRetract;
    final bob = math.sin(animPhase * 2) * 3 + (chew ? math.sin(animPhase * 10) * 4 : 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: frogX - 90,
          top: frogY + 28,
          child: CustomPaint(
            size: const Size(180, 70),
            painter: _LilyPadPainter(phase: animPhase),
          ),
        ),
        Positioned(
          left: frogX - frogSize / 2,
          top: frogY - frogSize / 2 + bob,
          child: CustomPaint(
            size: const Size(frogSize, frogSize),
            painter: _FeedFrogPainter(
              blink: blink,
              chew: chew,
              feeding: feeding,
              animPhase: animPhase,
              highContrast: highContrast,
            ),
          ),
        ),
      ],
    );
  }
}

class _LilyPadPainter extends CustomPainter {
  _LilyPadPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sway = math.sin(phase) * 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 4, cy + 6), width: 150, height: 48),
      Paint()..color = const Color(0xFF01579B).withValues(alpha: 0.25),
    );

    final pad = Rect.fromCenter(
      center: Offset(cx + sway, cy),
      width: 148,
      height: 52,
    );
    canvas.drawOval(pad, Paint()..color = const Color(0xFF2E7D32));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + sway - 6, cy - 4), width: 110, height: 34),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.75),
    );

    // Notch
    canvas.drawPath(
      Path()
        ..moveTo(cx + sway, cy - 24)
        ..lineTo(cx + sway + 14, cy)
        ..lineTo(cx + sway, cy + 4)
        ..close(),
      Paint()..color = const Color(0xFF0288D1).withValues(alpha: 0.35),
    );

    // Tiny flower on pad
    final flower = Offset(cx + sway + 40, cy - 8);
    for (var i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5;
      canvas.drawCircle(
        flower + Offset(math.cos(a) * 6, math.sin(a) * 6),
        4,
        Paint()..color = const Color(0xFFF48FB1),
      );
    }
    canvas.drawCircle(flower, 3.5, Paint()..color = const Color(0xFFFFF176));
  }

  @override
  bool shouldRepaint(covariant _LilyPadPainter old) => old.phase != phase;
}

class _FeedFrogPainter extends CustomPainter {
  _FeedFrogPainter({
    required this.blink,
    required this.chew,
    required this.feeding,
    required this.animPhase,
    required this.highContrast,
  });

  final bool blink;
  final bool chew;
  final bool feeding;
  final double animPhase;
  final bool highContrast;

  static const bodyGreen = Color(0xFF66BB6A);
  static const bodyDark = Color(0xFF43A047);
  static const belly = Color(0xFFC8E6C9);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;

    canvas.save();
    canvas.translate(cx, cy);

    _drawWebbedFoot(canvas, -38, 42, left: true);
    _drawWebbedFoot(canvas, 38, 42, left: false);

    _drawHindLeg(canvas, -36, 18, left: true);
    _drawHindLeg(canvas, 36, 18, left: false);

    // Body
    final bodyRect = Rect.fromCenter(center: const Offset(0, 10), width: 92, height: 72);
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.25),
          colors: [Color(0xFF81C784), bodyGreen, bodyDark],
          stops: [0.0, 0.5, 1.0],
        ).createShader(bodyRect),
    );

    // Belly
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 18), width: 58, height: 44),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFE8F5E9), belly],
        ).createShader(Rect.fromCircle(center: const Offset(0, 18), radius: 30)),
    );

    // Spots on back
    for (final p in [
      const Offset(-18, -2),
      const Offset(16, 0),
      const Offset(-6, 8),
      const Offset(8, -8),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 10, height: 7),
        Paint()..color = bodyDark.withValues(alpha: 0.35),
      );
    }

    _drawFrontArm(canvas, -48, 10, left: true);
    _drawFrontArm(canvas, 48, 10, left: false);

    _drawHead(canvas);

    if (chew) {
      for (var i = 0; i < 4; i++) {
        final a = animPhase * 6 + i;
        canvas.drawCircle(
          Offset(math.cos(a) * 28, -20 + math.sin(a * 1.2) * 8),
          2.5,
          Paint()..color = Color([0xFFEC407A, 0xFFFFEE58, 0xFF42A5F5, 0xFFAB47BC][i]),
        );
      }
    }

    canvas.restore();
  }

  void _drawHead(Canvas canvas) {
    canvas.drawCircle(
      const Offset(0, -28),
      36,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFF81C784), bodyGreen, bodyDark],
        ).createShader(const Rect.fromLTWH(-36, -64, 72, 72)),
    );

    // Cheek blush
    canvas.drawCircle(
      const Offset(-22, -18),
      7,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      const Offset(22, -18),
      7,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.45),
    );

    _drawEye(canvas, -16, -40);
    _drawEye(canvas, 16, -40);

    // Nostrils
    canvas.drawCircle(const Offset(-5, -22), 2, Paint()..color = bodyDark.withValues(alpha: 0.5));
    canvas.drawCircle(const Offset(5, -22), 2, Paint()..color = bodyDark.withValues(alpha: 0.5));

    // Mouth
    if (feeding || chew) {
      final open = feeding ? 14.0 : 8.0 + math.sin(animPhase * 12).abs() * 6;
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -10), width: 28, height: open),
        Paint()..color = const Color(0xFF2E7D32),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -8 + open * 0.15), width: 16, height: open * 0.4),
        Paint()..color = const Color(0xFFE57373),
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -12), width: 28, height: 16),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawEye(Canvas canvas, double x, double y) {
    // Eye bulge
    canvas.drawCircle(Offset(x, y), 16, Paint()..color = bodyGreen);
    canvas.drawCircle(Offset(x, y), 14, Paint()..color = Colors.white);

    if (blink) {
      canvas.drawLine(
        Offset(x - 8, y),
        Offset(x + 8, y),
        Paint()
          ..color = const Color(0xFF1B5E20)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    canvas.drawCircle(Offset(x + 1, y + 1), 8, Paint()..color = const Color(0xFF1B5E20));
    canvas.drawCircle(Offset(x + 2, y + 2), 4.5, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(Offset(x + 4, y - 1), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x - 2, y + 4), 1.2, Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  void _drawFrontArm(Canvas canvas, double x, double y, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(left ? -0.35 : 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -4, 16, 28),
        const Radius.circular(8),
      ),
      Paint()..color = bodyDark,
    );
    _drawWebbedHand(canvas, 0, 26, left: left);
    canvas.restore();
  }

  void _drawHindLeg(Canvas canvas, double x, double y, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(left ? 0.5 : -0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10, -6, 20, 36),
        const Radius.circular(10),
      ),
      Paint()..color = bodyDark,
    );
    canvas.restore();
  }

  void _drawWebbedFoot(Canvas canvas, double x, double y, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    final dir = left ? -1.0 : 1.0;

    // Palm
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dir * 4, 0), width: 28, height: 16),
      Paint()..color = bodyDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dir * 4, 0), width: 20, height: 10),
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.5),
    );

    // Three webbed toes
    for (var i = 0; i < 3; i++) {
      final a = -0.6 + i * 0.6;
      final tip = Offset(dir * 8 + math.cos(a) * 16 * dir, math.sin(a) * 12 + 2);
      final toe = Path()
        ..moveTo(dir * 2, 0)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(dir * 4, 6)
        ..close();
      canvas.drawPath(toe, Paint()..color = bodyDark);
      // Toe pad
      canvas.drawCircle(tip, 4, Paint()..color = const Color(0xFF558B2F));
      canvas.drawCircle(tip, 2, Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.6));
    }

    // Webbing between toes
    canvas.drawPath(
      Path()
        ..moveTo(dir * 2, 0)
        ..quadraticBezierTo(dir * 14, 8, dir * 18, 2)
        ..quadraticBezierTo(dir * 10, 12, dir * 2, 6)
        ..close(),
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.45),
    );

    canvas.restore();
  }

  void _drawWebbedHand(Canvas canvas, double x, double y, {required bool left}) {
    canvas.save();
    canvas.translate(x, y);
    final dir = left ? -1.0 : 1.0;

    // Palm
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dir * 2, 0), width: 20, height: 14),
      Paint()..color = bodyDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dir * 2, 0), width: 14, height: 9),
      Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.5),
    );

    // Four webbed fingers (spread)
    final tips = <Offset>[];
    for (var i = 0; i < 4; i++) {
      final a = -0.85 + i * 0.55;
      final tip = Offset(
        dir * 4 + math.cos(a) * 14 * dir,
        math.sin(a) * 11 + 1,
      );
      tips.add(tip);
      final finger = Path()
        ..moveTo(dir * 2, 0)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(dir * 3, 5)
        ..close();
      canvas.drawPath(finger, Paint()..color = bodyDark);
      // Finger pad
      canvas.drawCircle(tip, 3.5, Paint()..color = const Color(0xFF558B2F));
      canvas.drawCircle(tip, 1.8, Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.65));
    }

    // Webbing membrane between fingers
    if (tips.length >= 2) {
      final web = Path()..moveTo(dir * 2, 0);
      for (final tip in tips) {
        web.lineTo(tip.dx * 0.85, tip.dy * 0.85);
      }
      web.close();
      canvas.drawPath(
        web,
        Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.55),
      );
      // Extra translucent fan for clearer webbing
      canvas.drawPath(
        Path()
          ..moveTo(dir * 2, 0)
          ..quadraticBezierTo(dir * 12, 8, tips.last.dx, tips.last.dy)
          ..quadraticBezierTo(dir * 8, 10, dir * 2, 4)
          ..close(),
        Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.4),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FeedFrogPainter old) =>
      old.blink != blink ||
      old.chew != chew ||
      old.feeding != feeding ||
      old.animPhase != animPhase;
}
