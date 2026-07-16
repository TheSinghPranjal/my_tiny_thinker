import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/bunny_hop_adventure/models/bunny_hop_models.dart';

class BunnyWidget extends StatelessWidget {
  const BunnyWidget({
    super.key,
    required this.bunny,
    this.largerTouch = false,
  });

  final BunnyEntity bunny;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 100.0 : 88.0;
    final blink = (bunny.blinkTimer % 3.5) < 0.12;

    return Positioned(
      left: bunny.x - size / 2,
      top: bunny.y - size / 2,
      child: Transform.scale(
        scaleY: bunny.squash,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BunnyPainter(bunny: bunny, blink: blink),
          ),
        ),
      ),
    );
  }
}

class _BunnyPainter extends CustomPainter {
  _BunnyPainter({required this.bunny, required this.blink});

  final BunnyEntity bunny;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 6;
    final breathe = math.sin(bunny.animPhase * 2) * 1.5;
    final celebrate = bunny.celebrateProgress;
    final wet = bunny.phase == BunnyPhase.swimming || bunny.shakeWater > 0;

    canvas.save();
    canvas.translate(0, breathe - celebrate * 6);

    if (!bunny.facingRight) {
      canvas.translate(cx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-cx, 0);
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 36, height: 28),
      Paint()..color = const Color(0xFFEFEBE9),
    );

    canvas.drawCircle(Offset(cx, cy - 2), 22, Paint()..color = const Color(0xFFEFEBE9));
    canvas.drawCircle(Offset(cx - 14, cy - 18), 10, Paint()..color = const Color(0xFFEFEBE9));
    canvas.drawCircle(Offset(cx + 14, cy - 18), 10, Paint()..color = const Color(0xFFEFEBE9));
    canvas.drawCircle(Offset(cx - 14, cy - 18), 5, Paint()..color = const Color(0xFFF48FB1));
    canvas.drawCircle(Offset(cx + 14, cy - 18), 5, Paint()..color = const Color(0xFFF48FB1));

    _drawEye(canvas, cx - 8, cy - 4, blink);
    _drawEye(canvas, cx + 8, cy - 4, blink);

    canvas.drawCircle(Offset(cx, cy + 2), 3, Paint()..color = const Color(0xFFF48FB1));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 12, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(cx + 20, cy + 14), 8, Paint()..color = Colors.white);

    if (wet) {
      for (var i = 0; i < 4; i++) {
        canvas.drawCircle(
          Offset(cx - 16 + i * 10, cy + 22),
          2,
          Paint()..color = const Color(0xFF4FC3F7).withValues(alpha: 0.7),
        );
      }
    }

    if (bunny.phase == BunnyPhase.celebrating) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 22, cy + 2), width: 14, height: 18),
        -0.5,
        1.0,
        false,
        Paint()
          ..color = const Color(0xFFEFEBE9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  void _drawEye(Canvas canvas, double x, double y, bool blink) {
    if (blink) {
      canvas.drawLine(
        Offset(x - 4, y),
        Offset(x + 4, y),
        Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2,
      );
    } else {
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = const Color(0xFF3E2723));
      canvas.drawCircle(Offset(x - 1, y - 1), 1.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter old) =>
      old.bunny != bunny || old.blink != blink;
}

class CarrotWidget extends StatelessWidget {
  const CarrotWidget({super.key, required this.carrot});

  final CarrotEntity carrot;

  @override
  Widget build(BuildContext context) {
    if (!carrot.visible) return const SizedBox.shrink();
    final bounce = math.sin(carrot.bouncePhase) * 6;

    return Positioned(
      left: carrot.x - 28,
      top: carrot.y - 36 + bounce,
      child: SizedBox(
        width: 56,
        height: 64,
        child: CustomPaint(
          painter: _CarrotPainter(carrot: carrot),
        ),
      ),
    );
  }
}

class _CarrotPainter extends CustomPainter {
  _CarrotPainter({required this.carrot});

  final CarrotEntity carrot;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;

    if (carrot.glow > 0) {
      canvas.drawCircle(
        Offset(cx, cy),
        28,
        Paint()..color = const Color(0xFFFF9800).withValues(alpha: carrot.glow * 0.35),
      );
    }

    final path = Path()
      ..moveTo(cx - 10, cy - 16)
      ..lineTo(cx + 10, cy - 16)
      ..lineTo(cx + 6, cy + 22)
      ..quadraticBezierTo(cx, cy + 28, cx - 6, cy + 22)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF7043));

    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 4 + i * 4, cy - 16),
        Offset(cx - 8 + i * 6, cy - 28),
        Paint()
          ..color = const Color(0xFF66BB6A)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < 4; i++) {
      final a = carrot.sparklePhase + i * 1.5;
      canvas.drawCircle(
        Offset(cx + math.cos(a) * 22, cy + math.sin(a) * 18),
        2,
        Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarrotPainter old) => old.carrot != carrot;
}

class LilyPadWidget extends StatelessWidget {
  const LilyPadWidget({super.key, required this.pad});

  final LilyPadEntity pad;

  @override
  Widget build(BuildContext context) {
    if (pad.phase == LilyPadPhase.sunk) return const SizedBox.shrink();

    return Positioned(
      left: pad.x - 38,
      top: pad.y - 22 + pad.bobOffset,
      child: SizedBox(
        width: 76,
        height: 44,
        child: CustomPaint(
          painter: _LilyPadPainter(pad: pad),
        ),
      ),
    );
  }
}

class _LilyPadPainter extends CustomPainter {
  _LilyPadPainter({required this.pad});

  final LilyPadEntity pad;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sink = pad.sinkProgress;

    final padCenter = Offset(cx, cy + sink * 20);
    canvas.drawOval(
      Rect.fromCenter(center: padCenter, width: 68, height: 36),
      Paint()..color = pad.isCracked ? const Color(0xFF689F38) : const Color(0xFF7CB342),
    );
    canvas.drawOval(
      Rect.fromCenter(center: padCenter.translate(0, 2), width: 62, height: 30),
      Paint()..color = const Color(0xFF8BC34A).withValues(alpha: 0.55),
    );

    canvas.drawArc(
      Rect.fromCenter(center: padCenter, width: 68, height: 36),
      -0.3,
      0.5,
      false,
      Paint()
        ..color = const Color(0xFF558B2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (!pad.isCracked && pad.index % 2 == 0) {
      canvas.drawCircle(
        padCenter.translate(0, -4),
        5,
        Paint()..color = const Color(0xFFF48FB1),
      );
      for (var i = 0; i < 5; i++) {
        final a = i * 1.25;
        canvas.drawCircle(
          padCenter.translate(math.cos(a) * 7, -4 + math.sin(a) * 7),
          2.5,
          Paint()..color = const Color(0xFFFFEB3B),
        );
      }
    }

    if (pad.isCracked) {
      canvas.drawLine(
        Offset(cx - 12, cy - 4 + sink * 20),
        Offset(cx + 8, cy + 6 + sink * 20),
        Paint()..color = const Color(0xFF33691E)..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(cx + 4, cy - 6 + sink * 20),
        Offset(cx - 6, cy + 8 + sink * 20),
        Paint()..color = const Color(0xFF33691E)..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LilyPadPainter old) => old.pad != pad;
}
