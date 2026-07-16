import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';

class PondVisitorWidget extends StatelessWidget {
  const PondVisitorWidget({
    super.key,
    required this.visitor,
    required this.onTap,
    this.largerTouch = false,
  });

  final PondVisitorEntity visitor;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (visitor.phase == PondVisitorPhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 56.0 : 48.0;

    return GestureDetector(
      onTap: visitor.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch,
        height: touch,
        child: CustomPaint(
          painter: _VisitorPainter(visitor: visitor),
        ),
      ),
    );
  }
}

class _VisitorPainter extends CustomPainter {
  _VisitorPainter({required this.visitor});

  final PondVisitorEntity visitor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (visitor.kind) {
      case PondVisitorKind.turtle:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 4), width: 36, height: 22),
          Paint()..color = const Color(0xFF66BB6A),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 28, height: 18),
          Paint()..color = const Color(0xFF388E3C),
        );
        if (visitor.wasTapped) {
          canvas.drawCircle(Offset(cx + 14, cy - 10), 4, Paint()..color = const Color(0xFF8D6E63));
        }
      case PondVisitorKind.frog:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 6), width: 28, height: 20),
          Paint()..color = const Color(0xFF43A047),
        );
        canvas.drawCircle(Offset(cx - 6, cy - 4), 6, Paint()..color = const Color(0xFF66BB6A));
        canvas.drawCircle(Offset(cx + 6, cy - 4), 6, Paint()..color = const Color(0xFF66BB6A));
      case PondVisitorKind.dragonfly:
        final flap = math.sin(visitor.animPhase * 12).abs();
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: 6, height: 14),
          Paint()..color = const Color(0xFF00897B),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 10, cy - 2), width: 14, height: 8 * flap),
          Paint()..color = Colors.white.withValues(alpha: 0.5),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 10, cy - 2), width: 14, height: 8 * flap),
          Paint()..color = Colors.white.withValues(alpha: 0.5),
        );
      case PondVisitorKind.butterfly:
        final flap = 0.6 + math.sin(visitor.animPhase * 10).abs() * 0.4;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 8, cy), width: 12, height: 14 * flap),
          Paint()..color = const Color(0xFFEC407A).withValues(alpha: 0.85),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 8, cy), width: 12, height: 14 * flap),
          Paint()..color = const Color(0xFFAB47BC).withValues(alpha: 0.85),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _VisitorPainter old) => old.visitor != visitor;
}
