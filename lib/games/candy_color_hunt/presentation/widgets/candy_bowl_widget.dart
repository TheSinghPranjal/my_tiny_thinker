import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_piece_widget.dart';

class CandyBowlWidget extends StatelessWidget {
  const CandyBowlWidget({
    super.key,
    required this.candies,
    required this.onCandyTap,
    this.largerTouch = true,
  });

  final List<CandyEntity> candies;
  final void Function(String id) onCandyTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final candySize = largerTouch ? 108.0 : 92.0;
    final visible = candies.where((c) => !c.eaten).toList()
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Bowl body
            Positioned(
              left: 12,
              right: 12,
              bottom: 0,
              height: constraints.maxHeight * 0.55,
              child: CustomPaint(painter: _BowlPainter()),
            ),
            // Candies in a non-overlapping grid
            Positioned(
              left: 20,
              right: 20,
              top: 8,
              bottom: constraints.maxHeight * 0.22,
              child: _CandyGrid(
                candies: visible,
                candySize: candySize,
                onCandyTap: onCandyTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CandyGrid extends StatelessWidget {
  const _CandyGrid({
    required this.candies,
    required this.candySize,
    required this.onCandyTap,
  });

  final List<CandyEntity> candies;
  final double candySize;
  final void Function(String id) onCandyTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 5;
        final rows = (candies.length / cols).ceil().clamp(1, 2).toDouble();
        final cellW = constraints.maxWidth / cols;
        final cellH = constraints.maxHeight / rows;
        final maxSide = math.min(cellW, cellH);
        final size =
            candySize.clamp(72.0, math.max(72.0, maxSide - 4)).toDouble();

        return Stack(
          children: [
            for (var i = 0; i < candies.length; i++)
              Positioned(
                left: (i % cols) * cellW + (cellW - size) / 2,
                top: (i ~/ cols) * cellH + (cellH - size) / 2,
                width: size,
                height: size,
                child: CandyPieceWidget(
                  candy: candies[i],
                  size: size,
                  onTap: () => onCandyTap(candies[i].id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BowlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rim = Path()
      ..moveTo(size.width * 0.08, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.02,
        size.width * 0.92,
        size.height * 0.18,
      )
      ..lineTo(size.width * 0.82, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 1.05,
        size.width * 0.18,
        size.height * 0.85,
      )
      ..close();

    canvas.drawPath(
      rim,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF59D),
            const Color(0xFFFFB74D),
            const Color(0xFFFF8A65),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      rim,
      Paint()
        ..color = const Color(0xFFFF7043)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Inner shine
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.22,
        size.width * 0.6,
        size.height * 0.2,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Decorative stripes
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.22 + i * 0.14);
      canvas.drawLine(
        Offset(x, size.height * 0.35),
        Offset(x + (i.isEven ? 4 : -4), size.height * 0.78),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
