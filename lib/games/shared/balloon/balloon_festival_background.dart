import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Magical outdoor festival sky shared by balloon games.
class BalloonFestivalBackground extends StatefulWidget {
  const BalloonFestivalBackground({
    super.key,
    required this.child,
    this.showKites = false,
    this.reducedMotion = false,
  });

  final Widget child;
  final bool showKites;
  final bool reducedMotion;

  @override
  State<BalloonFestivalBackground> createState() =>
      _BalloonFestivalBackgroundState();
}

class _BalloonFestivalBackgroundState extends State<BalloonFestivalBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.reducedMotion ? 24 : 14),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant BalloonFestivalBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) {
      _ctrl.duration = Duration(seconds: widget.reducedMotion ? 24 : 14);
      if (!_ctrl.isAnimating) _ctrl.repeat();
    }
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
        return CustomPaint(
          painter: _FestivalPainter(
            t: _ctrl.value,
            showKites: widget.showKites,
            reducedMotion: widget.reducedMotion,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _FestivalPainter extends CustomPainter {
  _FestivalPainter({
    required this.t,
    required this.showKites,
    required this.reducedMotion,
  });

  final double t;
  final bool showKites;
  final bool reducedMotion;

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
            Color(0xFFE1F5FE),
            Color(0xFFFFF8E1),
          ],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(sky),
    );

    _drawSun(canvas, size);
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    if (showKites) _drawKites(canvas, size);
    _drawBirds(canvas, size);
    _drawHills(canvas, size);
    _drawGrass(canvas, size);
    _drawFlowers(canvas, size);
    _drawFenceBalloons(canvas, size);
    _drawWindmill(canvas, size);
    _drawTrees(canvas, size);
    _drawButterflies(canvas, size);
    _drawLadybugs(canvas, size);
    _drawSparkles(canvas, size);
  }

  void _drawSun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.82, size.height * 0.12);
    canvas.drawCircle(
      c,
      36,
      Paint()
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(c, 22, Paint()..color = const Color(0xFFFFF176));
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.55);
    final colors = [
      const Color(0x66EF5350),
      const Color(0x66FFA726),
      const Color(0x66FFEE58),
      const Color(0x6666BB6A),
      const Color(0x6642A5F5),
      const Color(0x66AB47BC),
    ];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.55 - i * 8),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    for (var i = 0; i < 5; i++) {
      final drift = (t + i * 0.18) % 1.0;
      final x = size.width * (drift * 1.3 - 0.15);
      final y = size.height * (0.08 + (i % 3) * 0.07);
      _cloud(canvas, Offset(x, y), 28 + i * 4.0, paint);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r * 0.7, paint);
    canvas.drawCircle(Offset(c.dx - r * 0.55, c.dy + 4), r * 0.5, paint);
    canvas.drawCircle(Offset(c.dx + r * 0.55, c.dy + 2), r * 0.55, paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.35),
        width: r * 2.1,
        height: r * 0.85,
      ),
      paint,
    );
  }

  void _drawKites(Canvas canvas, Size size) {
    for (var i = 0; i < 2; i++) {
      final bob = math.sin((t + i * 0.4) * math.pi * 2) * 10;
      final x = size.width * (0.18 + i * 0.55);
      final y = size.height * 0.22 + bob;
      final color = i == 0 ? const Color(0xFFEF5350) : const Color(0xFF42A5F5);
      final kite = Path()
        ..moveTo(x, y - 14)
        ..lineTo(x + 12, y)
        ..lineTo(x, y + 14)
        ..lineTo(x - 12, y)
        ..close();
      canvas.drawPath(kite, Paint()..color = color);
      final string = Path()
        ..moveTo(x, y + 14)
        ..quadraticBezierTo(x + 8, y + 40, x - 4, y + 60);
      canvas.drawPath(
        string,
        Paint()
          ..color = Colors.white70
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawBirds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF546E7A).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final x = size.width * ((t * 0.4 + i * 0.22) % 1.0);
      final y = size.height * (0.18 + (i % 2) * 0.05);
      final flap = math.sin((t * 8 + i) * math.pi) * 4;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x - 6, y + flap), width: 12, height: 8),
        math.pi,
        math.pi,
        false,
        paint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x + 6, y - flap), width: 12, height: 8),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawHills(Canvas canvas, Size size) {
    final hill = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.62,
        size.width * 0.5,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.78,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFFAED581));
  }

  void _drawGrass(Canvas canvas, Size size) {
    final baseY = size.height * 0.88;
    final paint = Paint()
      ..color = const Color(0xFF7CB342)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final blades = (size.width / 14).floor();
    for (var i = 0; i < blades; i++) {
      final x = i * 14.0 + 4;
      final sway = math.sin((t * 2 + i * 0.3) * math.pi * 2) *
          (reducedMotion ? 2 : 5);
      canvas.drawLine(
        Offset(x, baseY + 20),
        Offset(x + sway, baseY - 8 - (i % 3) * 4),
        paint,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
      Paint()..color = const Color(0xFF8BC34A),
    );
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF8A80),
      const Color(0xFFFFF176),
      const Color(0xFFCE93D8),
      const Color(0xFF80D8FF),
    ];
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.08 + (i % 8) * 0.11);
      final y = size.height * (0.9 + (i % 2) * 0.02);
      final sway = math.sin((t + i * 0.1) * math.pi * 2) * 3;
      canvas.drawLine(
        Offset(x, y + 10),
        Offset(x + sway, y - 8),
        Paint()
          ..color = const Color(0xFF558B2F)
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(x + sway, y - 12),
        5,
        Paint()..color = colors[i % colors.length],
      );
      canvas.drawCircle(
        Offset(x + sway, y - 12),
        2,
        Paint()..color = const Color(0xFFFFF59D),
      );
    }
  }

  void _drawFenceBalloons(Canvas canvas, Size size) {
    final fenceY = size.height * 0.86;
    canvas.drawLine(
      Offset(0, fenceY),
      Offset(size.width, fenceY),
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..strokeWidth = 3,
    );
    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.1 + i * 0.15);
      canvas.drawLine(
        Offset(x, fenceY - 16),
        Offset(x, fenceY + 10),
        Paint()
          ..color = const Color(0xFFA1887F)
          ..strokeWidth = 3,
      );
      final bob = math.sin((t * 2 + i) * math.pi * 2) * 3;
      final color = [
        const Color(0xFFEF5350),
        const Color(0xFF42A5F5),
        const Color(0xFFFFEE58),
        const Color(0xFFAB47BC),
      ][i % 4];
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, fenceY - 28 + bob),
          width: 14,
          height: 18,
        ),
        Paint()..color = color.withValues(alpha: 0.85),
      );
    }
  }

  void _drawWindmill(Canvas canvas, Size size) {
    final base = Offset(size.width * 0.12, size.height * 0.72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy + 30), width: 16, height: 60),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFF8E1),
    );
    final angle = t * math.pi * 2 * (reducedMotion ? 0.5 : 1.2);
    for (var i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      final tip = Offset(
        base.dx + math.cos(a) * 28,
        base.dy + math.sin(a) * 28,
      );
      canvas.drawLine(
        base,
        tip,
        Paint()
          ..color = AppColors.skyBlueDark
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(base, 5, Paint()..color = const Color(0xFFFFCA28));
  }

  void _drawTrees(Canvas canvas, Size size) {
    for (final xFrac in [0.88, 0.95]) {
      final x = size.width * xFrac;
      final y = size.height * 0.78;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y + 18), width: 10, height: 28),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF8D6E63),
      );
      canvas.drawCircle(
        Offset(x, y - 8),
        22,
        Paint()..color = const Color(0xFF81C784),
      );
      // Smile
      canvas.drawCircle(Offset(x - 7, y - 10), 2, Paint()..color = const Color(0xFF37474F));
      canvas.drawCircle(Offset(x + 7, y - 10), 2, Paint()..color = const Color(0xFF37474F));
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, y - 4), width: 12, height: 8),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = const Color(0xFF37474F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  void _drawButterflies(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.25) +
          math.sin((t + i) * math.pi * 2) * 20;
      final y = size.height * (0.35 + i * 0.08) +
          math.cos((t * 1.4 + i) * math.pi * 2) * 12;
      final flap = 0.6 + math.sin((t * 10 + i) * math.pi * 2) * 0.35;
      final color = [
        const Color(0xFFFF8A80),
        const Color(0xFFCE93D8),
        const Color(0xFF80D8FF),
      ][i];
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(flap, 1);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-6, 0), width: 12, height: 10),
        Paint()..color = color,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, 0), width: 12, height: 10),
        Paint()..color = color,
      );
      canvas.restore();
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFF5D4037));
    }
  }

  void _drawLadybugs(Canvas canvas, Size size) {
    for (var i = 0; i < 2; i++) {
      final x = size.width * (0.3 + i * 0.4) +
          math.sin((t * 0.5 + i) * math.pi * 2) * 8;
      final y = size.height * 0.93;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 8),
        Paint()..color = const Color(0xFFE53935),
      );
      canvas.drawCircle(Offset(x - 2, y - 1), 1.2, Paint()..color = Colors.black54);
      canvas.drawCircle(Offset(x + 2, y + 1), 1.2, Paint()..color = Colors.black54);
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 12; i++) {
      final pulse = (math.sin((t * 3 + i * 0.5) * math.pi * 2) + 1) / 2;
      if (pulse < 0.3) continue;
      final x = size.width * ((i * 0.17 + t * 0.05) % 1.0);
      final y = size.height * (0.1 + (i % 5) * 0.1);
      canvas.drawCircle(Offset(x, y), 1.5 + pulse * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FestivalPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.showKites != showKites ||
      oldDelegate.reducedMotion != reducedMotion;
}
