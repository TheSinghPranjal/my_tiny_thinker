import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';

class FishingBoatWidget extends StatelessWidget {
  const FishingBoatWidget({
    super.key,
    required this.boatX,
    required this.boatY,
    this.hookTargetFishId,
    this.fish = const [],
    this.largerTouch = false,
  });

  final double boatX;
  final double boatY;
  final String? hookTargetFishId;
  final List<CatchFishEntity> fish;
  final bool largerTouch;

  static double layoutWidth(bool largerTouch) => largerTouch ? 168.0 : 148.0;
  static double layoutHeight(bool largerTouch) => largerTouch ? 120.0 : 108.0;

  // Rod tip relative to the boat's anchor point; shared with the painter.
  static const double _rodTipDx = 52;
  static const double _rodTipDy = -60;

  CatchFishEntity? get _hookFish {
    final id = hookTargetFishId;
    if (id == null) return null;
    for (final f in fish) {
      if (f.id == id && f.phase == CatchFishPhase.reeling) return f;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final w = layoutWidth(largerTouch);
    final h = layoutHeight(largerTouch);
    final hookFish = _hookFish;

    // Rod tip relative to boat center (painter local coords → world).
    final rodTip = Offset(boatX + _rodTipDx, boatY + _rodTipDy);

    return Positioned.fill(
      child: Stack(
        children: [
          if (hookFish != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FishingLinePainter(
                    rodTip: rodTip,
                    fishPos: Offset(hookFish.x, hookFish.y),
                  ),
                ),
              ),
            ),
          Positioned(
            left: boatX - w / 2,
            top: boatY - h * 0.62,
            child: IgnorePointer(
              child: CustomPaint(
                size: Size(w, h),
                painter: _BoatPainter(showIdleLine: hookFish == null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FishingLinePainter extends CustomPainter {
  _FishingLinePainter({required this.rodTip, required this.fishPos});

  final Offset rodTip;
  final Offset fishPos;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(rodTip.dx, rodTip.dy)
      ..quadraticBezierTo(
        (rodTip.dx + fishPos.dx) / 2 + 8,
        (rodTip.dy + fishPos.dy) / 2 - 12,
        fishPos.dx,
        fishPos.dy - 8,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5D4037).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Hook
    final hook = fishPos + const Offset(0, -6);
    canvas.drawArc(
      Rect.fromCenter(center: hook, width: 12, height: 14),
      -0.2,
      math.pi + 0.6,
      false,
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      hook + const Offset(0, 6),
      2.5,
      Paint()..color = const Color(0xFFFFD54F),
    );
  }

  @override
  bool shouldRepaint(covariant _FishingLinePainter old) =>
      old.rodTip != rodTip || old.fishPos != fishPos;
}

class _BoatPainter extends CustomPainter {
  const _BoatPainter({required this.showIdleLine});

  final bool showIdleLine;

  static const _fur = Color(0xFFC98A4B);
  static const _muzzle = Color(0xFFF3D3A5);
  static const _ink = Color(0xFF3E2723);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    const tipDx = FishingBoatWidget._rodTipDx;
    const tipDy = FishingBoatWidget._rodTipDy;
    final rodTip = Offset(cx + tipDx, cy + tipDy);

    // Water ripples around the hull
    for (final (w, a) in [(150.0, 0.16), (128.0, 0.24)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 27), width: w, height: 14),
        Paint()
          ..color = Colors.white.withValues(alpha: a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 34), width: 100, height: 10),
      Paint()..color = const Color(0xFF0D47A1).withValues(alpha: 0.18),
    );

    // Back rim of the boat (inside), visible behind the bear
    _drawTeddy(canvas, Offset(cx - 6, cy - 22));

    // Fishing rod (over the bear's paws, behind the hull front)
    final rodBase = Offset(cx + 2, cy - 10);
    canvas.drawLine(
      rodBase,
      rodTip,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      rodBase + const Offset(4, -5),
      rodTip,
      Paint()
        ..color = const Color(0xFF9C6B4A)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
    // Paws gripping the rod
    for (final o in [const Offset(-2, -6), const Offset(6, -11)]) {
      canvas.drawCircle(rodBase + o, 5.5, Paint()..color = _fur);
      canvas.drawCircle(
        rodBase + o + const Offset(-1.2, -1.2),
        2,
        Paint()..color = _muzzle.withValues(alpha: 0.7),
      );
    }

    // Hull
    final hull = Path()
      ..moveTo(cx - 62, cy - 4)
      ..quadraticBezierTo(cx, cy + 6, cx + 62, cy - 4)
      ..quadraticBezierTo(cx + 56, cy + 22, cx + 30, cy + 30)
      ..quadraticBezierTo(cx, cy + 34, cx - 30, cy + 30)
      ..quadraticBezierTo(cx - 56, cy + 22, cx - 62, cy - 4)
      ..close();
    final hullRect = Rect.fromLTWH(cx - 62, cy - 6, 124, 40);
    canvas.drawPath(
      hull,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD9964F), Color(0xFFB8732E), Color(0xFF8B5220)],
        ).createShader(hullRect),
    );
    canvas.save();
    canvas.clipPath(hull);
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 62, cy + i * 8.0),
        Offset(cx + 62, cy + i * 8.0),
        Paint()
          ..color = const Color(0xFF6D3E14).withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
    }
    canvas.restore();
    // Rim highlight
    canvas.drawPath(
      Path()
        ..moveTo(cx - 62, cy - 4)
        ..quadraticBezierTo(cx, cy + 6, cx + 62, cy - 4),
      Paint()
        ..color = const Color(0xFFF0B674)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      hull,
      Paint()
        ..color = const Color(0xFF6D3E14).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Paw-print badge on the bow
    final badge = Offset(cx + 40, cy + 14);
    canvas.drawCircle(badge, 8.5, Paint()..color = const Color(0xFF7A4515));
    final paw = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawOval(
      Rect.fromCenter(center: badge + const Offset(0, 2), width: 8, height: 6),
      paw,
    );
    for (final o in [
      const Offset(-4, -2.5),
      const Offset(-1.5, -5),
      const Offset(1.5, -5),
      const Offset(4, -2.5),
    ]) {
      canvas.drawCircle(badge + o, 1.4, paw);
    }

    // Line and bobber
    if (showIdleLine) {
      final bobber = Offset(rodTip.dx + 14, cy + 20);
      canvas.drawPath(
        Path()
          ..moveTo(rodTip.dx, rodTip.dy)
          ..quadraticBezierTo(rodTip.dx + 2, cy - 10, bobber.dx, bobber.dy - 12),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawOval(
        Rect.fromCenter(center: bobber + const Offset(0, 8), width: 30, height: 8),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final ball = Rect.fromCenter(center: bobber, width: 14, height: 16);
      canvas.drawOval(ball, Paint()..color = Colors.white);
      canvas.save();
      canvas.clipPath(Path()..addOval(ball));
      canvas.drawRect(
        Rect.fromLTWH(ball.left, ball.top, ball.width, ball.height * 0.5),
        Paint()..color = const Color(0xFFE53935),
      );
      canvas.restore();
      canvas.drawCircle(
        bobber + const Offset(-2, -3),
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
      canvas.drawLine(
        bobber + const Offset(0, -8),
        bobber + const Offset(0, -12),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawTeddy(Canvas canvas, Offset c) {
    final fur = Paint()..color = _fur;

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 14), width: 44, height: 40),
      fur,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 17), width: 26, height: 28),
      Paint()..color = _muzzle,
    );

    // Ears
    for (final dx in [-19.0, 19.0]) {
      canvas.drawCircle(c + Offset(dx, -19), 9, fur);
      canvas.drawCircle(c + Offset(dx, -18), 5, Paint()..color = const Color(0xFFE8A96B));
    }

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, -6), width: 54, height: 48),
      fur,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(-8, -16), width: 20, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.14),
    );

    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 4), width: 26, height: 20),
      Paint()..color = _muzzle,
    );

    // Cheeks
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55);
    canvas.drawCircle(c + const Offset(-17, 2), 5, cheek);
    canvas.drawCircle(c + const Offset(17, 2), 5, cheek);

    // Eyes
    for (final dx in [-10.0, 10.0]) {
      canvas.drawCircle(c + Offset(dx, -8), 5, Paint()..color = _ink);
      canvas.drawCircle(c + Offset(dx - 1.6, -10), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(c + Offset(dx + 1.6, -6.5), 0.9, Paint()..color = Colors.white);
    }

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 0), width: 9, height: 6.5),
      Paint()..color = _ink,
    );
    canvas.drawCircle(
      c + const Offset(-1.6, -1),
      1.1,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    // Open smile with tongue
    final mouth = Path()
      ..moveTo(c.dx - 6, c.dy + 4)
      ..quadraticBezierTo(c.dx, c.dy + 14, c.dx + 6, c.dy + 4)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF6D2B1F));
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 9), width: 6, height: 4),
      Paint()..color = const Color(0xFFFF7A85),
    );
    canvas.drawLine(
      c + const Offset(0, 3),
      c + const Offset(0, 5),
      Paint()
        ..color = _ink
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BoatPainter old) =>
      old.showIdleLine != showIdleLine;
}
