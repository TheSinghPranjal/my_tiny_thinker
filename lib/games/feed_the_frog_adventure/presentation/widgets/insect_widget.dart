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

  static double layoutSize(bool largerTouch, {required bool isFirefly}) {
    if (isFirefly) return largerTouch ? 88.0 : 78.0;
    return largerTouch ? 100.0 : 90.0;
  }

  @override
  Widget build(BuildContext context) {
    if (insect.phase == InsectPhase.gone || insect.phase == InsectPhase.caught) {
      return const SizedBox.shrink();
    }

    final size = layoutSize(largerTouch, isFirefly: insect.isFirefly);
    final highlight = insect.highlight;

    return GestureDetector(
      onTap: insect.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 20,
        height: size + 20,
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
                    color: Colors.white.withValues(alpha: 0.85 * highlight),
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

/// Matches Catch the Butterfly Garden butterfly look.
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
    final flap = 0.62 + math.sin(wingPhase).abs() * 0.38;
    final primary = Color(def.primaryColor);
    final accent = Color(def.wingColor);
    final body = Color(def.bodyColor);

    canvas.save();
    canvas.translate(cx, cy);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 28), width: 34, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );

    _drawWing(canvas, const Offset(-6, 0), flap, primary, accent, mirrored: false);
    _drawWing(canvas, const Offset(6, 0), flap, primary, accent, mirrored: true);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 8, height: 28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(body, Colors.white, 0.15)!,
            body,
            Color.lerp(body, Colors.black, 0.2)!,
          ],
        ).createShader(const Rect.fromLTWH(-4, -8, 8, 28)),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-3, 2.0 + i * 6),
        Offset(3, 2.0 + i * 6),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..strokeWidth = 1,
      );
    }

    canvas.drawCircle(const Offset(0, -12), 6, Paint()..color = body);

    canvas.drawCircle(const Offset(-3.5, -13), 2.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(3.5, -13), 2.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-3, -12.5), 1.5, Paint()..color = const Color(0xFF1A237E));
    canvas.drawCircle(const Offset(4, -12.5), 1.5, Paint()..color = const Color(0xFF1A237E));
    canvas.drawCircle(const Offset(-2.4, -13.2), 0.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(4.6, -13.2), 0.6, Paint()..color = Colors.white);

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

    for (final p in [
      const Offset(12, -8),
      const Offset(22, -10),
      const Offset(28, -2),
      const Offset(16, 2),
    ]) {
      canvas.drawCircle(p, 2.2, Paint()..color = Colors.white.withValues(alpha: 0.4));
    }

    // Soft spots for variety
    canvas.drawCircle(const Offset(14, -6), 4, Paint()..color = accent.withValues(alpha: 0.45));
    canvas.drawCircle(const Offset(26, 0), 3, Paint()..color = Colors.white.withValues(alpha: 0.35));

    canvas.drawPath(
      upper,
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();

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
    final flap = 0.55 + math.sin(wingPhase).abs() * 0.45;
    final glow = 0.55 + math.sin(glowPhase) * 0.4;
    final bodyColor = Color(def.bodyColor);
    final wingColor = Color(def.wingColor).withValues(alpha: 0.6);
    final glowColor = Color(def.glowColor);

    canvas.save();
    canvas.translate(cx, cy);

    // Soft outer glow (bigger)
    canvas.drawCircle(
      const Offset(0, 10),
      22 + glow * 10,
      Paint()
        ..color = glowColor.withValues(alpha: glow * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      const Offset(0, 10),
      14 + glow * 4,
      Paint()..color = glowColor.withValues(alpha: 0.3 + glow * 0.35),
    );

    // Wings
    _drawWing(canvas, const Offset(-12, -2), flap, wingColor, left: true);
    _drawWing(canvas, const Offset(12, -2), flap, wingColor, left: false);

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 12, height: 22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(bodyColor, Colors.white, 0.15)!,
            bodyColor,
          ],
        ).createShader(const Rect.fromLTWH(-6, -9, 12, 22)),
    );

    // Glowing abdomen lantern
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 14), width: 14, height: 16),
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            glowColor,
            glowColor.withValues(alpha: 0.5),
          ],
        ).createShader(const Rect.fromLTWH(-7, 6, 14, 16)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 14), width: 8, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.55 + glow * 0.3),
    );

    // Head
    canvas.drawCircle(const Offset(0, -10), 7, Paint()..color = bodyColor);

    // Big cute eyes
    canvas.drawCircle(const Offset(-3.5, -11), 3.2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(3.5, -11), 3.2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-3, -10.5), 1.7, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(const Offset(4, -10.5), 1.7, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(const Offset(-2.4, -11.2), 0.7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(4.6, -11.2), 0.7, Paint()..color = Colors.white);

    // Antennae
    final ant = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(-2, -15)
        ..quadraticBezierTo(-8, -22, -10, -26),
      ant,
    );
    canvas.drawPath(
      Path()
        ..moveTo(2, -15)
        ..quadraticBezierTo(8, -22, 10, -26),
      ant,
    );
    canvas.drawCircle(const Offset(-10, -26), 2, Paint()..color = glowColor);
    canvas.drawCircle(const Offset(10, -26), 2, Paint()..color = glowColor);

    // Tiny legs
    for (final ox in [-4.0, 0.0, 4.0]) {
      canvas.drawLine(
        Offset(ox, 8),
        Offset(ox + 1, 16),
        Paint()
          ..color = bodyColor
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  void _drawWing(
    Canvas canvas,
    Offset center,
    double flap,
    Color color, {
    required bool left,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, flap);
    final wing = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(left ? -18 : 18, -16, left ? -10 : 10, -26)
      ..quadraticBezierTo(left ? 4 : -4, -12, 0, 0)
      ..close();
    canvas.drawPath(wing, Paint()..color = color);
    canvas.drawPath(
      wing,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
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

    final mouth = Offset(frogX, frogY - 12);
    final tip = Offset(tipX, tipY);
    final ctrl = Offset(
      (frogX + tipX) / 2 + (tipY - frogY) * 0.12,
      (frogY + tipY) / 2 - 40,
    );

    final path = Path()
      ..moveTo(mouth.dx, mouth.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFEF9A9A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE57373)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 9, Paint()..color = const Color(0xFFEF5350));
    canvas.drawCircle(
      tip.translate(-2, -2),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant FrogTonguePainter old) =>
      old.tipX != tipX ||
      old.tipY != tipY ||
      old.progress != progress ||
      old.visible != visible;
}
