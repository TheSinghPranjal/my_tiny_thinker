import 'dart:math' as math;

import 'package:flutter/material.dart';

class MagicalWebWidget extends StatelessWidget {
  const MagicalWebWidget({
    super.key,
    required this.opacity,
    required this.size,
    this.phase = 0,
  });

  final double opacity;
  final double size;
  final double phase;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.01) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: CustomPaint(
        size: Size(size, size * 0.7),
        painter: _WebPainter(phase: phase),
      ),
    );
  }
}

class _WebPainter extends CustomPainter {
  _WebPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.35);
    final glow = Paint()
      ..color = const Color(0xFFE1BEE7).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: size.width * 0.9, height: size.height * 0.7),
      glow,
    );

    final silk = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final sparkle = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(phase * 3));
    final accent = Paint()
      ..color = const Color(0xFFF8BBD0).withValues(alpha: 0.5 * sparkle)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Radial threads.
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final end = Offset(
        c.dx + math.cos(a) * size.width * 0.42,
        c.dy + math.sin(a) * size.height * 0.38,
      );
      canvas.drawLine(c, end, silk);
    }

    // Concentric ovals.
    for (var r = 1; r <= 3; r++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: size.width * 0.18 * r,
          height: size.height * 0.14 * r,
        ),
        r == 2 ? accent : silk,
      );
    }

    // Tiny dew sparkles.
    for (var i = 0; i < 6; i++) {
      final a = phase + i * 1.1;
      final p = Offset(
        c.dx + math.cos(a) * size.width * 0.28,
        c.dy + math.sin(a * 1.3) * size.height * 0.22,
      );
      canvas.drawCircle(
        p,
        1.8,
        Paint()..color = Colors.white.withValues(alpha: 0.7 * sparkle),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WebPainter old) => old.phase != phase;
}
