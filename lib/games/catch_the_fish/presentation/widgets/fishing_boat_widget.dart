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
    final rodTip = Offset(boatX + w * 0.28, boatY - h * 0.18);

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
                painter: const _BoatPainter(),
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
  const _BoatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;

    // Water shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height - 4),
        width: size.width * 0.72,
        height: 14,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // Hull
    final hull = Path()
      ..moveTo(cx - 58, cy - 8)
      ..quadraticBezierTo(cx - 62, cy + 18, cx - 40, cy + 28)
      ..quadraticBezierTo(cx, cy + 36, cx + 40, cy + 28)
      ..quadraticBezierTo(cx + 62, cy + 18, cx + 58, cy - 8)
      ..close();
    canvas.drawPath(
      hull,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63), Color(0xFF5D4037)],
        ).createShader(Rect.fromLTWH(cx - 62, cy - 8, 124, 44)),
    );

    // Wood planks
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 48 + i * 2, cy - 2 + i * 7.0),
        Offset(cx + 48 - i * 2, cy - 2 + i * 7.0),
        Paint()
          ..color = const Color(0xFF6D4C41).withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );
    }

    // Deck rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 6), width: 118, height: 18),
      Paint()..color = const Color(0xFFA1887F),
    );

    // Smiling boat face on bow
    final face = Offset(cx + 36, cy + 6);
    canvas.drawCircle(face + const Offset(-5, -2), 2, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(face + const Offset(5, -2), 2, Paint()..color = const Color(0xFF3E2723));
    canvas.drawArc(
      Rect.fromCenter(center: face + const Offset(0, 3), width: 12, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Teddy fisherman
    _drawTeddy(canvas, Offset(cx - 8, cy - 38));

    // Fishing rod
    final rodBase = Offset(cx + 6, cy - 34);
    final rodTip = Offset(cx + size.width * 0.28, cy - size.height * 0.42);
    canvas.drawLine(
      rodBase,
      rodTip,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(rodTip, 3, Paint()..color = const Color(0xFF795548));
  }

  void _drawTeddy(Canvas canvas, Offset c) {
    // Ears
    canvas.drawCircle(c + const Offset(-12, -14), 8, Paint()..color = const Color(0xFFA1887F));
    canvas.drawCircle(c + const Offset(12, -14), 8, Paint()..color = const Color(0xFFA1887F));
    canvas.drawCircle(c + const Offset(-12, -14), 4, Paint()..color = const Color(0xFFD7CCC8));
    canvas.drawCircle(c + const Offset(12, -14), 4, Paint()..color = const Color(0xFFD7CCC8));

    // Head
    canvas.drawCircle(c, 16, Paint()..color = const Color(0xFFBCAAA4));
    canvas.drawCircle(c + const Offset(0, 2), 10, Paint()..color = const Color(0xFFD7CCC8));

    // Eyes
    canvas.drawCircle(c + const Offset(-5, -2), 2.5, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(c + const Offset(5, -2), 2.5, Paint()..color = const Color(0xFF3E2723));
    canvas.drawCircle(c + const Offset(-4, -3), 1, Paint()..color = Colors.white);
    canvas.drawCircle(c + const Offset(6, -3), 1, Paint()..color = Colors.white);

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 3), width: 6, height: 5),
      Paint()..color = const Color(0xFF5D4037),
    );

    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 10, height: 6),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Body / life vest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, 26), width: 28, height: 24),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFFF7043),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, 26), width: 18, height: 20),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFFFCC80),
    );

    // Arms holding rod
    canvas.drawLine(
      c + const Offset(10, 20),
      c + const Offset(22, 12),
      Paint()
        ..color = const Color(0xFFA1887F)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BoatPainter old) => false;
}
