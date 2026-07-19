import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.size = 80,
    this.waving = true,
  });

  final double size;
  final bool waving;

  @override
  Widget build(BuildContext context) {
    final mascot = CustomPaint(
      size: Size(size, size),
      painter: _MascotPainter(waving: waving),
    );
    return waving
        ? FloatingAnimation(amplitude: 6, child: mascot)
        : mascot;
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({required this.waving});

  final bool waving;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Body shadow
    canvas.drawCircle(
      center.translate(2, 4),
      radius,
      Paint()..color = AppColors.skyBlueDark.withValues(alpha: 0.3),
    );

    // Body gradient
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.sunYellowLight, AppColors.sunYellow],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    // Cheeks
    final cheekPaint = Paint()..color = AppColors.candyPink.withValues(alpha: 0.5);
    canvas.drawCircle(
      center.translate(-radius * 0.45, radius * 0.15),
      radius * 0.15,
      cheekPaint,
    );
    canvas.drawCircle(
      center.translate(radius * 0.45, radius * 0.15),
      radius * 0.15,
      cheekPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(center.translate(-radius * 0.3, -radius * 0.1), radius * 0.12, eyePaint);
    canvas.drawCircle(center.translate(radius * 0.3, -radius * 0.1), radius * 0.12, eyePaint);

    // Eye shine
    final shinePaint = Paint()..color = AppColors.white;
    canvas.drawCircle(center.translate(-radius * 0.25, -radius * 0.15), radius * 0.04, shinePaint);
    canvas.drawCircle(center.translate(radius * 0.35, -radius * 0.15), radius * 0.04, shinePaint);

    // Smile
    final smilePath = Path()
      ..addArc(
        Rect.fromCenter(
          center: center.translate(0, radius * 0.15),
          width: radius * 0.6,
          height: radius * 0.35,
        ),
        0.1,
        math.pi - 0.2,
      );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Waving arm
    if (waving) {
      final armPaint = Paint()
        ..color = AppColors.sunYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.18
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center.translate(radius * 0.5, radius * 0.1),
        center.translate(radius * 0.85, -radius * 0.4),
        armPaint,
      );
      canvas.drawCircle(
        center.translate(radius * 0.85, -radius * 0.4),
        radius * 0.1,
        Paint()..color = AppColors.sunYellow,
      );
    }
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) =>
      oldDelegate.waving != waving;
}
