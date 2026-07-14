import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/shared/frog_varieties.dart';

class FrogWidget extends StatelessWidget {
  const FrogWidget({
    super.key,
    required this.frog,
    required this.onTap,
    this.largerTouch = false,
    this.highContrast = false,
  });

  final FrogEntity frog;
  final VoidCallback onTap;
  final bool largerTouch;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (frog.phase == FrogPhase.gone) return const SizedBox.shrink();

    final baseSize = frog.isKing ? 104.0 : 88.0;
    final touchSize = largerTouch ? baseSize * 1.25 : baseSize * 1.15;
    final blink = (frog.blinkTimer % 4.0) < 0.12;
    final bounce = frog.phase == FrogPhase.jumping
        ? math.sin(frog.jumpProgress * math.pi) * 8
        : math.sin(frog.animPhase * 3) * 3;
    final wave = math.sin(frog.animPhase * 5) * 0.15;

    return GestureDetector(
      onTap: frog.isTappable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touchSize,
        height: touchSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(touchSize, touchSize),
              painter: _FrogPainter(
                frog: frog,
                variety: frog.variety,
                blink: blink,
                bounce: bounce,
                waveAngle: wave,
                highContrast: highContrast,
              ),
            ),
            if (frog.isKing && frog.phase != FrogPhase.jumping)
              Positioned(
                top: 0,
                child: _CrownGems(gems: frog.crownGems),
              ),
          ],
        ),
      ),
    );
  }
}

class _CrownGems extends StatelessWidget {
  const _CrownGems({required this.gems});

  final int gems;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(FrogEntity.kingTapRequired, (i) {
        final lit = i < gems;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            lit ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 13,
            color: lit ? const Color(0xFFFFD54F) : Colors.white54,
          ),
        );
      }),
    );
  }
}

class _FrogPainter extends CustomPainter {
  _FrogPainter({
    required this.frog,
    required this.variety,
    required this.blink,
    required this.bounce,
    required this.waveAngle,
    required this.highContrast,
  });

  final FrogEntity frog;
  final FrogVariety variety;
  final bool blink;
  final double bounce;
  final double waveAngle;
  final bool highContrast;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + bounce;
    final bodyColor = frog.isKing
        ? const Color(0xFFE53935)
        : Color(variety.bodyColor);
    final bellyColor = frog.isKing
        ? const Color(0xFFFFCDD2)
        : Color(variety.bellyColor);
    final dark = Color.lerp(bodyColor, Colors.black, 0.18)!;

    if (frog.isKing) {
      final glow = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(cx, cy), size.width * 0.44, glow);
    }

    _drawBackLeg(canvas, cx - size.width * 0.28, cy + size.height * 0.12, bodyColor, dark, flip: true);
    _drawBackLeg(canvas, cx + size.width * 0.28, cy + size.height * 0.12, bodyColor, dark, flip: false);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.1),
        width: size.width * 0.68,
        height: size.height * 0.48,
      ),
      Paint()..color = bellyColor,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.02),
        width: size.width * 0.74,
        height: size.height * 0.56,
      ),
      Paint()..color = bodyColor,
    );

    _drawPattern(canvas, cx, cy, size);

    _drawFrontLeg(canvas, cx - size.width * 0.22, cy + size.height * 0.08, bodyColor, dark, waveAngle);
    _drawFrontLeg(canvas, cx + size.width * 0.22, cy + size.height * 0.08, bodyColor, dark, -waveAngle);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - size.height * 0.06),
        width: size.width * 0.58,
        height: size.height * 0.42,
      ),
      Paint()..color = bodyColor,
    );

    _drawFrogEye(canvas, cx - size.width * 0.16, cy - size.height * 0.18, size.width * 0.13, bodyColor);
    _drawFrogEye(canvas, cx + size.width * 0.16, cy - size.height * 0.18, size.width * 0.13, bodyColor);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.02),
        width: size.width * 0.24,
        height: size.height * 0.1,
      ),
      0.15,
      math.pi - 0.3,
      false,
      Paint()
        ..color = const Color(0xFF37474F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.04),
        width: size.width * 0.08,
        height: size.height * 0.05,
      ),
      Paint()..color = frog.isKing ? const Color(0xFFFFCDD2) : const Color(0xFF81C784),
    );

    canvas.drawCircle(
      Offset(cx - size.width * 0.14, cy + size.height * 0.01),
      size.width * 0.045,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.14, cy + size.height * 0.01),
      size.width * 0.045,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55),
    );

    if (frog.isKing) {
      _drawCrown(canvas, cx, cy - size.height * 0.34, size.width * 0.26);
    }
  }

  void _drawFrogEye(
    Canvas canvas,
    double x,
    double y,
    double r,
    Color lidColor,
  ) {
    canvas.drawCircle(Offset(x, y + r * 0.15), r * 0.95, Paint()..color = lidColor);
    if (blink) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, y + r * 0.1), width: r * 1.7, height: r * 0.35),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = lidColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.35
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    canvas.drawCircle(Offset(x, y), r * 0.82, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(x, y), r * 0.62, Paint()..color = const Color(0xFFFFF176));
    canvas.drawCircle(
      Offset(x + r * 0.08, y + r * 0.05),
      r * 0.34,
      Paint()..color = highContrast ? Colors.black : const Color(0xFF212121),
    );
    canvas.drawCircle(
      Offset(x + r * 0.16, y - r * 0.08),
      r * 0.1,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _drawFrontLeg(
    Canvas canvas,
    double x,
    double y,
    Color body,
    Color dark,
    double angle,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 6), width: 16, height: 22),
      Paint()..color = body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 16), width: 20, height: 12),
      Paint()..color = dark,
    );
    for (var i = -1; i <= 1; i++) {
      canvas.drawCircle(Offset(i * 5.0, 22), 3, Paint()..color = dark);
    }
    canvas.restore();
  }

  void _drawBackLeg(
    Canvas canvas,
    double x,
    double y,
    Color body,
    Color dark, {
    required bool flip,
  }) {
    canvas.save();
    canvas.translate(x, y);
    if (flip) canvas.scale(-1, 1);

    final leg = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(18, 8, 24, 22)
      ..quadraticBezierTo(26, 34, 14, 38)
      ..quadraticBezierTo(2, 40, -2, 28)
      ..quadraticBezierTo(-4, 14, 0, 0)
      ..close();
    canvas.drawPath(leg, Paint()..color = body);
    canvas.drawPath(
      leg,
      Paint()
        ..color = dark.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18, 36), width: 24, height: 10),
      Paint()..color = dark,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(10.0 + i * 6, 40), 2.5, Paint()..color = dark);
    }
    canvas.restore();
  }

  void _drawPattern(Canvas canvas, double cx, double cy, Size size) {
    if (frog.isKing) return;
    final spot = Paint()..color = Color(variety.spotColor).withValues(alpha: 0.55);
    switch (variety.pattern) {
      case FrogPattern.spotted:
        canvas.drawCircle(Offset(cx - 10, cy + 10), 4, spot);
        canvas.drawCircle(Offset(cx + 12, cy + 6), 3.5, spot);
        canvas.drawCircle(Offset(cx, cy + 16), 3, spot);
      case FrogPattern.striped:
        canvas.drawLine(
          Offset(cx - 14, cy + 8),
          Offset(cx + 14, cy + 8),
          Paint()
            ..color = Color(variety.spotColor).withValues(alpha: 0.55)
            ..strokeWidth = 2,
        );
      case FrogPattern.leafy:
        canvas.drawCircle(Offset(cx + 16, cy), 5, spot);
      case FrogPattern.mossy:
        canvas.drawCircle(Offset(cx - 12, cy + 12), 5, spot);
      case FrogPattern.shiny:
        canvas.drawCircle(
          Offset(cx - 10, cy - 4),
          4,
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );
      case FrogPattern.smooth:
        break;
    }
  }

  void _drawCrown(Canvas canvas, double cx, double cy, double w) {
    final path = Path()
      ..moveTo(cx - w, cy + 6)
      ..lineTo(cx - w * 0.6, cy - w * 0.4)
      ..lineTo(cx - w * 0.2, cy + 2)
      ..lineTo(cx, cy - w * 0.55)
      ..lineTo(cx + w * 0.2, cy + 2)
      ..lineTo(cx + w * 0.6, cy - w * 0.4)
      ..lineTo(cx + w, cy + 6)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFA000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FrogPainter oldDelegate) =>
      oldDelegate.frog != frog ||
      oldDelegate.blink != blink ||
      oldDelegate.bounce != bounce ||
      oldDelegate.waveAngle != waveAngle;
}
