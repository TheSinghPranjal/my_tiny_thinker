import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class CloudPopBackground extends StatefulWidget {
  const CloudPopBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
    this.showRainbow = false,
    this.rainbowProgress = 0,
    this.intensity = 1.0,
  });

  final Widget child;
  final bool reducedMotion;
  final bool showRainbow;
  final double rainbowProgress;
  final double intensity;

  @override
  State<CloudPopBackground> createState() => _CloudPopBackgroundState();
}

class _CloudPopBackgroundState extends State<CloudPopBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
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
          painter: _CloudPopPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            showRainbow: widget.showRainbow,
            rainbowProgress: widget.rainbowProgress,
            intensity: widget.intensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _CloudPopPainter extends CustomPainter {
  _CloudPopPainter({
    required this.t,
    required this.showRainbow,
    required this.rainbowProgress,
    required this.intensity,
  });

  final double t;
  final bool showRainbow;
  final double rainbowProgress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
        ).createShader(sky),
    );

    _drawSun(canvas, size);
    if (showRainbow || rainbowProgress > 0.15) {
      _drawRainbow(canvas, size);
    }

    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.1 + i * 0.22) + t * size.width * 0.04 * (i.isOdd ? 1 : -1)) %
          (size.width + 80);
      final y = size.height * (0.08 + i * 0.04);
      _drawBgCloud(canvas, Offset(x - 40, y), 0.55 + i * 0.08, 0.35);
    }

    _drawGrass(canvas, size);
    _drawSparkles(canvas, size);
  }

  void _drawSun(Canvas canvas, Size size) {
    final sunCenter = Offset(size.width * 0.82, size.height * 0.12);
    for (var i = 0; i < 8; i++) {
      final angle = t * math.pi * 2 + i * math.pi / 4;
      canvas.drawLine(
        sunCenter,
        sunCenter + Offset(math.cos(angle) * 36, math.sin(angle) * 36),
        Paint()
          ..color = AppColors.sunYellow.withValues(alpha: 0.25)
          ..strokeWidth = 4,
      );
    }
    canvas.drawCircle(
      sunCenter,
      28,
      Paint()..color = AppColors.sunYellow.withValues(alpha: 0.85),
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final strength = showRainbow ? 1.0 : rainbowProgress.clamp(0.2, 0.9);
    final center = Offset(size.width * 0.5, size.height * 0.72);
    const colors = [
      Color(0xFFFF5252),
      Color(0xFFFFCA28),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFAB47BC),
    ];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width * (1.1 + i * 0.06) * strength,
          height: size.height * (0.55 + i * 0.04) * strength,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.45 * strength)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
    }
  }

  void _drawBgCloud(Canvas canvas, Offset c, double scale, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    canvas.drawCircle(c, 22 * scale, paint);
    canvas.drawCircle(c + Offset(24 * scale, 4), 18 * scale, paint);
    canvas.drawCircle(c + Offset(-20 * scale, 6), 16 * scale, paint);
  }

  void _drawGrass(Canvas canvas, Size size) {
    final groundY = size.height * 0.88;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = const Color(0xFF66BB6A),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 18),
      Paint()..color = const Color(0xFF81C784),
    );
    for (var i = 0; i < 24; i++) {
      final x = i * size.width / 24 + math.sin(t * math.pi * 2 + i) * 4;
      final blade = Path()
        ..moveTo(x, groundY + 6)
        ..quadraticBezierTo(x + 6, groundY - 8, x + 2, groundY - 14);
      canvas.drawPath(blade, Paint()..color = const Color(0xFF43A047));
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final x = (size.width * (i / 10) + t * 40) % size.width;
      final y = size.height * (0.15 + (i % 5) * 0.08);
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white.withValues(alpha: 0.35 + (i % 3) * 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(_CloudPopPainter old) =>
      old.t != t ||
      old.showRainbow != showRainbow ||
      old.rainbowProgress != rainbowProgress;
}
