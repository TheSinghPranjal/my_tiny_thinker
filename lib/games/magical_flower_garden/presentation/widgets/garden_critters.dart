import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/magical_flower_garden/models/flower_garden_models.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterflies.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterfly_painter.dart';

class PollinatorWidget extends StatelessWidget {
  const PollinatorWidget({super.key, required this.pollinator});

  final PollinatorEntity pollinator;

  @override
  Widget build(BuildContext context) {
    final isButterfly = pollinator.kind == PollinatorKind.butterfly;
    final size = isButterfly ? 88.0 : 44.0;
    final sipping = pollinator.phase == PollinatorPhase.collecting;

    return Positioned(
      left: pollinator.x - size / 2,
      top: pollinator.y - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: isButterfly ? 0 : pollinator.rotation,
          child: isButterfly
              ? CustomPaint(
                  size: Size(size, size),
                  painter: GardenButterflyPainter(
                    def: GardenButterflies.byIndex(pollinator.varietyIndex),
                    wingPhase: pollinator.wingPhase,
                    fastFlap: sipping ||
                        pollinator.phase == PollinatorPhase.entering,
                  ),
                )
              : CustomPaint(
                  size: Size(size, size),
                  painter: _BeePainter(wingPhase: pollinator.wingPhase),
                ),
        ),
      ),
    );
  }
}

class BirdWidget extends StatelessWidget {
  const BirdWidget({
    super.key,
    required this.bird,
    required this.onTap,
  });

  final BirdEntity bird;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return Positioned(
      left: bird.x - size / 2,
      top: bird.y - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: bird.isTappable ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Transform.rotate(
          angle: bird.rotation,
          child: CustomPaint(
            size: const Size(size, size),
            painter: _BirdPainter(
              wingPhase: bird.wingPhase,
              scared: bird.phase == BirdPhase.scared,
            ),
          ),
        ),
      ),
    );
  }
}

class _BeePainter extends CustomPainter {
  _BeePainter({required this.wingPhase});

  final double wingPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = math.sin(wingPhase) * 0.35;

    for (final sign in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + sign * 14, cy - 8 + flap * 6),
          width: 18,
          height: 12 + flap.abs() * 8,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 22, height: 28),
      Paint()..color = const Color(0xFFFFCA28),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 10, cy - 2 + i * 8.0),
        Offset(cx + 10, cy - 2 + i * 8.0),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2.5,
      );
    }

    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(cx + sign * 5, cy - 2),
        3,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(cx + sign * 5 + 1, cy - 2),
        1.5,
        Paint()..color = Colors.black87,
      );
    }
  }

  @override
  bool shouldRepaint(_BeePainter old) => old.wingPhase != wingPhase;
}

class _BirdPainter extends CustomPainter {
  _BirdPainter({required this.wingPhase, required this.scared});

  final double wingPhase;
  final bool scared;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final flap = math.sin(wingPhase * (scared ? 2.5 : 1.2)) * 0.5;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 6), width: 20, height: 22),
      Paint()..color = const Color(0xFFFF7043),
    );

    canvas.drawCircle(
      Offset(cx + 10, cy),
      10,
      Paint()..color = const Color(0xFFFF8A65),
    );

    canvas.drawCircle(Offset(cx + 14, cy - 2), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 15, cy - 2), 1.2, Paint()..color = Colors.black87);

    for (final sign in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + sign * (16 + flap * 10), cy - 4),
          width: 24,
          height: 14 + flap.abs() * 8,
        ),
        Paint()..color = const Color(0xFFFFAB91),
      );
    }

    if (scared) {
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(cx - 8 + i * 6.0, cy + 18),
          2,
          Paint()..color = const Color(0xFFFFF59D),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BirdPainter old) =>
      old.wingPhase != wingPhase || old.scared != scared;
}
