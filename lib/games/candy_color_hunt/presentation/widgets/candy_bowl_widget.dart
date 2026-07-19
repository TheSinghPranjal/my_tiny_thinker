import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/presentation/widgets/candy_piece_widget.dart';

/// Floating candy field (no bowl) — candies scatter over the meadow.
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
    final candySize = largerTouch ? 128.0 : 112.0;
    final visible = candies.where((c) => !c.eaten).toList()
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    return _CandyField(
      candies: visible,
      candySize: candySize,
      onCandyTap: onCandyTap,
    );
  }
}

class _CandyField extends StatelessWidget {
  const _CandyField({
    required this.candies,
    required this.candySize,
    required this.onCandyTap,
  });

  final List<CandyEntity> candies;
  final double candySize;
  final void Function(String id) onCandyTap;

  /// Stable scatter offsets so candies feel natural, not grid-rigid.
  static const _jitter = <Offset>[
    Offset(0.02, -0.04),
    Offset(-0.03, 0.05),
    Offset(0.04, 0.02),
    Offset(-0.02, -0.03),
    Offset(0.01, 0.06),
    Offset(-0.04, 0.01),
    Offset(0.03, -0.05),
    Offset(-0.01, 0.03),
    Offset(0.05, 0.0),
    Offset(-0.05, -0.02),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 5;
        final rows = math.max(1, (candies.length / cols).ceil());
        final cellW = constraints.maxWidth / cols;
        final cellH = constraints.maxHeight / rows;
        // Prefer filling the cell so candies read large on screen.
        final maxSide = math.min(cellW, cellH);
        final size = math
            .min(candySize, maxSide * 0.98)
            .clamp(96.0, candySize)
            .toDouble();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < candies.length; i++)
              Positioned(
                left: _left(i, cols, cellW, size, constraints.maxWidth),
                top: _top(i, cols, cellH, size, constraints.maxHeight),
                width: size,
                height: size,
                child: CandyPieceWidget(
                  candy: candies[i],
                  size: size,
                  showGlow: true,
                  showMotionLines: true,
                  onTap: () => onCandyTap(candies[i].id),
                ),
              ),
          ],
        );
      },
    );
  }

  double _left(int i, int cols, double cellW, double size, double maxW) {
    final col = i % cols;
    final jitter = _jitter[i % _jitter.length];
    return (col * cellW + (cellW - size) / 2 + jitter.dx * cellW * 0.5)
        .clamp(0.0, math.max(0.0, maxW - size));
  }

  double _top(int i, int cols, double cellH, double size, double maxH) {
    final row = i ~/ cols;
    final jitter = _jitter[i % _jitter.length];
    return (row * cellH + (cellH - size) / 2 + jitter.dy * cellH * 0.5)
        .clamp(0.0, math.max(0.0, maxH - size));
  }
}
