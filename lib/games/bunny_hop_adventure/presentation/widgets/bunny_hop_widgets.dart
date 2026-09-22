import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';
import 'package:my_tiny_thinker/games/shared/bunny_character.dart';

class BunnyWidget extends StatelessWidget {
  const BunnyWidget({
    super.key,
    required this.bunny,
    this.largerTouch = false,
  });

  final BunnyEntity bunny;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 118.0 : 104.0;
    final blink = (bunny.blinkTimer % 3.5) < 0.12;
    final wet = bunny.phase == BunnyPhase.swimming || bunny.shakeWater > 0;
    final waving = bunny.phase == BunnyPhase.celebrating ||
        bunny.idleAction == 1 ||
        bunny.phase == BunnyPhase.idle;

    return Positioned(
      left: bunny.x - size / 2,
      top: bunny.y - size / 2,
      child: BunnyCharacter(
        size: size,
        facingRight: bunny.facingRight,
        animPhase: bunny.animPhase,
        blink: blink,
        waving: waving,
        wet: wet,
        squash: bunny.squash,
        celebrateProgress: bunny.celebrateProgress,
      ),
    );
  }
}

class CarrotWidget extends StatelessWidget {
  const CarrotWidget({super.key, required this.carrot});

  final CarrotEntity carrot;

  @override
  Widget build(BuildContext context) {
    if (!carrot.visible) return const SizedBox.shrink();
    final bounce = math.sin(carrot.bouncePhase) * 4;

    return Positioned(
      left: carrot.x - 36,
      top: carrot.y - 36 + bounce,
      child: SizedBox(
        width: 72,
        height: 72,
        child: CustomPaint(
          painter: _CarrotPainter(carrot: carrot),
        ),
      ),
    );
  }
}

class _CarrotPainter extends CustomPainter {
  _CarrotPainter({required this.carrot});

  final CarrotEntity carrot;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      c,
      32,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.28 + carrot.glow * 0.2),
    );
    canvas.drawCircle(
      c,
      26,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE082)],
        ).createShader(Rect.fromCircle(center: c, radius: 26)),
    );
    canvas.drawCircle(
      c,
      26,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFB300),
    );

    final path = Path()
      ..moveTo(c.dx - 9, c.dy - 10)
      ..lineTo(c.dx + 9, c.dy - 10)
      ..lineTo(c.dx + 5, c.dy + 16)
      ..quadraticBezierTo(c.dx, c.dy + 22, c.dx - 5, c.dy + 16)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF7043));

    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(c.dx - 4 + i * 4, c.dy - 10),
        Offset(c.dx - 8 + i * 6, c.dy - 22),
        Paint()
          ..color = const Color(0xFF66BB6A)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < 5; i++) {
      final a = carrot.sparklePhase + i * 1.25;
      canvas.drawCircle(
        Offset(c.dx + math.cos(a) * 30, c.dy + math.sin(a) * 28),
        2.2,
        Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter old) => old.carrot != carrot;
}

class LilyPadWidget extends StatelessWidget {
  const LilyPadWidget({super.key, required this.pad});

  final LilyPadEntity pad;

  @override
  Widget build(BuildContext context) {
    if (pad.phase == LilyPadPhase.sunk) return const SizedBox.shrink();

    return Positioned(
      left: pad.x - 40,
      top: pad.y - 28 + pad.bobOffset,
      child: SizedBox(
        width: 80,
        height: 56,
        child: CustomPaint(
          painter: _LilyPadPainter(pad: pad),
        ),
      ),
    );
  }
}

class _LilyPadPainter extends CustomPainter {
  _LilyPadPainter({required this.pad});

  final LilyPadEntity pad;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sink = pad.sinkProgress;
    final center = Offset(cx, cy + sink * 16);
    final showFlower = !pad.isCracked && pad.index % 2 == 1;

    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 6), width: 68, height: 22),
      Paint()..color = const Color(0xFF0277BD).withValues(alpha: 0.18),
    );

    final padRect = Rect.fromCenter(center: center, width: 70, height: 44);
    canvas.drawOval(
      padRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.35),
          colors: pad.isCracked
              ? const [Color(0xFF9CCC65), Color(0xFF558B2F)]
              : const [Color(0xFFAED581), Color(0xFF7CB342), Color(0xFF558B2F)],
        ).createShader(padRect),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-8, -6), width: 28, height: 14),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    if (pad.isCracked) {
      final xPaint = Paint()
        ..color = const Color(0xFF33691E)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center.translate(-10, -8),
        center.translate(10, 8),
        xPaint,
      );
      canvas.drawLine(
        center.translate(10, -8),
        center.translate(-10, 8),
        xPaint,
      );
    } else if (showFlower) {
      canvas.drawCircle(center.translate(0, -2), 5, Paint()..color = const Color(0xFFF48FB1));
      for (var i = 0; i < 5; i++) {
        final a = i * 1.26;
        canvas.drawCircle(
          center.translate(math.cos(a) * 8, -2 + math.sin(a) * 7),
          3.2,
          Paint()..color = i.isEven ? const Color(0xFFFFEB3B) : const Color(0xFFF8BBD0),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LilyPadPainter old) => old.pad != pad;
}
