import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/candy_color_hunt/models/candy_color_hunt_models.dart';

class CandyPieceWidget extends StatelessWidget {
  const CandyPieceWidget({
    super.key,
    required this.candy,
    required this.onTap,
    this.size = 100,
  });

  final CandyEntity candy;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (candy.eaten) return const SizedBox.shrink();

    final wiggle = math.sin(candy.wigglePhase) * 4;
    final bounce = math.cos(candy.wigglePhase * 1.2) * 3;
    final shake = candy.wrongShake ? math.sin(candy.wigglePhase * 12) * 8 : 0.0;
    final pulse =
        candy.pulseHint ? 1 + math.sin(candy.wigglePhase * 6) * 0.12 : 1.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(wiggle + shake, bounce),
        child: Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CandyPainter(candy: candy),
            ),
          ),
        ),
      ),
    );
  }
}

class _CandyPainter extends CustomPainter {
  _CandyPainter({required this.candy});
  final CandyEntity candy;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final def = candy.colorDef;
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [def.accent, def.color, def.color.withValues(alpha: 0.9)],
        stops: const [0.15, 0.55, 1],
      ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.4));

    switch (candy.style) {
      case CandyStyle.jelly:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: c,
              width: size.width * 0.7,
              height: size.height * 0.55,
            ),
            const Radius.circular(20),
          ),
          fill,
        );
        break;
      case CandyStyle.wrapped:
        canvas.drawOval(
          Rect.fromCenter(
            center: c,
            width: size.width * 0.5,
            height: size.height * 0.42,
          ),
          fill,
        );
        final wrap = Paint()
          ..color = def.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawLine(
          c + Offset(-size.width * 0.35, 0),
          c + Offset(-size.width * 0.15, 0),
          wrap,
        );
        canvas.drawLine(
          c + Offset(size.width * 0.15, 0),
          c + Offset(size.width * 0.35, 0),
          wrap,
        );
        canvas.drawCircle(
          c + Offset(-size.width * 0.38, 0),
          6,
          Paint()..color = def.color,
        );
        canvas.drawCircle(
          c + Offset(size.width * 0.38, 0),
          6,
          Paint()..color = def.color,
        );
        break;
      case CandyStyle.hard:
        canvas.drawCircle(c, size.width * 0.32, fill);
        canvas.drawCircle(
          c + Offset(-size.width * 0.1, -size.height * 0.1),
          size.width * 0.08,
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
        break;
      case CandyStyle.gummy:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: c,
              width: size.width * 0.55,
              height: size.height * 0.65,
            ),
            const Radius.circular(16),
          ),
          fill,
        );
        canvas.drawCircle(
          c + Offset(0, -size.height * 0.12),
          size.width * 0.08,
          Paint()..color = Colors.white.withValues(alpha: 0.4),
        );
        break;
      case CandyStyle.swirl:
        canvas.drawCircle(c, size.width * 0.34, fill);
        final swirl = Paint()
          ..color = Colors.white.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        final path = Path();
        for (var i = 0; i < 40; i++) {
          final a = i / 40 * math.pi * 3;
          final r = size.width * 0.05 + i / 40 * size.width * 0.26;
          final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(path, swirl);
        break;
    }

    if (candy.colorKind == CandyColorKind.white ||
        candy.colorKind == CandyColorKind.silver ||
        candy.colorKind == CandyColorKind.grey) {
      canvas.drawCircle(
        c,
        size.width * 0.34,
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (candy.pulseHint) {
      canvas.drawCircle(
        c,
        size.width * 0.42,
        Paint()
          ..color = def.color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandyPainter old) => old.candy != candy;
}
