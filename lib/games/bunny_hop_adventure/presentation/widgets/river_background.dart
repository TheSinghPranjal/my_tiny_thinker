import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the river scene sized to the play area so grass, water, and pads align.
class RiverPlayScene extends StatelessWidget {
  const RiverPlayScene({
    super.key,
    required this.envPhase,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RiverPlayScenePainter(
        envPhase: envPhase,
        reducedMotion: reducedMotion,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _RiverPlayScenePainter extends CustomPainter {
  _RiverPlayScenePainter({
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawMeadow(canvas, size);
    _drawSideBanks(canvas, size);
    _drawRiver(canvas, size);
    _drawClouds(canvas, size);
    _drawReeds(canvas, size);
    _drawFlowers(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.38),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.38)),
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.1),
      22,
      Paint()..color = const Color(0xFFFFF176).withValues(alpha: 0.9),
    );
  }

  void _drawMeadow(Canvas canvas, Size size) {
    final meadowTop = size.height * 0.34;
    canvas.drawRect(
      Rect.fromLTWH(0, meadowTop, size.width, size.height - meadowTop),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFA5D6A7), Color(0xFF66BB6A), Color(0xFF43A047)],
        ).createShader(Rect.fromLTWH(0, meadowTop, size.width, size.height - meadowTop)),
    );
  }

  void _drawSideBanks(Canvas canvas, Size size) {
    final bankTop = size.height * 0.30;
    final bankBottom = size.height * 0.52;
    for (final isLeft in [true, false]) {
      final rect = isLeft
          ? Rect.fromLTRB(0, bankTop, size.width * 0.16, bankBottom)
          : Rect.fromLTRB(size.width * 0.84, bankTop, size.width, bankBottom);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFF9CCC65), Color(0xFF7CB342), Color(0xFF558B2F)],
          ).createShader(rect),
      );
    }
  }

  void _drawRiver(Canvas canvas, Size size) {
    final riverTop = size.height * 0.48;
    final riverH = size.height * 0.18;
    final riverRect = Rect.fromLTWH(0, riverTop, size.width, riverH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(riverRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF039BE5), Color(0xFF0277BD)],
        ).createShader(riverRect),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, riverTop, size.width, 6),
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    if (!reducedMotion) {
      for (var i = 0; i < 6; i++) {
        final x = (size.width * i / 6 + envPhase * 24) % size.width;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, riverTop + riverH * 0.55 + math.sin(envPhase + i) * 3),
            width: 14,
            height: 5,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.2),
        );
      }
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    if (reducedMotion) return;
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.08 + i * 0.3) + envPhase * 10) % (size.width + 60) - 30;
      final y = size.height * (0.06 + i * 0.04);
      canvas.drawCircle(Offset(x, y), 20, Paint()..color = Colors.white.withValues(alpha: 0.9));
      canvas.drawCircle(Offset(x + 18, y + 3), 15, Paint()..color = Colors.white.withValues(alpha: 0.85));
    }
  }

  void _drawReeds(Canvas canvas, Size size) {
    final baseY = size.height * 0.62;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.03 + i * 0.04);
      final sway = reducedMotion ? 0.0 : math.sin(envPhase * 2 + i) * 3;
      canvas.drawLine(
        Offset(x, baseY),
        Offset(x + sway, baseY - 24),
        Paint()
          ..color = const Color(0xFF558B2F)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawFlowers(Canvas canvas, Size size) {
    const colors = [0xFFF48FB1, 0xFFFFEB3B, 0xFFCE93D8, 0xFFFF7043, 0xFF81D4FA];
    for (var i = 0; i < 12; i++) {
      final x = size.width * ((i * 37) % 92) / 100;
      final y = size.height * (0.68 + (i % 4) * 0.06);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Color(colors[i % colors.length]));
      canvas.drawCircle(Offset(x, y - 3), 2, Paint()..color = const Color(0xFF66BB6A));
    }
  }

  @override
  bool shouldRepaint(covariant _RiverPlayScenePainter old) => old.envPhase != envPhase;
}

/// Full-screen wrapper for setup screens and outer shell.
class RiverBackground extends StatelessWidget {
  const RiverBackground({
    super.key,
    this.child,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget? child;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RiverPlayScene(
          envPhase: envPhase,
          reducedMotion: reducedMotion,
          intensity: intensity,
        ),
        ?child,
      ],
    );
  }
}
