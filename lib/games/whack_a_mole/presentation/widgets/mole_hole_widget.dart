import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/presentation/widgets/mole_widget.dart';

class MoleHoleWidget extends StatelessWidget {
  const MoleHoleWidget({
    super.key,
    required this.hole,
    this.mole,
    required this.onTap,
    this.largerTouch = true,
  });

  final MoleHoleEntity hole;
  final MoleEntity? mole;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = hole.radius * 2.4 * (largerTouch ? 1.08 : 1.0);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size, size * 0.75),
              painter: _HolePainter(hole: hole),
            ),
            if (mole != null && mole!.isActive)
              Positioned(
                bottom: size * 0.22,
                child: MoleWidget(
                  mole: mole!,
                  size: size * 0.72,
                ),
              ),
            // Hole rim overlay so mole clips visually into the hole
            IgnorePointer(
              child: CustomPaint(
                size: Size(size, size * 0.75),
                painter: _HoleRimPainter(hole: hole),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter({required this.hole});

  final MoleHoleEntity hole;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    final rx = size.width * 0.38;
    final ry = size.height * 0.22;

    // Soft grass mound
    final mound = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, cy - 4),
        width: rx * 2.4,
        height: ry * 2.8,
      ));
    canvas.drawPath(
      mound,
      Paint()..color = const Color(0xFF81C784),
    );

    // Dark hole
    final holeRect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
    canvas.drawOval(
      holeRect,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF3E2723), Color(0xFF5D4037), Color(0xFF6D4C41)],
          stops: const [0.2, 0.7, 1],
        ).createShader(holeRect),
    );

    // Inner shadow ring
    canvas.drawOval(
      holeRect.inflate(2),
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Wooden border accents
    final wood = Paint()
      ..color = const Color(0xFFA1887F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(holeRect.inflate(6), -0.4, math.pi + 0.8, false, wood);

    _drawDecor(canvas, size, cx, cy, rx, ry);

    // Sparkle flowers idle
    final sparkle = (math.sin(hole.sparklePhase) + 1) / 2;
    if (sparkle > 0.7) {
      canvas.drawCircle(
        Offset(cx + rx * 0.9, cy - ry * 1.4),
        2.5,
        Paint()..color = Colors.white.withValues(alpha: sparkle),
      );
    }
  }

  void _drawDecor(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    final seed = hole.decorSeed;
    final flowerColors = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFD54F),
      const Color(0xFFCE93D8),
      const Color(0xFF80CBC4),
      const Color(0xFFFFAB91),
    ];

    // Flowers
    for (var i = 0; i < 3; i++) {
      final side = i.isEven ? -1.0 : 1.0;
      final fx = cx + side * (rx * (0.95 + (seed % 5) * 0.04 + i * 0.08));
      final fy = cy - ry * (0.6 + i * 0.25) + math.sin(hole.swayPhase + i) * 2;
      final color = flowerColors[(seed + i) % flowerColors.length];
      canvas.drawCircle(Offset(fx, fy), 5, Paint()..color = color);
      canvas.drawCircle(Offset(fx, fy), 2, Paint()..color = const Color(0xFFFFF176));
    }

    // Tiny mushrooms
    final mx = cx - rx * 1.05;
    final my = cy - ry * 0.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(mx, my + 4), width: 5, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(mx, my), width: 12, height: 8),
      Paint()..color = const Color(0xFFEF5350),
    );
    canvas.drawCircle(Offset(mx - 2, my - 1), 1.2, Paint()..color = Colors.white);

    // Smooth stones
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + rx * 1.1, cy + ry * 0.3), width: 10, height: 6),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + rx * 0.85, cy + ry * 0.5), width: 7, height: 5),
      Paint()..color = const Color(0xFF90A4AE),
    );

    // Leaves
    final leafSway = math.sin(hole.swayPhase) * 3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - rx * 0.7 + leafSway, cy - ry * 1.1),
        width: 10,
        height: 6,
      ),
      Paint()..color = const Color(0xFF7CB342),
    );
  }

  @override
  bool shouldRepaint(covariant _HolePainter oldDelegate) =>
      oldDelegate.hole != hole;
}

class _HoleRimPainter extends CustomPainter {
  _HoleRimPainter({required this.hole});

  final MoleHoleEntity hole;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    final rx = size.width * 0.38;
    final ry = size.height * 0.22;
    // Soft front lip of the hole so moles feel underground
    final lip = Path()
      ..addArc(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        0.15,
        math.pi - 0.3,
      );
    canvas.drawPath(
      lip,
      Paint()
        ..color = const Color(0xFF558B2F).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HoleRimPainter oldDelegate) => false;
}
