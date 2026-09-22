import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/shared/flying_insect_painters.dart';

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
                  ? FireflyPainter(
                      def: insect.def,
                      wingPhase: insect.wingPhase,
                      glowPhase: insect.glowPhase,
                    )
                  : FlyingInsectButterflyPainter(
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
