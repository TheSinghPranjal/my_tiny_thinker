import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class PeekABooBackground extends StatefulWidget {
  const PeekABooBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final bool reducedMotion;
  final double intensity;

  @override
  State<PeekABooBackground> createState() => _PeekABooBackgroundState();
}

class _PeekABooBackgroundState extends State<PeekABooBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
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
          painter: _GardenPainter(
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

class _GardenPainter extends CustomPainter {
  _GardenPainter({required this.t, required this.intensity});

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFFC8E6C9)],
      ).createShader(sky);
    canvas.drawRect(sky, skyPaint);

    _drawHills(canvas, size);
    _drawCloud(canvas, size.width * 0.18, size.height * 0.12, 0.9, t);
    _drawCloud(canvas, size.width * 0.62, size.height * 0.08, 1.1, t + 0.3);
    _drawCloud(canvas, size.width * 0.85, size.height * 0.16, 0.7, t + 0.6);
    _drawSun(canvas, size);
    _drawButterfly(canvas, size, t);
    _drawFlowers(canvas, size, t);
    _drawSparkles(canvas, size, t);
  }

  void _drawHills(Canvas canvas, Size size) {
    final hillPaint = Paint()..color = const Color(0xFF66BB6A);
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.48,
        size.width * 0.5,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.6,
        size.width,
        size.height * 0.52,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, hillPaint);

    final front = Paint()..color = const Color(0xFF43A047);
    final path2 = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.7,
        size.height * 0.69,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.72,
        size.width,
        size.height * 0.66,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, front);
  }

  void _drawCloud(Canvas canvas, double x, double y, double scale, double phase) {
    final drift = math.sin(phase * math.pi * 2) * 12 * intensity;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.save();
    canvas.translate(x + drift, y);
    canvas.scale(scale);
    canvas.drawCircle(const Offset(0, 0), 22, paint);
    canvas.drawCircle(const Offset(24, 4), 18, paint);
    canvas.drawCircle(const Offset(-22, 6), 16, paint);
    canvas.restore();
  }

  void _drawSun(Canvas canvas, Size size) {
    final cx = size.width * 0.82;
    final cy = size.height * 0.14;
    final pulse = 1 + math.sin(t * math.pi * 2) * 0.04 * intensity;
    canvas.drawCircle(
      Offset(cx, cy),
      34 * pulse,
      Paint()..color = AppColors.sunYellow,
    );
    canvas.drawCircle(
      Offset(cx - 8, cy - 6),
      6,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    final rayPaint = Paint()
      ..color = AppColors.sunYellow.withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + t * math.pi;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * 42, cy + math.sin(angle) * 42),
        Offset(cx + math.cos(angle) * 58, cy + math.sin(angle) * 58),
        rayPaint,
      );
    }
  }

  void _drawButterfly(Canvas canvas, Size size, double phase) {
    final x = (size.width * 0.2 + phase * size.width * 0.6) % (size.width + 40) - 20;
    final y = size.height * 0.28 + math.sin(phase * math.pi * 4) * 18;
    final wing = math.sin(phase * math.pi * 8) * 0.35 + 0.65;
    canvas.save();
    canvas.translate(x, y);
    canvas.drawCircle(const Offset(0, 0), 4, Paint()..color = const Color(0xFF37474F));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, -2), width: 14, height: 10 * wing),
      Paint()..color = const Color(0xFFEC407A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(8, -2), width: 14, height: 10 * wing),
      Paint()..color = const Color(0xFFAB47BC),
    );
    canvas.restore();
  }

  void _drawFlowers(Canvas canvas, Size size, double phase) {
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.08 + i * 0.16);
      final sway = math.sin(phase * math.pi * 2 + i) * 3 * intensity;
      canvas.drawCircle(
        Offset(x + sway, size.height * 0.58),
        5,
        Paint()..color = const Color(0xFFFF80AB),
      );
      canvas.drawCircle(
        Offset(x + sway, size.height * 0.58),
        2,
        Paint()..color = AppColors.sunYellow,
      );
    }
  }

  void _drawSparkles(Canvas canvas, Size size, double phase) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 10; i++) {
      final x = size.width * ((i * 0.11 + phase * 0.2) % 1.0);
      final y = size.height * (0.2 + (i % 3) * 0.08);
      final s = 2 + math.sin(phase * math.pi * 2 + i) * 1.5;
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.intensity != intensity;
}
