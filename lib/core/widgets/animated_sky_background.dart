import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';

class AnimatedSkyBackground extends StatefulWidget {
  const AnimatedSkyBackground({
    super.key,
    required this.child,
    this.showGrass = true,
    this.showElements = true,
  });

  final Widget child;
  final bool showGrass;
  final bool showElements;

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.sky)),
        if (widget.showElements) ...[
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, _) => CustomPaint(
              painter: _SkyElementsPainter(
                cloudProgress: _cloudController.value,
                starProgress: _starController.value,
                showGrass: widget.showGrass,
              ),
              size: Size.infinite,
            ),
          ),
        ],
        widget.child,
      ],
    );
  }
}

class _SkyElementsPainter extends CustomPainter {
  _SkyElementsPainter({
    required this.cloudProgress,
    required this.starProgress,
    required this.showGrass,
  });

  final double cloudProgress;
  final double starProgress;
  final bool showGrass;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSun(canvas, size);
    _drawRainbow(canvas, size);
    _drawClouds(canvas, size);
    _drawStars(canvas, size);
    _drawBalloons(canvas, size);
    if (showGrass) _drawGrass(canvas, size);
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.12);
    final radius = size.width * 0.08;
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()..color = AppColors.sunYellow.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.sunYellowLight, AppColors.sunYellow],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    // Smile on sun
    final smilePath = Path()
      ..addArc(
        Rect.fromCenter(center: center.translate(0, radius * 0.2), width: radius, height: radius * 0.5),
        0.2,
        math.pi - 0.4,
      );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = AppColors.orange.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.55);
    final colors = AppColors.rainbow;
    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: size.width * 1.2,
          height: size.height * 0.5,
        ),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = AppColors.white.withValues(alpha: 0.85);
    for (var i = 0; i < 4; i++) {
      final baseX = ((cloudProgress + i * 0.25) % 1.0) * (size.width + 200) - 100;
      final y = size.height * (0.08 + i * 0.06);
      _drawCloud(canvas, Offset(baseX, y), 40 + i * 10.0, cloudPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size * 0.5, paint);
    canvas.drawCircle(center.translate(-size * 0.4, size * 0.1), size * 0.35, paint);
    canvas.drawCircle(center.translate(size * 0.4, size * 0.05), size * 0.4, paint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = math.Random(42);
    for (var i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.4;
      final opacity = 0.3 + starProgress * 0.5 + (i % 3) * 0.1;
      canvas.drawCircle(
        Offset(x, y),
        2 + (i % 3),
        Paint()..color = AppColors.white.withValues(alpha: opacity.clamp(0, 1)),
      );
    }
  }

  void _drawBalloons(Canvas canvas, Size size) {
    final colors = [AppColors.candyPink, AppColors.skyBlue, AppColors.mintGreen];
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.1 + i * 0.15);
      final y = size.height * (0.2 + math.sin(cloudProgress * math.pi * 2 + i) * 10);
      final paint = Paint()..color = colors[i];
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 24, height: 30),
        paint,
      );
      canvas.drawLine(
        Offset(x, y + 15),
        Offset(x + 5, y + 50),
        Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
    }
  }

  void _drawGrass(Canvas canvas, Size size) {
    final grassRect = Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12);
    canvas.drawRect(
      grassRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grassGreen, AppColors.grassDark],
        ).createShader(grassRect),
    );
    // Flowers
    final flowerColors = [AppColors.candyPink, AppColors.sunYellow, AppColors.lavender];
    for (var i = 0; i < 8; i++) {
      final x = size.width * (0.05 + i * 0.12);
      final y = size.height * 0.9;
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = flowerColors[i % flowerColors.length],
      );
    }
  }

  @override
  bool shouldRepaint(_SkyElementsPainter oldDelegate) =>
      oldDelegate.cloudProgress != cloudProgress ||
      oldDelegate.starProgress != starProgress;
}

class FloatingBubblesBackground extends StatefulWidget {
  const FloatingBubblesBackground({super.key, required this.child});

  final Widget child;

  @override
  State<FloatingBubblesBackground> createState() =>
      _FloatingBubblesBackgroundState();
}

class _FloatingBubblesBackgroundState extends State<FloatingBubblesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _FloatingBubblesPainter(_controller.value),
            size: Size.infinite,
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _FloatingBubblesPainter extends CustomPainter {
  _FloatingBubblesPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    for (var i = 0; i < 20; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final offset = math.sin((progress + i * 0.1) * math.pi * 2) * 15;
      final radius = 8 + random.nextDouble() * 20;
      canvas.drawCircle(
        Offset(baseX, baseY + offset),
        radius,
        Paint()
          ..color = AppColors.bubbleColors[i % AppColors.bubbleColors.length]
              .withValues(alpha: 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(_FloatingBubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
