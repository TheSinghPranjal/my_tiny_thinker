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

  @override
  Widget build(BuildContext context) {
    if (butterfly.phase == ButterflyPhase.gone) return const SizedBox.shrink();

    final touch = (largerTouch ? 72.0 : 64.0) * butterfly.sizeScale;
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
        width: touch + 12,
        height: touch + 12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (butterfly.isGolden)
              Container(
                width: touch,
                height: touch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            if (butterfly.glow > 0)
              Container(
                width: touch * 0.95,
                height: touch * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFF176)
                          .withValues(alpha: butterfly.glow * 0.65),
                      blurRadius: 16,
                      spreadRadius: 2,
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
              size: Size(touch * 0.85, touch * 0.85),
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
        ? 0.55 + math.sin(wingPhase * 2).abs() * 0.45
        : 0.72 + math.sin(wingPhase).abs() * 0.28;
    final primary = Color(def.primaryColor);
    final accent = Color(def.wingColor);
    final body = Color(def.bodyColor);

    canvas.save();
    canvas.translate(cx, cy);

    _drawWing(canvas, const Offset(-10, -2), flap, primary, accent, false);
    _drawWing(canvas, const Offset(10, -2), flap, primary, accent, true);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 5, height: 18),
      Paint()..color = body,
    );
    canvas.drawCircle(const Offset(0, -8), 3.2, Paint()..color = body);

    final antenna = Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-1.5, -10), const Offset(-5, -16), antenna);
    canvas.drawLine(const Offset(1.5, -10), const Offset(5, -16), antenna);

    canvas.restore();
  }

  void _drawWing(
    Canvas canvas,
    Offset center,
    double flap,
    Color primary,
    Color accent,
    bool mirrored,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (mirrored) canvas.scale(-1, 1);

    canvas.save();
    canvas.scale(1, flap);
    final upper = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(14, -10, 22, -2)
      ..quadraticBezierTo(16, 6, 0, 4)
      ..close();

    if (def.pattern == GardenButterflyPattern.rainbow) {
      canvas.drawPath(upper, Paint()..color = primary.withValues(alpha: 0.9));
      canvas.drawPath(
        upper,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFFFEE58), Color(0xFF42A5F5), Color(0xFFAB47BC)],
          ).createShader(Rect.fromLTWH(-2, -12, 24, 18))
          ..blendMode = BlendMode.srcATop,
      );
    } else {
      canvas.drawPath(upper, Paint()..color = primary.withValues(alpha: 0.92));
    }

    if (def.pattern == GardenButterflyPattern.spotted) {
      canvas.drawCircle(const Offset(10, -4), 2.5, Paint()..color = Color(def.spotColor));
      canvas.drawCircle(const Offset(16, 0), 2, Paint()..color = Color(def.spotColor));
    }
    if (def.pattern == GardenButterflyPattern.striped) {
      canvas.drawLine(
        const Offset(6, -6),
        const Offset(14, 2),
        Paint()
          ..color = accent.withValues(alpha: 0.7)
          ..strokeWidth = 2,
      );
    }
    if (isGolden) {
      canvas.drawPath(
        upper,
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.restore();

    canvas.save();
    canvas.scale(1, flap * 0.92);
    final lower = Path()
      ..moveTo(0, 2)
      ..quadraticBezierTo(12, 8, 18, 14)
      ..quadraticBezierTo(8, 16, 0, 10)
      ..close();
    canvas.drawPath(lower, Paint()..color = accent.withValues(alpha: 0.88));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GardenButterflyPainter old) =>
      old.wingPhase != wingPhase ||
      old.def != def ||
      old.isGolden != isGolden ||
      old.fastFlap != fastFlap;
}
