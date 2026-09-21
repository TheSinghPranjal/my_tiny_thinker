import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/cloud_pop_garden/models/cloud_pop_garden_models.dart';

class CloudWidget extends StatelessWidget {
  const CloudWidget({
    super.key,
    required this.cloud,
    required this.onTap,
    this.lightningEnabled = true,
  });

  final CloudEntity cloud;
  final VoidCallback onTap;
  final bool lightningEnabled;

  @override
  Widget build(BuildContext context) {
    const size = 88.0;
    final bounce = cloud.bounceTimer > 0
        ? math.sin(cloud.bounceTimer * 14) * 6
        : 0.0;

    return Positioned(
      left: cloud.x - size / 2,
      top: cloud.y - size / 2 + bounce,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: cloud.isTappable ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: _CloudPainter(
            blueLevel: cloud.blueLevel,
            showSmile: cloud.showSmile || cloud.phase == CloudPhase.leaving,
            thunderTimer: cloud.thunderTimer,
            lightningEnabled: lightningEnabled,
            rainDrops: cloud.rainDrops,
            bob: math.sin(cloud.bobPhase) * 3,
          ),
          size: const Size(size, size),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter({
    required this.blueLevel,
    required this.showSmile,
    required this.thunderTimer,
    required this.lightningEnabled,
    required this.rainDrops,
    required this.bob,
  });

  final double blueLevel;
  final bool showSmile;
  final double thunderTimer;
  final bool lightningEnabled;
  final List<RainDropEntity> rainDrops;
  final double bob;

  Color get _cloudColor =>
      Color.lerp(kCloudLightBlue, kCloudDarkBlue, blueLevel.clamp(0, 1))!;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + bob;

    if (thunderTimer > 0 && lightningEnabled) {
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.42,
        Paint()
          ..color = const Color(0xFF3949AB).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    final base = _cloudColor;
    final light = Color.lerp(base, Colors.white, 0.35)!;
    final dark = Color.lerp(base, const Color(0xFF1A237E), 0.25)!;

    // Soft ground shadow so the cloud reads as a floating character.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 34),
        width: size.width * 0.6,
        height: 8,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );

    final puffs = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - 18, cy + 4), radius: 22))
      ..addOval(Rect.fromCircle(center: Offset(cx + 20, cy + 2), radius: 24))
      ..addOval(Rect.fromCircle(center: Offset(cx, cy - 8), radius: 26))
      ..addOval(Rect.fromCircle(center: Offset(cx - 4, cy + 10), radius: 20));
    final bounds = Rect.fromCenter(
      center: Offset(cx, cy),
      width: size.width * 0.9,
      height: size.height * 0.7,
    );
    canvas.drawPath(
      puffs,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, base, dark],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );

    // Glossy highlight on the top puff.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy - 22), width: 22, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );
    canvas.drawCircle(
      Offset(cx, cy - 8),
      26,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _drawFace(canvas, cx, cy);

    if (thunderTimer > 0 && lightningEnabled) {
      _drawLightning(canvas, cx, cy + 8);
    }

    for (final drop in rainDrops) {
      final localY = drop.y - (cy - size.height / 2);
      if (localY > 0 && localY < size.height + 40) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(drop.x - (cx - size.width / 2), localY),
            width: drop.size,
            height: drop.size * 1.6,
          ),
          Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.85),
        );
      }
    }
  }

  void _drawFace(Canvas canvas, double cx, double cy) {
    for (final sign in [-1.0, 1.0]) {
      final e = Offset(cx + sign * 12, cy - 2);
      canvas.drawCircle(e, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        e + const Offset(0.8, 0.4),
        3,
        Paint()..color = const Color(0xFF263238),
      );
      canvas.drawCircle(
        e + const Offset(-0.4, -1),
        1.1,
        Paint()..color = Colors.white,
      );
    }

    if (showSmile) {
      final cheek = Paint()
        ..color = const Color(0xFFFF8FA3).withValues(alpha: 0.55);
      canvas.drawCircle(Offset(cx - 21, cy + 6), 4.5, cheek);
      canvas.drawCircle(Offset(cx + 21, cy + 6), 4.5, cheek);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + 8), width: 18, height: 10),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = const Color(0xFF37474F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawLine(
        Offset(cx - 6, cy + 10),
        Offset(cx + 6, cy + 10),
        Paint()
          ..color = const Color(0xFF263238)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawLightning(Canvas canvas, double cx, double cy) {
    final flash = (math.sin(thunderTimer * 28) + 1) * 0.5;
    final bolt = Path()
      ..moveTo(cx - 4, cy - 6)
      ..lineTo(cx + 2, cy + 2)
      ..lineTo(cx - 2, cy + 2)
      ..lineTo(cx + 6, cy + 16);
    canvas.drawPath(
      bolt,
      Paint()
        ..color = AppColors.sunYellow.withValues(alpha: 0.5 + flash * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CloudPainter old) =>
      old.blueLevel != blueLevel ||
      old.showSmile != showSmile ||
      old.thunderTimer != thunderTimer ||
      old.rainDrops.length != rainDrops.length ||
      old.bob != bob;
}
