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
            Color(0xFF64B5F6),
            Color(0xFFBBDEFB),
            Color(0xFFE3F2FD),
            Color(0xFFC8E6C9),
            Color(0xFF81C784),
            Color(0xFF66BB6A),
          ],
          stops: [0, 0.22, 0.38, 0.55, 0.78, 1],
        ).createShader(rect),
    );

    _rainbow(canvas, size);
    _distantHills(canvas, size);
    _windmill(canvas, size);
    _hotAirBalloon(canvas, size);
    _clouds(canvas, size);
    _bird(canvas, size);
    _midHills(canvas, size);
    _frontMeadow(canvas, size);
    _flowers(canvas, size);
    _bushes(canvas, size);
    _rockAndLadybug(canvas, size);
    _sparkles(canvas, size);
  }

  void _rainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.48);
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
        Rect.fromCircle(center: center, radius: size.width * 0.58 - i * 11),
        math.pi + 0.08,
        math.pi - 0.16,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _distantHills(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.42,
        size.width * 0.4,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.58,
        size.width,
        size.height * 0.48,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      back,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA5D6A7), Color(0xFF81C784)],
        ).createShader(Offset.zero & size),
    );
  }

  void _midHills(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.5,
        size.width * 0.48,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.68,
        size.width,
        size.height * 0.56,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
        ).createShader(Offset.zero & size),
    );
  }

  void _frontMeadow(Canvas canvas, Size size) {
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
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        ).createShader(Offset.zero & size),
    );

    // Soft grass tufts.
    final blade = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i++) {
      final x = size.width * (0.05 + i * 0.05);
      final y = size.height * (0.82 + (i % 3) * 0.04);
      final sway = math.sin(t * math.pi * 2 + i) * 3;
      canvas.drawLine(Offset(x, y), Offset(x + sway, y - 10), blade);
    }
  }

  void _windmill(Canvas canvas, Size size) {
    final base = Offset(size.width * 0.86, size.height * 0.5);
    // Soft tapered tower (no brown box base).
    final tower = Path()
      ..moveTo(base.dx - 8, base.dy + 22)
      ..lineTo(base.dx - 5, base.dy - 18)
      ..lineTo(base.dx + 5, base.dy - 18)
      ..lineTo(base.dx + 8, base.dy + 22)
      ..close();
    canvas.drawPath(tower, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawPath(
      tower,
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final hub = base + const Offset(0, -14);
    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate(t * math.pi * 2);
    final blade = Paint()..color = const Color(0xFFE53935);
    for (var i = 0; i < 4; i++) {
      canvas.rotate(math.pi / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-3, -28, 6, 26),
          const Radius.circular(3),
        ),
        blade,
      );
    }
    canvas.restore();
    canvas.drawCircle(hub, 5, Paint()..color = const Color(0xFFFFF176));
  }

  void _hotAirBalloon(Canvas canvas, Size size) {
    final c = Offset(
      size.width * 0.14 + math.sin(t * math.pi * 2) * 6,
      size.height * 0.22 + math.cos(t * math.pi * 2) * 4,
    );
    final balloon = Rect.fromCenter(center: c, width: 34, height: 40);
    canvas.drawOval(
      balloon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF8A80),
            Color(0xFFFFF176),
            Color(0xFF80D8FF),
            Color(0xFFCE93D8),
          ],
        ).createShader(balloon),
    );
    // Soft basket (rounded, not a brown box).
    canvas.drawLine(
      c + const Offset(-4, 18),
      c + const Offset(-5, 26),
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      c + const Offset(4, 18),
      c + const Offset(5, 26),
      Paint()
        ..color = const Color(0xFF90A4AE)
        ..strokeWidth = 1.4,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 28), width: 12, height: 8),
      Paint()..color = const Color(0xFFFFCC80),
    );
  }

  void _bird(Canvas canvas, Size size) {
    final x = size.width * (0.72 + math.sin(t * math.pi * 2) * 0.04);
    final y = size.height * (0.18 + math.cos(t * math.pi * 2) * 0.02);
    final flap = 0.6 + math.sin(t * math.pi * 10) * 0.35;
    final paint = Paint()..color = const Color(0xFFFFB74D);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 14, height: 10),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - 8, y - 2 * flap),
        width: 12,
        height: 6 * flap,
      ),
      Paint()..color = const Color(0xFFFFCC80),
    );
    canvas.drawCircle(
      Offset(x + 5, y - 1),
      1.5,
      Paint()..color = const Color(0xFF5D4037),
    );
  }

  void _clouds(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final x = (size.width * (0.08 + i * 0.2) +
              math.sin(t * math.pi * 2 + i) * 10) %
          size.width;
      final y = size.height * (0.06 + (i % 3) * 0.045);
      _cloud(canvas, Offset(x, y), 26 + i * 3, smile: i.isEven);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, {required bool smile}) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.94);
    canvas.drawCircle(c, r * 0.55, paint);
    canvas.drawCircle(c + Offset(-r * 0.45, 4), r * 0.42, paint);
    canvas.drawCircle(c + Offset(r * 0.45, 6), r * 0.4, paint);
    canvas.drawCircle(c + Offset(0, -r * 0.2), r * 0.35, paint);
    if (smile) {
      canvas.drawCircle(
        c + Offset(-r * 0.12, 0),
        2,
        Paint()..color = const Color(0xFF90A4AE),
      );
      canvas.drawCircle(
        c + Offset(r * 0.12, 0),
        2,
        Paint()..color = const Color(0xFF90A4AE),
      );
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
  }

  void _flowers(Canvas canvas, Size size) {
    final spots = [
      (Offset(size.width * 0.1, size.height * 0.74), const Color(0xFFFF80AB)),
      (Offset(size.width * 0.18, size.height * 0.8), const Color(0xFFFFF176)),
      (Offset(size.width * 0.28, size.height * 0.86), const Color(0xFF80CBC4)),
      (Offset(size.width * 0.72, size.height * 0.82), const Color(0xFFFFAB91)),
      (Offset(size.width * 0.84, size.height * 0.76), const Color(0xFFCE93D8)),
      (Offset(size.width * 0.92, size.height * 0.84), const Color(0xFFFF80AB)),
      (Offset(size.width * 0.5, size.height * 0.9), const Color(0xFFFFF59D)),
    ];
    for (var i = 0; i < spots.length; i++) {
      final sway = math.sin(t * math.pi * 2 + i) * 2.5;
      final c = spots[i].$1 + Offset(sway, 0);
      canvas.drawLine(
        c,
        c + const Offset(0, 18),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      for (var p = 0; p < 5; p++) {
        final a = p * math.pi * 2 / 5 + t * math.pi;
        canvas.drawCircle(
          c + Offset(math.cos(a) * 8, math.sin(a) * 8),
          6,
          Paint()..color = spots[i].$2,
        );
      }
      canvas.drawCircle(c, 4.5, Paint()..color = const Color(0xFFFFF176));
    }

    // Daisy clusters
    for (final base in [
      Offset(size.width * 0.36, size.height * 0.88),
      Offset(size.width * 0.62, size.height * 0.86),
    ]) {
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawOval(
          Rect.fromCenter(
            center: base + Offset(math.cos(a) * 7, math.sin(a) * 7),
            width: 8,
            height: 5,
          ),
          Paint()..color = Colors.white,
        );
      }
      canvas.drawCircle(base, 3.5, Paint()..color = const Color(0xFFFFC107));
    }
  }

  void _bushes(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF43A047);
    for (final c in [
      Offset(size.width * 0.05, size.height * 0.86),
      Offset(size.width * 0.95, size.height * 0.88),
      Offset(size.width * 0.42, size.height * 0.93),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: 48, height: 28),
        paint,
      );
      canvas.drawCircle(c + const Offset(-12, -4), 14, paint);
      canvas.drawCircle(c + const Offset(12, -2), 12, paint);
    }
  }

  void _rockAndLadybug(Canvas canvas, Size size) {
    final rock = Offset(size.width * 0.22, size.height * 0.9);
    canvas.drawOval(
      Rect.fromCenter(center: rock, width: 36, height: 18),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: rock + const Offset(-4, -2), width: 10, height: 5),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    // Ladybug
    final bug = rock + const Offset(6, -8);
    canvas.drawOval(
      Rect.fromCenter(center: bug, width: 12, height: 9),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawCircle(bug + const Offset(0, -4), 3, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(bug + const Offset(-3, 0), 1.4, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(bug + const Offset(3, 1), 1.4, Paint()..color = const Color(0xFF212121));
  }

  void _sparkles(Canvas canvas, Size size) {
    final n = exciting ? 36 : 22;
    for (var i = 0; i < n; i++) {
      final x = size.width * ((i * 0.07 + t * (exciting ? 0.28 : 0.1)) % 1);
      final y = size.height * ((i * 0.09 + t * 0.06) % 0.75);
      final twinkle = 0.45 + 0.55 * ((math.sin(t * math.pi * 4 + i) + 1) / 2);
      canvas.drawCircle(
        Offset(x, y),
        exciting ? 2.8 : 2.0,
        Paint()..color = Colors.white.withValues(alpha: 0.55 * twinkle),
      );
      if (i.isEven) {
        _star(
          canvas,
          Offset(x + 6, y + 8),
          exciting ? 4 : 2.8,
          Paint()
            ..color = const Color(0xFFFFF59D).withValues(alpha: 0.7 * twinkle),
        );
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
