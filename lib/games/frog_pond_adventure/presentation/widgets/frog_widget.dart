import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/shared/feed_frog_character.dart';
import 'package:my_tiny_thinker/games/shared/frog_varieties.dart';

class FrogWidget extends StatelessWidget {
  const FrogWidget({
    super.key,
    required this.frog,
    required this.onTap,
    this.largerTouch = false,
    this.highContrast = false,
  });

  final FrogEntity frog;
  final VoidCallback onTap;
  final bool largerTouch;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    if (frog.phase == FrogPhase.gone) return const SizedBox.shrink();

    final baseSize = frog.isKing ? 104.0 : 88.0;
    final touchSize = largerTouch ? baseSize * 1.25 : baseSize * 1.15;
    final blink = (frog.blinkTimer % 4.0) < 0.12;
    final bounce = frog.phase == FrogPhase.jumping
        ? math.sin(frog.jumpProgress * math.pi) * 8
        : math.sin(frog.animPhase * 3) * 3;
    final wave = math.sin(frog.animPhase * 5) * 0.15;

    return GestureDetector(
      onTap: frog.isTappable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touchSize,
        height: touchSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (frog.isKing)
              Container(
                width: touchSize * 0.9,
                height: touchSize * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            Transform.translate(
              offset: Offset(0, bounce),
              child: FeedFrogCharacter(
                size: touchSize * 1.15,
                animPhase: frog.animPhase,
                blink: blink,
                bodyColor:
                    frog.isKing ? const Color(0xFFE5433D) : Color(frog.variety.bodyColor),
                bellyColor: frog.isKing
                    ? const Color(0xFFFFE0E0)
                    : Color(frog.variety.bellyColor),
                spotColor:
                    frog.isKing ? null : Color(frog.variety.spotColor),
                pattern: frog.isKing ? FrogPattern.smooth : frog.variety.pattern,
                waveAngle: wave * 2.5,
              ),
            ),
            if (frog.isKing)
              Positioned(
                top: touchSize * 0.04,
                child: SizedBox(
                  width: touchSize * 0.34,
                  height: touchSize * 0.2,
                  child: const CustomPaint(painter: _CrownPainter()),
                ),
              ),
            if (frog.isKing && frog.phase != FrogPhase.jumping)
              Positioned(
                top: -16,
                child: _CrownGems(gems: frog.crownGems),
              ),
          ],
        ),
      ),
    );
  }
}

class _CrownGems extends StatelessWidget {
  const _CrownGems({required this.gems});

  final int gems;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(FrogEntity.kingTapRequired, (i) {
        final lit = i < gems;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            lit ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 13,
            color: lit ? const Color(0xFFFFD54F) : Colors.white54,
          ),
        );
      }),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 2;
    final cx = size.width / 2;
    final base = size.height;
    final path = Path()
      ..moveTo(cx - w, base)
      ..lineTo(cx - w * 0.8, base - size.height * 0.85)
      ..lineTo(cx - w * 0.35, base - size.height * 0.4)
      ..lineTo(cx, base - size.height)
      ..lineTo(cx + w * 0.35, base - size.height * 0.4)
      ..lineTo(cx + w * 0.8, base - size.height * 0.85)
      ..lineTo(cx + w, base)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE57F), Color(0xFFFFC107)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFA000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    for (final x in [cx - w * 0.8, cx, cx + w * 0.8]) {
      canvas.drawCircle(
        Offset(x, base - size.height * (x == cx ? 1.0 : 0.85)),
        2.2,
        Paint()..color = const Color(0xFFE53935),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrownPainter old) => false;
}
