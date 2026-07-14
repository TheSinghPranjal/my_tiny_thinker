import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class PondBackground extends StatefulWidget {
  const PondBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final bool reducedMotion;
  final double intensity;

  @override
  State<PondBackground> createState() => _PondBackgroundState();
}

class _PondBackgroundState extends State<PondBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
          painter: _PondPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            intensity: widget.intensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _PondPainter extends CustomPainter {
  _PondPainter({required this.t, required this.intensity});

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawClouds(canvas, size);
    _drawReeds(canvas, size);
    _drawWater(canvas, size);
    _drawFish(canvas, size);
    _drawBubbles(canvas, size);
    _drawFlowers(canvas, size);
    _drawDragonfly(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFF4DD0E1)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.12),
      36,
      Paint()..color = AppColors.sunYellow,
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.1 + i * 0.35) + t * size.width * 0.05) %
          (size.width + 80);
      canvas.drawCircle(Offset(x, size.height * (0.1 + i * 0.03)), 20, paint);
      canvas.drawCircle(Offset(x + 22, size.height * (0.11 + i * 0.03)), 16, paint);
    }
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterTop = size.height * 0.38;
    final waterRect = Rect.fromLTWH(0, waterTop, size.width, size.height - waterTop);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4FC3F7).withValues(alpha: 0.85),
            const Color(0xFF0288D1).withValues(alpha: 0.92),
          ],
        ).createShader(waterRect),
    );

    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 5; i++) {
      final y = waterTop + 20 + i * 28 + math.sin(t * math.pi * 2 + i) * 4 * intensity;
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 24) {
        path.lineTo(x, y + math.sin((x / 40) + t * math.pi * 2 + i) * 5);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF558B2F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.04 + i * 0.12);
      final sway = math.sin(t * math.pi * 2 + i) * 8 * intensity;
      canvas.drawLine(
        Offset(x, size.height * 0.34),
        Offset(x + sway, size.height * 0.58),
        paint,
      );
    }
  }

  void _drawFish(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final x = (size.width * 0.15 + i * 0.22 + t * 0.15) % 1.0 * size.width;
      final y = size.height * (0.62 + (i % 2) * 0.08);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 18, height: 10),
        Paint()..color = const Color(0xFFFF7043).withValues(alpha: 0.55),
      );
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 0.09 + t * 0.12) % 1.0);
      final y = size.height * (0.55 + ((i * 0.07 + t * 0.2) % 0.35));
      canvas.drawCircle(Offset(x, y), 2 + (i % 3), paint);
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.06 + i * 0.2);
      canvas.drawCircle(
        Offset(x, size.height * 0.36),
        6,
        Paint()..color = const Color(0xFFFF80AB),
      );
    }
  }

  void _drawDragonfly(Canvas canvas, Size size) {
    final x = size.width * (0.3 + t * 0.4) % size.width;
    final y = size.height * 0.32 + math.sin(t * math.pi * 4) * 12;
    canvas.drawCircle(Offset(x, y), 3, Paint()..color = const Color(0xFF37474F));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x - 8, y - 2), width: 12, height: 6),
      Paint()..color = const Color(0xFF29B6F6).withValues(alpha: 0.7),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x + 8, y - 2), width: 12, height: 6),
      Paint()..color = const Color(0xFF29B6F6).withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant _PondPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.intensity != intensity;
}
