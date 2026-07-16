import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

class PondFishWidget extends StatelessWidget {
  const PondFishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.largerTouch = false,
  });

  final PondFishEntity fish;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (fish.phase == FishPhase.gone) return const SizedBox.shrink();

    final def = PondFishVarieties.byIndex(fish.varietyIndex, isGolden: fish.isGolden);
    final touch = (largerTouch ? 84.0 : 76.0) * def.lengthScale;
    final alpha = fish.phase == FishPhase.sinking ? (1 - fish.sinkProgress).clamp(0.0, 1.0) : 1.0;
    final selected = fish.phase == FishPhase.selected;
    final tappable = fish.canTap;

    return GestureDetector(
      onTap: tappable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alpha,
        child: AnimatedScale(
          scale: selected ? 1.18 : (tappable ? 1.0 : 0.95),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: touch + 20,
            height: touch * 0.78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (tappable)
                  _TapPulse(color: Color(def.bodyColor), active: !selected),
                if (fish.isGolden || fish.glow > 0)
                  Container(
                    width: touch * 0.9,
                    height: touch * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(fish.isGolden ? 0xFFFFD54F : 0xFFFFF176)
                              .withValues(alpha: (fish.glow * 0.7).clamp(0.25, 0.85)),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                Transform.scale(
                  scaleX: fish.facingRight ? 1 : -1,
                  child: CustomPaint(
                    size: Size(touch, touch * 0.62),
                    painter: _FishPainter(
                      def: def,
                      wiggle: fish.pathT,
                      selected: selected,
                      depth: fish.depth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TapPulse extends StatefulWidget {
  const _TapPulse({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  State<_TapPulse> createState() => _TapPulseState();
}

class _TapPulseState extends State<_TapPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return CustomPaint(
          size: const Size(72, 48),
          painter: _PulsePainter(progress: t, color: widget.color),
        );
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = 18 + progress * 16;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withValues(alpha: (1 - progress) * 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.progress != progress;
}

class _FishPainter extends CustomPainter {
  _FishPainter({
    required this.def,
    required this.wiggle,
    required this.selected,
    required this.depth,
  });

  final PondFishDef def;
  final double wiggle;
  final bool selected;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor = Color(def.bodyColor);
    final finColor = Color(def.finColor);
    final wobble = math.sin(wiggle * 3.2) * 2.2;
    final cx = size.width / 2;
    final cy = size.height / 2 + wobble;
    final bodyW = size.width * 0.58;
    final bodyH = size.height * 0.48;
    final depthShade = 1.0 - depth * 0.15;

    canvas.save();
    canvas.translate(cx, cy);

    final darkBody = Color.lerp(bodyColor, Colors.black, 0.18)!;
    final lightBody = Color.lerp(bodyColor, Colors.white, 0.25)!;

    // --- Tail (forked) ---
    final tailWave = math.sin(wiggle * 5) * 0.12;
    canvas.save();
    canvas.translate(-bodyW * 0.42, 0);
    canvas.rotate(tailWave);
    final tail = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-bodyW * 0.22, -bodyH * 0.85, -bodyW * 0.55, -bodyH * 0.95)
      ..quadraticBezierTo(-bodyW * 0.28, -bodyH * 0.15, -bodyW * 0.18, 0)
      ..quadraticBezierTo(-bodyW * 0.28, bodyH * 0.15, -bodyW * 0.55, bodyH * 0.95)
      ..quadraticBezierTo(-bodyW * 0.22, bodyH * 0.85, 0, 0)
      ..close();
    canvas.drawPath(
      tail,
      Paint()
        ..shader = LinearGradient(
          colors: [finColor, Color.lerp(finColor, Colors.white, 0.2)!],
        ).createShader(Rect.fromLTWH(-bodyW * 0.55, -bodyH, bodyW * 0.55, bodyH * 2)),
    );
    canvas.drawPath(
      tail,
      Paint()
        ..color = darkBody.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.restore();

    // --- Body (teardrop / fish silhouette) ---
    final body = Path()
      ..moveTo(bodyW * 0.48, 0) // nose
      ..quadraticBezierTo(bodyW * 0.35, -bodyH * 0.55, 0, -bodyH * 0.5)
      ..quadraticBezierTo(-bodyW * 0.35, -bodyH * 0.45, -bodyW * 0.42, 0)
      ..quadraticBezierTo(-bodyW * 0.35, bodyH * 0.45, 0, bodyH * 0.5)
      ..quadraticBezierTo(bodyW * 0.35, bodyH * 0.55, bodyW * 0.48, 0)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lightBody.withValues(alpha: depthShade),
            bodyColor.withValues(alpha: depthShade),
            darkBody.withValues(alpha: depthShade),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: bodyW, height: bodyH)),
    );

    // Belly highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bodyW * 0.05, bodyH * 0.12), width: bodyW * 0.55, height: bodyH * 0.35),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    _drawScales(canvas, bodyW, bodyH);
    _drawPattern(canvas, bodyW, bodyH, finColor);

    // --- Dorsal fin ---
    final dorsalWave = math.sin(wiggle * 4) * 0.05;
    final dorsal = Path()
      ..moveTo(-bodyW * 0.05, -bodyH * 0.42)
      ..quadraticBezierTo(bodyW * 0.02 + dorsalWave * bodyW, -bodyH * 1.05, bodyW * 0.22, -bodyH * 0.38)
      ..quadraticBezierTo(bodyW * 0.08, -bodyH * 0.55, -bodyW * 0.05, -bodyH * 0.42)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = finColor.withValues(alpha: 0.95 * depthShade));
    canvas.drawPath(
      dorsal,
      Paint()
        ..color = darkBody.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // --- Pectoral fin ---
    final pecWave = math.sin(wiggle * 6) * 0.15;
    canvas.save();
    canvas.translate(bodyW * 0.05, bodyH * 0.05);
    canvas.rotate(0.35 + pecWave);
    final pec = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(bodyW * 0.02, bodyH * 0.45, -bodyW * 0.18, bodyH * 0.55)
      ..quadraticBezierTo(-bodyW * 0.08, bodyH * 0.2, 0, 0)
      ..close();
    canvas.drawPath(pec, Paint()..color = finColor.withValues(alpha: 0.88));
    canvas.restore();

    // --- Anal fin ---
    final anal = Path()
      ..moveTo(-bodyW * 0.12, bodyH * 0.32)
      ..lineTo(-bodyW * 0.28, bodyH * 0.62)
      ..lineTo(bodyW * 0.02, bodyH * 0.38)
      ..close();
    canvas.drawPath(anal, Paint()..color = finColor.withValues(alpha: 0.8));

    // --- Mouth ---
    canvas.drawArc(
      Rect.fromCenter(center: Offset(bodyW * 0.4, bodyH * 0.06), width: bodyW * 0.12, height: bodyH * 0.14),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = darkBody.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // --- Eye (big & cute) ---
    final eyeCenter = Offset(bodyW * 0.28, -bodyH * 0.1);
    final eyeR = bodyH * 0.22;
    canvas.drawCircle(eyeCenter, eyeR, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.15, eyeCenter.dy),
      eyeR * 0.62,
      Paint()..color = const Color(0xFF1A237E),
    );
    canvas.drawCircle(
      Offset(eyeCenter.dx + eyeR * 0.35, eyeCenter.dy - eyeR * 0.28),
      eyeR * 0.22,
      Paint()..color = Colors.white,
    );

    // Soft cheek blush
    canvas.drawCircle(
      Offset(bodyW * 0.32, bodyH * 0.12),
      bodyH * 0.1,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.35),
    );

    if (selected) {
      canvas.drawCircle(
        Offset.zero,
        bodyW * 0.62,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      for (var i = 0; i < 6; i++) {
        final a = wiggle * 4 + i * math.pi / 3;
        canvas.drawCircle(
          Offset(math.cos(a) * bodyW * 0.7, math.sin(a) * bodyH * 0.7),
          2.5,
          Paint()..color = const Color(0xFFFFEB3B),
        );
      }
    }

    canvas.restore();
  }

  void _drawScales(Canvas canvas, double bodyW, double bodyH) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        final ox = -bodyW * 0.22 + col * bodyW * 0.14 + (row.isOdd ? bodyW * 0.07 : 0);
        final oy = -bodyH * 0.22 + row * bodyH * 0.18;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(ox, oy), width: bodyW * 0.12, height: bodyH * 0.16),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          paint,
        );
      }
    }
  }

  void _drawPattern(Canvas canvas, double bodyW, double bodyH, Color fin) {
    switch (def.pattern) {
      case PondFishPattern.striped:
        for (var i = 0; i < 4; i++) {
          canvas.drawLine(
            Offset(-bodyW * 0.18 + i * bodyW * 0.14, -bodyH * 0.38),
            Offset(-bodyW * 0.18 + i * bodyW * 0.14, bodyH * 0.38),
            Paint()
              ..color = fin.withValues(alpha: 0.4)
              ..strokeWidth = 2.5
              ..strokeCap = StrokeCap.round,
          );
        }
      case PondFishPattern.spotted:
        for (final offset in [
          Offset(bodyW * 0.02, -bodyH * 0.16),
          Offset(bodyW * 0.14, bodyH * 0.02),
          Offset(-bodyW * 0.08, bodyH * 0.14),
          Offset(-bodyW * 0.18, -bodyH * 0.06),
        ]) {
          canvas.drawCircle(
            offset,
            bodyH * 0.1,
            Paint()..color = Color(def.spotColor).withValues(alpha: 0.6),
          );
        }
      case PondFishPattern.rainbow:
        const colors = [
          Color(0xFFFF7043),
          Color(0xFFFFCA28),
          Color(0xFF66BB6A),
          Color(0xFF42A5F5),
          Color(0xFFAB47BC),
        ];
        for (var i = 0; i < colors.length; i++) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset.zero, width: bodyW * 0.9, height: bodyH * 1.05),
            math.pi * 0.5 + i * 0.1,
            0.14,
            false,
            Paint()
              ..color = colors[i].withValues(alpha: 0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      case PondFishPattern.tropical:
        canvas.drawPath(
          Path()
            ..moveTo(bodyW * 0.05, -bodyH * 0.25)
            ..lineTo(bodyW * 0.22, 0)
            ..lineTo(bodyW * 0.05, bodyH * 0.25),
          Paint()
            ..color = fin.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      case PondFishPattern.solid:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _FishPainter old) =>
      old.def != def ||
      old.wiggle != wiggle ||
      old.selected != selected ||
      old.depth != depth;
}
