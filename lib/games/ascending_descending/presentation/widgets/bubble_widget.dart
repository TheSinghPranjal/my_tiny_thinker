import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/animations/bounce_animation.dart';
import 'package:my_tiny_thinker/core/theme/app_typography.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_gradients.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

class BubbleWidget extends StatefulWidget {
  const BubbleWidget({
    super.key,
    required this.bubble,
    required this.onTap,
    this.showHint = false,
  });

  final BubbleEntity bubble;
  final VoidCallback onTap;
  final bool showHint;

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(BubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bubble.isPopping && !oldWidget.bubble.isPopping) {
      _popController.forward();
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = widget.bubble;
    final diameter = bubble.radius * 2;
    final gradient = AppGradients.forIndex(bubble.colorIndex);

    Widget content = GestureDetector(
      onTap: bubble.isPopping ? null : widget.onTap,
      child: ShakeAnimation(
        trigger: bubble.isWrong,
        child: CustomPaint(
          size: Size(diameter, diameter),
          painter: _BubblePainter(
            gradient: gradient,
            isWrong: bubble.isWrong,
            showHint: widget.showHint,
            rotation: bubble.rotation,
          ),
          child: Center(
            child: _BubbleNumberText(
              number: bubble.number,
              radius: bubble.radius,
            ),
          ),
        ),
      ),
    );

    if (bubble.isPopping) {
      content = ScaleTransition(scale: _popScale, child: content);
    } else {
      content = WiggleAnimation(child: content);
    }

    return Positioned(
      left: bubble.x - bubble.radius,
      top: bubble.y - bubble.radius,
      child: Semantics(
        label: 'Bubble number ${bubble.number}',
        button: true,
        child: content,
      ),
    );
  }
}

class _BubbleNumberText extends StatelessWidget {
  const _BubbleNumberText({required this.number, required this.radius});

  final int number;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final text = number.toString();
    final fontSize = (radius * 0.65).clamp(12.0, 36.0);
    if (text.length > 4) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: AppTypography.bubbleNumber(fontSize * 0.8),
        ),
      );
    }
    return Text(text, style: AppTypography.bubbleNumber(fontSize));
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.gradient,
    required this.isWrong,
    required this.showHint,
    required this.rotation,
  });

  final Gradient gradient;
  final bool isWrong;
  final bool showHint;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Shadow
    canvas.drawCircle(
      center.translate(2, 4),
      radius,
      Paint()..color = AppColors.skyBlueDark.withValues(alpha: 0.25),
    );

    // Main bubble
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    // Glass highlight
    canvas.drawCircle(
      center.translate(-radius * 0.25, -radius * 0.3),
      radius * 0.25,
      Paint()..color = AppColors.white.withValues(alpha: 0.45),
    );

    // Gloss arc
    final glossPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius * 0.85),
        -math.pi * 0.8,
        math.pi * 0.5,
      );
    canvas.drawPath(
      glossPath,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (isWrong) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.error.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    if (showHint) {
      canvas.drawCircle(
        center,
        radius + 4,
        Paint()
          ..color = AppColors.sunYellow.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.isWrong != isWrong ||
      oldDelegate.showHint != showHint ||
      oldDelegate.rotation != rotation;
}
