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

  @override
  Widget build(BuildContext context) {
    if (bee.phase == BeePhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 60.0 : 52.0;
    final wobble = bee.wasTapped ? math.sin(bee.wingPhase) * 4 : 0.0;

    return GestureDetector(
      onTap: bee.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(wobble, 0),
        child: SizedBox(
          width: touch,
          height: touch,
          child: CustomPaint(
            painter: _BeePainter(wingPhase: bee.wingPhase, happy: bee.wasTapped),
          ),
        ),
      ),
    );
  }
}

class _BeePainter extends CustomPainter {
  _BeePainter({required this.wingPhase, required this.happy});

  final double wingPhase;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = 0.6 + math.sin(wingPhase).abs() * 0.4;

    canvas.save();
    canvas.translate(cx, cy);

    canvas.save();
    canvas.scale(1, flap);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-10, -2), width: 16, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();

    canvas.save();
    canvas.scale(1, flap);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(10, -2), width: 16, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 22, height: 16),
      Paint()..color = const Color(0xFFFFCA28),
    );
    canvas.drawLine(
      const Offset(-8, 0),
      const Offset(8, 0),
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(-8, 5),
      const Offset(8, 5),
      Paint()
        ..color = const Color(0xFF37474F)
        ..strokeWidth = 2,
    );

    canvas.drawCircle(const Offset(-4, -4), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(4, -4), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-3, -3), 1.2, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(5, -3), 1.2, Paint()..color = Colors.black);

    if (happy) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, 2), width: 10, height: 6),
        0.1,
        math.pi - 0.2,
        false,
        Paint()
          ..color = const Color(0xFF37474F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeePainter old) =>
      old.wingPhase != wingPhase || old.happy != happy;
}
