import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';

class BushWidget extends StatelessWidget {
  const BushWidget({
    super.key,
    required this.bush,
    required this.onTap,
    this.highContrast = false,
  });

  final BushEntity bush;
  final VoidCallback onTap;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(bush.swayPhase) * 4;
    final shake = bush.visualPhase == BushVisualPhase.shaking ||
            bush.visualPhase == BushVisualPhase.hintShaking
        ? math.sin(bush.shakePhase * 6) * 8 * bush.shakeIntensity
        : 0.0;
    final bounce = bush.bounceProgress > 0
        ? math.sin(bush.bounceProgress * math.pi) * 14
        : 0.0;

    return GestureDetector(
      onTap: bush.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(sway + shake, -bounce),
        child: CustomPaint(
          size: Size(bush.width, bush.height),
          painter: _BushPainter(
            bush: bush,
            color: bushColorForIndex(bush.colorIndex),
            highContrast: highContrast,
          ),
        ),
      ),
    );
  }
}

class _BushPainter extends CustomPainter {
  _BushPainter({
    required this.bush,
    required this.color,
    required this.highContrast,
  });

  final BushEntity bush;
  final Color color;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final open = bush.openProgress.clamp(0.0, 1.0);
    final split = open * size.width * 0.18;

    final dark = highContrast ? color.withValues(alpha: 1) : Color.lerp(color, Colors.black, 0.15)!;
    final light = highContrast ? color : Color.lerp(color, Colors.white, 0.2)!;

    _drawPuff(canvas, Offset(cx - split, cy), size.width * 0.42, dark, light);
    _drawPuff(canvas, Offset(cx + split, cy), size.width * 0.42, dark, light);
    _drawPuff(canvas, Offset(cx, cy - size.height * 0.08), size.width * 0.36, light, dark);

    final trunk = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.88),
          width: size.width * 0.12,
          height: size.height * 0.22,
        ),
        const Radius.circular(8),
      ),
      trunk,
    );

    if (open > 0.1) {
      final gapPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + size.height * 0.05),
          width: size.width * 0.22 * open,
          height: size.height * 0.18 * open,
        ),
        gapPaint,
      );
    }
  }

  void _drawPuff(Canvas canvas, Offset c, double r, Color c1, Color c2) {
    canvas.drawCircle(c, r * 0.55, Paint()..color = c1);
    canvas.drawCircle(Offset(c.dx - r * 0.35, c.dy + r * 0.05), r * 0.42, Paint()..color = c2);
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy + r * 0.05), r * 0.42, Paint()..color = c2);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.25), r * 0.38, Paint()..color = c1.withValues(alpha: 0.95));
  }

  @override
  bool shouldRepaint(covariant _BushPainter oldDelegate) =>
      oldDelegate.bush != bush || oldDelegate.highContrast != highContrast;
}
