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
            Color(0xFF81D4FA),
            Color(0xFFB3E5FC),
            Color(0xFFFFF9C4),
            Color(0xFFC8E6C9),
            Color(0xFF81C784),
          ],
          stops: [0.0, 0.28, 0.5, 0.72, 1.0],
        ).createShader(bg),
    );

    // Soft sun
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      36,
      Paint()
        ..color = const Color(0xFFFFF176).withValues(alpha: 0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      52,
      Paint()
        ..color = const Color(0xFFFFECB3).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    for (var i = 0; i < 4; i++) {
      final cx = (size.width * (0.08 + i * 0.28) + t * size.width * 0.08) %
          (size.width + 120);
      _drawCloud(canvas, Offset(cx - 60, 36 + i * 16.0), 0.92 - i * 0.1);
    }

    // Always a soft rainbow; brighter while flower is blooming.
    _drawRainbow(canvas, size, showRainbow ? 0.7 : 0.38);

    if (showSunbeam) {
      final beamX = size.width * 0.5;
      final path = Path()
        ..moveTo(beamX - 30, 0)
        ..lineTo(beamX + 90, size.height * 0.55)
        ..lineTo(beamX - 90, size.height * 0.55)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.16 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    for (var i = 0; i < 3; i++) {
      final bx = size.width * (0.15 + i * 0.32) +
          math.sin(t * math.pi * 2 + i) * 24;
      final by = size.height * (0.2 + i * 0.05) +
          math.cos(t * math.pi * 2 + i * 1.3) * 16;
      _drawMiniButterfly(canvas, Offset(bx, by), 0.6 + i * 0.08);
    }

    final farHill = Path()
      ..moveTo(0, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.58,
        size.width * 0.55,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.72,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farHill, Paint()..color = const Color(0xFF81C784));

    final grassPath = Path()
      ..moveTo(0, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.76,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.82,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, Paint()..color = const Color(0xFF66BB6A));

    for (var i = 0; i < 28; i++) {
      final gx = size.width * (i / 28);
      final sway = math.sin(t * math.pi * 2 + i) * 5;
      canvas.drawLine(
        Offset(gx, size.height * 0.8),
        Offset(gx + sway, size.height * 0.72),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    final flowerColors = [
      AppColors.candyPink,
      AppColors.sunYellow,
      AppColors.lavender,
      AppColors.skyBlue,
      const Color(0xFFFF7043),
      const Color(0xFF26C6DA),
    ];
    for (var i = 0; i < 12; i++) {
      final fx = size.width * (0.03 + i * 0.085);
      final fy = size.height * 0.86 + math.sin(t * math.pi * 2 + i) * 3;
      final color = flowerColors[i % flowerColors.length];
      canvas.drawLine(
        Offset(fx, fy + 10),
        Offset(fx, fy + 22),
        Paint()
          ..color = const Color(0xFF388E3C)
          ..strokeWidth = 2,
      );
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(fx + math.cos(a) * 6, fy + math.sin(a) * 6),
          4.5,
          Paint()..color = color,
        );
      }
      canvas.drawCircle(Offset(fx, fy), 3.5, Paint()..color = const Color(0xFFFFF176));
    }

    for (var i = 0; i < 14; i++) {
      final px = size.width * ((i * 0.07 + t * 0.18) % 1.0);
      final py = size.height * (0.32 + (i % 5) * 0.07) +
          math.sin(t * math.pi * 4 + i) * 12;
      canvas.drawCircle(
        Offset(px, py),
        2.8,
        Paint()
          ..color = [
            const Color(0xFFFFF59D),
            const Color(0xFFFF80AB),
            Colors.white,
          ][i % 3]
              .withValues(alpha: 0.45 + (i % 3) * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawRainbow(Canvas canvas, Size size, double alpha) {
    const colors = [
      Color(0xFFEF5350),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFF7E57C2),
      Color(0xFFEC407A),
    ];
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final baseW = size.width * 1.08;
    final baseH = size.height * 0.55;
    for (var i = 0; i < colors.length; i++) {
      final shrink = i * 13.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: baseW - shrink,
          height: baseH - shrink * 0.55,
        ),
        // Clockwise from ~9 o'clock through the TOP → upright rainbow.
        math.pi + 0.08,
        math.pi - 0.16,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset c, double alpha) {
    for (final o in [
      Offset.zero,
      const Offset(22, -6),
      const Offset(44, 0),
      const Offset(18, 8),
    ]) {
      canvas.drawCircle(
        c + o,
        18,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawMiniButterfly(Canvas canvas, Offset c, double scale) {
    final colors = [
      const Color(0xFFFF80AB),
      const Color(0xFF81D4FA),
      const Color(0xFFFFEE58),
    ];
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-9 * scale, 0),
        width: 16 * scale,
        height: 20 * scale,
      ),
      Paint()..color = colors[0].withValues(alpha: 0.75),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(9 * scale, 0),
        width: 16 * scale,
        height: 20 * scale,
      ),
      Paint()..color = colors[1].withValues(alpha: 0.75),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 4 * scale, height: 14 * scale),
      Paint()..color = const Color(0xFF5D4037).withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_GardenPainter old) =>
      old.t != t ||
      old.showRainbow != showRainbow ||
      old.showSunbeam != showSunbeam ||
      old.intensity != intensity;
}
