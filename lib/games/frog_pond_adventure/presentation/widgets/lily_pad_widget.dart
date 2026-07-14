import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';

class LilyPadWidget extends StatelessWidget {
  const LilyPadWidget({super.key, required this.pad});

  final LilyPadEntity pad;

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(pad.swayPhase) * 5;
    return Transform.translate(
      offset: Offset(sway, 0),
      child: CustomPaint(
        size: Size(pad.radius * 2.2, pad.radius * 1.4),
        painter: _LilyPadPainter(pad: pad),
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

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width, height: size.height * 0.82),
      Paint()..color = const Color(0xFF388E3C),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.88,
        height: size.height * 0.72,
      ),
      Paint()..color = const Color(0xFF66BB6A),
    );

    final notch = Path()
      ..moveTo(cx, cy - size.height * 0.35)
      ..lineTo(cx + size.width * 0.08, cy)
      ..lineTo(cx, cy + size.height * 0.05)
      ..close();
    canvas.drawPath(notch, Paint()..color = const Color(0xFF0288D1).withValues(alpha: 0.35));

    if (pad.state == PadState.waiting || pad.showSplash) {
      final rippleR = pad.radius * (0.4 + pad.splashProgress * 0.8);
      canvas.drawCircle(
        Offset(cx, cy + 4),
        rippleR,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25 * (1 - pad.splashProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    if (pad.ripplePhase > 0) {
      canvas.drawCircle(
        Offset(cx + math.sin(pad.ripplePhase) * 4, cy + 6),
        4,
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LilyPadPainter oldDelegate) => oldDelegate.pad != pad;
}
