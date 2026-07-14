import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';
import 'package:my_tiny_thinker/games/shared/peek_a_boo_animals.dart';

class AnimalWidget extends StatelessWidget {
  const AnimalWidget({super.key, required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    if (animal.phase == AnimalPhase.hidden || animal.phase == AnimalPhase.gone) {
      return const SizedBox.shrink();
    }

    final def = animal.def;
    if (def == null) return const SizedBox.shrink();

    final size = 88.0 + animal.popProgress * 24;
    final blink = (animal.animPhase % 4.2) < 0.12;
    final wave = math.sin(animal.wavePhase) * 0.35;

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, -size * 0.1),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _AnimalFacePainter(
                  def: def,
                  blink: blink,
                  bounce: math.sin(animal.animPhase * 5) * 3,
                  waveAngle: wave,
                  pop: animal.popProgress.clamp(0.0, 1.0),
                ),
              ),
              Positioned(
                top: 4,
                child: Text(def.emoji, style: TextStyle(fontSize: size * 0.42)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalFacePainter extends CustomPainter {
  _AnimalFacePainter({
    required this.def,
    required this.blink,
    required this.bounce,
    required this.waveAngle,
    required this.pop,
  });

  final PeekAnimalDef def;
  final bool blink;
  final double bounce;
  final double waveAngle;
  final double pop;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + bounce;
    final bodyR = size.width * 0.34 * (0.6 + pop * 0.4);

    canvas.drawCircle(
      Offset(cx, cy),
      bodyR,
      Paint()..color = Color(def.primaryColor),
    );

    canvas.drawCircle(
      Offset(cx - bodyR * 0.55, cy - bodyR * 0.75),
      bodyR * 0.28,
      Paint()..color = Color(def.primaryColor),
    );
    canvas.drawCircle(
      Offset(cx + bodyR * 0.55, cy - bodyR * 0.75),
      bodyR * 0.28,
      Paint()..color = Color(def.primaryColor),
    );

    final eyeH = blink ? 2.0 : bodyR * 0.14;
    final eyePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - bodyR * 0.28, cy - bodyR * 0.08),
        width: bodyR * 0.18,
        height: eyeH,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + bodyR * 0.28, cy - bodyR * 0.08),
        width: bodyR * 0.18,
        height: eyeH,
      ),
      eyePaint,
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy + bodyR * 0.12),
        width: bodyR * 0.55,
        height: bodyR * 0.35,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(cx - bodyR * 0.42, cy + bodyR * 0.05),
      bodyR * 0.1,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.65),
    );
    canvas.drawCircle(
      Offset(cx + bodyR * 0.42, cy + bodyR * 0.05),
      bodyR * 0.1,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.65),
    );

    canvas.save();
    canvas.translate(cx + bodyR * 0.75, cy + bodyR * 0.15);
    canvas.rotate(-0.6 + waveAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bodyR * 0.55, height: bodyR * 0.22),
        const Radius.circular(10),
      ),
      Paint()..color = Color(def.primaryColor),
    );
    canvas.drawCircle(
      Offset(bodyR * 0.22, 0),
      bodyR * 0.12,
      Paint()..color = const Color(0xFFFFCCBC),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnimalFacePainter oldDelegate) =>
      oldDelegate.blink != blink ||
      oldDelegate.bounce != bounce ||
      oldDelegate.waveAngle != waveAngle ||
      oldDelegate.pop != pop;
}
