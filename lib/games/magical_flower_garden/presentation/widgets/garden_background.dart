import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class GardenBackground extends StatefulWidget {
  const GardenBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
    this.showRainbow = false,
    this.showSunbeam = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final bool reducedMotion;
  final bool showRainbow;
  final bool showSunbeam;
  final double intensity;

  @override
  State<GardenBackground> createState() => _GardenBackgroundState();
}

class _GardenBackgroundState extends State<GardenBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
          painter: _GardenPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            showRainbow: widget.showRainbow,
            showSunbeam: widget.showSunbeam,
            intensity: widget.intensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GardenPainter extends CustomPainter {
  _GardenPainter({
    required this.t,
    required this.showRainbow,
    required this.showSunbeam,
    required this.intensity,
  });

  final double t;
  final bool showRainbow;
  final bool showSunbeam;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bg,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB3E5FC),
            Color(0xFFC8E6C9),
            Color(0xFFA5D6A7),
            Color(0xFF81C784),
          ],
        ).createShader(bg),
    );

    // Soft clouds
    for (var i = 0; i < 4; i++) {
      final cx = (size.width * (0.1 + i * 0.28) + t * size.width * 0.08) %
          (size.width + 120);
      _drawCloud(canvas, Offset(cx - 60, 40 + i * 18), 0.9 - i * 0.12);
    }

    // Sunbeam
    if (showSunbeam) {
      final beamX = size.width * 0.5;
      final path = Path()
        ..moveTo(beamX - 30, 0)
        ..lineTo(beamX + 80, size.height * 0.55)
        ..lineTo(beamX - 80, size.height * 0.55)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Rainbow arc
    if (showRainbow) {
      final colors = [
        const Color(0xFFFF5252),
        const Color(0xFFFFCA28),
        const Color(0xFF66BB6A),
        const Color(0xFF42A5F5),
        const Color(0xFFAB47BC),
      ];
      for (var i = 0; i < colors.length; i++) {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.15),
            width: size.width * 0.95,
            height: size.height * 0.45,
          ),
          math.pi * 0.05,
          math.pi * 0.9,
          false,
          Paint()
            ..color = colors[i].withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10,
        );
      }
    }

    // Distant butterflies
    for (var i = 0; i < 3; i++) {
      final bx = size.width * (0.15 + i * 0.32) +
          math.sin(t * math.pi * 2 + i) * 24;
      final by = size.height * (0.18 + i * 0.06) +
          math.cos(t * math.pi * 2 + i * 1.3) * 16;
      _drawMiniButterfly(canvas, Offset(bx, by), 0.55);
    }

    // Grass hill
    final grassPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.68,
        size.width * 0.5,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.8,
        size.width,
        size.height * 0.73,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, Paint()..color = const Color(0xFF66BB6A));

    // Grass blades
    for (var i = 0; i < 24; i++) {
      final gx = size.width * (i / 24);
      final sway = math.sin(t * math.pi * 2 + i) * 4;
      canvas.drawLine(
        Offset(gx, size.height * 0.78),
        Offset(gx + sway, size.height * 0.72),
        Paint()
          ..color = const Color(0xFF388E3C)
          ..strokeWidth = 2,
      );
    }

    // Flowers in grass
    final flowerColors = [
      AppColors.candyPink,
      AppColors.sunYellow,
      AppColors.lavender,
      AppColors.skyBlue,
    ];
    for (var i = 0; i < 10; i++) {
      final fx = size.width * (0.04 + i * 0.1);
      final fy = size.height * 0.84 + math.sin(t * math.pi * 2 + i) * 2;
      canvas.drawCircle(
        Offset(fx, fy),
        5,
        Paint()..color = flowerColors[i % flowerColors.length],
      );
    }

    // Fireflies / pollen
    for (var i = 0; i < 12; i++) {
      final px = size.width * ((i * 0.08 + t * 0.15) % 1.0);
      final py = size.height * (0.35 + (i % 5) * 0.08) +
          math.sin(t * math.pi * 4 + i) * 10;
      canvas.drawCircle(
        Offset(px, py),
        2.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35 + (i % 3) * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset c, double alpha) {
    for (final o in [
      Offset(0, 0),
      Offset(22, -6),
      Offset(44, 0),
      Offset(18, 8),
    ]) {
      canvas.drawCircle(
        c + o,
        18,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawMiniButterfly(Canvas canvas, Offset c, double scale) {
    final paint = Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-8 * scale, 0), width: 14 * scale, height: 18 * scale),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(8 * scale, 0), width: 14 * scale, height: 18 * scale),
      paint..color = const Color(0xFF81D4FA).withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_GardenPainter old) =>
      old.t != t ||
      old.showRainbow != showRainbow ||
      old.showSunbeam != showSunbeam ||
      old.intensity != intensity;
}
