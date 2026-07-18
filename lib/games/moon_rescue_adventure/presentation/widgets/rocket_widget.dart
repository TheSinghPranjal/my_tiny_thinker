import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

class RocketWidget extends StatelessWidget {
  const RocketWidget({
    super.key,
    required this.rocket,
    required this.capacity,
    this.size = 110,
    this.onTap,
  });

  final MoonRocket rocket;
  final int capacity;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bob = math.sin(rocket.bobPhase) * (rocket.phase == RocketPhase.launching ? 0 : 3);
    final ready = rocket.phase == RocketPhase.ready;
    final launching = rocket.phase == RocketPhase.launching;
    final scale = launching ? (1 - rocket.launchProgress * 0.65).clamp(0.2, 1.0) : 1.0;
    final blink = (math.sin(rocket.lightBlink) + 1) / 2;

    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CapacityBadge(
                passengers: rocket.passengers,
                capacity: capacity,
                ready: ready,
              ),
              if (ready) ...[
                const SizedBox(height: 6),
                _TapToLaunchBanner(pulse: blink),
              ],
              const SizedBox(height: 6),
              SizedBox(
                width: size,
                height: size * 1.35,
                child: CustomPaint(
                  painter: _RocketPainter(
                    ready: ready,
                    launching: launching,
                    blink: blink,
                    flame: launching ? rocket.launchProgress : 0,
                    steam: ready || launching,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityBadge extends StatelessWidget {
  const _CapacityBadge({
    required this.passengers,
    required this.capacity,
    required this.ready,
  });

  final int passengers;
  final int capacity;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFFFF176) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Passengers: $passengers/$capacity',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: ready ? const Color(0xFFE65100) : const Color(0xFF4527A0),
        ),
      ),
    );
  }
}

class _TapToLaunchBanner extends StatelessWidget {
  const _TapToLaunchBanner({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.96 + pulse * 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFFCA28)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          '🚀 Tap to Launch!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _RocketPainter extends CustomPainter {
  _RocketPainter({
    required this.ready,
    required this.launching,
    required this.blink,
    required this.flame,
    required this.steam,
  });

  final bool ready;
  final bool launching;
  final double blink;
  final double flame;
  final bool steam;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Exhaust / flame
    if (flame > 0 || ready) {
      final flameH = size.height * (0.12 + flame * 0.35);
      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF176),
            const Color(0xFFFF9800),
            const Color(0xFFE53935).withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromLTWH(cx - 14, size.height * 0.78, 28, flameH));
      final path = Path()
        ..moveTo(cx - 12, size.height * 0.82)
        ..lineTo(cx, size.height * 0.82 + flameH)
        ..lineTo(cx + 12, size.height * 0.82)
        ..close();
      canvas.drawPath(path, flamePaint);
    }

    if (steam) {
      final s = Paint()..color = Colors.white.withValues(alpha: 0.35 + blink * 0.25);
      canvas.drawCircle(Offset(cx - 18, size.height * 0.8), 5 + blink * 3, s);
      canvas.drawCircle(Offset(cx + 18, size.height * 0.82), 4 + blink * 2, s);
    }

    // Fins
    final fin = Paint()..color = MoonRescuePalette.rocketAccent;
    canvas.drawPath(
      Path()
        ..moveTo(cx - size.width * 0.18, size.height * 0.7)
        ..lineTo(cx - size.width * 0.42, size.height * 0.88)
        ..lineTo(cx - size.width * 0.12, size.height * 0.82)
        ..close(),
      fin,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + size.width * 0.18, size.height * 0.7)
        ..lineTo(cx + size.width * 0.42, size.height * 0.88)
        ..lineTo(cx + size.width * 0.12, size.height * 0.82)
        ..close(),
      fin,
    );

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.52),
        width: size.width * 0.42,
        height: size.height * 0.55,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(body, Paint()..color = MoonRescuePalette.rocketBody);

    // Stripes
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.48),
        width: size.width * 0.42,
        height: 8,
      ),
      Paint()..color = MoonRescuePalette.rocketAccent,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.58),
        width: size.width * 0.42,
        height: 8,
      ),
      Paint()..color = const Color(0xFF42A5F5),
    );

    // Nose
    canvas.drawPath(
      Path()
        ..moveTo(cx - size.width * 0.18, size.height * 0.28)
        ..lineTo(cx, size.height * 0.08)
        ..lineTo(cx + size.width * 0.18, size.height * 0.28)
        ..close(),
      Paint()..color = MoonRescuePalette.rocketAccent,
    );

    // Window
    canvas.drawCircle(
      Offset(cx, size.height * 0.4),
      size.width * 0.1,
      Paint()..color = const Color(0xFF4FC3F7),
    );
    canvas.drawCircle(
      Offset(cx - 3, size.height * 0.38),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    // Nav lights
    final lightColor = Color.lerp(
      const Color(0xFFFFEB3B),
      const Color(0xFFFF9800),
      blink,
    )!;
    canvas.drawCircle(
      Offset(cx - size.width * 0.16, size.height * 0.66),
      3.5,
      Paint()..color = lightColor,
    );
    canvas.drawCircle(
      Offset(cx + size.width * 0.16, size.height * 0.66),
      3.5,
      Paint()..color = lightColor,
    );

    if (ready) {
      canvas.drawRRect(
        body.inflate(4),
        Paint()
          ..color = const Color(0xFFFFF176).withValues(alpha: 0.25 + blink * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RocketPainter oldDelegate) =>
      oldDelegate.blink != blink ||
      oldDelegate.flame != flame ||
      oldDelegate.ready != ready ||
      oldDelegate.launching != launching;
}
