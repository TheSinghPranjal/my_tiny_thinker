import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';

class GardenBeeWidget extends StatelessWidget {
  const GardenBeeWidget({
    super.key,
    required this.bee,
    required this.onTap,
    this.largerTouch = false,
  });

  final BeeEntity bee;
  final VoidCallback onTap;
  final bool largerTouch;

  static double layoutSize(bool largerTouch) => largerTouch ? 78.0 : 70.0;

  @override
  Widget build(BuildContext context) {
    if (bee.phase == BeePhase.gone) return const SizedBox.shrink();

    final touch = layoutSize(largerTouch);
    final fleeing = bee.phase == BeePhase.leaving || bee.wasTapped;
    final wobble = fleeing ? math.sin(bee.wingPhase) * 6 : math.sin(bee.pathT) * 2;

    return GestureDetector(
      onTap: bee.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(wobble, fleeing ? -4 : 0),
        child: Transform.rotate(
          angle: fleeing ? -0.25 : bee.vx < 0 ? 0.08 : -0.08,
          child: SizedBox(
            width: touch,
            height: touch,
            child: CustomPaint(
              painter: _BeePainter(
                wingPhase: bee.wingPhase,
                happy: bee.wasTapped,
                fleeing: fleeing,
                facingRight: bee.vx >= 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BeePainter extends CustomPainter {
  _BeePainter({
    required this.wingPhase,
    required this.happy,
    required this.fleeing,
    required this.facingRight,
  });

  final double wingPhase;
  final bool happy;
  final bool fleeing;
  final bool facingRight;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = fleeing
        ? 0.35 + math.sin(wingPhase * 1.5).abs() * 0.65
        : 0.55 + math.sin(wingPhase).abs() * 0.45;

    canvas.save();
    canvas.translate(cx, cy);
    if (!facingRight) canvas.scale(-1, 1);

    // Soft shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 22), width: 28, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // Wings (behind body) — translucent with veins
    _drawWing(canvas, const Offset(-14, -6), flap, left: true);
    _drawWing(canvas, const Offset(14, -6), flap, left: false);

    // Abdomen / body
    final bodyRect = Rect.fromCenter(center: const Offset(2, 4), width: 30, height: 22);
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFFFCA28), Color(0xFFFFA000)],
        ).createShader(bodyRect),
    );

    // Black stripes
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(-8.0 + i * 6, -4),
        Offset(-6.0 + i * 6, 12),
        Paint()
          ..color = const Color(0xFF37474F)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Head
    canvas.drawCircle(
      const Offset(-12, 0),
      9,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFCA28)],
        ).createShader(const Rect.fromLTWH(-21, -9, 18, 18)),
    );

    // Eyes
    canvas.drawCircle(const Offset(-15, -3), 3.2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-9, -3), 3.2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-14.5, -2.5), 1.8, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(const Offset(-8.5, -2.5), 1.8, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(const Offset(-14, -3.2), 0.7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-8, -3.2), 0.7, Paint()..color = Colors.white);

    // Antennae
    final ant = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(-16, -6)
        ..quadraticBezierTo(-20, -14, -18, -18),
      ant,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-10, -6)
        ..quadraticBezierTo(-8, -14, -6, -18),
      ant,
    );
    canvas.drawCircle(const Offset(-18, -18), 2, Paint()..color = const Color(0xFF37474F));
    canvas.drawCircle(const Offset(-6, -18), 2, Paint()..color = const Color(0xFF37474F));

    // Smile when tapped / fleeing happily
    if (happy) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(-12, 3), width: 10, height: 7),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF37474F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Stinger
    final sting = Path()
      ..moveTo(16, 4)
      ..lineTo(26, 6)
      ..lineTo(16, 10)
      ..close();
    canvas.drawPath(sting, Paint()..color = const Color(0xFF546E7A));
    canvas.drawPath(
      sting,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Tiny legs
    for (final ox in [-2.0, 4.0, 10.0]) {
      canvas.drawLine(
        Offset(ox, 12),
        Offset(ox + 2, 18),
        Paint()
          ..color = const Color(0xFF37474F)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  void _drawWing(Canvas canvas, Offset center, double flap, {required bool left}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, flap);
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(left ? -16 : 16, -14, left ? -8 : 8, -22)
      ..quadraticBezierTo(left ? 4 : -4, -10, 0, 0)
      ..close();
    canvas.drawPath(
      wing,
      Paint()..color = const Color(0xFFE3F2FD).withValues(alpha: 0.75),
    );
    canvas.drawPath(
      wing,
      Paint()
        ..color = const Color(0xFF90CAF9).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Vein
    canvas.drawLine(
      Offset.zero,
      Offset(left ? -6 : 6, -14),
      Paint()
        ..color = const Color(0xFF64B5F6).withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeePainter old) =>
      old.wingPhase != wingPhase ||
      old.happy != happy ||
      old.fleeing != fleeing ||
      old.facingRight != facingRight;
}
