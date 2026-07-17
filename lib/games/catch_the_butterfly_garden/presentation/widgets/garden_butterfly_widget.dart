import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterflies.dart';

class GardenButterflyWidget extends StatelessWidget {
  const GardenButterflyWidget({
    super.key,
    required this.butterfly,
    required this.onTap,
    this.largerTouch = false,
  });

  final ButterflyEntity butterfly;
  final VoidCallback onTap;
  final bool largerTouch;

  static double layoutSize(bool largerTouch, double sizeScale) =>
      (largerTouch ? 108.0 : 96.0) * sizeScale;

  @override
  Widget build(BuildContext context) {
    if (butterfly.phase == ButterflyPhase.gone) return const SizedBox.shrink();

    final touch = layoutSize(largerTouch, butterfly.sizeScale);
    final def = GardenButterflies.byIndex(
      butterfly.varietyIndex,
      isGolden: butterfly.isGolden,
    );
    final fastFlap = butterfly.phase == ButterflyPhase.tapped ||
        butterfly.phase == ButterflyPhase.collecting;

    return GestureDetector(
      onTap: butterfly.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch + 16,
        height: touch + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (butterfly.isGolden || butterfly.glow > 0)
              Container(
                width: touch * 0.9,
                height: touch * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(butterfly.isGolden ? 0xFFFFD54F : 0xFFFFF176)
                          .withValues(alpha: (0.35 + butterfly.glow * 0.4).clamp(0.2, 0.85)),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            if (butterfly.highlight > 0)
              Container(
                width: touch,
                height: touch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85 * butterfly.highlight),
                    width: 3,
                  ),
                ),
              ),
            CustomPaint(
              size: Size(touch, touch),
              painter: _GardenButterflyPainter(
                def: def,
                wingPhase: butterfly.wingPhase,
                isGolden: butterfly.isGolden,
                fastFlap: fastFlap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenButterflyPainter extends CustomPainter {
  _GardenButterflyPainter({
    required this.def,
    required this.wingPhase,
    required this.isGolden,
    required this.fastFlap,
  });

  final GardenButterflyDef def;
  final double wingPhase;
  final bool isGolden;
  final bool fastFlap;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = fastFlap
        ? 0.45 + math.sin(wingPhase * 2.4).abs() * 0.55
        : 0.62 + math.sin(wingPhase).abs() * 0.38;
    final primary = Color(def.primaryColor);
    final accent = Color(def.wingColor);
    final body = Color(def.bodyColor);

    canvas.save();
    canvas.translate(cx, cy);

    // Soft shadow under butterfly
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 36, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    _drawWing(canvas, const Offset(-6, 0), flap, primary, accent, mirrored: false);
    _drawWing(canvas, const Offset(6, 0), flap, primary, accent, mirrored: true);

    // Body (abdomen + thorax)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 8, height: 28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(body, Colors.white, 0.15)!, body, Color.lerp(body, Colors.black, 0.2)!],
        ).createShader(const Rect.fromLTWH(-4, -8, 8, 28)),
    );
    // Thorax segment rings
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-3, 2.0 + i * 6),
        Offset(3, 2.0 + i * 6),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..strokeWidth = 1,
      );
    }

    // Head
    canvas.drawCircle(
      const Offset(0, -12),
      6,
      Paint()..color = body,
    );

    // Eyes
    canvas.drawCircle(const Offset(-3.5, -13), 2.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(3.5, -13), 2.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-3, -12.5), 1.5, Paint()..color = const Color(0xFF1A237E));
    canvas.drawCircle(const Offset(4, -12.5), 1.5, Paint()..color = const Color(0xFF1A237E));
    canvas.drawCircle(const Offset(-2.4, -13.2), 0.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(4.6, -13.2), 0.6, Paint()..color = Colors.white);

    // Antennae with knobs
    final antenna = Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(-2, -16)
        ..quadraticBezierTo(-8, -24, -12, -28),
      antenna,
    );
    canvas.drawPath(
      Path()
        ..moveTo(2, -16)
        ..quadraticBezierTo(8, -24, 12, -28),
      antenna,
    );
    canvas.drawCircle(const Offset(-12, -28), 2.2, Paint()..color = accent);
    canvas.drawCircle(const Offset(12, -28), 2.2, Paint()..color = accent);

    canvas.restore();
  }

  void _drawWing(
    Canvas canvas,
    Offset center,
    double flap,
    Color primary,
    Color accent, {
    required bool mirrored,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (mirrored) canvas.scale(-1, 1);

    // Upper wing
    canvas.save();
    canvas.scale(1, flap);
    final upper = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(18, -22, 38, -8)
      ..quadraticBezierTo(42, 4, 28, 10)
      ..quadraticBezierTo(14, 8, 0, 4)
      ..close();

    canvas.drawPath(
      upper,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          colors: [
            Color.lerp(primary, Colors.white, 0.35)!,
            primary,
            accent,
          ],
        ).createShader(const Rect.fromLTWH(0, -24, 44, 36)),
    );

    // Wing veins / scales
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(
      Path()
        ..moveTo(2, 0)
        ..quadraticBezierTo(16, -12, 34, -4),
      vein,
    );
    canvas.drawPath(
      Path()
        ..moveTo(2, 2)
        ..quadraticBezierTo(14, 2, 28, 6),
      vein,
    );

    // Scale dots
    for (final p in [
      const Offset(12, -8),
      const Offset(22, -10),
      const Offset(28, -2),
      const Offset(16, 2),
    ]) {
      canvas.drawCircle(p, 2.2, Paint()..color = Colors.white.withValues(alpha: 0.4));
    }

    _drawPattern(canvas, upper, primary, accent);

    canvas.drawPath(
      upper,
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();

    // Lower wing
    canvas.save();
    canvas.scale(1, flap * 0.9);
    final lower = Path()
      ..moveTo(0, 4)
      ..quadraticBezierTo(16, 10, 30, 22)
      ..quadraticBezierTo(18, 28, 4, 18)
      ..quadraticBezierTo(0, 12, 0, 4)
      ..close();
    canvas.drawPath(
      lower,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(accent, Colors.white, 0.2)!,
            accent,
            Color.lerp(accent, Colors.black, 0.15)!,
          ],
        ).createShader(const Rect.fromLTWH(0, 4, 32, 26)),
    );
    canvas.drawCircle(const Offset(14, 14), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawPath(
      lower,
      Paint()
        ..color = primary.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.restore();

    canvas.restore();
  }

  void _drawPattern(Canvas canvas, Path upper, Color primary, Color accent) {
    switch (def.pattern) {
      case GardenButterflyPattern.spotted:
        canvas.drawCircle(const Offset(14, -6), 4.5, Paint()..color = Color(def.spotColor));
        canvas.drawCircle(const Offset(26, 0), 3.5, Paint()..color = Color(def.spotColor));
        canvas.drawCircle(const Offset(18, 4), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.5));
      case GardenButterflyPattern.striped:
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(8.0 + i * 8, -12),
            Offset(14.0 + i * 8, 6),
            Paint()
              ..color = accent.withValues(alpha: 0.65)
              ..strokeWidth = 2.5
              ..strokeCap = StrokeCap.round,
          );
        }
      case GardenButterflyPattern.rainbow:
        const colors = [
          Color(0xFFEF5350),
          Color(0xFFFFB74D),
          Color(0xFFFFEE58),
          Color(0xFF66BB6A),
          Color(0xFF42A5F5),
          Color(0xFFAB47BC),
        ];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: const Offset(18, -2), width: 28, height: 22),
            -1.2 + i * 0.25,
            0.2,
            false,
            Paint()
              ..color = colors[i].withValues(alpha: 0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5,
          );
        }
      case GardenButterflyPattern.solid:
        break;
    }
    if (isGolden) {
      canvas.drawPath(
        upper,
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GardenButterflyPainter old) =>
      old.wingPhase != wingPhase ||
      old.def != def ||
      old.isGolden != isGolden ||
      old.fastFlap != fastFlap;
}
