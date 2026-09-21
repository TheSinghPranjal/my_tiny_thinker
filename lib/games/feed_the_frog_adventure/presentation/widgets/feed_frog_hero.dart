import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/presentation/widgets/feed_frog_character.dart';

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
          left: frogX - 128,
          top: frogY + 24,
          child: CustomPaint(
            size: const Size(256, 84),
            painter: _LilyPadPainter(phase: animPhase),
          ),
        ),
        Positioned(
          left: frogX - frogSize / 2,
          top: frogY - frogSize / 2 + bob,
          child: FeedFrogCharacter(
            size: frogSize,
            animPhase: animPhase,
            blink: blink,
            chew: chew,
            feeding: feeding,
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

    // Ripples on the water around the pad.
    for (final (w, a) in [(252.0, 0.16), (226.0, 0.26)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 6), width: w, height: w * 0.27),
        Paint()
          ..color = Colors.white.withValues(alpha: a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Thick underside gives the pad body.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + sway, cy + 9), width: 206, height: 62),
      Paint()..color = const Color(0xFF3C9A3A),
    );
    final pad = Rect.fromCenter(center: Offset(cx + sway, cy), width: 206, height: 62);
    canvas.drawOval(
      pad,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA6E36A), Color(0xFF67BF48), Color(0xFF55B043)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(pad),
    );
    // Notch cut into the pad, showing water.
    canvas.drawPath(
      Path()
        ..moveTo(cx + sway, cy + 1)
        ..lineTo(cx + sway + 26, cy + 27)
        ..lineTo(cx + sway - 4, cy + 31)
        ..close(),
      Paint()..color = const Color(0xFF3FA8E8),
    );
    // Veins
    final vein = Paint()
      ..color = const Color(0xFF3E8E35).withValues(alpha: 0.35)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = math.pi * 0.08 + i * math.pi * 0.12;
      canvas.drawLine(
        Offset(cx + sway, cy + 2),
        Offset(cx + sway + math.cos(a + math.pi) * 88, cy + 2 + math.sin(a + math.pi) * 24),
        vein,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + sway - 40, cy - 12), width: 70, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawOval(
      pad,
      Paint()
        ..color = const Color(0xFF3C8E33).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _LilyPadPainter old) => old.phase != phase;
}
