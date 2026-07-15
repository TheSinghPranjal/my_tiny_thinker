import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class FeedPondBackground extends StatefulWidget {
  const FeedPondBackground({
    super.key,
    required this.child,
    required this.nightFactor,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double nightFactor;
  final bool reducedMotion;
  final double intensity;

  @override
  State<FeedPondBackground> createState() => _FeedPondBackgroundState();
}

class _FeedPondBackgroundState extends State<FeedPondBackground>
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
          painter: _FeedPondPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
            night: widget.nightFactor.clamp(0.0, 1.0),
            intensity: widget.intensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _FeedPondPainter extends CustomPainter {
  _FeedPondPainter({
    required this.t,
    required this.night,
    required this.intensity,
  });

  final double t;
  final double night;
  final double intensity;

  Color _lerp(Color day, Color nite) => Color.lerp(day, nite, night)!;

  @override
  void paint(Canvas canvas, Size size) {
    final skyTop = _lerp(const Color(0xFF81D4FA), const Color(0xFF1A237E));
    final skyMid = _lerp(const Color(0xFFB3E5FC), const Color(0xFF283593));
    final skyBot = _lerp(const Color(0xFFC8E6C9), const Color(0xFF1B5E20));

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyMid, skyBot],
        ).createShader(rect),
    );

    if (night > 0.2) _drawStars(canvas, size);
    if (night > 0.35) _drawMoon(canvas, size);
    if (night < 0.8) _drawSun(canvas, size);

    _drawClouds(canvas, size);
    _drawHills(canvas, size);
    _drawWater(canvas, size);
    _drawReeds(canvas, size);
    _drawFlowers(canvas, size);
    _drawFish(canvas, size);
    _drawBubbles(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.5 * night);
    for (var i = 0; i < 24; i++) {
      final x = size.width * ((i * 0.13 + 0.05) % 1.0);
      final y = size.height * (0.04 + (i % 5) * 0.035);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * 0.4, paint);
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.1),
      28,
      Paint()..color = Color.lerp(AppColors.sunYellow, const Color(0xFFECEFF1), night)!,
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    final alpha = (1 - night).clamp(0.0, 1.0);
    if (alpha <= 0.05) return;
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.11),
      30 * alpha,
      Paint()..color = AppColors.sunYellow.withValues(alpha: alpha),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88 * (1 - night * 0.5));
    final x = size.width * 0.2 + math.sin(t * math.pi * 2) * 10;
    canvas.drawCircle(Offset(x, size.height * 0.1), 20, paint);
    canvas.drawCircle(Offset(x + 22, size.height * 0.11), 16, paint);
  }

  void _drawHills(Canvas canvas, Size size) {
    final hill = Paint()..color = _lerp(const Color(0xFF66BB6A), const Color(0xFF1B5E20));
    final path = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.36, size.width, size.height * 0.44)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(0, size.height * 0.58)
      ..close();
    canvas.drawPath(path, hill);
  }

  void _drawWater(Canvas canvas, Size size) {
    final top = size.height * 0.42;
    final waterRect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lerp(const Color(0xFF4FC3F7), const Color(0xFF01579B)).withValues(alpha: 0.88),
            _lerp(const Color(0xFF0288D1), const Color(0xFF002171)).withValues(alpha: 0.94),
          ],
        ).createShader(waterRect),
    );
    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.1 * (1 - night * 0.4))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 4; i++) {
      final y = top + 18 + i * 24 + math.sin(t * math.pi * 2 + i) * 3;
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 20) {
        path.lineTo(x, y + math.sin(x / 36 + t * math.pi * 2) * 4);
      }
      canvas.drawPath(path, wave);
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lerp(const Color(0xFF558B2F), const Color(0xFF33691E))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.05 + i * 0.16);
      final sway = math.sin(t * math.pi * 2 + i) * 6 * intensity;
      canvas.drawLine(
        Offset(x, size.height * 0.4),
        Offset(x + sway, size.height * 0.56),
        paint,
      );
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final scale = 1 - night * 0.35;
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.08 + i * 0.2), size.height * 0.4),
        5 * scale,
        Paint()..color = _lerp(const Color(0xFFFF80AB), const Color(0xFF880E4F)),
      );
    }
  }

  void _drawFish(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final x = (size.width * 0.2 + i * 0.25 + t * 0.1) % 1.0 * size.width;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, size.height * 0.62), width: 16, height: 8),
        Paint()..color = const Color(0xFFFF7043).withValues(alpha: 0.45),
      );
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    for (var i = 0; i < 10; i++) {
      final x = size.width * ((i * 0.1 + t * 0.15) % 1.0);
      final y = size.height * (0.5 + ((i * 0.08 + t * 0.18) % 0.3));
      canvas.drawCircle(Offset(x, y), 2 + (i % 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FeedPondPainter old) =>
      old.t != t || old.night != night || old.intensity != intensity;
}
