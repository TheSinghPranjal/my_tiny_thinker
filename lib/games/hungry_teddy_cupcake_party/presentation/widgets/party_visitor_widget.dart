import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';

class PartyVisitorWidget extends StatelessWidget {
  const PartyVisitorWidget({
    super.key,
    required this.visitor,
    required this.onTap,
  });

  final PartyVisitorEntity visitor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (visitor.phase == PartyVisitorPhase.gone) return const SizedBox.shrink();

    final size = switch (visitor.kind) {
      PartyVisitorKind.balloon => 48.0,
      PartyVisitorKind.toyAnimal => 44.0,
      PartyVisitorKind.giftBox => 40.0,
      PartyVisitorKind.bird => 36.0,
    };

    return Positioned(
      left: visitor.x - size / 2,
      top: visitor.y - size / 2,
      child: GestureDetector(
        onTap: visitor.canTap ? onTap : null,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _VisitorPainter(visitor: visitor),
          ),
        ),
      ),
    );
  }
}

class _VisitorPainter extends CustomPainter {
  _VisitorPainter({required this.visitor});

  final PartyVisitorEntity visitor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final react = visitor.reactProgress;

    switch (visitor.kind) {
      case PartyVisitorKind.balloon:
        final colors = [0xFFF48FB1, 0xFF81D4FA, 0xFFFFF176];
        final c = Color(colors[visitor.id.hashCode.abs() % colors.length]);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy - react * 8), width: 34, height: 42),
          Paint()..color = c,
        );
        canvas.drawLine(
          Offset(cx, cy + 18),
          Offset(cx, size.height),
          Paint()..color = Colors.white70..strokeWidth = 1.5,
        );
      case PartyVisitorKind.toyAnimal:
        canvas.drawCircle(Offset(cx, cy), 16, Paint()..color = const Color(0xFF8D6E63));
        canvas.drawCircle(Offset(cx - 10, cy - 8), 6, Paint()..color = const Color(0xFF8D6E63));
        canvas.drawCircle(Offset(cx + 10, cy - 8), 6, Paint()..color = const Color(0xFF8D6E63));
        if (visitor.wasTapped) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx - 18, cy - 12), width: 14, height: 18),
            -0.4 + react,
            0.9,
            false,
            Paint()
              ..color = const Color(0xFF8D6E63)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round,
          );
        }
      case PartyVisitorKind.giftBox:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + react * 4), width: 34, height: 30),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFFEF5350),
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + react * 4), width: 34, height: 6),
          Paint()..color = const Color(0xFFFFEB3B),
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + react * 4), width: 6, height: 30),
          Paint()..color = const Color(0xFFFFEB3B),
        );
      case PartyVisitorKind.bird:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 28, height: 18),
          Paint()..color = const Color(0xFF42A5F5),
        );
        canvas.drawCircle(Offset(cx + 10, cy - 4), 8, Paint()..color = const Color(0xFF42A5F5));
        canvas.drawCircle(Offset(cx + 14, cy - 5), 2, Paint()..color = const Color(0xFF3E2723));
        if (visitor.wasTapped) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx - 6, cy - 10 - react * 10), width: 16, height: 12),
            math.pi,
            math.pi,
            false,
            Paint()
              ..color = const Color(0xFF1E88E5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant _VisitorPainter old) => old.visitor != visitor;
}
