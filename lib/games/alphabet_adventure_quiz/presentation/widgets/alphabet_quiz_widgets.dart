import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wooden "Alphabet Adventure" plaque with leaves and a cream sub-banner.
class AlphabetTitleBanner extends StatelessWidget {
  const AlphabetTitleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE0A567), Color(0xFFC57F3E)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF3CFA0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A4A1C).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _OutlinedText(
                'Alphabet Adventure',
                fontSize: 23,
                fill: Colors.white,
                stroke: const Color(0xFF8A4F1E),
              ),
            ),
          ),
          Positioned(left: 0, top: -4, child: _LeafCluster(flip: false)),
          Positioned(right: 0, top: -4, child: _LeafCluster(flip: true)),
          Positioned(
            top: 40,
            left: 38,
            right: 38,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3DC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3D7A8), width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Tap the picture that starts with...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF8A5A33),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText(this.text, {required this.fontSize, required this.fill, required this.stroke});

  final String text;
  final double fontSize;
  final Color fill;
  final Color stroke;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.5
              ..strokeJoin = StrokeJoin.round
              ..color = stroke,
          ),
        ),
        Text(text, style: style.copyWith(color: fill)),
      ],
    );
  }
}

class _LeafCluster extends StatelessWidget {
  const _LeafCluster({required this.flip});

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: SizedBox(
        width: 54,
        height: 60,
        child: CustomPaint(painter: _LeafPainter()),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, len, ang) in [
      (30.0, 34.0, 34.0, -1.9),
      (28.0, 32.0, 36.0, -0.6),
      (26.0, 36.0, 32.0, 0.9),
      (30.0, 34.0, 30.0, 2.1),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(ang);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.3, -len * 0.3, len, 0)
        ..quadraticBezierTo(len * 0.3, len * 0.3, 0, 0)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF3C9A3E), Color(0xFF7CCB5B)],
          ).createShader(Rect.fromLTWH(0, -len * 0.3, len, len * 0.6)),
      );
      canvas.drawLine(
        Offset.zero,
        Offset(len * 0.9, 0),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 1.4,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Big blue letter tile with a glossy 3D white letter and little sparkles.
class AlphabetLetterTile extends StatelessWidget {
  const AlphabetLetterTile({super.key, required this.letter, this.size = 138});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.98,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        color: const Color(0xFFD7ECFA),
        border: Border.all(color: const Color(0xFFBFE0F6), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D8BE8).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B9DF2), Color(0xFF3F82E6)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: _SparklePainter())),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Chunky 3D depth: a blue-tinted copy offset below.
                  Transform.translate(
                    offset: const Offset(0, 5),
                    child: Text(
                      letter,
                      style: GoogleFonts.fredoka(
                        fontSize: size * 0.74,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9CC4F5),
                      ),
                    ),
                  ),
                  Text(
                    letter,
                    style: GoogleFonts.fredoka(
                      fontSize: size * 0.74,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Color(0x553A75D8), blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFFFE066)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    // Two short rays each on the top-left and top-right corners.
    void ray(Offset c, double angle, double len) {
      final d = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(c - d * len / 2, c + d * len / 2, p);
    }

    final l = Offset(size.width * 0.14, size.height * 0.22);
    final r = Offset(size.width * 0.86, size.height * 0.22);
    ray(l + const Offset(0, 0), 0.5, 12);
    ray(l + const Offset(6, -12), -0.9, 10);
    ray(r + const Offset(0, 0), math.pi - 0.5, 12);
    ray(r + const Offset(-6, -12), math.pi + 0.9, 10);
    ray(Offset(size.width * 0.86, size.height * 0.34), 0, 10);
    ray(Offset(size.width * 0.12, size.height * 0.36), 0.2, 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cream, dashed "A is for Airplane" pill. [word] is null until answered.
class AlphabetAnswerPill extends StatelessWidget {
  const AlphabetAnswerPill({super.key, required this.letter, this.word});

  final String letter;
  final String? word;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPillPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              letter.toUpperCase(),
              style: GoogleFonts.fredoka(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3D82E6),
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              word == null ? 'is for ...' : 'is for $word',
              style: GoogleFonts.fredoka(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A5A33),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedPillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6DF), Color(0xFFFFE9B8)],
        ).createShader(Offset.zero & size),
    );
    final dash = Path()..addRRect(rrect.deflate(4));
    for (final m in dash.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(
          m.extractPath(d, math.min(d + 7, m.length)),
          Paint()
            ..color = const Color(0xFFE5B25D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round,
        );
        d += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// White answer card with a big picture and a coloured name pill.
class AlphabetPictureCard extends StatelessWidget {
  const AlphabetPictureCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.correct,
    required this.wrong,
    required this.enabled,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool correct;
  final bool wrong;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = correct
        ? const Color(0xFF8FE08F)
        : wrong
            ? const Color(0xFFF48FB1)
            : const Color(0xFFD9ECFA);
    final pillBg = correct ? const Color(0xFFD3F2D0) : const Color(0xFFFBDDE5);
    final pillText = correct ? const Color(0xFF2E7D32) : const Color(0xFF8E1B3A);

    return AnimatedScale(
      scale: correct ? 1.03 : (wrong ? 0.95 : 1.0),
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFFCFEFF),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor, width: correct || wrong ? 3 : 2.4),
              boxShadow: [
                BoxShadow(
                  color: (correct ? const Color(0xFF6FDC6F) : const Color(0xFF7CC0EE))
                      .withValues(alpha: correct ? 0.55 : 0.28),
                  blurRadius: correct ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: LayoutBuilder(
              builder: (context, c) {
                final pictureSize = math.min(c.maxWidth * 0.66, c.maxHeight * 0.58);
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: pictureSize, height: 1.15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 34,
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: pillText,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
