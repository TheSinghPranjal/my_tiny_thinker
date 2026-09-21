import 'dart:math' as math;

import 'package:flutter/material.dart';

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
          colors: [Color(0xFF5DB3F5), Color(0xFF8ECDF8), Color(0xFFCDEBFB)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(sky),
    );

    _drawSun(canvas, size);
    if (showRainbow || rainbowProgress > 0.15) {
      _drawRainbow(canvas, size);
    }

    // Drifting, friendly background clouds.
    const clouds = [
      (0.12, 0.13, 1.0, 0),
      (0.62, 0.2, 0.85, 1),
      (0.9, 0.09, 0.65, 2),
      (0.3, 0.34, 0.6, 3),
      (0.85, 0.42, 0.7, 4),
    ];
    for (final (nx, ny, sc, i) in clouds) {
      final drift = t * size.width * 0.05 * (i.isOdd ? 1 : -1);
      final x = (size.width * nx + drift) % (size.width + 160) - 60;
      _drawFluffyCloud(canvas, Offset(x, size.height * ny), sc, face: i < 3);
    }

    _drawMountains(canvas, size);
    _drawHills(canvas, size);
    _drawTrees(canvas, size);
    _drawFence(canvas, size);
    _drawMeadow(canvas, size);
    _drawBushes(canvas, size);
    _drawSparkles(canvas, size);
    _drawLeaves(canvas, size);
  }

  void _drawSun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.84, size.height * 0.1);
    canvas.drawCircle(
      c,
      70,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xAAFFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: c, radius: 70)),
    );
    for (var i = 0; i < 12; i++) {
      final a = t * math.pi * 2 + i * math.pi / 6;
      canvas.drawLine(
        c + Offset(math.cos(a) * 38, math.sin(a) * 38),
        c + Offset(math.cos(a) * 54, math.sin(a) * 54),
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.8)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 36, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c + const Offset(-9, -9),
      16,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    final face = Paint()..color = const Color(0xFF8D5A2B);
    canvas.drawCircle(c + const Offset(-11, -3), 2.8, face);
    canvas.drawCircle(c + const Offset(11, -3), 2.8, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 20, height: 13),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF8D5A2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55);
    canvas.drawCircle(c + const Offset(-20, 5), 5, cheek);
    canvas.drawCircle(c + const Offset(20, 5), 5, cheek);
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final strength = showRainbow ? 1.0 : rainbowProgress.clamp(0.2, 0.9);
    final center = Offset(size.width * 0.5, size.height * 0.72);
    const colors = [
      Color(0xFFF77F7F),
      Color(0xFFFFB067),
      Color(0xFFFFE066),
      Color(0xFF9BDB8B),
      Color(0xFF6FC3F5),
      Color(0xFF9B8CE8),
    ];
    const band = 15.0;
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: (size.width * 1.08 - i * band * 2) * strength,
          height: (size.height * 0.78 - i * band * 2) * strength,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.85 * strength)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band + 1,
      );
    }
  }

  void _drawFluffyCloud(Canvas canvas, Offset c, double s, {required bool face}) {
    final shade = Paint()..color = const Color(0xFFD6E9FA).withValues(alpha: 0.9);
    final body = Paint()..color = Colors.white.withValues(alpha: 0.96);
    void puffs(Paint p, double dy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 14 * s + dy), width: 96 * s, height: 30 * s),
          Radius.circular(16 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-22 * s, 2 * s + dy), 20 * s, p);
      canvas.drawCircle(c + Offset(6 * s, -10 * s + dy), 26 * s, p);
      canvas.drawCircle(c + Offset(32 * s, 4 * s + dy), 18 * s, p);
    }

    puffs(shade, 3 * s);
    puffs(body, 0);
    if (!face) return;
    final eye = Paint()..color = const Color(0xFF4A5A8A);
    canvas.drawCircle(c + Offset(-8 * s, 4 * s), 2.6 * s, eye);
    canvas.drawCircle(c + Offset(12 * s, 4 * s), 2.6 * s, eye);
    canvas.drawArc(
      Rect.fromCenter(center: c + Offset(2 * s, 11 * s), width: 12 * s, height: 8 * s),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF4A5A8A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFFA4B8).withValues(alpha: 0.55);
    canvas.drawCircle(c + Offset(-18 * s, 10 * s), 4.5 * s, cheek);
    canvas.drawCircle(c + Offset(22 * s, 10 * s), 4.5 * s, cheek);
  }

  void _drawMountains(Canvas canvas, Size size) {
    final base = size.height * 0.7;
    final left = Path()
      ..moveTo(0, base)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.6, size.width * 0.38, base)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFF8FC6D8).withValues(alpha: 0.7));
    final right = Path()
      ..moveTo(size.width * 0.55, base)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.58, size.width, base)
      ..close();
    canvas.drawPath(right, Paint()..color = const Color(0xFF7DB9CE).withValues(alpha: 0.7));
  }

  void _drawHills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final far = Path()
      ..moveTo(0, h * 0.7)
      ..quadraticBezierTo(w * 0.25, h * 0.64, w * 0.5, h * 0.7)
      ..quadraticBezierTo(w * 0.78, h * 0.76, w, h * 0.68)
      ..lineTo(w, h * 0.8)
      ..lineTo(0, h * 0.8)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF9ED67A));
    final near = Path()
      ..moveTo(0, h * 0.74)
      ..quadraticBezierTo(w * 0.3, h * 0.69, w * 0.6, h * 0.75)
      ..quadraticBezierTo(w * 0.85, h * 0.79, w, h * 0.73)
      ..lineTo(w, h * 0.82)
      ..lineTo(0, h * 0.82)
      ..close();
    canvas.drawPath(
      near,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8CCB5E), Color(0xFF7BBF50)],
        ).createShader(Rect.fromLTWH(0, h * 0.69, w, h * 0.13)),
    );
  }

  void _drawTree(Canvas canvas, Offset base, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 4 * s, base.dy - 18 * s, 8 * s, 22 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    for (final (dx, dy, r, c) in [
      (-14.0, -30.0, 15.0, 0xFF4CAF50),
      (14.0, -30.0, 15.0, 0xFF4CAF50),
      (0.0, -42.0, 18.0, 0xFF66BB6A),
      (-4.0, -34.0, 11.0, 0xFF81C784),
    ]) {
      canvas.drawCircle(base + Offset(dx * s, dy * s), r * s, Paint()..color = Color(c));
    }
  }

  void _drawTrees(Canvas canvas, Size size) {
    for (final (nx, ny, sc) in [
      (0.07, 0.755, 1.5),
      (0.2, 0.75, 0.9),
      (0.78, 0.755, 0.9),
      (0.93, 0.76, 1.6),
    ]) {
      _drawTree(canvas, Offset(size.width * nx, size.height * ny), sc);
    }
  }

  void _drawFence(Canvas canvas, Size size) {
    final y = size.height * 0.765;
    final wood = Paint()..color = const Color(0xFFF7F3EC);
    final edge = Paint()
      ..color = const Color(0xFFD8CFC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final ry in [y + 4, y + 18]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, ry, size.width, 5),
          const Radius.circular(2),
        ),
        wood,
      );
    }
    const n = 18;
    for (var i = 0; i < n; i++) {
      final x = size.width * (i + 0.5) / n;
      final post = Path()
        ..moveTo(x - 6, y + 32)
        ..lineTo(x - 6, y - 2)
        ..lineTo(x, y - 10)
        ..lineTo(x + 6, y - 2)
        ..lineTo(x + 6, y + 32)
        ..close();
      canvas.drawPath(post, wood);
      canvas.drawPath(post, edge);
    }
  }

  void _drawMeadow(Canvas canvas, Size size) {
    final top = size.height * 0.8;
    final rect = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5DA6B), Color(0xFF86C44F), Color(0xFF5FA83A)],
        ).createShader(rect),
    );
    for (var i = 0; i < 26; i++) {
      final x = i * size.width / 26 + math.sin(t * math.pi * 2 + i) * 3;
      final y = top + 8 + ((i * 47) % 100) / 100 * (size.height - top - 20);
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 5, y - 8, x + 2, y - 13),
        Paint()
          ..color = const Color(0xFF4E9A2E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
    // Tiny white daisies.
    for (var i = 0; i < 14; i++) {
      final x = size.width * (((i * 43) % 96) + 2) / 100;
      final y = top + 14 + ((i * 29) % 100) / 100 * (size.height - top - 30);
      canvas.drawCircle(Offset(x, y), 3.2, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 1.4, Paint()..color = const Color(0xFFFFD54F));
    }
  }

  void _drawBushes(Canvas canvas, Size size) {
    final h = size.height;
    for (final (nx, ny, r, shade) in [
      (0.02, 0.965, 46.0, 0xFF3F8F3A),
      (0.13, 0.99, 40.0, 0xFF4CA043),
      (0.98, 0.96, 50.0, 0xFF3F8F3A),
      (0.86, 0.995, 42.0, 0xFF4CA043),
      (0.5, 1.02, 60.0, 0xFF56AB47),
    ]) {
      canvas.drawCircle(
        Offset(size.width * nx, h * ny),
        r,
        Paint()..color = Color(shade),
      );
    }
    for (final (nx, ny, c) in [
      (0.06, 0.94, 0xFFFFFFFF),
      (0.93, 0.93, 0xFFFFCA28),
      (0.9, 0.975, 0xFFFFFFFF),
      (0.11, 0.975, 0xFFFFCA28),
    ]) {
      final o = Offset(size.width * nx, h * ny);
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5;
        canvas.drawCircle(
          o + Offset(math.cos(a) * 5, math.sin(a) * 5),
          3.6,
          Paint()..color = Color(c),
        );
      }
      canvas.drawCircle(o, 3, Paint()..color = const Color(0xFFFF8F00));
    }
  }

  void _drawLeaves(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final p = (t * 1.5 + i * 0.27) % 1.0;
      final x = size.width * (0.15 + i * 0.22) + math.sin(p * 6 + i) * 18;
      final y = size.height * (0.3 + p * 0.5);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p * 5 + i);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 7),
        Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.85),
      );
      canvas.restore();
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final x = size.width * ((i * 37 + 11) % 90 + 5) / 100;
      final y = size.height * (0.06 + (i % 4) * 0.09);
      final tw = (math.sin(t * math.pi * 2 * 2 + i) + 1) / 2;
      final r = 3.0 + tw * 3;
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.4 + tw * 0.5);
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..quadraticBezierTo(x, y, x + r, y)
          ..quadraticBezierTo(x, y, x, y + r)
          ..quadraticBezierTo(x, y, x - r, y)
          ..quadraticBezierTo(x, y, x, y - r),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CloudPopPainter old) =>
      old.t != t ||
      old.showRainbow != showRainbow ||
      old.rainbowProgress != rainbowProgress;
}
