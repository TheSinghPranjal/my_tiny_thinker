import 'dart:math' as math;

import 'package:flutter/material.dart';

class MeadowBackground extends StatefulWidget {
  const MeadowBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
  });

  final Widget child;
  final bool reducedMotion;

  @override
  State<MeadowBackground> createState() => _MeadowBackgroundState();
}

class _MeadowBackgroundState extends State<MeadowBackground>
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
          painter: _MeadowPainter(
            t: widget.reducedMotion ? 0 : _controller.value,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _MeadowPainter extends CustomPainter {
  _MeadowPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF81D4FA),
            Color(0xFFB3E5FC),
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
          ],
          stops: [0, 0.35, 0.55, 1],
        ).createShader(sky),
    );

    _drawSun(canvas, size);
    _drawCloud(canvas, size.width * 0.15, size.height * 0.1, 1.0, t);
    _drawCloud(canvas, size.width * 0.55, size.height * 0.07, 1.2, t + 0.25);
    _drawCloud(canvas, size.width * 0.82, size.height * 0.14, 0.75, t + 0.5);
    _drawHills(canvas, size);
    _drawFence(canvas, size);
    _drawTree(canvas, size.width * 0.08, size.height * 0.42, 0.85, t);
    _drawTree(canvas, size.width * 0.92, size.height * 0.4, 1.0, t + 0.2);
    _drawButterflies(canvas, size, t);
    _drawBee(canvas, size, t);
    _drawBird(canvas, size, t);
    _drawBubbles(canvas, size, t);
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.88, size.height * 0.12);
    canvas.drawCircle(
      center,
      28,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.35),
    );
    canvas.drawCircle(center, 18, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(
      center.translate(-4, -3),
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _drawCloud(Canvas canvas, double x, double y, double s, double phase) {
    final drift = math.sin(phase * math.pi * 2) * 12;
    final cx = x + drift;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(Offset(cx, y), 16 * s, paint);
    canvas.drawCircle(Offset(cx + 18 * s, y - 4 * s), 20 * s, paint);
    canvas.drawCircle(Offset(cx + 36 * s, y + 2 * s), 14 * s, paint);
    // Smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + 16 * s, y + 2 * s),
        width: 14 * s,
        height: 10 * s,
      ),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF90CAF9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHills(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.38,
        size.width * 0.55,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.54,
        size.width,
        size.height * 0.44,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF81C784));

    final front = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.5,
        size.width * 0.5,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.64,
        size.width,
        size.height * 0.54,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF66BB6A));

    // Grass blades
    final grass = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 28; i++) {
      final gx = size.width * (i / 28);
      final sway = math.sin(t * math.pi * 2 + i) * 3;
      final gy = size.height * 0.62 + (i % 3) * 8;
      canvas.drawLine(
        Offset(gx, gy),
        Offset(gx + sway, gy - 10 - (i % 4) * 2),
        grass,
      );
    }
  }

  void _drawFence(Canvas canvas, Size size) {
    final y = size.height * 0.5;
    final paint = Paint()
      ..color = const Color(0xFFA1887F)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.62, y), Offset(size.width * 0.95, y), paint);
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.65 + i * 0.07);
      canvas.drawLine(Offset(x, y - 18), Offset(x, y + 10), paint);
    }
  }

  void _drawTree(Canvas canvas, double x, double y, double s, double phase) {
    final sway = math.sin(phase * math.pi * 2) * 3 * s;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y + 30 * s), width: 12 * s, height: 36 * s),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    final canopy = Paint()..color = const Color(0xFF43A047);
    canvas.drawCircle(Offset(x + sway, y - 8 * s), 28 * s, canopy);
    canvas.drawCircle(Offset(x - 16 * s + sway, y + 4 * s), 20 * s, canopy);
    canvas.drawCircle(Offset(x + 16 * s + sway, y + 6 * s), 18 * s, canopy);
  }

  void _drawButterflies(Canvas canvas, Size size, double phase) {
    _butterfly(
      canvas,
      size.width * (0.2 + 0.05 * math.sin(phase * math.pi * 2)),
      size.height * (0.28 + 0.03 * math.cos(phase * math.pi * 2)),
      phase,
      const Color(0xFFFF80AB),
    );
    _butterfly(
      canvas,
      size.width * (0.7 + 0.04 * math.cos(phase * math.pi * 2 + 1)),
      size.height * (0.22 + 0.04 * math.sin(phase * math.pi * 2 + 1)),
      phase + 0.4,
      const Color(0xFFFFD54F),
    );
  }

  void _butterfly(Canvas canvas, double x, double y, double phase, Color color) {
    final flap = 0.6 + 0.4 * math.sin(phase * math.pi * 8);
    final paint = Paint()..color = color.withValues(alpha: 0.9);
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(flap, 1);
    canvas.drawOval(const Rect.fromLTWH(-10, -6, 10, 12), paint);
    canvas.drawOval(const Rect.fromLTWH(0, -6, 10, 12), paint);
    canvas.restore();
    canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFF5D4037));
  }

  void _drawBee(Canvas canvas, Size size, double phase) {
    final x = size.width * (0.4 + 0.25 * math.sin(phase * math.pi * 2));
    final y = size.height * (0.32 + 0.05 * math.cos(phase * math.pi * 4));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 14, height: 10),
      Paint()..color = const Color(0xFFFFEB3B),
    );
    canvas.drawLine(
      Offset(x - 3, y - 3),
      Offset(x - 3, y + 3),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(x + 3, y - 3),
      Offset(x + 3, y + 3),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(x - 2, y - 8),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _drawBird(Canvas canvas, Size size, double phase) {
    final x = size.width * ((phase * 0.6) % 1.2 - 0.1);
    final y = size.height * 0.18 + math.sin(phase * math.pi * 4) * 8;
    final wing = math.sin(phase * math.pi * 16) * 6;
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x - 8, y + wing), Offset(x, y), paint);
    canvas.drawLine(Offset(x + 8, y + wing), Offset(x, y), paint);
  }

  void _drawBubbles(Canvas canvas, Size size, double phase) {
    for (var i = 0; i < 5; i++) {
      final bx = size.width * (0.1 + i * 0.18);
      final by = size.height * (0.7 - ((phase + i * 0.15) % 1.0) * 0.35);
      final r = 4.0 + (i % 3) * 2;
      canvas.drawCircle(
        Offset(bx, by),
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter oldDelegate) => oldDelegate.t != t;
}
