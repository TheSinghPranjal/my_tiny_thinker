import 'dart:math' as math;

import 'package:flutter/material.dart';

class PartyBackground extends StatelessWidget {
  const PartyBackground({
    super.key,
    required this.child,
    this.eveningFactor = 0,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _PartyRoomPainter(
            eveningFactor: eveningFactor,
            envPhase: envPhase,
            reducedMotion: reducedMotion,
            intensity: intensity,
          ),
        ),
        child,
      ],
    );
  }
}

class _PartyRoomPainter extends CustomPainter {
  _PartyRoomPainter({
    required this.eveningFactor,
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final evening = eveningFactor.clamp(0.0, 1.0);
    final wallTop = Color.lerp(const Color(0xFFFFF8E1), const Color(0xFF4E342E), evening * 0.5)!;
    final wallBottom = Color.lerp(const Color(0xFFFFECB3), const Color(0xFF3E2723), evening * 0.55)!;
    final floor = Color.lerp(const Color(0xFFD7CCC8), const Color(0xFF4E342E), evening * 0.35)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.82),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [wallTop, wallBottom],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.82)),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
      Paint()..color = floor,
    );

    // Baseboard
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.81, size.width, 6),
      Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.6),
    );

    _drawBanner(canvas, size);
    _drawFairyLights(canvas, size, evening);
    _drawBalloons(canvas, size);
    _drawWindow(canvas, size, evening);

    if (evening > 0.15) {
      _drawWarmGlow(canvas, size, evening);
    }
  }

  void _drawBanner(Canvas canvas, Size size) {
    final y = size.height * 0.055;
    final rope = Paint()
      ..color = const Color(0xFFFF7043)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(size.width * 0.04, y);
    for (var i = 0; i <= 7; i++) {
      final x = size.width * (0.04 + i * 0.12);
      path.quadraticBezierTo(x + size.width * 0.06, y + (i.isEven ? 12 : 5), x + size.width * 0.12, y);
    }
    canvas.drawPath(path, rope);

    const flagColors = [0xFFF48FB1, 0xFF81D4FA, 0xFFFFF176, 0xFFCE93D8, 0xFFA5D6A7];
    for (var i = 0; i < 7; i++) {
      final fx = size.width * (0.08 + i * 0.12);
      final flag = Path()
        ..moveTo(fx, y + 4)
        ..lineTo(fx + 10, y + 16)
        ..lineTo(fx - 10, y + 16)
        ..close();
      canvas.drawPath(flag, Paint()..color = Color(flagColors[i % flagColors.length]));
    }
  }

  void _drawFairyLights(Canvas canvas, Size size, double evening) {
    final glow = 0.4 + evening * 0.5;
    for (var i = 0; i < 10; i++) {
      final x = size.width * (0.05 + i * 0.095);
      final y = size.height * 0.095 + math.sin(envPhase * 2 + i) * 2;
      final colors = [0xFFFFEB3B, 0xFFFF4081, 0xFF69F0AE, 0xFF40C4FF];
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = Color(colors[i % colors.length]).withValues(alpha: glow),
      );
      canvas.drawLine(
        Offset(x, y - 5),
        Offset(x, y - 12),
        Paint()..color = Colors.white54..strokeWidth = 1,
      );
    }
  }

  void _drawBalloons(Canvas canvas, Size size) {
    if (reducedMotion) return;
    final balloons = [
      (0.9, 0.22, 0xFFF48FB1),
      (0.94, 0.30, 0xFF81D4FA),
      (0.05, 0.28, 0xFFFFF176),
    ];
    for (final (nx, ny, color) in balloons) {
      final x = size.width * nx + math.sin(envPhase + nx * 10) * 5;
      final y = size.height * ny + math.cos(envPhase * 0.8) * 3;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 30, height: 38),
        Paint()
          ..shader = RadialGradient(
            colors: [Color(color), Color.lerp(Color(color), Colors.black, 0.2)!],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 20)),
      );
      canvas.drawLine(
        Offset(x, y + 19),
        Offset(x - 3, y + 34),
        Paint()..color = Colors.white70..strokeWidth = 1.5,
      );
    }
  }

  void _drawWindow(Canvas canvas, Size size, double evening) {
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.64, size.height * 0.07, size.width * 0.26, size.height * 0.16),
      const Radius.circular(10),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRRect(
      frame.deflate(5),
      Paint()..color = Color.lerp(const Color(0xFF81D4FA), const Color(0xFF1A237E), evening * 0.6)!,
    );
    // Cross panes
    final inner = frame.deflate(5);
    canvas.drawLine(
      Offset(inner.left + inner.width / 2, inner.top),
      Offset(inner.left + inner.width / 2, inner.bottom),
      Paint()..color = const Color(0xFF8D6E63)..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(inner.left, inner.top + inner.height / 2),
      Offset(inner.right, inner.top + inner.height / 2),
      Paint()..color = const Color(0xFF8D6E63)..strokeWidth = 3,
    );
    // Curtains
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.61, size.height * 0.06, size.width * 0.05, size.height * 0.18),
      Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.75),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.88, size.height * 0.06, size.width * 0.05, size.height * 0.18),
      Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.75),
    );
  }

  void _drawWarmGlow(Canvas canvas, Size size, double evening) {
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.45,
      Paint()..color = const Color(0xFFFFB74D).withValues(alpha: 0.06 * evening),
    );
  }

  @override
  bool shouldRepaint(covariant _PartyRoomPainter old) =>
      old.eveningFactor != eveningFactor ||
      old.envPhase != envPhase ||
      old.reducedMotion != reducedMotion;
}
