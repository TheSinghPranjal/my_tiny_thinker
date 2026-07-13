import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Animated underwater background with seaweed, bubbles, and light rays.
class OceanBackground extends StatefulWidget {
  const OceanBackground({
    super.key,
    required this.child,
    this.bubbleDensity = 1.0,
    this.reducedMotion = false,
  });

  final Widget child;
  final double bubbleDensity;
  final bool reducedMotion;

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (!widget.reducedMotion) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OceanPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            bubbleDensity: widget.bubbleDensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _OceanPainter extends CustomPainter {
  _OceanPainter({required this.t, required this.bubbleDensity});

  final double t;
  final double bubbleDensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Deep ocean gradient
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FC3F7),
            Color(0xFF0288D1),
            Color(0xFF01579B),
            Color(0xFF004D73),
          ],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(bg),
    );

    // Sunlight rays
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.15 + i * 0.18) + math.sin(t * math.pi * 2 + i) * 20;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 40, size.height * 0.6)
        ..lineTo(x - 40, size.height * 0.6)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Colors.white.withValues(alpha: 0.04 + i * 0.008),
      );
    }

    // Sandy bottom
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
      Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.35),
    );

    // Seaweed
    for (var i = 0; i < 6; i++) {
      final bx = size.width * (0.08 + i * 0.17);
      _drawSeaweed(canvas, bx, size.height * 0.88, 40 + i * 8, t + i * 0.3);
    }

    // Distant tiny fish
    for (var i = 0; i < 4; i++) {
      final fx = (size.width * (i * 0.25) + t * 80) % (size.width + 40) - 20;
      final fy = size.height * (0.2 + i * 0.12);
      canvas.drawCircle(
        Offset(fx, fy),
        3,
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
    }

    // Floating bubbles
    final count = (12 * bubbleDensity).round();
    for (var i = 0; i < count; i++) {
      final bx = (size.width * (i / count) + t * 30 + i * 17) % size.width;
      final by = size.height - ((t * 200 + i * 45) % (size.height + 60));
      canvas.drawCircle(
        Offset(bx, by),
        2 + (i % 4).toDouble(),
        Paint()..color = Colors.white.withValues(alpha: 0.15 + (i % 3) * 0.05),
      );
    }

    // Coral dots
    for (var i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.05 + i * 0.12), size.height * 0.9),
        6 + (i % 3) * 2,
        Paint()
          ..color = [
            AppColors.candyPink,
            AppColors.orange,
            AppColors.mintGreen,
          ][i % 3]
              .withValues(alpha: 0.5),
      );
    }
  }

  void _drawSeaweed(Canvas canvas, double x, double baseY, double h, double phase) {
    final path = Path()..moveTo(x, baseY);
    for (var i = 0; i <= 8; i++) {
      final py = baseY - h * (i / 8);
      final px = x + math.sin(phase * 2 + i * 0.5) * 12;
      path.lineTo(px, py);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_OceanPainter old) => old.t != t;
}
