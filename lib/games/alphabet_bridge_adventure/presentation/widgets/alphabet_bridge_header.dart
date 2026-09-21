import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Two hanging wooden signs ("little letters" / "BIG LETTERS") that sit above
/// their columns.
class AlphabetColumnSigns extends StatelessWidget {
  const AlphabetColumnSigns({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HangingSign(text: 'little letters'),
          _HangingSign(text: 'BIG LETTERS'),
        ],
      ),
    );
  }
}

class _HangingSign extends StatelessWidget {
  const _HangingSign({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Ropes
          Positioned(
            top: -6,
            left: 22,
            child: _rope(),
          ),
          Positioned(
            top: -6,
            right: 22,
            child: _rope(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFCB8848), Color(0xFFA9642B)],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF8A4F1E), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.fredoka(
                fontSize: 19,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFF3DC),
                shadows: const [
                  Shadow(color: Color(0x88512A0A), offset: Offset(0, 2), blurRadius: 1),
                ],
              ),
            ),
          ),
          // Leaves at the outer corner.
          const Positioned(bottom: -6, left: -8, child: _MiniLeaves()),
        ],
      ),
    );
  }

  Widget _rope() => Container(
        width: 5,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFB08560),
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

class _MiniLeaves extends StatelessWidget {
  const _MiniLeaves();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 26,
      child: CustomPaint(painter: _MiniLeavesPainter()),
    );
  }
}

class _MiniLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, len, ang) in [(8.0, 10.0, 20.0, -0.9), (10.0, 14.0, 22.0, 0.3), (8.0, 18.0, 18.0, 1.5)]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(ang);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.3, -len * 0.3, len, 0)
        ..quadraticBezierTo(len * 0.3, len * 0.3, 0, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFF4FA84A));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cloud-shaped speech bubble: "Match the same letter!" with sparkle dashes.
class AlphabetInstructionCloud extends StatelessWidget {
  const AlphabetInstructionCloud({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CloudBubblePainter()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Match the same letter!',
              style: GoogleFonts.fredoka(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2A5C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(6, h * 0.22, w - 12, h * 0.62),
        Radius.circular(h * 0.31),
      ))
      ..addOval(Rect.fromCenter(center: Offset(w * 0.2, h * 0.3), width: h * 0.7, height: h * 0.7))
      ..addOval(Rect.fromCenter(center: Offset(w * 0.42, h * 0.2), width: h * 0.85, height: h * 0.8))
      ..addOval(Rect.fromCenter(center: Offset(w * 0.68, h * 0.22), width: h * 0.8, height: h * 0.75))
      ..addOval(Rect.fromCenter(center: Offset(w * 0.86, h * 0.34), width: h * 0.62, height: h * 0.62));
    canvas.drawPath(
      body.shift(const Offset(0, 3)),
      Paint()..color = const Color(0xFF7FB8E8).withValues(alpha: 0.35),
    );
    canvas.drawPath(body, Paint()..color = Colors.white);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFFDCEBF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Sparkle dashes on both sides.
    final dash = Paint()
      ..color = const Color(0xFFFFE066)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-4, h * 0.3), Offset(6, h * 0.36), dash);
    canvas.drawLine(Offset(-8, h * 0.6), Offset(2, h * 0.58), dash);
    canvas.drawLine(Offset(w + 4, h * 0.3), Offset(w - 6, h * 0.36), dash);
    canvas.drawLine(Offset(w + 8, h * 0.6), Offset(w - 2, h * 0.58), dash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
