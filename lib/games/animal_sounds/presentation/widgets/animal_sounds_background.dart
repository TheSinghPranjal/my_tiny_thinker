import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Bright meadow / farm sky for Animal Sounds — kid-friendly and playful.
class AnimalSoundsBackground extends StatefulWidget {
  const AnimalSoundsBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimalSoundsBackground> createState() => _AnimalSoundsBackgroundState();
}

class _AnimalSoundsBackgroundState extends State<AnimalSoundsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _MeadowPainter(t: _ctrl.value),
              child: const SizedBox.expand(),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _MeadowPainter extends CustomPainter {
  _MeadowPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF81D4FA),
          Color(0xFFFFF59D),
          Color(0xFFA5D6A7),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    // Soft sun
    final sunX = size.width * 0.82;
    final sunY = size.height * 0.14;
    canvas.drawCircle(
      Offset(sunX, sunY),
      42,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(sunX, sunY),
      58,
      Paint()..color = const Color(0xFFFFECB3).withValues(alpha: 0.35),
    );

    // Floating clouds
    _cloud(canvas, Offset(size.width * 0.18 + math.sin(t * math.pi * 2) * 12,
        size.height * 0.12), 1.1);
    _cloud(canvas, Offset(size.width * 0.55 + math.cos(t * math.pi * 2) * 10,
        size.height * 0.08), 0.85);

    // Rolling hills
    final hillPaint = Paint()..color = const Color(0xFF66BB6A);
    final hillPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.62 + math.sin(t * math.pi * 2) * 4,
        size.width * 0.5,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.82,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    final frontHill = Paint()..color = const Color(0xFF43A047);
    final front = Path()
      ..moveTo(0, size.height * 0.86)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.78 + math.cos(t * math.pi * 2) * 3,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, frontHill);

    // Decorative dots (flowers)
    final flowerColors = [
      AppColors.candyPink,
      AppColors.sunYellow,
      const Color(0xFFCE93D8),
      AppColors.skyBlue,
    ];
    for (var i = 0; i < 10; i++) {
      final fx = size.width * ((i * 0.11 + 0.05) % 1.0);
      final fy = size.height * (0.78 + (i % 3) * 0.05);
      canvas.drawCircle(
        Offset(fx, fy),
        5,
        Paint()..color = flowerColors[i % flowerColors.length],
      );
    }
  }

  void _cloud(Canvas canvas, Offset c, double scale) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(c, 18 * scale, p);
    canvas.drawCircle(c + Offset(-22 * scale, 4), 14 * scale, p);
    canvas.drawCircle(c + Offset(20 * scale, 6), 15 * scale, p);
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter oldDelegate) =>
      oldDelegate.t != t;
}
