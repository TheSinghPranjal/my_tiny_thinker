import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_bee_widget.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/presentation/widgets/garden_butterfly_widget.dart';

class AnimatedSkyBackground extends StatefulWidget {
  const AnimatedSkyBackground({
    super.key,
    required this.child,
    this.showGrass = true,
    this.showElements = true,
    /// Optional landscape PNG with transparent sky so clouds show through.
    this.landscapeAsset,
  });

  final Widget child;
  final bool showGrass;
  final bool showElements;
  final String? landscapeAsset;

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _critterController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _critterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _critterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLandscape = widget.landscapeAsset != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.sky)),
        if (widget.showElements)
          AnimatedBuilder(
            animation: Listenable.merge([_cloudController, _critterController]),
            builder: (context, _) => CustomPaint(
              painter: _SkyElementsPainter(
                cloudProgress: _cloudController.value,
                critterProgress: _critterController.value,
                showGrass: widget.showGrass && !hasLandscape,
                skyOnly: hasLandscape,
              ),
              size: Size.infinite,
            ),
          ),
        if (hasLandscape)
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                widget.landscapeAsset!,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        if (widget.showElements)
          AnimatedBuilder(
            animation: _critterController,
            builder: (context, _) {
              final p = _critterController.value;
              return IgnorePointer(
                child: Stack(
                  children: [
                    for (var i = 0; i < 4; i++) _flyingButterfly(i, p),
                    for (var i = 0; i < 3; i++) _flyingBee(i, p),
                  ],
                ),
              );
            },
          ),
        widget.child,
      ],
    );
  }

  Widget _flyingButterfly(int i, double p) {
    final t = (p * (0.5 + i * 0.08) + i * 0.19) % 1.0;
    final wingPhase = p * math.pi * 2 * 7 + i;
    return Align(
      alignment: Alignment(
        -1.15 + t * 2.3,
        -0.72 + (i % 3) * 0.18 + math.sin(p * math.pi * 2 * 1.3 + i) * 0.06,
      ),
      child: Transform.scale(
        scale: 0.38 + (i % 3) * 0.05,
        child: GardenButterflyWidget(
          butterfly: ButterflyEntity(
            id: 'sky_bf_$i',
            varietyIndex: i,
            pathSeed: i * 11,
            wingPhase: wingPhase,
            sizeScale: 1,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _flyingBee(int i, double p) {
    final t = (p * (0.4 + i * 0.1) + 0.3 + i * 0.25) % 1.0;
    final wingPhase = p * math.pi * 2 * 9 + i * 1.7;
    final goingRight = i.isEven;
    return Align(
      alignment: Alignment(
        goingRight ? (-1.1 + t * 2.2) : (1.1 - t * 2.2),
        -0.55 + i * 0.14 + math.sin(p * math.pi * 2 * 1.6 + i) * 0.05,
      ),
      child: Transform.scale(
        scale: 0.42,
        child: GardenBeeWidget(
          bee: BeeEntity(
            id: 'sky_bee_$i',
            x: 0,
            y: 0,
            wingPhase: wingPhase,
            pathT: p * math.pi * 2 + i,
            vx: goingRight ? 1.0 : -1.0,
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

class _SkyElementsPainter extends CustomPainter {
  _SkyElementsPainter({
    required this.cloudProgress,
    required this.critterProgress,
    required this.showGrass,
    this.skyOnly = false,
  });

  final double cloudProgress;
  final double critterProgress;
  final bool showGrass;
  final bool skyOnly;

  // Pastel / lighter rainbow bands
  static const _rainbowColors = [
    Color(0xFFFF8A80), // light red
    Color(0xFFFFCC80), // light orange
    Color(0xFFFFF59D), // light yellow
    Color(0xFFA5D6A7), // light green
    Color(0xFF90CAF9), // light blue
    Color(0xFF9FA8DA), // light indigo
    Color(0xFFCE93D8), // light violet
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawRainbow(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawBirds(canvas, size);
    if (!skyOnly) _drawBalloons(canvas, size);
    if (showGrass) _drawGrass(canvas, size);
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.86, size.height * 0.11);
    final radius = size.width * 0.085;

    canvas.drawCircle(
      center,
      radius * 1.35,
      Paint()..color = AppColors.sunYellow.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      radius * 1.15,
      Paint()..color = AppColors.sunYellow.withValues(alpha: 0.35),
    );

    for (var i = 0; i < 10; i++) {
      final a = critterProgress * math.pi * 2 * 0.15 + i * math.pi * 2 / 10;
      canvas.drawLine(
        center + Offset(math.cos(a) * radius * 1.15, math.sin(a) * radius * 1.15),
        center + Offset(math.cos(a) * radius * 1.45, math.sin(a) * radius * 1.45),
        Paint()
          ..color = AppColors.sunYellow.withValues(alpha: 0.55)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF59D),
            AppColors.sunYellowLight,
            AppColors.sunYellow,
          ],
          stops: const [0.2, 0.65, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final eyeY = center.dy - radius * 0.12;
    for (final dx in [-0.28, 0.28]) {
      final eye = Offset(center.dx + radius * dx, eyeY);
      canvas.drawCircle(eye, radius * 0.16, Paint()..color = Colors.white);
      canvas.drawCircle(
        eye + Offset(radius * 0.03, radius * 0.04),
        radius * 0.09,
        Paint()..color = const Color(0xFF5D4037),
      );
      canvas.drawCircle(
        eye + Offset(-radius * 0.04, -radius * 0.04),
        radius * 0.035,
        Paint()..color = Colors.white,
      );
    }

    canvas.drawCircle(
      Offset(center.dx - radius * 0.42, center.dy + radius * 0.18),
      radius * 0.1,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.42, center.dy + radius * 0.18),
      radius * 0.1,
      Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.7),
    );

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.22),
        width: radius * 0.95,
        height: radius * 0.7,
      ),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFFE65100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(3.0, radius * 0.08)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.5,
      size.height * (skyOnly ? 0.38 : 0.52),
    );
    final outerRadius = size.width * (skyOnly ? 0.5 : 0.68);
    // Wider pastel bands
    final band = (size.width * 1.048).clamp(18.0, 40.0);

    for (var i = 0; i < _rainbowColors.length; i++) {
      final radius = outerRadius - i * band;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + 0.05,
        math.pi - 0.1,
        false,
        Paint()
          ..color = _rainbowColors[i].withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = band * 0.95
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: outerRadius - _rainbowColors.length * band + band * 0.4,
      ),
      math.pi + 0.05,
      math.pi - 0.1,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = band * 0.45
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final specs = [
      (0.00, 0.06, 52.0, 0.92),
      (0.12, 0.11, 40.0, 0.85),
      (0.22, 0.07, 58.0, 0.9),
      (0.35, 0.14, 36.0, 0.8),
      (0.48, 0.09, 48.0, 0.88),
      (0.58, 0.16, 34.0, 0.78),
      (0.70, 0.08, 55.0, 0.9),
      (0.82, 0.13, 38.0, 0.82),
      (0.92, 0.05, 44.0, 0.86),
      (0.05, 0.18, 30.0, 0.75),
    ];

    for (var i = 0; i < specs.length; i++) {
      final (phase, yFrac, cloudSize, alpha) = specs[i];
      final speed = 0.7 + (i % 3) * 0.15;
      final baseX =
          ((cloudProgress * speed + phase) % 1.0) * (size.width + 220) - 110;
      final bob = math.sin(cloudProgress * math.pi * 2 + i) * 4;
      final y = size.height * yFrac + bob;
      _drawCloud(
        canvas,
        Offset(baseX, y),
        cloudSize,
        Paint()..color = AppColors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double s, Paint paint) {
    canvas.drawCircle(center, s * 0.48, paint);
    canvas.drawCircle(center.translate(-s * 0.42, s * 0.08), s * 0.36, paint);
    canvas.drawCircle(center.translate(s * 0.4, s * 0.05), s * 0.38, paint);
    canvas.drawCircle(center.translate(-s * 0.12, -s * 0.18), s * 0.32, paint);
    canvas.drawCircle(center.translate(s * 0.18, -s * 0.12), s * 0.28, paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, s * 0.28),
        width: s * 1.1,
        height: s * 0.35,
      ),
      Paint()..color = const Color(0xFFE3F2FD).withValues(alpha: 0.35),
    );
  }

  void _drawBirds(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final t = (critterProgress + i * 0.22) % 1.0;
      final x = size.width * (-0.1 + t * 1.2);
      final y = size.height * (0.14 + i * 0.045) +
          math.sin(t * math.pi * 4 + i) * 10;
      final flap = math.sin(critterProgress * math.pi * 12 + i * 2) * 7;
      _drawBird(canvas, Offset(x, y), flap);
    }
  }

  void _drawBird(Canvas canvas, Offset c, double flap) {
    final paint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(c.dx - 8, c.dy + flap * 0.3),
        width: 18,
        height: 12 + flap.abs() * 0.4,
      ),
      math.pi * 0.95,
      math.pi * 0.85,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(c.dx + 8, c.dy - flap * 0.3),
        width: 18,
        height: 12 + flap.abs() * 0.4,
      ),
      math.pi * 0.95,
      math.pi * 0.85,
      false,
      paint,
    );
  }

  void _drawBalloons(Canvas canvas, Size size) {
    final colors = [AppColors.candyPink, AppColors.skyBlue, AppColors.mintGreen];
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.08 + i * 0.12);
      final y = size.height *
          (0.28 + math.sin(cloudProgress * math.pi * 2 + i) * 0.02);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 22, height: 28),
        Paint()..color = colors[i],
      );
      canvas.drawLine(
        Offset(x, y + 14),
        Offset(x + 4, y + 44),
        Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.35)
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawGrass(Canvas canvas, Size size) {
    final grassRect =
        Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12);
    canvas.drawRect(
      grassRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.grassGreen, AppColors.grassDark],
        ).createShader(grassRect),
    );
    final flowerColors = [
      AppColors.candyPink,
      AppColors.sunYellow,
      AppColors.lavender,
    ];
    for (var i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.05 + i * 0.12), size.height * 0.9),
        4,
        Paint()..color = flowerColors[i % flowerColors.length],
      );
    }
  }

  @override
  bool shouldRepaint(_SkyElementsPainter oldDelegate) =>
      oldDelegate.cloudProgress != cloudProgress ||
      oldDelegate.critterProgress != critterProgress ||
      oldDelegate.showGrass != showGrass ||
      oldDelegate.skyOnly != skyOnly;
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
