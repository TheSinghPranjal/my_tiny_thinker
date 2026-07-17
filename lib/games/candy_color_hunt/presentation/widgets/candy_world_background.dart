import 'dart:math' as math;

import 'package:flutter/material.dart';

class CandyWorldBackground extends StatefulWidget {
  const CandyWorldBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.exciting = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;
  final bool exciting;

  @override
  State<CandyWorldBackground> createState() => _CandyWorldBackgroundState();
}

class _CandyWorldBackgroundState extends State<CandyWorldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))
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
        CustomPaint(
          painter: _CandyWorldPainter(
            t: t,
            exciting: widget.exciting,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _CandyWorldPainter extends CustomPainter {
  _CandyWorldPainter({required this.t, required this.exciting});
  final double t;
  final bool exciting;

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
            Color(0xFF81D4FA),
            Color(0xFFE1F5FE),
            Color(0xFFFFF9C4),
            Color(0xFFA5D6A7),
            Color(0xFF66BB6A),
          ],
          stops: [0, 0.28, 0.48, 0.72, 1],
        ).createShader(rect),
    );

    _rainbow(canvas, size);
    _hills(canvas, size);
    _clouds(canvas, size);
    _flowers(canvas, size);
    _mushrooms(canvas, size);
    _butterflies(canvas, size);
    _bubbles(canvas, size);
    _particles(canvas, size);
  }

  void _rainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
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
        Rect.fromCircle(center: center, radius: size.width * 0.55 - i * 10),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _hills(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.52,
        size.width * 0.45,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.7,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF81C784),
            const Color(0xFF4CAF50),
          ],
        ).createShader(Offset.zero & size),
    );

    final front = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.55,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.86,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF66BB6A));
  }

  void _clouds(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final x = (size.width * (0.1 + i * 0.25) + math.sin(t * math.pi * 2 + i) * 12) %
          size.width;
      final y = size.height * (0.08 + (i % 3) * 0.05);
      _cloud(canvas, Offset(x, y), 28 + i * 4);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(c, r * 0.55, paint);
    canvas.drawCircle(c + Offset(-r * 0.45, 4), r * 0.42, paint);
    canvas.drawCircle(c + Offset(r * 0.45, 6), r * 0.4, paint);
    // smile
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 4), width: r * 0.5, height: r * 0.35),
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
      Offset(size.width * 0.12, size.height * 0.72),
      Offset(size.width * 0.88, size.height * 0.7),
      Offset(size.width * 0.22, size.height * 0.86),
      Offset(size.width * 0.78, size.height * 0.84),
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
        c + const Offset(0, 28),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5 + t * math.pi;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 12, math.sin(a) * 12),
          9,
          Paint()..color = colors[i],
        );
      }
      canvas.drawCircle(c, 7, Paint()..color = const Color(0xFFFFF176));
    }
  }

  void _mushrooms(Canvas canvas, Size size) {
    final spots = [
      Offset(size.width * 0.08, size.height * 0.9),
      Offset(size.width * 0.93, size.height * 0.88),
    ];
    for (final c in spots) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + const Offset(0, 8), width: 14, height: 18),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFFFF8E1),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 34, height: 22),
        Paint()..color = const Color(0xFFEF5350),
      );
      canvas.drawCircle(c + const Offset(-6, -2), 3, Paint()..color = Colors.white);
      canvas.drawCircle(c + const Offset(5, 1), 2.5, Paint()..color = Colors.white);
    }
  }

  void _butterflies(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.28) +
          math.sin(t * math.pi * 2 + i * 1.7) * 20;
      final y = size.height * (0.35 + i * 0.08) +
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
          center: Offset(x - 8 * flap, y),
          width: 16 * flap,
          height: 12,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 8 * flap, y),
          width: 16 * flap,
          height: 12,
        ),
        paint,
      );
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = const Color(0xFF5D4037));
    }
  }

  void _bubbles(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final x = (size.width * ((i * 0.13 + t * 0.15) % 1));
      final y = size.height * (0.55 + (i % 4) * 0.08) -
          math.sin(t * math.pi * 2 + i) * 8;
      canvas.drawCircle(
        Offset(x, y),
        4 + (i % 3),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _particles(Canvas canvas, Size size) {
    final n = exciting ? 28 : 14;
    for (var i = 0; i < n; i++) {
      final x = size.width * ((i * 0.07 + t * (exciting ? 0.35 : 0.12)) % 1);
      final y = size.height * ((i * 0.11 + t * 0.08) % 0.7);
      final isStar = i.isEven;
      final paint = Paint()
        ..color = [
          const Color(0xFFFFF59D),
          const Color(0xFFFF80AB),
          const Color(0xFF80D8FF),
          const Color(0xFFCE93D8),
        ][i % 4]
            .withValues(alpha: exciting ? 0.9 : 0.65);
      if (isStar) {
        _star(canvas, Offset(x, y), exciting ? 5 : 3.5, paint);
      } else {
        canvas.drawCircle(Offset(x, y), exciting ? 3.5 : 2.2, paint);
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / 5;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      final b = a + math.pi / 5;
      final q = c + Offset(math.cos(b) * r * 0.45, math.sin(b) * r * 0.45);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CandyWorldPainter old) =>
      old.t != t || old.exciting != exciting;
}
