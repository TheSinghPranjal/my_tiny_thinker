import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';

class FlowerWidget extends StatelessWidget {
  const FlowerWidget({
    super.key,
    required this.flower,
    required this.size,
    required this.onTap,
    required this.canTap,
  });

  final FlowerEntity flower;
  final double size;
  final VoidCallback onTap;
  final bool canTap;

  @override
  Widget build(BuildContext context) {
    final breathe = 1.0 + math.sin(flower.breathePhase) * 0.03;
    final blink = (flower.blinkTimer % 4.5) < 0.12;
    final palette =
        kBloomPalettes[flower.paletteIndex % kBloomPalettes.length];

    return Opacity(
      opacity: flower.opacity.clamp(0.0, 1.0),
      child: GestureDetector(
        onTap: canTap ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _FlowerPainter(
              bloomProgress: flower.bloomProgress,
              petalCount: flower.petalCount,
              petalSpread: flower.petalSpread,
              palette: palette,
              blink: blink,
              breathe: breathe,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  _FlowerPainter({
    required this.bloomProgress,
    required this.petalCount,
    required this.petalSpread,
    required this.palette,
    required this.blink,
    required this.breathe,
  });

  final double bloomProgress;
  final int petalCount;
  final double petalSpread;
  final BloomPalette palette;
  final bool blink;
  final double breathe;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(breathe);

    // Stem + leaves (bud or bloom)
    _drawStem(canvas, size);
    _drawLeaves(canvas, size);

    if (bloomProgress <= 0.02) {
      _drawBud(canvas, size);
    } else {
      _drawBloom(canvas, size);
    }

    _drawFace(canvas, size);
    canvas.restore();
  }

  void _drawStem(Canvas canvas, Size size) {
    final stemH = size.height * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, size.height * 0.18),
          width: size.width * 0.06,
          height: stemH,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF388E3C),
    );
  }

  void _drawLeaves(Canvas canvas, Size size) {
    for (final sign in [-1.0, 1.0]) {
      final leaf = Path()
        ..moveTo(0, size.height * 0.08)
        ..quadraticBezierTo(
          sign * size.width * 0.18,
          size.height * 0.12,
          sign * size.width * 0.22,
          size.height * 0.02,
        )
        ..quadraticBezierTo(
          sign * size.width * 0.12,
          size.height * 0.06,
          0,
          size.height * 0.08,
        );
      canvas.drawPath(leaf, Paint()..color = const Color(0xFF43A047));
    }
  }

  void _drawBud(Canvas canvas, Size size) {
    final r = size.width * 0.22;
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      r,
      Paint()..color = const Color(0xFF66BB6A),
    );
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      r * 0.88,
      Paint()..color = const Color(0xFF81C784),
    );
    // Bud tip petals folded
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final petal = Path()
        ..moveTo(0, -size.height * 0.02)
        ..quadraticBezierTo(
          math.cos(angle) * r * 0.5,
          -size.height * 0.02 + math.sin(angle) * r * 0.5 - r * 0.3,
          math.cos(angle) * r * 0.25,
          -size.height * 0.02 + math.sin(angle) * r * 0.25,
        );
      canvas.drawPath(
        petal,
        Paint()
          ..color = const Color(0xFFA5D6A7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _drawBloom(Canvas canvas, Size size) {
    final open = Curves.easeOutCubic.transform(bloomProgress);
    final radius = size.width * 0.24 * (0.4 + open * 0.85) * petalSpread;

    for (var i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi * i / petalCount) - math.pi / 2;
      final color = palette.petals[i % palette.petals.length];
      canvas.save();
      canvas.rotate(angle);
      final petalRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -radius * open),
          width: radius * 0.95,
          height: radius * 1.35,
        ),
        Radius.circular(radius),
      );
      canvas.drawRRect(
        petalRect,
        Paint()..color = color.withValues(alpha: 0.85 + open * 0.15),
      );
      canvas.restore();
    }

    // Glow center
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      radius * 0.55 * open,
      Paint()
        ..color = palette.glow.withValues(alpha: 0.2 * open)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Nectar center
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      radius * 0.35 * open,
      Paint()..color = palette.center,
    );

    // Nectar tentacles
    if (open > 0.5) {
      for (var i = 0; i < 6; i++) {
        final a = i * math.pi / 3 + bloomProgress;
        canvas.drawLine(
          Offset(0, -size.height * 0.02),
          Offset(math.cos(a) * radius * 0.45, -size.height * 0.02 + math.sin(a) * radius * 0.45),
          Paint()
            ..color = palette.center.withValues(alpha: 0.8)
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  void _drawFace(Canvas canvas, Size size) {
    final faceY = -size.height * 0.02;
    final eyeY = faceY - size.height * 0.03;
    final eyeOffset = size.width * 0.07;

    // Cheeks
    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * size.width * 0.11, faceY + size.height * 0.015),
        size.width * 0.035,
        Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.55),
      );
    }

    // Eyes
    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * eyeOffset, eyeY),
        size.width * 0.035,
        Paint()..color = Colors.white,
      );
      if (!blink) {
        canvas.drawCircle(
          Offset(sign * eyeOffset + 2, eyeY),
          size.width * 0.018,
          Paint()..color = Colors.black87,
        );
        canvas.drawCircle(
          Offset(sign * eyeOffset + 4, eyeY - 3),
          size.width * 0.008,
          Paint()..color = Colors.white,
        );
      } else {
        canvas.drawLine(
          Offset(sign * eyeOffset - 8, eyeY),
          Offset(sign * eyeOffset + 8, eyeY),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2,
        );
      }
    }

    // Smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(0, faceY + size.height * 0.02),
        width: size.width * 0.12,
        height: size.height * 0.06,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_FlowerPainter old) =>
      old.bloomProgress != bloomProgress ||
      old.blink != blink ||
      old.breathe != breathe ||
      old.palette != palette;
}
