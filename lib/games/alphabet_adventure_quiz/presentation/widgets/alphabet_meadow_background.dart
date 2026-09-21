import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sunny meadow behind the Alphabet Adventure quiz: blue sky, smiling sun,
/// fluffy clouds, round trees, a picket fence and a grassy foreground.
class AlphabetMeadowBackground extends StatefulWidget {
  const AlphabetMeadowBackground({
    super.key,
    required this.child,
    this.reducedMotion = false,
  });

  final Widget child;
  final bool reducedMotion;

  @override
  State<AlphabetMeadowBackground> createState() =>
      _AlphabetMeadowBackgroundState();
}

class _AlphabetMeadowBackgroundState extends State<AlphabetMeadowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 30));
    if (!widget.reducedMotion) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        painter: _MeadowPainter(t: widget.reducedMotion ? 0 : _c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _MeadowPainter extends CustomPainter {
  _MeadowPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _sky(canvas, size);
    _sun(canvas, size);
    _clouds(canvas, size);
    _trees(canvas, size);
    _meadow(canvas, size);
    _fence(canvas, size);
    _grassTexture(canvas, size);
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
          colors: [Color(0xFF6FC0F5), Color(0xFF9CD8F8), Color(0xFFD0EFFA)],
          stops: [0.0, 0.35, 0.6],
        ).createShader(r),
    );
  }

  void _sun(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.87, size.height * 0.195);
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
        c + Offset(math.cos(a) * 36, math.sin(a) * 36),
        c + Offset(math.cos(a) * 50, math.sin(a) * 50),
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.8)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 32, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c + const Offset(-8, -8),
      14,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(c + const Offset(-9, -3), 2.6, face);
    canvas.drawCircle(c + const Offset(9, -3), 2.6, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 18, height: 12),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawCircle(c + const Offset(-17, 5), 4.5, cheek);
    canvas.drawCircle(c + const Offset(17, 5), 4.5, cheek);
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final shade = Paint()..color = const Color(0xFFC9E2F6);
    final body = Paint()..color = Colors.white.withValues(alpha: 0.97);
    void puffs(Paint p, double dy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 12 * s + dy), width: 92 * s, height: 26 * s),
          Radius.circular(13 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-22 * s, 3 * s + dy), 18 * s, p);
      canvas.drawCircle(c + Offset(4 * s, -8 * s + dy), 24 * s, p);
      canvas.drawCircle(c + Offset(30 * s, 5 * s + dy), 16 * s, p);
    }

    puffs(shade, 3 * s);
    puffs(body, 0);
  }

  void _clouds(Canvas canvas, Size size) {
    for (final (nx, ny, sc) in [
      (0.14, 0.25, 0.85),
      (0.12, 0.33, 0.75),
      (0.93, 0.31, 0.95),
      (0.7, 0.35, 0.55),
      (0.5, 0.245, 0.5),
      (0.28, 0.375, 0.5),
    ]) {
      final x = (size.width * nx + t * size.width * 0.03) % (size.width + 120) - 40;
      _cloud(canvas, Offset(x, size.height * ny), sc);
    }
  }

  void _tree(Canvas canvas, Offset base, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx - 6 * s, base.dy - 30 * s, 12 * s, 40 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );
    for (final (dx, dy, r, c) in [
      (-26.0, -56.0, 30.0, 0xFF3F9C45),
      (26.0, -56.0, 30.0, 0xFF3F9C45),
      (0.0, -78.0, 36.0, 0xFF56B052),
      (-4.0, -50.0, 34.0, 0xFF4BA84B),
      (-12.0, -84.0, 18.0, 0xFF7CCB6E),
    ]) {
      canvas.drawCircle(base + Offset(dx * s, dy * s), r * s, Paint()..color = Color(c));
    }
  }

  void _trees(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Soft far hills behind the trees.
    final hills = Path()
      ..moveTo(0, h * 0.5)
      ..quadraticBezierTo(w * 0.2, h * 0.42, w * 0.45, h * 0.48)
      ..quadraticBezierTo(w * 0.75, h * 0.42, w, h * 0.47)
      ..lineTo(w, h * 0.62)
      ..lineTo(0, h * 0.62)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF8FD37D));
    for (final (nx, ny, sc) in [
      (0.06, 0.5, 1.6),
      (0.2, 0.47, 1.1),
      (0.94, 0.5, 1.6),
      (0.8, 0.475, 1.15),
    ]) {
      _tree(canvas, Offset(w * nx, h * ny), sc);
    }
  }

  void _meadow(Canvas canvas, Size size) {
    final top = size.height * 0.455;
    final path = Path()
      ..moveTo(0, top + 20)
      ..quadraticBezierTo(size.width * 0.5, top - 4, size.width, top + 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final r = Rect.fromLTWH(0, top, size.width, size.height - top);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9DE72), Color(0xFF86CC55), Color(0xFF63B03F)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(r),
    );
  }

  void _fence(Canvas canvas, Size size) {
    final w = size.width;
    final y = size.height * 0.435;
    final wood = Paint()..color = const Color(0xFFD9A868);
    final dark = Paint()..color = const Color(0xFFB98649);
    // Only the left and right ends show; the middle is covered by the content.
    for (final (x0, x1) in [(0.0, w * 0.24), (w * 0.76, w)]) {
      for (final ry in [y + 6, y + 24]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(x0, ry, x1, ry + 8), const Radius.circular(3)),
          wood,
        );
        canvas.drawRect(Rect.fromLTRB(x0, ry + 5, x1, ry + 8), dark);
      }
      final n = ((x1 - x0) / 44).round();
      for (var i = 0; i < n; i++) {
        final x = x0 + 20 + i * 44.0;
        final post = Path()
          ..moveTo(x - 11, y + 46)
          ..lineTo(x - 11, y + 4)
          ..lineTo(x, y - 8)
          ..lineTo(x + 11, y + 4)
          ..lineTo(x + 11, y + 46)
          ..close();
        canvas.drawPath(post, Paint()..color = const Color(0xFFDDAE6F));
        canvas.drawPath(
          post,
          Paint()
            ..color = const Color(0xFF9C6B36).withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
        canvas.drawCircle(Offset(x, y + 10), 1.6, Paint()..color = const Color(0xFF7A5230));
      }
    }
  }

  void _grassTexture(Canvas canvas, Size size) {
    final green = [const Color(0xFF4FA83A), const Color(0xFF6DBE4C), const Color(0xFF3F9430)];
    for (var i = 0; i < 26; i++) {
      final x = size.width * (((i * 37) % 94) + 3) / 100;
      final y = size.height * (0.5 + ((i * 23) % 44) / 100);
      final sway = math.sin(t * math.pi * 4 + i) * 2;
      for (var b = -1; b <= 1; b++) {
        canvas.drawPath(
          Path()
            ..moveTo(x + b * 4, y)
            ..quadraticBezierTo(x + b * 7 + sway, y - 9, x + b * 10 + sway, y - 15 + b.abs() * 3),
          Paint()
            ..color = green[(i + b + 1) % 3].withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _daisy(Canvas canvas, Offset c, double r) {
    for (var p = 0; p < 6; p++) {
      final a = p * math.pi / 3;
      canvas.drawCircle(c + Offset(math.cos(a) * r, math.sin(a) * r), r * 0.68, Paint()..color = Colors.white);
    }
    canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFFFFB300));
  }

  void _daisies(Canvas canvas, Size size) {
    for (final (nx, ny, r) in [
      (0.06, 0.475, 7.0),
      (0.87, 0.475, 6.5),
      (0.92, 0.49, 5.0),
      (0.83, 0.485, 4.5),
      (0.16, 0.925, 8.0),
      (0.68, 0.815, 5.5),
    ]) {
      _daisy(canvas, Offset(size.width * nx, size.height * ny), r);
    }
  }

  void _foreground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (nx, ny, r, c) in [
      (0.0, 0.97, 70.0, 0xFF3B9440),
      (0.12, 1.02, 56.0, 0xFF2F8437),
      (1.0, 0.965, 76.0, 0xFF3B9440),
      (0.88, 1.03, 58.0, 0xFF2F8437),
    ]) {
      canvas.drawCircle(Offset(w * nx, h * ny), r, Paint()..color = Color(c));
    }
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
    leaf(Offset(w * 0.02, h * 0.99), 100, -1.1, g1);
    leaf(Offset(w * 0.08, h * 1.0), 90, -0.5, g2);
    leaf(Offset(w * 0.15, h * 1.0), 76, -1.45, g1);
    leaf(Offset(w * 0.98, h * 0.99), 100, -math.pi + 1.1, g1);
    leaf(Offset(w * 0.92, h * 1.0), 90, -math.pi + 0.5, g2);
    leaf(Offset(w * 0.85, h * 1.0), 76, -math.pi + 1.45, g1);
    _daisy(canvas, Offset(w * 0.88, h * 0.955), 9);
    _daisy(canvas, Offset(w * 0.2, h * 0.965), 9);
    _daisy(canvas, Offset(w * 0.07, h * 0.925), 6);
  }

  @override
  bool shouldRepaint(covariant _MeadowPainter old) => old.t != t;
}
