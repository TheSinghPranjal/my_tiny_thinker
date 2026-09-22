import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cream bunny with pink-lined ears, drawn from plain state (not tied to any
/// one game's entity) so it can be reused wherever a bunny character is
/// needed. Currently used by Bunny Hop Adventure.
class BunnyCharacter extends StatelessWidget {
  const BunnyCharacter({
    super.key,
    required this.facingRight,
    required this.animPhase,
    this.blink = false,
    this.waving = false,
    this.wet = false,
    this.squash = 1.0,
    this.celebrateProgress = 0,
    this.size = 104,
  });

  final bool facingRight;
  final double animPhase;
  final bool blink;
  final bool waving;
  final bool wet;
  final double squash;
  final double celebrateProgress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: squash,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: BunnyPainter(
            facingRight: facingRight,
            animPhase: animPhase,
            blink: blink,
            waving: waving,
            wet: wet,
            celebrateProgress: celebrateProgress,
          ),
        ),
      ),
    );
  }
}

class BunnyPainter extends CustomPainter {
  BunnyPainter({
    required this.facingRight,
    required this.animPhase,
    required this.blink,
    required this.waving,
    required this.wet,
    required this.celebrateProgress,
  });

  final bool facingRight;
  final double animPhase;
  final bool blink;
  final bool waving;
  final bool wet;
  final double celebrateProgress;

  static const _fur = Color(0xFFFFF8E7);
  static const _pink = Color(0xFFF8BBD0);
  static const _ink = Color(0xFF3E2723);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    final breathe = math.sin(animPhase * 2) * 1.8;

    canvas.save();
    canvas.translate(0, breathe - celebrateProgress * 8);

    if (!facingRight) {
      canvas.translate(cx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-cx, 0);
    }

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 34), width: 44, height: 12),
      Paint()..color = const Color(0xFF33691E).withValues(alpha: 0.18),
    );

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: 46, height: 34),
      Paint()..color = _fur,
    );

    // Head
    canvas.drawCircle(Offset(cx, cy - 4), 26, Paint()..color = _fur);

    // Ears
    void ear(double dx) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + dx, cy - 30), width: 16, height: 26),
        Paint()..color = _fur,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + dx, cy - 30), width: 8, height: 16),
        Paint()..color = _pink,
      );
    }

    ear(-16);
    ear(16);

    // Cheeks
    canvas.drawCircle(Offset(cx - 16, cy + 4), 6, Paint()..color = _pink.withValues(alpha: 0.7));
    canvas.drawCircle(Offset(cx + 16, cy + 4), 6, Paint()..color = _pink.withValues(alpha: 0.7));

    _drawEye(canvas, cx - 9, cy - 6, blink);
    _drawEye(canvas, cx + 9, cy - 6, blink);

    canvas.drawCircle(Offset(cx, cy + 2), 3.2, Paint()..color = const Color(0xFFF48FB1));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 14, height: 9),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Paw / wave
    final wave = waving ? math.sin(animPhase * 4) * 0.35 : 0.0;
    canvas.save();
    canvas.translate(cx + 24, cy + 10);
    canvas.rotate(-0.4 + wave);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 14),
      Paint()..color = _fur,
    );
    canvas.restore();

    if (wet) {
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(cx - 16 + i * 10, cy + 26),
          2.2,
          Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.75),
        );
      }
    }

    canvas.restore();
  }

  void _drawEye(Canvas canvas, double x, double y, bool blink) {
    if (blink) {
      canvas.drawLine(
        Offset(x - 5, y),
        Offset(x + 5, y),
        Paint()
          ..color = _ink
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawCircle(Offset(x, y), 6.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y + 0.5), 4.2, Paint()..color = _ink);
      canvas.drawCircle(Offset(x - 1.4, y - 1.4), 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant BunnyPainter old) =>
      old.facingRight != facingRight ||
      old.animPhase != animPhase ||
      old.blink != blink ||
      old.waving != waving ||
      old.wet != wet ||
      old.celebrateProgress != celebrateProgress;
}
