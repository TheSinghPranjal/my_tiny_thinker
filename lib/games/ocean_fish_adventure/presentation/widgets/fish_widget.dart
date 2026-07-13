import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';

class FishWidget extends StatelessWidget {
  const FishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.highContrast = false,
  });

  final FishEntity fish;
  final VoidCallback onTap;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final variant = kFishVariants[fish.variantIndex % kFishVariants.length];
    final touchSize = fish.size * 1.35;
    final canTap =
        fish.phase == FishPhase.waiting || fish.phase == FishPhase.entering;

    return Positioned(
      left: fish.x - touchSize / 2,
      top: fish.y - touchSize / 2,
      width: touchSize,
      height: touchSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canTap ? onTap : null,
        child: Transform.rotate(
          angle: fish.rotation,
          child: Transform.scale(
            scale: 1.0 + fish.wiggle,
            child: CustomPaint(
              size: Size(touchSize, touchSize),
              painter: _FishPainter(
                variant: variant,
                highContrast: highContrast,
                happy: fish.phase == FishPhase.tapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter({
    required this.variant,
    required this.highContrast,
    required this.happy,
  });

  final FishVariant variant;
  final bool highContrast;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bodyW = size.width * 0.58;
    final bodyH = size.height * 0.36;

    // Caudal (tail) fin
    final tail = Path()
      ..moveTo(cx - bodyW * 0.48, cy)
      ..lineTo(cx - bodyW * 0.92, cy - bodyH * 0.75)
      ..lineTo(cx - bodyW * 0.78, cy)
      ..lineTo(cx - bodyW * 0.92, cy + bodyH * 0.75)
      ..close();
    canvas.drawPath(tail, Paint()..color = variant.finColor);

    // Body
    final bodyCenter = Offset(cx + bodyW * 0.04, cy);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyCenter, width: bodyW, height: bodyH),
      Radius.circular(bodyH),
    );
    canvas.drawRRect(bodyRect, Paint()..color = variant.bodyColor);

    // Scales
    _drawScales(canvas, bodyCenter, bodyW, bodyH);

    // Pattern overlay
    _drawPattern(canvas, bodyCenter, bodyW, bodyH);

    // Dorsal fin
    final dorsal = Path()
      ..moveTo(cx - bodyW * 0.05, cy - bodyH * 0.42)
      ..lineTo(cx + bodyW * 0.08, cy - bodyH * 0.85)
      ..lineTo(cx + bodyW * 0.22, cy - bodyH * 0.38)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = variant.finColor.withValues(alpha: 0.9));

    // Pectoral fins
    for (final sign in [-1.0, 1.0]) {
      final fin = Path()
        ..moveTo(cx + bodyW * 0.02, cy + sign * bodyH * 0.08)
        ..lineTo(cx - bodyW * 0.08, cy + sign * bodyH * 0.55)
        ..lineTo(cx + bodyW * 0.12, cy + sign * bodyH * 0.22)
        ..close();
      canvas.drawPath(
        fin,
        Paint()..color = variant.finColor.withValues(alpha: 0.85),
      );
    }

    // Belly highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bodyCenter.dx, bodyCenter.dy + bodyH * 0.12),
          width: bodyW * 0.75,
          height: bodyH * 0.45,
        ),
        Radius.circular(bodyH * 0.4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Eye
    final eyeCenter = Offset(cx + bodyW * 0.28, cy - bodyH * 0.1);
    final eyeR = bodyH * 0.14;
    canvas.drawCircle(
      eyeCenter,
      eyeR,
      Paint()..color = highContrast ? Colors.white : const Color(0xFFF5F5F5),
    );
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.15, eyeCenter.dy),
      eyeR * 0.55,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.35, eyeCenter.dy - eyeR * 0.25),
      eyeR * 0.18,
      Paint()..color = Colors.white,
    );

    // Mouth / smile
    if (happy) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + bodyW * 0.18, cy + bodyH * 0.18),
          width: bodyW * 0.28,
          height: bodyH * 0.28,
        ),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + bodyW * 0.2, cy + bodyH * 0.12),
          width: bodyW * 0.12,
          height: bodyH * 0.1,
        ),
        0,
        math.pi,
        false,
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawScales(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final scalePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        final ox = center.dx - bodyW * 0.22 + col * bodyW * 0.14;
        final oy = center.dy - bodyH * 0.22 + row * bodyH * 0.2;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(ox, oy),
            width: bodyW * 0.12,
            height: bodyH * 0.18,
          ),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          scalePaint,
        );
      }
    }
  }

  void _drawPattern(Canvas canvas, Offset center, double bodyW, double bodyH) {
    switch (variant.pattern) {
      case 'stripes':
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(center.dx - bodyW * 0.15 + i * bodyW * 0.18, center.dy - bodyH * 0.38),
            Offset(center.dx - bodyW * 0.15 + i * bodyW * 0.18, center.dy + bodyH * 0.38),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.3)
              ..strokeWidth = 2.5,
          );
        }
      case 'spots':
        for (final offset in [
          Offset(bodyW * 0.05, -bodyH * 0.15),
          Offset(bodyW * 0.18, bodyH * 0.05),
          Offset(-bodyW * 0.05, bodyH * 0.1),
        ]) {
          canvas.drawCircle(
            center + offset,
            bodyH * 0.1,
            Paint()..color = Colors.white.withValues(alpha: 0.35),
          );
        }
      case 'rainbow':
        final colors = [
          const Color(0xFFFF7043),
          const Color(0xFFFFCA28),
          const Color(0xFF66BB6A),
          const Color(0xFF42A5F5),
        ];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(
              center: center,
              width: bodyW * 0.9,
              height: bodyH * 1.1,
            ),
            math.pi * 0.55 + i * 0.08,
            0.12,
            false,
            Paint()
              ..color = colors[i].withValues(alpha: 0.45)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(_FishPainter old) =>
      old.happy != happy || old.variant != variant || old.highContrast != highContrast;
}
