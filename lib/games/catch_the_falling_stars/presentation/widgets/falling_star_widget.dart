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

    return GestureDetector(
      onTap: star.isTappable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, bounce),
            child: Transform.rotate(
              angle: rot +
                  (star.phase == StarLifePhase.collected
                      ? star.collectProgress * math.pi * 2
                      : 0),
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft rays.
                    CustomPaint(
                      size: Size(size, size),
                      painter: _GlowRaysPainter(
                        color: color,
                        phase: star.glowPulse,
                        intensity: glow,
                      ),
                    ),
                    CustomPaint(
                      size: Size(size * 0.92, size * 0.92),
                      painter: _CuteStarPainter(
                        color: color,
                        variant: star.variant,
                        blink: math.sin(star.animPhase * 1.4),
                      ),
                    ),
                    if (star.accessory != StarAccessory.none)
                      Positioned(
                        top: size * 0.02,
                        child: Text(
                          _accessoryEmoji(star.accessory),
                          style: TextStyle(fontSize: size * 0.28),
                        ),
                      ),
                    // Face sparkles.
                    Positioned(
                      right: size * 0.12,
                      top: size * 0.18,
                      child: Opacity(
                        opacity: 0.5 + 0.5 * math.sin(star.animPhase * 3),
                        child: Text('✨', style: TextStyle(fontSize: size * 0.16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _accessoryEmoji(StarAccessory a) => switch (a) {
        StarAccessory.crown => '👑',
        StarAccessory.partyHat => '🎉',
        StarAccessory.bow => '🎀',
        StarAccessory.glasses => '👓',
        StarAccessory.scarf => '🧣',
        StarAccessory.halo => '😇',
        StarAccessory.sleepingCap => '😴',
        StarAccessory.butterflyWings => '🦋',
        StarAccessory.ribbon => '💝',
        StarAccessory.none => '',
      };
}

class _GlowRaysPainter extends CustomPainter {
  _GlowRaysPainter({
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
    final paint = Paint()
      ..color = color.withValues(alpha: 0.18 * intensity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final len = size.width * (0.42 + 0.06 * math.sin(phase));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + phase * 0.15;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * size.width * 0.22,
        c + Offset(math.cos(a), math.sin(a)) * len,
        paint,
      );
    }
    canvas.drawCircle(
      c,
      size.width * 0.38,
      Paint()..color = color.withValues(alpha: 0.16 * intensity),
    );
  }

  @override
  bool shouldRepaint(covariant _GlowRaysPainter old) =>
      old.phase != phase || old.intensity != intensity || old.color != color;
}

class _CuteStarPainter extends CustomPainter {
  _CuteStarPainter({
    required this.color,
    required this.variant,
    required this.blink,
  });

  final Color color;
  final StarVariant variant;
  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    final path = _starPath(c, r, r * 0.45);

    // Body fill with slight gradient feel.
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.45)!,
            color,
            Color.lerp(color, const Color(0xFF5D4037), 0.15)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rainbow stripe accent.
    if (variant == StarVariant.rainbow) {
      final accents = [
        const Color(0xFFFF5252),
        const Color(0xFFFFD740),
        const Color(0xFF69F0AE),
        const Color(0xFF40C4FF),
      ];
      for (var i = 0; i < accents.length; i++) {
        canvas.drawCircle(
          c.translate(-r * 0.25 + i * r * 0.18, r * 0.05),
          3,
          Paint()..color = accents[i].withValues(alpha: 0.8),
        );
      }
    }

    // Face.
    final eyeOpen = blink > 0.85 ? 1.5 : size.width * 0.055;
    final eyePaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(-r * 0.22, -r * 0.05),
        width: size.width * 0.08,
        height: eyeOpen,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(r * 0.22, -r * 0.05),
        width: size.width * 0.08,
        height: eyeOpen,
      ),
      eyePaint,
    );
    // Eye shine.
    if (blink <= 0.85) {
      canvas.drawCircle(
        c.translate(-r * 0.2, -r * 0.08),
        1.8,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        c.translate(r * 0.24, -r * 0.08),
        1.8,
        Paint()..color = Colors.white,
      );
    }
    // Cheeks.
    canvas.drawCircle(
      c.translate(-r * 0.38, r * 0.12),
      size.width * 0.05,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.75),
    );
    canvas.drawCircle(
      c.translate(r * 0.38, r * 0.12),
      size.width * 0.05,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.75),
    );
    // Smile.
    final smile = Path()
      ..moveTo(c.dx - r * 0.2, c.dy + r * 0.22)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.38,
        c.dx + r * 0.2,
        c.dy + r * 0.22,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _starPath(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? outer : inner;
      final p = Offset(c.dx + math.cos(angle) * rad, c.dy + math.sin(angle) * rad);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _CuteStarPainter old) =>
      old.color != color || old.blink != blink || old.variant != variant;
}
