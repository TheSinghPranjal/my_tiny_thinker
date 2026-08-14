import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/services/audio_service.dart';
import 'package:my_tiny_thinker/core/services/haptic_service.dart';

/// Glossy blue Play button used on game setup / skills screens.
class GlossyPlayButton extends ConsumerWidget {
  const GlossyPlayButton({
    super.key,
    required this.onPressed,
    this.label = 'Play',
  });

  final VoidCallback onPressed;
  final String label;

  static const Color _top = Color(0xFF5CB4FF);
  static const Color _mid = Color(0xFF2F8DF0);
  static const Color _bottom = Color(0xFF1A6FD6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BounceTapWrapper(
      onTap: () {
        ref.read(hapticServiceProvider).trigger(HapticType.light);
        ref.read(audioServiceProvider).playSfx(SoundEffect.buttonTap);
        onPressed();
      },
      child: SizedBox(
        height: 62,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 4.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withValues(alpha: 0.38),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_top, _mid, _bottom],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                const CustomPaint(painter: _CheckerPainter()),
                const CustomPaint(painter: _GlossPainter()),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        label.replaceAll('!', ''),
                        style: GoogleFonts.fredoka(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                          shadows: const [
                            Shadow(
                              color: Color(0x33000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 22,
                  bottom: 10,
                  child: _Sparkle(size: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 11.0;
    final paint = Paint()
      ..color = const Color(0xFF1A5FB8).withValues(alpha: 0.16);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final col = (x / cell).floor();
        final row = (y / cell).floor();
        if ((col + row).isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlossPainter extends CustomPainter {
  const _GlossPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final gloss = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.55);

    canvas.drawPath(
      Path()..addArc(
        Rect.fromCircle(center: Offset(r, r), radius: r - 7),
        -math.pi * 0.92,
        math.pi * 0.42,
      ),
      gloss,
    );
    canvas.drawPath(
      Path()..addArc(
        Rect.fromCircle(center: Offset(size.width - r, r), radius: r - 7),
        -math.pi * 0.50,
        math.pi * 0.42,
      ),
      gloss,
    );

    final shade = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.12)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.55,
              size.width,
              size.height * 0.45,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
      shade,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SparklePainter());
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = -math.pi / 2 + i * math.pi / 2;
      final outer = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      final innerA = a + math.pi / 4;
      final inner = Offset(
        c.dx + math.cos(innerA) * r * 0.28,
        c.dy + math.sin(innerA) * r * 0.28,
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
