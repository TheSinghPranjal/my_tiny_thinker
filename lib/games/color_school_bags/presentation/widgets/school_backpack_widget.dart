import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';

class SchoolBackpackWidget extends StatelessWidget {
  const SchoolBackpackWidget({
    super.key,
    required this.backpack,
    this.size = 130,
    this.hovering = false,
  });

  final SortBackpack backpack;
  final double size;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    final breath = 1 + math.sin(backpack.breathPhase) * 0.03;
    final bounce = math.sin(backpack.breathPhase * 0.6) * 3 +
        (backpack.smiling ? math.sin(backpack.breathPhase * 8) * 6 : 0);
    final pulse = backpack.hintPulse
        ? 1 + math.sin(backpack.breathPhase * 5) * 0.08
        : 1.0;

    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.scale(
        scale: breath * pulse * (hovering ? 1.06 : 1),
        child: CustomPaint(
          size: Size(size, size * 1.15),
          painter: _BackpackPainter(
            backpack: backpack,
            hovering: hovering,
          ),
        ),
      ),
    );
  }
}

class _BackpackPainter extends CustomPainter {
  _BackpackPainter({required this.backpack, required this.hovering});
  final SortBackpack backpack;
  final bool hovering;

  @override
  void paint(Canvas canvas, Size size) {
    final def = backpack.colorDef;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.76,
        size.height * 0.72,
      ),
      const Radius.circular(28),
    );

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.95),
        width: size.width * 0.55,
        height: 12,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    if (backpack.glow || hovering || backpack.hintPulse) {
      canvas.drawRRect(
        body.inflate(8),
        Paint()
          ..color = (backpack.hintPulse
                  ? def.color
                  : const Color(0xFFFFD54F))
              .withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Straps
    final strap = Paint()
      ..color = def.color.withValues(alpha: 0.75)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.02, size.width * 0.28, size.height * 0.28),
      math.pi * 0.9,
      math.pi * 0.9,
      false,
      strap,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.54, size.height * 0.02, size.width * 0.28, size.height * 0.28),
      math.pi * 0.2,
      math.pi * 0.9,
      false,
      strap,
    );

    // Body
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [def.accent, def.color, def.color.withValues(alpha: 0.9)],
        ).createShader(Offset.zero & size),
    );

    // Side pockets
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.02, size.height * 0.45, size.width * 0.14, size.height * 0.28),
        const Radius.circular(10),
      ),
      Paint()..color = def.color.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.84, size.height * 0.45, size.width * 0.14, size.height * 0.28),
        const Radius.circular(10),
      ),
      Paint()..color = def.color.withValues(alpha: 0.85),
    );

    // Front pocket
    final pocket = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * (backpack.open ? 0.52 : 0.48),
        size.width * 0.56,
        size.height * 0.32,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      pocket,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawRRect(
      pocket,
      Paint()
        ..color = def.color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Zipper
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.48),
      Offset(size.width * 0.72, size.height * 0.48),
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.72, size.height * 0.48),
          width: 14,
          height: 10,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFC107),
    );

    // Gloss highlight
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.24, size.width * 0.28, size.height * 0.12),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // Outline for white/light bags
    if (backpack.colorKind == BagColorKind.white ||
        backpack.colorKind == BagColorKind.silver ||
        backpack.colorKind == BagColorKind.grey) {
      canvas.drawRRect(
        body,
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Happy face after match
    if (backpack.smiling || backpack.filled) {
      final faceY = size.height * 0.62;
      final eyePaint = Paint()..color = const Color(0xFF3E2723);
      canvas.drawCircle(Offset(size.width * 0.38, faceY), 4, eyePaint);
      canvas.drawCircle(Offset(size.width * 0.62, faceY), 4, eyePaint);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, faceY + 8),
          width: 22,
          height: 14,
        ),
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..color = const Color(0xFF3E2723)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackpackPainter old) =>
      old.backpack != backpack || old.hovering != hovering;
}
