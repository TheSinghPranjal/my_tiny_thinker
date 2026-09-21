import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bright meadow for the Alphabet Bridge board: sky, sun, clouds, rolling
/// hills, fence ends, daisies and big foreground leaves.
class AlphabetBridgeBackground extends StatelessWidget {
  const AlphabetBridgeBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BridgeMeadowPainter(phase: reducedMotion ? 0 : envPhase),
      child: child,
    );
  }
}

class _BridgeMeadowPainter extends CustomPainter {
  _BridgeMeadowPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _sky(canvas, size);
    _clouds(canvas, size);
    _sun(canvas, size);
    _hills(canvas, size);
    _meadow(canvas, size);
    _fences(canvas, size);
    _bushes(canvas, size);
    _tufts(canvas, size);
    _daisies(canvas, size);
    _foreground(canvas, size);
  }

  void _sky(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7CC8F7), Color(0xFFA6DBF8), Color(0xFFD5EFFA)],
          stops: [0.0, 0.4, 0.7],
        ).createShader(r),
    );
  }

  void _sun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.88, size.height * 0.262);
    canvas.drawCircle(
      c,
      64,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xAAFFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: c, radius: 64)),
    );
    for (var i = 0; i < 12; i++) {
      final a = phase * 0.2 + i * math.pi / 6;
      canvas.drawLine(
        c + Offset(math.cos(a) * 33, math.sin(a) * 33),
        c + Offset(math.cos(a) * 46, math.sin(a) * 46),
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.75)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 30, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c + const Offset(-8, -8),
      13,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(c + const Offset(-9, -3), 2.4, face);
    canvas.drawCircle(c + const Offset(9, -3), 2.4, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 17, height: 11),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawCircle(c + const Offset(-16, 5), 4, cheek);
    canvas.drawCircle(c + const Offset(16, 5), 4, cheek);
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final shade = Paint()..color = const Color(0xFFCBE3F6);
    final body = Paint()..color = Colors.white.withValues(alpha: 0.97);
    void puffs(Paint p, double dy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 12 * s + dy), width: 94 * s, height: 26 * s),
          Radius.circular(13 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-22 * s, 3 * s + dy), 18 * s, p);
      canvas.drawCircle(c + Offset(4 * s, -8 * s + dy), 25 * s, p);
      canvas.drawCircle(c + Offset(30 * s, 5 * s + dy), 16 * s, p);
    }

    puffs(shade, 3 * s);
    puffs(body, 0);
  }

  void _clouds(Canvas canvas, Size size) {
    final drift = phase * 4;
    for (final (nx, ny, sc) in [
      (0.06, 0.3, 1.15),
      (0.94, 0.34, 0.75),
      (0.56, 0.4, 0.6),
      (0.05, 0.58, 0.55),
      (0.96, 0.53, 0.7),
    ]) {
      _cloud(canvas, Offset(size.width * nx + drift % 6, size.height * ny), sc);
    }
  }

  void _hills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final mtn = Path()
      ..moveTo(0, h * 0.7)
      ..quadraticBezierTo(w * 0.2, h * 0.6, w * 0.4, h * 0.68)
      ..quadraticBezierTo(w * 0.62, h * 0.58, w * 0.85, h * 0.66)
      ..quadraticBezierTo(w * 0.95, h * 0.62, w, h * 0.65)
      ..lineTo(w, h * 0.8)
      ..lineTo(0, h * 0.8)
      ..close();
    canvas.drawPath(mtn, Paint()..color = const Color(0xFF9FD7BE).withValues(alpha: 0.85));
    final hill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.3, h * 0.66, w * 0.55, h * 0.72)
      ..quadraticBezierTo(w * 0.85, h * 0.68, w, h * 0.7)
      ..lineTo(w, h * 0.85)
      ..lineTo(0, h * 0.85)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF9CDA75));
  }

  void _meadow(Canvas canvas, Size size) {
    final top = size.height * 0.72;
    final r = Rect.fromLTWH(0, top, size.width, size.height - top);
    final path = Path()
      ..moveTo(0, top + 24)
      ..quadraticBezierTo(size.width * 0.5, top - 6, size.width, top + 24)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB0E077), Color(0xFF8FCF5C), Color(0xFF6DB644)],
        ).createShader(r),
    );
    // Sunlit patch in the middle of the field.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.87),
        width: size.width * 1.1,
        height: size.height * 0.13,
      ),
      Paint()..color = const Color(0xFFCDEB8A).withValues(alpha: 0.5),
    );
  }

  void _fences(Canvas canvas, Size size) {
    final y = size.height * 0.705;
    final wood = Paint()..color = const Color(0xFFD9A868);
    final dark = Paint()..color = const Color(0xFFB98649);
    for (final (x0, x1) in [(0.0, size.width * 0.2), (size.width * 0.82, size.width)]) {
      for (final ry in [y + 10, y + 26]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(x0, ry, x1, ry + 8), const Radius.circular(3)),
          wood,
        );
        canvas.drawRect(Rect.fromLTRB(x0, ry + 5, x1, ry + 8), dark);
      }
      final n = ((x1 - x0) / 34).round().clamp(2, 6);
      for (var i = 0; i < n; i++) {
        final x = x0 + 16 + i * 34.0;
        final post = Path()
          ..moveTo(x - 10, y + 48)
          ..lineTo(x - 10, y + 6)
          ..lineTo(x, y - 8)
          ..lineTo(x + 10, y + 6)
          ..lineTo(x + 10, y + 48)
          ..close();
        canvas.drawPath(post, Paint()..color = const Color(0xFFDDAE6F));
        canvas.drawPath(
          post,
          Paint()
            ..color = const Color(0xFF9C6B36).withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
      }
    }
  }

  void _bushes(Canvas canvas, Size size) {
    final h = size.height;
    for (final side in [0.0, 1.0]) {
      for (var i = 0; i < 5; i++) {
        final nx = side == 0 ? 0.0 + i * 0.05 : 0.8 + i * 0.05;
        final c = Offset(size.width * nx, h * (0.7 + (i % 2) * 0.01));
        final r = 26.0 + (i % 3) * 7;
        canvas.drawCircle(c, r, Paint()..color = const Color(0xFF3F9C45));
        canvas.drawCircle(
          c + Offset(-r * 0.25, -r * 0.3),
          r * 0.55,
          Paint()..color = const Color(0xFF66BB58).withValues(alpha: 0.8),
        );
      }
    }
  }

  void _tufts(Canvas canvas, Size size) {
    final greens = [const Color(0xFF4FA83A), const Color(0xFF6DBE4C), const Color(0xFF3F9430)];
    for (var i = 0; i < 12; i++) {
      final x = size.width * (((i * 41) % 90) + 5) / 100;
      final y = size.height * (0.78 + ((i * 17) % 20) / 100);
      final sway = math.sin(phase * 2 + i) * 2;
      for (var b = -1; b <= 1; b++) {
        canvas.drawPath(
          Path()
            ..moveTo(x + b * 4, y)
            ..quadraticBezierTo(x + b * 7 + sway, y - 9, x + b * 10 + sway, y - 15 + b.abs() * 3),
          Paint()
            ..color = greens[(i + b + 1) % 3].withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _daisy(Canvas canvas, Offset c, double r) {
    canvas.drawLine(
      c,
      c + Offset(0, r * 2.4),
      Paint()
        ..color = const Color(0xFF3F9430)
        ..strokeWidth = 2.4,
    );
    for (var p = 0; p < 6; p++) {
      final a = p * math.pi / 3;
      canvas.drawCircle(c + Offset(math.cos(a) * r, math.sin(a) * r), r * 0.68, Paint()..color = Colors.white);
    }
    canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFFFFB300));
  }

  void _daisies(Canvas canvas, Size size) {
    for (final (nx, ny, r) in [
      (0.07, 0.745, 6.5),
      (0.9, 0.75, 6.0),
    ]) {
      _daisy(canvas, Offset(size.width * nx, size.height * ny), r);
    }
  }

  void _foreground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (nx, ny, r, c) in [
      (0.0, 0.96, 70.0, 0xFF3B9440),
      (0.13, 1.02, 58.0, 0xFF2F8437),
      (1.0, 0.95, 78.0, 0xFF3B9440),
      (0.86, 1.03, 60.0, 0xFF2F8437),
    ]) {
      canvas.drawCircle(Offset(w * nx, h * ny), r, Paint()..color = Color(c));
    }
    // A mossy rock at the bottom right.
    final rock = Path()
      ..moveTo(w * 0.78, h * 0.965)
      ..quadraticBezierTo(w * 0.79, h * 0.925, w * 0.84, h * 0.93)
      ..quadraticBezierTo(w * 0.9, h * 0.925, w * 0.91, h * 0.965)
      ..close();
    canvas.drawPath(rock, Paint()..color = const Color(0xFF9AA3B0));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.82, h * 0.935), width: 28, height: 8),
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    void leaf(Offset base, double len, double ang, Color c) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(ang);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.3, -len * 0.32, len, 0)
        ..quadraticBezierTo(len * 0.3, len * 0.32, 0, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = c);
      canvas.drawLine(
        Offset.zero,
        Offset(len * 0.9, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..strokeWidth = 1.6,
      );
      canvas.restore();
    }

    const g1 = Color(0xFF4CAF50);
    const g2 = Color(0xFF2E7D32);
    leaf(Offset(w * 0.02, h * 0.99), 105, -1.1, g1);
    leaf(Offset(w * 0.08, h * 1.0), 92, -0.55, g2);
    leaf(Offset(w * 0.15, h * 1.0), 78, -1.45, g1);
    leaf(Offset(w * 0.98, h * 0.99), 105, -math.pi + 1.1, g1);
    leaf(Offset(w * 0.92, h * 1.0), 92, -math.pi + 0.55, g2);
    leaf(Offset(w * 0.85, h * 1.0), 78, -math.pi + 1.45, g1);
    _daisy(canvas, Offset(w * 0.11, h * 0.925), 12);
    _daisy(canvas, Offset(w * 0.21, h * 0.96), 8);
    _daisy(canvas, Offset(w * 0.88, h * 0.94), 8);
    _daisy(canvas, Offset(w * 0.86, h * 0.985), 11);
  }

  @override
  bool shouldRepaint(covariant _BridgeMeadowPainter old) => old.phase != phase;
}
