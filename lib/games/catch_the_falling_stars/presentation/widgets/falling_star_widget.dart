import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

class FallingStarWidget extends StatelessWidget {
  const FallingStarWidget({
    super.key,
    required this.star,
    required this.onTap,
    this.largerTouch = true,
  });

  final FallingStarEntity star;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (star.phase == StarLifePhase.gone) return const SizedBox.shrink();

    final size = star.radius * 2 * (largerTouch ? 1.08 : 1.0);
    final color = kStarVariantColors[star.variant] ?? const Color(0xFFFFD54F);

    final bounce = math.sin(star.animPhase * 2.2) * 4;
    final rot = math.sin(star.swayPhase) * 0.12;
    final glow = 0.45 + 0.35 * (0.5 + 0.5 * math.sin(star.glowPulse));

    double scale = 1;
    double opacity = 1;
    if (star.phase == StarLifePhase.appearing) {
      scale = Curves.easeOutBack.transform(star.appearProgress.clamp(0.0, 1.0));
      opacity = star.appearProgress.clamp(0.0, 1.0);
    } else if (star.phase == StarLifePhase.collected) {
      final p = star.collectProgress;
      scale = 1 + math.sin(p * math.pi) * 0.35;
      if (p > 0.35) {
        scale = (1.2 - (p - 0.35) * 1.6).clamp(0.0, 1.4);
      }
      // Squash then stretch.
      opacity = (1 - p * 0.9).clamp(0.0, 1.0);
    } else if (star.phase == StarLifePhase.driftedOff) {
      opacity = (1 - star.driftProgress).clamp(0.0, 1.0);
      scale = 1 - star.driftProgress * 0.3;
    }

    // Stars that are already collected or fading must not swallow taps meant
    // for the star underneath, so they ignore pointers entirely.
    return IgnorePointer(
      ignoring: !star.isTappable,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, bounce),
              child: Transform.rotate(
                angle:
                    rot +
                    (star.phase == StarLifePhase.collected
                        ? star.collectProgress * math.pi * 2
                        : 0),
                child: Transform.scale(
                  scale: scale,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Light trail streaming up behind the falling star.
                      CustomPaint(
                        size: Size(size, size),
                        painter: _TrailPainter(
                          color: color,
                          phase: star.glowPulse,
                          intensity: glow,
                        ),
                      ),
                      CustomPaint(
                        size: Size(size, size),
                        painter: _CuteStarPainter(
                          color: color,
                          variant: star.variant,
                          accessory: star.accessory,
                          blink: math.sin(star.animPhase * 1.4),
                          glow: glow,
                          phase: star.glowPulse,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.color,
    required this.phase,
    required this.intensity,
  });

  final Color color;
  final double phase;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final len = size.height * (1.5 + 0.1 * math.sin(phase));
    // Three fading streaks, tallest in the middle.
    for (final (dx, l, w) in [
      (-0.2, 0.7, 3.4),
      (0.0, 1.0, 4.4),
      (0.2, 0.8, 3.4),
    ]) {
      final top = Offset(
        c.dx + size.width * dx,
        c.dy - size.height * 0.2 - len * l,
      );
      final bottom = Offset(c.dx + size.width * dx, c.dy - size.height * 0.1);
      canvas.drawLine(
        bottom,
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color.withValues(alpha: 0.85 * intensity + 0.1),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromPoints(top, bottom))
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round,
      );
    }
    // Tiny sparkles drifting in the trail.
    for (var i = 0; i < 4; i++) {
      final t = (phase * 0.4 + i * 0.25) % 1.0;
      final p = Offset(
        c.dx + math.sin(i * 2.1 + phase) * size.width * 0.28,
        c.dy - size.height * 0.3 - t * len * 0.8,
      );
      final r = 2.8 * (1 - t) + 1.2;
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy - r)
          ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
          ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r),
        Paint()..color = Colors.white.withValues(alpha: 0.85 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) =>
      old.phase != phase || old.intensity != intensity || old.color != color;
}

class _CuteStarPainter extends CustomPainter {
  _CuteStarPainter({
    required this.color,
    required this.variant,
    required this.accessory,
    required this.blink,
    required this.glow,
    required this.phase,
  });

  final Color color;
  final StarVariant variant;
  final StarAccessory accessory;
  final double blink;
  final double glow;
  final double phase;

  static const _ink = Color(0xFF5A3A2A);

  bool get _openEyes =>
      variant == StarVariant.pinkGlitter ||
      variant == StarVariant.rainbow ||
      variant == StarVariant.blueCrystal;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + size.height * 0.03);
    final r = size.width * 0.46;
    final path = _starPath(c, r, r * 0.52);
    final hi = Color.lerp(color, Colors.white, 0.55)!;
    final lo = Color.lerp(color, const Color(0xFFB36A00), 0.22)!;

    // Outer glow.
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.55 * glow + 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Rounded body: fill + same-colour stroke rounds the points.
    final rect = Rect.fromCircle(center: c, radius: r);
    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 1.0,
        colors: [hi, color, lo],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(path, fill);
    // Glowing rim.
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );
    // Soft top highlight.
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(-r * 0.22, -r * 0.42),
        width: r * 0.6,
        height: r * 0.24,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );

    _drawFace(canvas, c, r);
    _drawAccessory(canvas, c, r);
  }

  void _drawFace(Canvas canvas, Offset c, double r) {
    final hasShades = accessory == StarAccessory.glasses;
    final eyeY = c.dy - r * 0.02;
    final ink = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    if (!hasShades) {
      for (final dx in [-0.3, 0.3]) {
        final e = Offset(c.dx + r * dx, eyeY);
        if (_openEyes && blink <= 0.85) {
          canvas.drawOval(
            Rect.fromCenter(center: e, width: r * 0.2, height: r * 0.27),
            Paint()..color = _ink,
          );
          canvas.drawCircle(
            e.translate(r * 0.03, -r * 0.05),
            r * 0.045,
            Paint()..color = Colors.white,
          );
        } else {
          canvas.drawArc(
            Rect.fromCenter(
              center: e.translate(0, r * 0.03),
              width: r * 0.27,
              height: r * 0.2,
            ),
            math.pi + 0.3,
            math.pi - 0.6,
            false,
            ink,
          );
        }
      }
    }
    // Cheeks
    final cheek = Paint()
      ..color = const Color(0xFFFF7E9B).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(c.dx - r * 0.5, eyeY + r * 0.22), r * 0.13, cheek);
    canvas.drawCircle(Offset(c.dx + r * 0.5, eyeY + r * 0.22), r * 0.13, cheek);
    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.16, eyeY + r * 0.3)
        ..quadraticBezierTo(
          c.dx,
          eyeY + r * 0.5,
          c.dx + r * 0.16,
          eyeY + r * 0.3,
        ),
      ink..strokeWidth = 2.2,
    );
  }

  void _drawAccessory(Canvas canvas, Offset c, double r) {
    switch (accessory) {
      case StarAccessory.none:
        break;
      case StarAccessory.glasses:
        final lens = Paint()..color = const Color(0xFF15151F);
        for (final dx in [-0.3, 0.3]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(c.dx + r * dx, c.dy - r * 0.02),
                width: r * 0.42,
                height: r * 0.3,
              ),
              Radius.circular(r * 0.1),
            ),
            lens,
          );
        }
        canvas.drawLine(
          Offset(c.dx - r * 0.09, c.dy - r * 0.05),
          Offset(c.dx + r * 0.09, c.dy - r * 0.05),
          Paint()
            ..color = const Color(0xFF15151F)
            ..strokeWidth = 2.6,
        );
        canvas.drawLine(
          Offset(c.dx - r * 0.5, c.dy - r * 0.05),
          Offset(c.dx - r * 0.68, c.dy - r * 0.12),
          Paint()
            ..color = const Color(0xFF15151F)
            ..strokeWidth = 2.4,
        );
        canvas.drawLine(
          Offset(c.dx + r * 0.5, c.dy - r * 0.05),
          Offset(c.dx + r * 0.68, c.dy - r * 0.12),
          Paint()
            ..color = const Color(0xFF15151F)
            ..strokeWidth = 2.4,
        );
      case StarAccessory.partyHat:
        final base = Offset(c.dx + r * 0.1, c.dy - r * 0.82);
        final hat = Path()
          ..moveTo(base.dx - r * 0.24, base.dy + r * 0.24)
          ..lineTo(base.dx + r * 0.02, base.dy - r * 0.42)
          ..lineTo(base.dx + r * 0.3, base.dy + r * 0.2)
          ..close();
        canvas.drawPath(hat, Paint()..color = const Color(0xFF9C6CE8));
        canvas.save();
        canvas.clipPath(hat);
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(base.dx - r * 0.3, base.dy + r * (0.12 - i * 0.2)),
            Offset(base.dx + r * 0.36, base.dy + r * (0.0 - i * 0.2)),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.75)
              ..strokeWidth = 3,
          );
        }
        canvas.restore();
        canvas.drawCircle(
          Offset(base.dx + r * 0.02, base.dy - r * 0.42),
          r * 0.09,
          Paint()..color = const Color(0xFFFFCA28),
        );
      case StarAccessory.bow:
        final b = Offset(c.dx + r * 0.62, c.dy - r * 0.72);
        for (final dir in [-1.0, 1.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(b.dx, b.dy)
              ..quadraticBezierTo(
                b.dx + dir * r * 0.2,
                b.dy - r * 0.26,
                b.dx + dir * r * 0.36,
                b.dy - r * 0.1,
              )
              ..quadraticBezierTo(
                b.dx + dir * r * 0.4,
                b.dy + r * 0.14,
                b.dx + dir * r * 0.3,
                b.dy + r * 0.2,
              )
              ..quadraticBezierTo(
                b.dx + dir * r * 0.12,
                b.dy + r * 0.1,
                b.dx,
                b.dy,
              )
              ..close(),
            Paint()..color = const Color(0xFF9C6CE8),
          );
        }
        canvas.drawCircle(
          b,
          r * 0.09,
          Paint()..color = const Color(0xFF7E4FD0),
        );
      case StarAccessory.crown:
        final b = Offset(c.dx, c.dy - r * 0.86);
        final crown = Path()
          ..moveTo(b.dx - r * 0.32, b.dy + r * 0.2)
          ..lineTo(b.dx - r * 0.34, b.dy - r * 0.16)
          ..lineTo(b.dx - r * 0.14, b.dy + r * 0.02)
          ..lineTo(b.dx, b.dy - r * 0.24)
          ..lineTo(b.dx + r * 0.14, b.dy + r * 0.02)
          ..lineTo(b.dx + r * 0.34, b.dy - r * 0.16)
          ..lineTo(b.dx + r * 0.32, b.dy + r * 0.2)
          ..close();
        canvas.drawPath(crown, Paint()..color = const Color(0xFFFFC107));
        canvas.drawPath(
          crown,
          Paint()
            ..color = const Color(0xFFE59A00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      case StarAccessory.halo:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy - r * 1.0),
            width: r * 0.8,
            height: r * 0.22,
          ),
          Paint()
            ..color = const Color(0xFFFFF59D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2,
        );
      case StarAccessory.sleepingCap:
        final b = Offset(c.dx - r * 0.05, c.dy - r * 0.8);
        final cap = Path()
          ..moveTo(b.dx - r * 0.34, b.dy + r * 0.22)
          ..quadraticBezierTo(
            b.dx - r * 0.2,
            b.dy - r * 0.4,
            b.dx + r * 0.4,
            b.dy - r * 0.2,
          )
          ..lineTo(b.dx + r * 0.34, b.dy + r * 0.22)
          ..close();
        canvas.drawPath(cap, Paint()..color = const Color(0xFF7986CB));
        canvas.drawCircle(
          Offset(b.dx + r * 0.42, b.dy - r * 0.18),
          r * 0.1,
          Paint()..color = Colors.white,
        );
      case StarAccessory.scarf:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(c.dx, c.dy + r * 0.5),
              width: r * 0.9,
              height: r * 0.16,
            ),
            Radius.circular(r * 0.08),
          ),
          Paint()..color = const Color(0xFFEF5350),
        );
      case StarAccessory.butterflyWings:
        for (final dir in [-1.0, 1.0]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(c.dx + dir * r * 0.95, c.dy - r * 0.1),
              width: r * 0.5,
              height: r * 0.7,
            ),
            Paint()..color = const Color(0xFF80DEEA).withValues(alpha: 0.7),
          );
        }
      case StarAccessory.ribbon:
        canvas.drawCircle(
          Offset(c.dx + r * 0.5, c.dy - r * 0.7),
          r * 0.12,
          Paint()..color = const Color(0xFFF06292),
        );
    }
  }

  Path _starPath(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? outer : inner;
      final p = Offset(
        c.dx + math.cos(angle) * rad,
        c.dy + math.sin(angle) * rad,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _CuteStarPainter old) =>
      old.color != color ||
      old.blink != blink ||
      old.variant != variant ||
      old.accessory != accessory ||
      old.glow != glow ||
      old.phase != phase;
}
