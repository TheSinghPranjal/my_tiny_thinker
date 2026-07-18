import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

class AstronautWidget extends StatelessWidget {
  const AstronautWidget({
    super.key,
    required this.astronaut,
    this.size = 56,
    this.highlighted = false,
  });

  final MoonAstronaut astronaut;
  final double size;
  final bool highlighted;

  static const _patchColors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(astronaut.wavePhase) * 0.15;
    final enter = Curves.easeOut.transform(astronaut.enterProgress.clamp(0.0, 1.0));
    return Opacity(
      opacity: enter,
      child: Transform.translate(
        offset: Offset(0, (1 - enter) * 18),
        child: Transform.scale(
          scale: 0.82 + enter * 0.18,
          child: Transform.rotate(
            angle: astronaut.rotation,
            child: SizedBox(
              width: size,
              height: size * 1.25,
              child: CustomPaint(
                painter: _AstronautPainter(
                  variety: astronaut.variety,
                  wave: wave,
                  landing: astronaut.phase == AstronautPhase.landing,
                  running: astronaut.phase == AstronautPhase.running ||
                      astronaut.phase == AstronautPhase.waiting,
                  trail: astronaut.trail,
                  glow: highlighted ||
                      astronaut.phase == AstronautPhase.pushed ||
                      astronaut.phase == AstronautPhase.waiting,
                  patch: _patchColors[astronaut.variety % _patchColors.length],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AstronautPainter extends CustomPainter {
  _AstronautPainter({
    required this.variety,
    required this.wave,
    required this.landing,
    required this.running,
    required this.trail,
    required this.glow,
    required this.patch,
  });

  final int variety;
  final double wave;
  final bool landing;
  final bool running;
  final bool trail;
  final bool glow;
  final Color patch;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyTop = size.height * 0.38;

    if (trail) {
      canvas.drawCircle(
        Offset(cx, size.height * 0.5),
        size.width * 0.55,
        Paint()..color = const Color(0xFFFFF59D).withValues(alpha: 0.25),
      );
    }
    if (glow) {
      canvas.drawCircle(
        Offset(cx, size.height * 0.45),
        size.width * 0.5,
        Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.35),
      );
    }

    // Backpack
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + size.width * 0.22, bodyTop + size.height * 0.18),
          width: size.width * 0.28,
          height: size.height * 0.28,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = patch.withValues(alpha: 0.85),
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bodyTop + size.height * 0.2),
          width: size.width * 0.55,
          height: size.height * 0.42,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = MoonRescuePalette.suit,
    );

    // Patch
    canvas.drawCircle(
      Offset(cx - size.width * 0.12, bodyTop + size.height * 0.18),
      size.width * 0.08,
      Paint()..color = patch,
    );

    // Legs
    final legSwing = running ? math.sin(wave * 20) * 6 : 0.0;
    final legPaint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - size.width * 0.22,
          size.height * 0.72 + (landing ? 2 : 0),
          size.width * 0.16,
          size.height * 0.22,
        ).shift(Offset(-legSwing, 0)),
        const Radius.circular(6),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx + size.width * 0.06,
          size.height * 0.72 + (landing ? 2 : 0),
          size.width * 0.16,
          size.height * 0.22,
        ).shift(Offset(legSwing, 0)),
        const Radius.circular(6),
      ),
      legPaint,
    );

    // Arms
    final armPaint = Paint()
      ..color = MoonRescuePalette.suit
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - size.width * 0.28, bodyTop + size.height * 0.15),
      Offset(cx - size.width * 0.42, bodyTop + size.height * 0.05 + wave * 10),
      armPaint,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.28, bodyTop + size.height * 0.15),
      Offset(cx + size.width * 0.42, bodyTop + size.height * 0.08 - wave * 8),
      armPaint,
    );

    // Helmet
    final helmetC = Offset(cx, size.height * 0.22);
    final helmetR = size.width * 0.32;
    canvas.drawCircle(helmetC, helmetR, Paint()..color = MoonRescuePalette.suit);
    canvas.drawCircle(
      helmetC,
      helmetR * 0.78,
      Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.55),
    );
    // Face
    canvas.drawCircle(
      helmetC.translate(-helmetR * 0.22, 0),
      2.2,
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawCircle(
      helmetC.translate(helmetR * 0.22, 0),
      2.2,
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawArc(
      Rect.fromCircle(center: helmetC.translate(0, helmetR * 0.15), radius: 5),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFFEF5350)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    // Visor shine
    canvas.drawCircle(
      helmetC.translate(-helmetR * 0.2, -helmetR * 0.25),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _AstronautPainter oldDelegate) =>
      oldDelegate.wave != wave ||
      oldDelegate.landing != landing ||
      oldDelegate.running != running ||
      oldDelegate.trail != trail ||
      oldDelegate.glow != glow;
}
