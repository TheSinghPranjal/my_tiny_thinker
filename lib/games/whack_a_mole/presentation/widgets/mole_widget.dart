import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/logic/whack_a_mole_logic.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

class MoleWidget extends StatelessWidget {
  const MoleWidget({
    super.key,
    required this.mole,
    required this.size,
  });

  final MoleEntity mole;
  final double size;

  @override
  Widget build(BuildContext context) {
    final rise = WhackAMoleLogic.riseAmount(mole);
    final hitSpin = mole.phase == MolePhase.hit ? mole.hitProgress * 0.35 : 0.0;
    final squash = mole.phase == MolePhase.hit
        ? 1.0 + math.sin(mole.hitProgress * math.pi) * 0.25
        : 1.0;
    final stretch = mole.phase == MolePhase.hit
        ? 1.0 - math.sin(mole.hitProgress * math.pi) * 0.2
        : 1.0;

    return Transform.translate(
      offset: Offset(0, (1 - rise) * size * 0.85),
      child: Transform.rotate(
        angle: hitSpin,
        child: Transform.scale(
          scaleX: squash,
          scaleY: stretch,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: rise.clamp(0.0, 1.0),
            child: CustomPaint(
              size: Size(size, size),
              painter: _MolePainter(mole: mole),
            ),
          ),
        ),
      ),
    );
  }
}

class _MolePainter extends CustomPainter {
  _MolePainter({required this.mole});

  final MoleEntity mole;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final bodyColor = kFurTones[mole.furTone % kFurTones.length];
    final belly = Color.lerp(bodyColor, const Color(0xFFFFE0B2), 0.55)!;
    final dark = Color.lerp(bodyColor, Colors.black, 0.2)!;

    // Idle motion offsets
    final look = _lookOffset();
    final bounce = _bounceOffset();
    final earWiggle = _earWiggle();
    final tilt = _headTilt();
    final wave = _waveOffset();

    canvas.save();
    canvas.translate(cx, cy + bounce);
    canvas.rotate(tilt);

    // Ears
    _drawEar(canvas, -size.width * 0.22, -size.height * 0.28, earWiggle, bodyColor, dark);
    _drawEar(canvas, size.width * 0.22, -size.height * 0.28, -earWiggle, bodyColor, dark);

    // Body
    final bodyR = size.width * 0.32;
    canvas.drawCircle(Offset.zero, bodyR, Paint()..color = bodyColor);
    canvas.drawCircle(
      Offset(0, bodyR * 0.15),
      bodyR * 0.55,
      Paint()..color = belly,
    );

    // Soft shadow highlight
    canvas.drawCircle(
      Offset(-bodyR * 0.25, -bodyR * 0.3),
      bodyR * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Eyes
    final blink = _isBlinking();
    final eyeY = -bodyR * 0.12 + look.dy;
    final eyeSpread = bodyR * 0.28;
    _drawEye(canvas, -eyeSpread + look.dx, eyeY, bodyR * 0.16, blink);
    _drawEye(canvas, eyeSpread + look.dx, eyeY, bodyR * 0.16, blink);

    // Rosy cheeks
    canvas.drawCircle(
      Offset(-bodyR * 0.38, bodyR * 0.12),
      bodyR * 0.1,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.75),
    );
    canvas.drawCircle(
      Offset(bodyR * 0.38, bodyR * 0.12),
      bodyR * 0.1,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.75),
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(look.dx * 0.5, bodyR * 0.08),
        width: bodyR * 0.28,
        height: bodyR * 0.2,
      ),
      Paint()..color = const Color(0xFFFF80AB),
    );
    canvas.drawCircle(
      Offset(-2 + look.dx * 0.5, bodyR * 0.04),
      1.5,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    // Smile / laugh
    final laugh = mole.idleAnim == MoleIdleAnim.laugh || mole.phase == MolePhase.hit;
    final smilePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(0, bodyR * 0.28),
        width: bodyR * (laugh ? 0.55 : 0.42),
        height: bodyR * (laugh ? 0.4 : 0.28),
      ),
      0.15,
      math.pi - 0.3,
      false,
      smilePaint,
    );

    // Tiny paws
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-bodyR * 0.55, bodyR * 0.55),
        width: bodyR * 0.28,
        height: bodyR * 0.18,
      ),
      Paint()..color = belly,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyR * 0.55 + wave, bodyR * 0.5),
        width: bodyR * 0.28,
        height: bodyR * 0.18,
      ),
      Paint()..color = belly,
    );

    // Eyebrows
    final brow = Paint()
      ..color = dark
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-eyeSpread - 4 + look.dx, eyeY - bodyR * 0.22),
      Offset(-eyeSpread + 6 + look.dx, eyeY - bodyR * 0.2),
      brow,
    );
    canvas.drawLine(
      Offset(eyeSpread - 6 + look.dx, eyeY - bodyR * 0.2),
      Offset(eyeSpread + 4 + look.dx, eyeY - bodyR * 0.22),
      brow,
    );

    _drawAccessory(canvas, bodyR);

    canvas.restore();
  }

  void _drawEar(
    Canvas canvas,
    double x,
    double y,
    double wiggle,
    Color color,
    Color dark,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(wiggle);
    canvas.drawOval(
      const Rect.fromLTWH(-10, -16, 20, 28),
      Paint()..color = color,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-5, -10, 10, 16),
      Paint()..color = const Color(0xFFFFCCBC),
    );
    canvas.restore();
  }

  void _drawEye(Canvas canvas, double x, double y, double r, bool blink) {
    if (blink) {
      canvas.drawLine(
        Offset(x - r, y),
        Offset(x + r, y),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x + 1, y + 1), r * 0.55, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(
      Offset(x - r * 0.25, y - r * 0.25),
      r * 0.22,
      Paint()..color = Colors.white,
    );
  }

  void _drawAccessory(Canvas canvas, double bodyR) {
    switch (mole.accessory) {
      case MoleAccessory.none:
        return;
      case MoleAccessory.partyHat:
        final path = Path()
          ..moveTo(0, -bodyR * 1.35)
          ..lineTo(-bodyR * 0.35, -bodyR * 0.7)
          ..lineTo(bodyR * 0.35, -bodyR * 0.7)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFF7043));
        canvas.drawCircle(
          Offset(0, -bodyR * 1.35),
          4,
          Paint()..color = const Color(0xFFFFEB3B),
        );
      case MoleAccessory.crown:
        final crown = Path()
          ..moveTo(-bodyR * 0.35, -bodyR * 0.75)
          ..lineTo(-bodyR * 0.35, -bodyR * 1.05)
          ..lineTo(-bodyR * 0.15, -bodyR * 0.85)
          ..lineTo(0, -bodyR * 1.15)
          ..lineTo(bodyR * 0.15, -bodyR * 0.85)
          ..lineTo(bodyR * 0.35, -bodyR * 1.05)
          ..lineTo(bodyR * 0.35, -bodyR * 0.75)
          ..close();
        canvas.drawPath(crown, Paint()..color = const Color(0xFFFFD54F));
      case MoleAccessory.bow:
        canvas.drawCircle(
          Offset(-bodyR * 0.35, -bodyR * 0.85),
          bodyR * 0.14,
          Paint()..color = const Color(0xFFEC407A),
        );
        canvas.drawCircle(
          Offset(bodyR * 0.35, -bodyR * 0.85),
          bodyR * 0.14,
          Paint()..color = const Color(0xFFEC407A),
        );
        canvas.drawCircle(
          Offset(0, -bodyR * 0.85),
          bodyR * 0.1,
          Paint()..color = const Color(0xFFF48FB1),
        );
      case MoleAccessory.flower:
        for (var i = 0; i < 5; i++) {
          final a = i * math.pi * 2 / 5;
          canvas.drawCircle(
            Offset(
              math.cos(a) * bodyR * 0.18,
              -bodyR * 0.95 + math.sin(a) * bodyR * 0.18,
            ),
            bodyR * 0.1,
            Paint()..color = const Color(0xFFFF80AB),
          );
        }
        canvas.drawCircle(
          Offset(0, -bodyR * 0.95),
          bodyR * 0.08,
          Paint()..color = const Color(0xFFFFF176),
        );
      case MoleAccessory.glasses:
        final g = Paint()
          ..color = const Color(0xFF5C6BC0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(-bodyR * 0.28, -bodyR * 0.1), bodyR * 0.2, g);
        canvas.drawCircle(Offset(bodyR * 0.28, -bodyR * 0.1), bodyR * 0.2, g);
        canvas.drawLine(
          Offset(-bodyR * 0.08, -bodyR * 0.1),
          Offset(bodyR * 0.08, -bodyR * 0.1),
          g,
        );
      case MoleAccessory.scarf:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(0, bodyR * 0.55),
              width: bodyR * 1.1,
              height: bodyR * 0.22,
            ),
            const Radius.circular(6),
          ),
          Paint()..color = const Color(0xFF29B6F6),
        );
      case MoleAccessory.bowTie:
        final tie = Path()
          ..moveTo(0, bodyR * 0.45)
          ..lineTo(-bodyR * 0.28, bodyR * 0.3)
          ..lineTo(-bodyR * 0.28, bodyR * 0.6)
          ..close()
          ..moveTo(0, bodyR * 0.45)
          ..lineTo(bodyR * 0.28, bodyR * 0.3)
          ..lineTo(bodyR * 0.28, bodyR * 0.6)
          ..close();
        canvas.drawPath(tie, Paint()..color = const Color(0xFFE53935));
      case MoleAccessory.pirateHat:
        final hat = Path()
          ..moveTo(-bodyR * 0.55, -bodyR * 0.7)
          ..quadraticBezierTo(0, -bodyR * 1.25, bodyR * 0.55, -bodyR * 0.7)
          ..lineTo(bodyR * 0.45, -bodyR * 0.55)
          ..lineTo(-bodyR * 0.45, -bodyR * 0.55)
          ..close();
        canvas.drawPath(hat, Paint()..color = const Color(0xFF37474F));
        canvas.drawCircle(
          Offset(0, -bodyR * 0.9),
          4,
          Paint()..color = const Color(0xFFFFD54F),
        );
      case MoleAccessory.heroMask:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(0, -bodyR * 0.12),
              width: bodyR * 0.95,
              height: bodyR * 0.32,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xFF5C6BC0).withValues(alpha: 0.85),
        );
      case MoleAccessory.mustache:
        final m = Paint()..color = const Color(0xFF5D4037);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-bodyR * 0.16, bodyR * 0.2),
            width: bodyR * 0.28,
            height: bodyR * 0.12,
          ),
          m,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(bodyR * 0.16, bodyR * 0.2),
            width: bodyR * 0.28,
            height: bodyR * 0.12,
          ),
          m,
        );
    }
  }

  bool _isBlinking() {
    if (mole.idleAnim == MoleIdleAnim.blink) {
      return (mole.animPhase % 3.2) < 0.15;
    }
    return (mole.animPhase % 4.5) < 0.1;
  }

  Offset _lookOffset() {
    if (mole.idleAnim != MoleIdleAnim.lookAround) return Offset.zero;
    final a = math.sin(mole.animPhase * 2.2);
    return Offset(a * 3, math.cos(mole.animPhase * 1.4) * 1.5);
  }

  double _bounceOffset() {
    if (mole.idleAnim == MoleIdleAnim.bounce ||
        mole.idleAnim == MoleIdleAnim.smile) {
      return math.sin(mole.animPhase * 4) * 2.5;
    }
    return math.sin(mole.animPhase * 2) * 1.2;
  }

  double _earWiggle() {
    if (mole.idleAnim == MoleIdleAnim.earWiggle) {
      return math.sin(mole.animPhase * 8) * 0.25;
    }
    return math.sin(mole.animPhase * 2) * 0.05;
  }

  double _headTilt() {
    if (mole.idleAnim == MoleIdleAnim.headTilt) {
      return math.sin(mole.animPhase * 1.5) * 0.12;
    }
    return 0;
  }

  double _waveOffset() {
    if (mole.idleAnim == MoleIdleAnim.wave) {
      return math.sin(mole.animPhase * 7) * 6;
    }
    return 0;
  }

  @override
  bool shouldRepaint(covariant _MolePainter oldDelegate) =>
      oldDelegate.mole != mole;
}
