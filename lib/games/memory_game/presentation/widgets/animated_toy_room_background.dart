import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

class AnimatedToyRoomBackground extends StatefulWidget {
  const AnimatedToyRoomBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AnimatedToyRoomBackground> createState() =>
      _AnimatedToyRoomBackgroundState();
}

class _AnimatedToyRoomBackgroundState extends State<AnimatedToyRoomBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.rainbow),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lavenderLight.withValues(alpha: 0.6),
                AppColors.cream,
                AppColors.sunYellowLight.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([_floatController, _sparkleController]),
          builder: (context, _) => CustomPaint(
            painter: _ToyRoomPainter(
              float: _floatController.value,
              sparkle: _sparkleController.value,
            ),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ToyRoomPainter extends CustomPainter {
  _ToyRoomPainter({required this.float, required this.sparkle});

  final double float;
  final double sparkle;
  final _random = math.Random(12);

  @override
  void paint(Canvas canvas, Size size) {
    _drawClouds(canvas, size);
    _drawStars(canvas, size);
    _drawToys(canvas, size);
    _drawBalloons(canvas, size);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.white.withValues(alpha: 0.7);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (0.1 + i * 0.35) + float * 30) % size.width;
      _cloud(canvas, Offset(x, size.height * 0.08), 50, paint);
    }
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint paint) {
    canvas.drawCircle(c, s * 0.4, paint);
    canvas.drawCircle(c.translate(-s * 0.3, s * 0.05), s * 0.3, paint);
    canvas.drawCircle(c.translate(s * 0.3, 0), s * 0.35, paint);
  }

  void _drawStars(Canvas canvas, Size size) {
    for (var i = 0; i < 20; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height * 0.5;
      canvas.drawCircle(
        Offset(x, y),
        2 + (i % 3),
        Paint()
          ..color = AppColors.white
              .withValues(alpha: 0.3 + sparkle * 0.5),
      );
    }
  }

  void _drawToys(Canvas canvas, Size size) {
    const toys = ['🧸', '🎈', '🎨', '🎲', '🎯', '🪀'];
    for (var i = 0; i < toys.length; i++) {
      final x = size.width * (0.08 + i * 0.15);
      final y = size.height * 0.85 +
          math.sin(float * math.pi * 2 + i) * 8;
      _drawEmoji(canvas, toys[i], Offset(x, y), 24);
    }
  }

  void _drawBalloons(Canvas canvas, Size size) {
    final colors = AppColors.bubbleColors;
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.85 - i * 0.08);
      final y = size.height * (0.15 + i * 0.05) +
          math.sin(float * math.pi * 2 + i * 0.5) * 12;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 20, height: 26),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.7),
      );
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset pos, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_ToyRoomPainter old) =>
      old.float != float || old.sparkle != sparkle;
}
