import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

/// Rainbow “TinyThink” wordmark with a thick white outline (home header).
class TinyThinkTitle extends StatelessWidget {
  const TinyThinkTitle({
    super.key,
    this.fontSize = 42,
  });

  final double fontSize;

  static const _gradientColors = [
    Color(0xFF43B5FF),
    Color(0xFF7B6DFF),
    Color(0xFFFF7BEA),
    Color(0xFFFFA726),
    Color(0xFF7ED957),
    Color(0xFFFF5E9C),
  ];

  TextStyle _baseStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
      fontFamily: 'Baloo2',
      height: 1.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = 'TinyThink';
    final style = _baseStyle();
    final strokeWidth = (fontSize * 0.2).clamp(7.0, 14.0);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        strokeWidth * 0.15,
        strokeWidth * 0.1,
        strokeWidth * 0.35,
        strokeWidth * 0.15,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            text,
            style: style.copyWith(
              foreground: strokePaint,
              shadows: const [
                Shadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 2.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          GradientText(
            text,
            style: style,
            colors: _gradientColors,
          ),
        ],
      ),
    );
  }
}
