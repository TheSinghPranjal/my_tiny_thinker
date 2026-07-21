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

  BloomPalette _resolvedPalette() {
    final current =
        kBloomPalettes[flower.paletteIndex % kBloomPalettes.length];
    final targetIdx = flower.morphPaletteIndex;
    if (targetIdx == null || flower.colorMorph <= 0) return current;
    final target = kBloomPalettes[targetIdx % kBloomPalettes.length];
    final t = Curves.easeInOut.transform(flower.colorMorph.clamp(0.0, 1.0));
    return BloomPalette(
      name: target.name,
      petals: List.generate(
        math.max(current.petals.length, target.petals.length),
        (i) => Color.lerp(
          current.petals[i % current.petals.length],
          target.petals[i % target.petals.length],
          t,
        )!,
      ),
      center: Color.lerp(current.center, target.center, t)!,
      glow: Color.lerp(current.glow, target.glow, t)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final breathe = 1.0 + math.sin(flower.breathePhase) * 0.04;
    final blink = (flower.blinkTimer % 4.5) < 0.12;
    final palette = _resolvedPalette();
    final pulse = flower.phase == FlowerPhase.bud
        ? 1.0 + math.sin(flower.breathePhase * 1.4) * 0.05
        : 1.0;

    return Opacity(
      opacity: flower.opacity.clamp(0.0, 1.0),
      child: GestureDetector(
        onTap: canTap ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Transform.scale(
          scale: pulse,
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
                morphing: flower.morphPaletteIndex != null,
              ),
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
    required this.morphing,
  });

  final double bloomProgress;
  final int petalCount;
  final double petalSpread;
  final BloomPalette palette;
  final bool blink;
  final double breathe;
  final bool morphing;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(breathe);

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
          width: size.width * 0.07,
          height: stemH,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF43A047),
    );
  }

  void _drawLeaves(Canvas canvas, Size size) {
    for (final sign in [-1.0, 1.0]) {
      final leaf = Path()
        ..moveTo(0, size.height * 0.08)
        ..quadraticBezierTo(
          sign * size.width * 0.2,
          size.height * 0.14,
          sign * size.width * 0.26,
          size.height * 0.02,
        )
        ..quadraticBezierTo(
          sign * size.width * 0.14,
          size.height * 0.07,
          0,
          size.height * 0.08,
        );
      canvas.drawPath(leaf, Paint()..color = const Color(0xFF66BB6A));
      canvas.drawPath(
        leaf,
        Paint()
          ..color = const Color(0xFF2E7D32).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawBud(Canvas canvas, Size size) {
    final r = size.width * 0.24;
    // Soft glow so toddlers notice the bud
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      r * 1.25,
      Paint()
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      r,
      Paint()..color = const Color(0xFF81C784),
    );
    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      r * 0.82,
      Paint()..color = const Color(0xFFA5D6A7),
    );
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            math.cos(angle) * r * 0.35,
            -size.height * 0.02 + math.sin(angle) * r * 0.35,
          ),
          width: r * 0.55,
          height: r * 0.7,
        ),
        Paint()..color = const Color(0xFFC8E6C9).withValues(alpha: 0.85),
      );
    }
  }

  void _drawBloom(Canvas canvas, Size size) {
    final open = Curves.easeOutCubic.transform(bloomProgress);
    final radius = size.width * 0.26 * (0.4 + open * 0.9) * petalSpread;

    if (morphing) {
      canvas.drawCircle(
        Offset(0, -size.height * 0.02),
        radius * 1.35,
        Paint()
          ..color = palette.glow.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    for (var i = 0; i < petalCount; i++) {
      final angle = (2 * math.pi * i / petalCount) - math.pi / 2;
      final color = palette.petals[i % palette.petals.length];
      canvas.save();
      canvas.rotate(angle);
      final petalRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -radius * open),
          width: radius * 1.05,
          height: radius * 1.4,
        ),
        Radius.circular(radius),
      );
      canvas.drawRRect(
        petalRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.lerp(color, Colors.white, 0.35)!,
              color,
              Color.lerp(color, Colors.black, 0.08)!,
            ],
          ).createShader(petalRect.outerRect),
      );
      canvas.restore();
    }

    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      radius * 0.58 * open,
      Paint()
        ..color = palette.glow.withValues(alpha: 0.25 * open)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawCircle(
      Offset(0, -size.height * 0.02),
      radius * 0.38 * open,
      Paint()..color = palette.center,
    );
    canvas.drawCircle(
      Offset(0, -size.height * 0.04),
      radius * 0.14 * open,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    if (open > 0.5) {
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 + bloomProgress;
        canvas.drawCircle(
          Offset(
            math.cos(a) * radius * 0.42,
            -size.height * 0.02 + math.sin(a) * radius * 0.42,
          ),
          2.5,
          Paint()..color = palette.center.withValues(alpha: 0.9),
        );
      }
    }
  }

  void _drawFace(Canvas canvas, Size size) {
    final faceY = -size.height * 0.02;
    final eyeY = faceY - size.height * 0.03;
    final eyeOffset = size.width * 0.075;

    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * size.width * 0.12, faceY + size.height * 0.018),
        size.width * 0.04,
        Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.6),
      );
    }

    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * eyeOffset, eyeY),
        size.width * 0.038,
        Paint()..color = Colors.white,
      );
      if (!blink) {
        canvas.drawCircle(
          Offset(sign * eyeOffset + 2, eyeY),
          size.width * 0.02,
          Paint()..color = Colors.black87,
        );
        canvas.drawCircle(
          Offset(sign * eyeOffset + 4, eyeY - 3),
          size.width * 0.009,
          Paint()..color = Colors.white,
        );
      } else {
        canvas.drawLine(
          Offset(sign * eyeOffset - 8, eyeY),
          Offset(sign * eyeOffset + 8, eyeY),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2.5,
        );
      }
    }

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(0, faceY + size.height * 0.025),
        width: size.width * 0.14,
        height: size.height * 0.07,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FlowerPainter old) =>
      old.bloomProgress != bloomProgress ||
      old.blink != blink ||
      old.breathe != breathe ||
      old.palette != palette ||
      old.morphing != morphing;
}
