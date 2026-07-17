import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

class SchoolBookWidget extends StatelessWidget {
  const SchoolBookWidget({
    super.key,
    required this.book,
    this.size = 120,
    this.glow = false,
  });

  final SortBook book;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(book.floatPhase) * 4;
    final bob = math.cos(book.floatPhase * 1.1) * 5;
    final shake = book.shake ? math.sin(book.floatPhase * 14) * 10 : 0.0;

    return Transform.translate(
      offset: Offset(sway + shake, bob),
      child: Transform.rotate(
        angle: math.sin(book.floatPhase * 0.7) * 0.05,
        child: CustomPaint(
          size: Size(size * 0.78, size),
          painter: _BookPainter(
            colorDef: book.colorDef,
            glow: glow,
          ),
        ),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  _BookPainter({required this.colorDef, required this.glow});
  final BagColorDef colorDef;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, 4, size.width * 0.84, size.height - 8),
      const Radius.circular(14),
    );

    if (glow) {
      canvas.drawRRect(
        cover.inflate(6),
        Paint()
          ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Pages peek
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, 10, size.width * 0.72, size.height - 18),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.white,
    );

    canvas.drawRRect(
      cover,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorDef.accent, colorDef.color],
        ).createShader(Offset.zero & size),
    );

    // Spine
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, 4, size.width * 0.16, size.height - 8),
        const Radius.circular(10),
      ),
      Paint()..color = colorDef.color.withValues(alpha: 0.85),
    );

    // Gloss
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, 12, size.width * 0.35, size.height * 0.18),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Border for light colors
    canvas.drawRRect(
      cover,
      Paint()
        ..color = colorDef.color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Tiny star sparkle
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _BookPainter old) =>
      old.colorDef != colorDef || old.glow != glow;
}
