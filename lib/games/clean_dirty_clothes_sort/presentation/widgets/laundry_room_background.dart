import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cheerful cartoon laundry room with animated bubbles and sunshine.
class LaundryRoomBackground extends StatelessWidget {
  const LaundryRoomBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.roomGlow = 0,
    this.bubbleEffects = true,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final double roomGlow;
  final bool bubbleEffects;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _LaundryRoomPainter(
            envPhase: envPhase,
            roomGlow: roomGlow,
            reducedMotion: reducedMotion,
          ),
        ),
        if (bubbleEffects && !reducedMotion)
          ...List.generate(6, (i) {
            final phase = envPhase + i * 1.3;
            return Positioned(
              left: (math.sin(phase * 0.4 + i) * 0.5 + 0.5) *
                  MediaQuery.sizeOf(context).width,
              bottom: 80 + math.sin(phase + i) * 30 + i * 18,
              child: Opacity(
                opacity: 0.35 + math.sin(phase) * 0.15,
                child: Text(
                  '🫧',
                  style: TextStyle(fontSize: 14 + i * 3.0),
                ),
              ),
            );
          }),
        child,
      ],
    );
  }
}

class _LaundryRoomPainter extends CustomPainter {
  const _LaundryRoomPainter({
    required this.envPhase,
    required this.roomGlow,
    required this.reducedMotion,
  });

  final double envPhase;
  final double roomGlow;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wallpaper gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFFB3E5FC),
              const Color(0xFFE1F5FE),
              roomGlow * 0.4,
            )!,
            Color.lerp(
              const Color(0xFFFFF9C4),
              const Color(0xFFFFFDE7),
              roomGlow * 0.3,
            )!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Floor
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.78, w, h * 0.22),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
        ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.22)),
    );

    // Window
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, h * 0.06, w * 0.3, h * 0.18),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      windowRect,
      Paint()..color = const Color(0xFF81D4FA),
    );
    canvas.drawRRect(
      windowRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white,
    );

    // Sunshine
    if (!reducedMotion) {
      final sunX = w * 0.72 + math.sin(envPhase * 0.3) * 8;
      canvas.drawCircle(
        Offset(sunX, h * 0.1),
        28,
        Paint()..color = const Color(0xFFFFEE58).withValues(alpha: 0.7),
      );
    }

    // Rainbow curtains
    final curtainPaint = Paint()..color = const Color(0xFFF48FB1);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.32, h * 0.04, w * 0.08, h * 0.22),
      curtainPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.6, h * 0.04, w * 0.08, h * 0.22),
      Paint()..color = const Color(0xFFCE93D8),
    );

    // Flower pot on windowsill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.22, w * 0.12, h * 0.04),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.21),
      10,
      Paint()..color = const Color(0xFF66BB6A),
    );
  }

  @override
  bool shouldRepaint(_LaundryRoomPainter old) =>
      old.envPhase != envPhase ||
      old.roomGlow != roomGlow ||
      old.reducedMotion != reducedMotion;
}
