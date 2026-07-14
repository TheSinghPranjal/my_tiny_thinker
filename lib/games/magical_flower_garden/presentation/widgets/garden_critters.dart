import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

class BeeWidget extends StatelessWidget {
  const BeeWidget({super.key, required this.bee});

  final BeeEntity bee;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    return Positioned(
      left: bee.x - size / 2,
      top: bee.y - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: bee.rotation,
          child: CustomPaint(
            size: const Size(size, size),
            painter: _BeePainter(wingPhase: bee.wingPhase),
          ),
        ),
      ),
    );
  }
}

class _BeePainter extends CustomPainter {
  _BeePainter({required this.wingPhase});

  final double wingPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = math.sin(wingPhase) * 0.35;

    for (final sign in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + sign * 14, cy - 8 + flap * 6),
          width: 18,
          height: 12 + flap.abs() * 8,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 22, height: 28),
      Paint()..color = const Color(0xFFFFCA28),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 10, cy - 2 + i * 8.0),
        Offset(cx + 10, cy - 2 + i * 8.0),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2.5,
      );
    }

    canvas.drawCircle(Offset(cx - 4, cy - 2), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 4, cy - 2), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx - 3, cy - 2), 1.5, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + 5, cy - 2), 1.5, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(_BeePainter old) => old.wingPhase != wingPhase;
}
