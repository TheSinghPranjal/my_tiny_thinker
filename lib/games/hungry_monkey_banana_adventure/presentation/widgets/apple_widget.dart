import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

class AppleWidget extends StatelessWidget {
  const AppleWidget({
    super.key,
    required this.apple,
    required this.onTap,
    this.largerTouch = false,
  });

  final AppleEntity apple;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (apple.phase == ApplePhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 68.0 : 60.0;
    final bounce = apple.phase == ApplePhase.appearing
        ? math.sin(apple.bounceProgress * math.pi) * 8
        : 0.0;
    final wobble = apple.phase == ApplePhase.wobble
        ? math.sin(apple.wobblePhase) * 6
        : 0.0;
    final alpha = apple.phase == ApplePhase.fading
        ? (1 - apple.fadeProgress).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: apple.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alpha,
        child: Transform.translate(
          offset: Offset(wobble, -bounce),
          child: SizedBox(
            width: touch,
            height: touch,
            child: CustomPaint(
              painter: _ApplePainter(wasTapped: apple.wasTapped),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplePainter extends CustomPainter {
  _ApplePainter({required this.wasTapped});

  final bool wasTapped;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 34, height: 36),
      Paint()
        ..color = wasTapped ? const Color(0xFFD32F2F) : const Color(0xFFE53935),
    );
    canvas.drawCircle(
      Offset(cx - 8, cy - 4),
      6,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 20), width: 4, height: 10),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 8, cy - 22), width: 14, height: 8),
      Paint()..color = const Color(0xFF43A047),
    );
  }

  @override
  bool shouldRepaint(covariant _ApplePainter old) => old.wasTapped != wasTapped;
}
