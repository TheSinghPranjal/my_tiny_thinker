import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlaygroundBackground extends StatefulWidget {
  const PlaygroundBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;

  @override
  State<PlaygroundBackground> createState() => _PlaygroundBackgroundState();
}

class _PlaygroundBackgroundState extends State<PlaygroundBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.reducedMotion ? widget.envPhase * 0.04 : _c.value;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _PlaygroundPainter(t: t)),
        widget.child,
      ],
    );
  }
}

class _PlaygroundPainter extends CustomPainter {
  _PlaygroundPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF64B5F6),
            Color(0xFFBBDEFB),
            Color(0xFFFFF9C4),
            Color(0xFFA5D6A7),
            Color(0xFF66BB6A),
          ],
          stops: [0, 0.32, 0.5, 0.72, 1],
        ).createShader(rect),
    );

    _sunRays(canvas, size);
    _rainbow(canvas, size);
    _hills(canvas, size);
    _trees(canvas, size);
    _clouds(canvas, size);
    _flowers(canvas, size);
    _butterflies(canvas, size);
    _birds(canvas, size);
    _sparkles(canvas, size);
  }

  void _sunRays(Canvas canvas, Size size) {
    final sun = Offset(size.width * 0.88, size.height * 0.1);
    canvas.drawCircle(sun, 28, Paint()..color = const Color(0xFFFFF176));
    for (var i = 0; i < 8; i++) {
      final a = t * math.pi * 2 + i * math.pi / 4;
      canvas.drawLine(
        sun + Offset(math.cos(a) * 34, math.sin(a) * 34),
        sun + Offset(math.cos(a) * 48, math.sin(a) * 48),
        Paint()
          ..color = const Color(0xFFFFF59D).withValues(alpha: 0.7)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _rainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.18, size.height * 0.38);
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFFFB8C00),
      const Color(0xFFFDD835),
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFF8E24AA),
    ];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * 0.28 - i * 7),
        math.pi * 1.05,
        math.pi * 0.7,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _hills(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.48,
        size.width * 0.5,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.64,
        size.width,
        size.height * 0.52,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF81C784));

    final front = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.64,
        size.width * 0.6,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.82,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF66BB6A));
  }

  void _trees(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.08, size.height * 0.62),
      Offset(size.width * 0.92, size.height * 0.6),
    ];
    for (final c in spots) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + const Offset(0, 28), width: 12, height: 36),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF6D4C41),
      );
      canvas.drawCircle(c, 28, Paint()..color = const Color(0xFF43A047));
      canvas.drawCircle(
        c + const Offset(-16, 8),
        18,
        Paint()..color = const Color(0xFF66BB6A),
      );
      canvas.drawCircle(
        c + const Offset(14, 10),
        16,
        Paint()..color = const Color(0xFF81C784),
      );
    }
  }

  void _clouds(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.05 + i * 0.24) +
              math.sin(t * math.pi * 2 + i) * 14) %
          size.width;
      final y = size.height * (0.08 + (i % 3) * 0.06);
      _cloud(canvas, Offset(x, y), 26 + i * 3.0);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(c, r * 0.55, paint);
    canvas.drawCircle(c + Offset(-r * 0.45, 4), r * 0.42, paint);
    canvas.drawCircle(c + Offset(r * 0.45, 6), r * 0.4, paint);
    canvas.drawArc(
      Rect.fromCenter(
        center: c + const Offset(0, 4),
        width: r * 0.45,
        height: r * 0.3,
      ),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _flowers(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.9),
      Offset(size.width * 0.7, size.height * 0.88),
    ];
    final colors = [
      const Color(0xFFFF80AB),
      const Color(0xFFFFD54F),
      const Color(0xFFCE93D8),
      const Color(0xFF80CBC4),
    ];
    for (var i = 0; i < spots.length; i++) {
      final sway = math.sin(t * math.pi * 2 + i) * 3;
      final c = spots[i] + Offset(sway, 0);
      canvas.drawLine(
        c,
        c + const Offset(0, 22),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5 + t * math.pi;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 10, math.sin(a) * 10),
          7,
          Paint()..color = colors[i],
        );
      }
      canvas.drawCircle(c, 5, Paint()..color = const Color(0xFFFFF176));
    }
  }

  void _butterflies(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.25) +
          math.sin(t * math.pi * 2 + i * 1.5) * 18;
      final y = size.height * (0.4 + i * 0.07) +
          math.cos(t * math.pi * 2 + i) * 10;
      final flap = 0.7 + math.sin(t * math.pi * 8 + i) * 0.25;
      final paint = Paint()
        ..color = [
          const Color(0xFFFF80AB),
          const Color(0xFF80D8FF),
          const Color(0xFFFFE082),
        ][i];
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - 7 * flap, y),
          width: 14 * flap,
          height: 10,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 7 * flap, y),
          width: 14 * flap,
          height: 10,
        ),
        paint,
      );
    }
  }

  void _birds(Canvas canvas, Size size) {
    for (var i = 0; i < 2; i++) {
      final x = (size.width * ((0.3 + i * 0.4 + t * 0.2) % 1));
      final y = size.height * (0.18 + i * 0.04) +
          math.sin(t * math.pi * 4 + i) * 6;
      final wing = math.sin(t * math.pi * 10 + i) * 6;
      final paint = Paint()
        ..color = const Color(0xFF455A64)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x - 6, y + wing),
          width: 14,
          height: 10,
        ),
        math.pi,
        math.pi,
        false,
        paint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x + 6, y - wing),
          width: 14,
          height: 10,
        ),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _sparkles(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 0.09 + t * 0.1) % 1);
      final y = size.height * ((i * 0.13 + t * 0.06) % 0.65);
      canvas.drawCircle(
        Offset(x, y),
        i.isEven ? 2.5 : 1.8,
        Paint()
          ..color = [
            const Color(0xFFFFF59D),
            Colors.white,
            const Color(0xFFFF80AB),
          ][i % 3]
              .withValues(alpha: 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PlaygroundPainter old) => old.t != t;
}
