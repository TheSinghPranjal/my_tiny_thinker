import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

class BananaWidget extends StatelessWidget {
  const BananaWidget({
    super.key,
    required this.banana,
    required this.onTap,
    this.largerTouch = false,
  });

  final BananaEntity banana;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (banana.phase == BananaPhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 72.0 : 64.0;
    final visual = 36.0 * banana.sizeScale;

    return GestureDetector(
      onTap: banana.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch,
        height: touch,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (banana.glow > 0)
              Container(
                width: touch * 0.9,
                height: touch * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFF176)
                          .withValues(alpha: banana.glow * 0.6),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            Transform.rotate(
              angle: banana.rotation,
              child: CustomPaint(
                size: Size(visual, visual * 1.4),
                painter: _BananaPainter(banana: banana),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BananaPainter extends CustomPainter {
  _BananaPainter({required this.banana});

  final BananaEntity banana;

  @override
  void paint(Canvas canvas, Size size) {
    final grow = banana.phase == BananaPhase.growing ? banana.growProgress : 1.0;
    final ripe = grow.clamp(0.0, 1.0);
    final green = Color.lerp(const Color(0xFF689F38), const Color(0xFFFFEB3B), ripe)!;
    final dark = Color.lerp(const Color(0xFF33691E), const Color(0xFFF9A825), ripe)!;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(0.4 + grow * 0.6, 0.4 + grow * 0.6);

    final path = Path()
      ..moveTo(-6, -size.height * 0.35)
      ..quadraticBezierTo(14, -size.height * 0.1, 10, size.height * 0.35)
      ..quadraticBezierTo(0, size.height * 0.42, -10, size.height * 0.3)
      ..quadraticBezierTo(-16, 0, -6, -size.height * 0.35)
      ..close();

    canvas.drawPath(path, Paint()..color = green);
    canvas.drawPath(
      path,
      Paint()
        ..color = dark.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -size.height * 0.38), width: 8, height: 5),
      Paint()..color = const Color(0xFF558B2F),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BananaPainter old) => old.banana != banana;
}

class FallingBananaWidget extends StatelessWidget {
  const FallingBananaWidget({super.key, required this.banana});

  final BananaEntity banana;

  @override
  Widget build(BuildContext context) {
    if (banana.phase != BananaPhase.falling && banana.phase != BananaPhase.tapped) {
      return const SizedBox.shrink();
    }
    final visual = 36.0 * banana.sizeScale;
    return Transform.rotate(
      angle: banana.rotation,
      child: CustomPaint(
        size: Size(visual, visual * 1.4),
        painter: _BananaPainter(
          banana: banana.copyWith(phase: BananaPhase.onTree, growProgress: 1),
        ),
      ),
    );
  }
}
