import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/shared/flying_insects.dart';

class InsectWidget extends StatelessWidget {
  const InsectWidget({
    super.key,
    required this.insect,
    required this.onTap,
    this.largerTouch = false,
    this.nightFactor = 0,
  });

  final InsectEntity insect;
  final VoidCallback onTap;
  final bool largerTouch;
  final double nightFactor;

  @override
  Widget build(BuildContext context) {
    if (insect.phase == InsectPhase.gone || insect.phase == InsectPhase.caught) {
      return const SizedBox.shrink();
    }

    final size = largerTouch ? 64.0 : 56.0;
    final highlight = insect.highlight;

    return GestureDetector(
      onTap: insect.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 16,
        height: size + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (highlight > 0)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8 * highlight),
                    width: 3,
                  ),
                ),
              ),
            CustomPaint(
              size: Size(size, size),
              painter: insect.isFirefly
                  ? _FireflyPainter(
                      def: insect.def,
                      wingPhase: insect.wingPhase,
                      glowPhase: insect.glowPhase,
                    )
                  : _ButterflyPainter(
                      def: insect.def,
                      wingPhase: insect.wingPhase,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  _ButterflyPainter({
    required this.def,
    required this.wingPhase,
  });

  final InsectDef def;
  final double wingPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = 0.72 + math.sin(wingPhase).abs() * 0.28;
    final primary = Color(def.primaryColor);
    final accent = Color(def.wingColor);
    final body = Color(def.bodyColor);

    canvas.save();
    canvas.translate(cx, cy);

    _drawButterflyWing(
      canvas,
      center: const Offset(-10, -2),
      flap: flap,
      primary: primary,
      accent: accent,
      mirrored: false,
    );
    _drawButterflyWing(
      canvas,
      center: const Offset(10, -2),
      flap: flap,
      primary: primary,
      accent: accent,
      mirrored: true,
    );

    final bodyPaint = Paint()..color = body;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 5, height: 18),
      bodyPaint,
    );
    canvas.drawCircle(const Offset(0, -8), 3.2, bodyPaint);

    final antennaPaint = Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-1.5, -10), const Offset(-5, -16), antennaPaint);
    canvas.drawLine(const Offset(1.5, -10), const Offset(5, -16), antennaPaint);
    canvas.drawCircle(const Offset(-5, -16), 1.2, antennaPaint..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(5, -16), 1.2, antennaPaint);

    canvas.restore();
  }

  void _drawButterflyWing(
    Canvas canvas, {
    required Offset center,
    required double flap,
    required Color primary,
    required Color accent,
    required bool mirrored,
  }) {
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
    canvas.drawPath(upper, Paint()..color = primary.withValues(alpha: 0.92));
    canvas.drawPath(
      upper,
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
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
  bool shouldRepaint(covariant _ButterflyPainter old) =>
      old.wingPhase != wingPhase || old.def != def;
}

class _FireflyPainter extends CustomPainter {
  _FireflyPainter({
    required this.def,
    required this.wingPhase,
    required this.glowPhase,
  });

  final InsectDef def;
  final double wingPhase;
  final double glowPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = 0.65 + math.sin(wingPhase).abs() * 0.35;
    final glow = 0.55 + math.sin(glowPhase) * 0.35;
    final bodyColor = Color(def.bodyColor);
    final wingColor = Color(def.wingColor).withValues(alpha: 0.55);
    final glowColor = Color(def.glowColor);

    canvas.save();
    canvas.translate(cx, cy);

    final tailCenter = const Offset(0, 12);
    canvas.drawCircle(
      tailCenter,
      10 + glow * 6,
      Paint()
        ..color = glowColor.withValues(alpha: glow * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      tailCenter,
      5 + glow * 2,
      Paint()..color = glowColor.withValues(alpha: 0.35 + glow * 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: tailCenter, width: 7, height: 10),
      Paint()..color = glowColor.withValues(alpha: 0.75 + glow * 0.25),
    );

    _drawFireflyWing(canvas, center: const Offset(-8, -1), flap: flap, color: wingColor);
    _drawFireflyWing(canvas, center: const Offset(8, -1), flap: flap, color: wingColor, mirrored: true);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 5, height: 14),
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(const Offset(0, -7), 3.5, Paint()..color = bodyColor);

    final antennaPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-1.2, -9), const Offset(-4.5, -15), antennaPaint);
    canvas.drawLine(const Offset(1.2, -9), const Offset(4.5, -15), antennaPaint);

    canvas.drawCircle(const Offset(-1.8, -8), 0.9, Paint()..color = Colors.white70);
    canvas.drawCircle(const Offset(1.8, -8), 0.9, Paint()..color = Colors.white70);

    canvas.restore();
  }

  void _drawFireflyWing(
    Canvas canvas, {
    required Offset center,
    required double flap,
    required Color color,
    bool mirrored = false,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (mirrored) canvas.scale(-1, 1);
    canvas.scale(1, flap);

    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(10, -6, 14, 2)
      ..quadraticBezierTo(8, 8, 0, 6)
      ..close();
    canvas.drawPath(wing, Paint()..color = color);
    canvas.drawPath(
      wing,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter old) =>
      old.wingPhase != wingPhase ||
      old.glowPhase != glowPhase ||
      old.def != def;
}

class FrogTonguePainter extends CustomPainter {
  FrogTonguePainter({
    required this.frogX,
    required this.frogY,
    required this.tipX,
    required this.tipY,
    required this.progress,
    required this.visible,
  });

  final double frogX;
  final double frogY;
  final double tipX;
  final double tipY;
  final double progress;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || progress <= 0) return;

    final mouth = Offset(frogX, frogY - 24);
    final tip = Offset(tipX, tipY);
    final ctrl = Offset(
      (frogX + tipX) / 2 + (tipY - frogY) * 0.12,
      (frogY + tipY) / 2 - 36,
    );

    final path = Path()
      ..moveTo(mouth.dx, mouth.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE57373)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 7, Paint()..color = const Color(0xFFEF5350));
  }

  @override
  bool shouldRepaint(covariant FrogTonguePainter old) =>
      old.tipX != tipX ||
      old.tipY != tipY ||
      old.progress != progress ||
      old.visible != visible;
}
