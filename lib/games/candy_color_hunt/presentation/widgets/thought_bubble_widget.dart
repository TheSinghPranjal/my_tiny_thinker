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
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: target.color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: target.accent, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: CandyPieceWidget(
                    candy: CandyEntity(
                      id: 'preview',
                      colorKind: target.kind,
                      style: CandyStyle.swirl,
                      slotIndex: 0,
                    ),
                    onTap: () {},
                    size: 72,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  target.name.toLowerCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: target.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(28, 16),
            painter: _BubbleTailPainter(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.8, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.35),
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.75),
      2.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) => old.color != color;
}
