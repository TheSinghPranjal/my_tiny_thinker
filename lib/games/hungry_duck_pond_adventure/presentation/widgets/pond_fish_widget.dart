import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

class PondFishWidget extends StatelessWidget {
  const PondFishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.largerTouch = false,
  });

  final PondFishEntity fish;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (fish.phase == FishPhase.gone) return const SizedBox.shrink();

    final def = PondFishVarieties.byIndex(fish.varietyIndex, isGolden: fish.isGolden);
    final touch = (largerTouch ? 72.0 : 64.0) * def.lengthScale;
    final alpha = fish.phase == FishPhase.sinking ? (1 - fish.sinkProgress).clamp(0.0, 1.0) : 1.0;
    final selected = fish.phase == FishPhase.selected;

    return GestureDetector(
      onTap: fish.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alpha,
        child: SizedBox(
          width: touch + 16,
          height: touch * 0.72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (fish.isGolden || fish.glow > 0)
                Container(
                  width: touch,
                  height: touch * 0.62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(fish.isGolden ? 0xFFFFD54F : 0xFFFFF176)
                            .withValues(alpha: (fish.glow * 0.6).clamp(0.2, 0.8)),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              Transform.scale(
                scaleX: fish.facingRight ? 1 : -1,
                child: CustomPaint(
                  size: Size(touch, touch * 0.58),
                  painter: _FishPainter(
                    def: def,
                    wiggle: fish.pathT,
                    selected: selected,
                    depth: fish.depth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter({
    required this.def,
    required this.wiggle,
    required this.selected,
    required this.depth,
  });

  final PondFishDef def;
  final double wiggle;
  final bool selected;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Color(def.bodyColor);
    final fin = Color(def.finColor);
    final wobble = math.sin(wiggle * 3) * 2;
    final cx = size.width / 2;
    final cy = size.height / 2 + wobble;
    final bodyW = size.width * 0.62;
    final bodyH = size.height * 0.42;
    final depthShade = 1.0 - depth * 0.18;

    canvas.save();
    canvas.translate(cx, cy);

    // Caudal (tail) fin
    final tailWave = math.sin(wiggle * 4) * 0.08;
    final tail = Path()
      ..moveTo(-bodyW * 0.46, 0)
      ..lineTo(-bodyW * 0.88, -bodyH * 0.72 + tailWave * bodyH)
      ..lineTo(-bodyW * 0.72, 0)
      ..lineTo(-bodyW * 0.88, bodyH * 0.72 - tailWave * bodyH)
      ..close();
    canvas.drawPath(tail, Paint()..color = fin.withValues(alpha: depthShade));

    // Body
    final bodyCenter = Offset(bodyW * 0.04, 0);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyCenter, width: bodyW, height: bodyH),
      Radius.circular(bodyH),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            body.withValues(alpha: depthShade),
            Color.lerp(body, Colors.black, 0.18)!,
          ],
        ).createShader(bodyRect.outerRect),
    );

    _drawScales(canvas, bodyCenter, bodyW, bodyH);
    _drawPattern(canvas, bodyCenter, bodyW, bodyH, fin);

    // Dorsal fin
    final dorsal = Path()
      ..moveTo(-bodyW * 0.08, -bodyH * 0.42)
      ..lineTo(bodyW * 0.06, -bodyH * 0.92)
      ..lineTo(bodyW * 0.2, -bodyH * 0.38)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = fin.withValues(alpha: 0.92 * depthShade));

    // Pectoral fins
    for (final sign in [-1.0, 1.0]) {
      final pectoralWave = math.sin(wiggle * 5 + sign) * 0.12;
      final pFin = Path()
        ..moveTo(bodyW * 0.02, sign * bodyH * 0.1)
        ..lineTo(-bodyW * 0.1, sign * bodyH * 0.58 + pectoralWave * bodyH)
        ..lineTo(bodyW * 0.14, sign * bodyH * 0.24)
        ..close();
      canvas.drawPath(pFin, Paint()..color = fin.withValues(alpha: 0.85 * depthShade));
    }

    // Anal fin
    final anal = Path()
      ..moveTo(-bodyW * 0.12, bodyH * 0.28)
      ..lineTo(-bodyW * 0.28, bodyH * 0.55)
      ..lineTo(bodyW * 0.02, bodyH * 0.34)
      ..close();
    canvas.drawPath(anal, Paint()..color = fin.withValues(alpha: 0.75 * depthShade));

    // Belly highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(bodyCenter.dx, bodyCenter.dy + bodyH * 0.14),
          width: bodyW * 0.72,
          height: bodyH * 0.42,
        ),
        Radius.circular(bodyH * 0.35),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );

    // Eye
    final eyeCenter = Offset(bodyW * 0.28, -bodyH * 0.12);
    final eyeR = bodyH * 0.16;
    canvas.drawCircle(eyeCenter, eyeR, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.12, eyeCenter.dy),
      eyeR * 0.58,
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.28, eyeCenter.dy - eyeR * 0.22),
      eyeR * 0.2,
      Paint()..color = Colors.white,
    );

    if (selected) {
      canvas.drawCircle(
        bodyCenter,
        bodyW * 0.55,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.restore();
  }

  void _drawScales(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final scalePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        final ox = center.dx - bodyW * 0.18 + col * bodyW * 0.16;
        final oy = center.dy - bodyH * 0.18 + row * bodyH * 0.22;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(ox, oy),
            width: bodyW * 0.11,
            height: bodyH * 0.16,
          ),
          math.pi * 0.2,
          math.pi * 0.6,
          false,
          scalePaint,
        );
      }
    }
  }

  void _drawPattern(Canvas canvas, Offset center, double bodyW, double bodyH, Color fin) {
    switch (def.pattern) {
      case PondFishPattern.striped:
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(center.dx - bodyW * 0.12 + i * bodyW * 0.16, center.dy - bodyH * 0.36),
            Offset(center.dx - bodyW * 0.12 + i * bodyW * 0.16, center.dy + bodyH * 0.36),
            Paint()
              ..color = fin.withValues(alpha: 0.35)
              ..strokeWidth = 2,
          );
        }
      case PondFishPattern.spotted:
        for (final offset in [
          Offset(bodyW * 0.04, -bodyH * 0.12),
          Offset(bodyW * 0.16, bodyH * 0.04),
          Offset(-bodyW * 0.04, bodyH * 0.12),
        ]) {
          canvas.drawCircle(
            center + offset,
            bodyH * 0.09,
            Paint()..color = Color(def.spotColor).withValues(alpha: 0.55),
          );
        }
      case PondFishPattern.rainbow:
        const colors = [
          Color(0xFFFF7043),
          Color(0xFFFFCA28),
          Color(0xFF66BB6A),
          Color(0xFF42A5F5),
        ];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: center, width: bodyW * 0.88, height: bodyH * 1.05),
            math.pi * 0.55 + i * 0.08,
            0.12,
            false,
            Paint()
              ..color = colors[i].withValues(alpha: 0.42)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5,
          );
        }
      case PondFishPattern.tropical:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx + bodyW * 0.08, center.dy - bodyH * 0.2)
            ..lineTo(center.dx + bodyW * 0.22, center.dy)
            ..lineTo(center.dx + bodyW * 0.08, center.dy + bodyH * 0.2),
          Paint()
            ..color = fin.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      case PondFishPattern.solid:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _FishPainter old) =>
      old.def != def ||
      old.wiggle != wiggle ||
      old.selected != selected ||
      old.depth != depth;
}
