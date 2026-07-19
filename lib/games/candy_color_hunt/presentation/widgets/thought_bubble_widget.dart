import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_piece_widget.dart';

class ThoughtBubbleWidget extends StatelessWidget {
  const ThoughtBubbleWidget({
    super.key,
    required this.target,
    required this.scale,
  });

  final CandyColorDef target;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D4037).withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: target.color.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFFF3E0),
                width: 4,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Find this candy!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6D4C41),
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Same wrapped candy the player must tap (color-matched pattern).
                IgnorePointer(
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: CustomPaint(
                      painter: CandyPainter(
                        colorDef: target,
                        pattern: candyPatternFor(target.kind),
                        showGlow: false,
                        showMotionLines: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(36, 18),
            painter: _BubbleTailPainter(
              fill: Colors.white.withValues(alpha: 0.97),
              border: const Color(0xFFFFF3E0),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.fill, required this.border});
  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.28, 0)
      ..lineTo(size.width * 0.5, size.height * 0.85)
      ..lineTo(size.width * 0.72, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Thought dots
    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.35),
      3.5,
      Paint()..color = fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.72),
      2.4,
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) =>
      old.fill != fill || old.border != border;
}
