import 'dart:math' as math;

import 'package:flutter/material.dart';

class ClassroomBackground extends StatefulWidget {
  const ClassroomBackground({
    super.key,
    required this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
  });

  final Widget child;
  final double envPhase;
  final bool reducedMotion;

  @override
  State<ClassroomBackground> createState() => _ClassroomBackgroundState();
}

class _ClassroomBackgroundState extends State<ClassroomBackground>
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
    final t = widget.reducedMotion ? widget.envPhase * 0.05 : _c.value;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _ClassroomPainter(t: t)),
        widget.child,
      ],
    );
  }
}

class _ClassroomPainter extends CustomPainter {
  _ClassroomPainter({required this.t});
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
            Color(0xFFFFE0F0),
            Color(0xFFE1F5FE),
            Color(0xFFFFF9C4),
            Color(0xFFE8F5E9),
          ],
        ).createShader(rect),
    );

    _rainbow(canvas, size);
    _clouds(canvas, size);
    _balloons(canvas, size);
    _butterflies(canvas, size);
    _stars(canvas, size);
    _books(canvas, size);
  }

  void _rainbow(Canvas canvas, Size size) {
    const colors = [
      Color(0x66EF5350),
      Color(0x66FF9800),
      Color(0x66FFEB3B),
      Color(0x6666BB6A),
      Color(0x6642A5F5),
      Color(0x667E57C2),
    ];
    final c = Offset(size.width * 0.5, size.height * 0.55);
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: c,
          width: size.width * 1.1 - i * 16,
          height: size.height * 0.55 - i * 10,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }
  }

  void _clouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.1 + i * 0.32) + t * 40) % (size.width + 80);
      final y = size.height * (0.08 + i * 0.03);
      canvas.drawCircle(Offset(x, y), 18, paint);
      canvas.drawCircle(Offset(x + 18, y + 2), 14, paint);
      canvas.drawCircle(Offset(x + 6, y - 8), 12, paint);
      // Smile
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x + 8, y + 2), width: 10, height: 6),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = const Color(0xFF90A4AE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _balloons(Canvas canvas, Size size) {
    const colors = [0xFFF48FB1, 0xFF81D4FA, 0xFFFFF176, 0xFFCE93D8];
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.08 + i * 0.28);
      final y = size.height * 0.22 + math.sin(t * math.pi * 2 + i) * 10;
      final color = Color(colors[i]);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 28, height: 36),
        Paint()..color = color,
      );
      canvas.drawLine(
        Offset(x, y + 18),
        Offset(x - 2, y + 40),
        Paint()..color = Colors.white70..strokeWidth = 1.5,
      );
    }
  }

  void _butterflies(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.2 + i * 0.3) + t * 60) % size.width;
      final y = size.height * (0.35 + i * 0.05) + math.sin(t * 8 + i) * 8;
      canvas.drawCircle(Offset(x - 6, y), 5, Paint()..color = const Color(0xFFF48FB1));
      canvas.drawCircle(Offset(x + 6, y), 5, Paint()..color = const Color(0xFFCE93D8));
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = const Color(0xFF5D4037));
    }
  }

  void _stars(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final x = size.width * ((i * 37) % 90) / 100;
      final y = size.height * (0.55 + (i % 3) * 0.08);
      final a = 0.35 + math.sin(t * 6 + i).abs() * 0.45;
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = const Color(0xFFFFF176).withValues(alpha: a),
      );
    }
  }

  void _books(Canvas canvas, Size size) {
    final base = size.height * 0.88;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, base, 40, 18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFEF5350),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.88, base - 4, 36, 22),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF42A5F5),
    );
  }

  @override
  bool shouldRepaint(covariant _ClassroomPainter old) => old.t != t;
}
