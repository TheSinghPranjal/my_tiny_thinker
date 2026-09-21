import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

class AppleWidget extends StatelessWidget {
  const AppleWidget({
    super.key,
    required this.apple,
    required this.onTap,
    this.largerTouch = false,
  });

  final AppleEntity apple;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (apple.phase == ApplePhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 68.0 : 60.0;
    final bounce = apple.phase == ApplePhase.appearing
        ? math.sin(apple.bounceProgress * math.pi) * 8
        : 0.0;
    final wobble = apple.phase == ApplePhase.wobble
        ? math.sin(apple.wobblePhase) * 6
        : 0.0;
    final alpha = apple.phase == ApplePhase.fading
        ? (1 - apple.fadeProgress).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: apple.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alpha,
        child: Transform.translate(
          offset: Offset(wobble, -bounce),
          child: SizedBox(
            width: touch,
            height: touch,
            child: CustomPaint(
              painter: _ApplePainter(wasTapped: apple.wasTapped),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplePainter extends CustomPainter {
  _ApplePainter({required this.wasTapped});

  final bool wasTapped;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;
    final base = wasTapped ? const Color(0xFFC62828) : const Color(0xFFE53935);

    // Apple body: two soft lobes with a dimple at the top.
    final body = Path()
      ..moveTo(cx, cy - 14)
      ..cubicTo(cx - 8, cy - 22, cx - 30, cy - 18, cx - 28, cy + 4)
      ..cubicTo(cx - 27, cy + 24, cx - 12, cy + 32, cx, cy + 26)
      ..cubicTo(cx + 12, cy + 32, cx + 27, cy + 24, cx + 28, cy + 4)
      ..cubicTo(cx + 30, cy - 18, cx + 8, cy - 22, cx, cy - 14)
      ..close();
    final r = Rect.fromCenter(center: Offset(cx, cy + 4), width: 58, height: 52);
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.5),
          radius: 1.0,
          colors: [const Color(0xFFFF6B6B), base, const Color(0xFFB71C1C)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(r),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF8E1B1B).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Gloss
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 13, cy - 6), width: 11, height: 18),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    // Stem
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 14)
        ..quadraticBezierTo(cx + 1, cy - 24, cx + 5, cy - 28),
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );
    // Two leaves
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(cx + 4, cy - 24);
      canvas.rotate(dir * 0.7 - 0.2);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(dir * 8, -10, dir * 19, -6)
        ..quadraticBezierTo(dir * 10, 4, 0, 0)
        ..close();
      canvas.drawPath(leaf, Paint()..color = const Color(0xFF66BB47));
      canvas.drawLine(
        Offset.zero,
        Offset(dir * 15, -5),
        Paint()
          ..color = const Color(0xFF2E7D32).withValues(alpha: 0.6)
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ApplePainter old) => old.wasTapped != wasTapped;
}
