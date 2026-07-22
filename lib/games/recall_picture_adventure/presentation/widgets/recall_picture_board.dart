import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/recall_picture_adventure/models/recall_picture_models.dart';

/// Visual-only scene card: balloons, animal, color blob, shape — no text labels.
class RecallSceneCard extends StatelessWidget {
  const RecallSceneCard({
    super.key,
    required this.scene,
    this.bounce = false,
    this.dimmed = false,
  });

  final RecallScene scene;
  final bool bounce;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(
        '${scene.balloonCount}-${scene.animal}-${scene.color.key}-${scene.shape.name}-$bounce',
      ),
      tween: Tween(begin: 0.88, end: bounce ? 1.08 : 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360, minHeight: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1)],
            ),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.softPurple.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Balloons row
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: [
                  for (var i = 0; i < scene.balloonCount; i++)
                    const Text('🎈', style: TextStyle(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 12),
              // Animal + color + shape row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(scene.animal, style: const TextStyle(fontSize: 64)),
                  _ColorBlob(color: scene.color.color, size: 64),
                  RecallShapeIcon(
                    shape: scene.shape,
                    color: scene.shapeAccent,
                    size: 56,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorBlob extends StatelessWidget {
  const _ColorBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BlobPainter(color),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final wobble = (i.isEven ? 1.12 : 0.88) * r;
      final x = cx + math.cos(angle) * wobble;
      final y = cy + math.sin(angle) * wobble;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(cx - r * 0.25, cy - r * 0.25),
      r * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.color != color;
}

class RecallShapeIcon extends StatelessWidget {
  const RecallShapeIcon({
    super.key,
    required this.shape,
    required this.color,
    this.size = 48,
  });

  final RecallSceneShape shape;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShapePainter(shape: shape, color: color),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.shape, required this.color});

  final RecallSceneShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    switch (shape) {
      case RecallSceneShape.circle:
        canvas.drawCircle(Offset(cx, cy), r, paint);
      case RecallSceneShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 1.7, height: r * 1.7),
            const Radius.circular(6),
          ),
          paint,
        );
      case RecallSceneShape.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy + r * 0.85)
          ..lineTo(cx - r, cy + r * 0.85)
          ..close();
        canvas.drawPath(path, paint);
      case RecallSceneShape.star:
        canvas.drawPath(_starPath(cx, cy, r), paint);
      case RecallSceneShape.heart:
        canvas.drawPath(_heartPath(cx, cy, r), paint);
    }
  }

  Path _starPath(double cx, double cy, double r) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      final ox = cx + math.cos(a) * r;
      final oy = cy + math.sin(a) * r;
      final ix = cx + math.cos(b) * r * 0.42;
      final iy = cy + math.sin(b) * r * 0.42;
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    return path;
  }

  Path _heartPath(double cx, double cy, double r) {
    final path = Path();
    path.moveTo(cx, cy + r * 0.7);
    path.cubicTo(
      cx + r * 1.4,
      cy - r * 0.1,
      cx + r * 0.7,
      cy - r * 1.1,
      cx,
      cy - r * 0.35,
    );
    path.cubicTo(
      cx - r * 0.7,
      cy - r * 1.1,
      cx - r * 1.4,
      cy - r * 0.1,
      cx,
      cy + r * 0.7,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}

class RecallOptionButton extends StatefulWidget {
  const RecallOptionButton({
    super.key,
    required this.option,
    required this.onTap,
    this.isSelected = false,
    this.isWrong = false,
    this.enabled = true,
  });

  final RecallOption option;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isWrong;
  final bool enabled;

  @override
  State<RecallOptionButton> createState() => _RecallOptionButtonState();
}

class _RecallOptionButtonState extends State<RecallOptionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobble;

  @override
  void initState() {
    super.initState();
    _wobble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant RecallOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWrong && !oldWidget.isWrong) {
      _wobble.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.option.color ??
        (widget.isSelected
            ? AppColors.mintGreen
            : const Color(0xFF7E57C2));

    return AnimatedBuilder(
      animation: _wobble,
      builder: (context, child) {
        final shake =
            math.sin(_wobble.value * math.pi * 6) * 6 * (1 - _wobble.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(accent, Colors.white, 0.35)!,
                  accent,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.white
                    : widget.isWrong
                        ? const Color(0xFFFFAB91)
                        : Colors.white70,
                width: widget.isSelected || widget.isWrong ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: widget.isSelected ? 0.55 : 0.32,
                  ),
                  blurRadius: widget.isSelected ? 16 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final o = widget.option;
    if (o.emoji != null) {
      return Text(o.emoji!, style: const TextStyle(fontSize: 40));
    }
    if (o.color != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: o.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: o.color!.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
      );
    }
    if (o.shape != null) {
      return RecallShapeIcon(
        shape: o.shape!,
        color: Colors.white,
        size: 40,
      );
    }
    return Text(
      o.label ?? o.valueKey,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
      ),
    );
  }
}

class RecallPictureBoard extends StatelessWidget {
  const RecallPictureBoard({
    super.key,
    required this.scene,
    required this.question,
    required this.phase,
    required this.onAnswer,
    this.selectedOptionId,
    this.wrongOptionId,
    this.bounceCorrect = false,
  });

  final RecallScene scene;
  final RecallQuestion? question;
  final RecallPicturePhase phase;
  final ValueChanged<String> onAnswer;
  final String? selectedOptionId;
  final String? wrongOptionId;
  final bool bounceCorrect;

  bool get _showing => phase == RecallPicturePhase.showing;
  bool get _input =>
      phase == RecallPicturePhase.input ||
      phase == RecallPicturePhase.celebrating;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Column(
        key: ValueKey(
          '${scene.balloonCount}-${scene.animal}-${question?.type.name}-$_showing',
        ),
        children: [
          const Spacer(flex: 1),
          if (_showing) ...[
            const Text(
              'Look carefully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4527A0),
                shadows: [Shadow(color: Colors.white, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 12),
            RecallSceneCard(scene: scene, bounce: true),
          ] else if (_input && question != null) ...[
            Text(
              question!.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4527A0),
                shadows: [Shadow(color: Colors.white, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 12),
            // Tiny bounce cue on correct — no scene peek during recall.
            TweenAnimationBuilder<double>(
              key: ValueKey('cue-$bounceCorrect-${question!.type.name}'),
              tween: Tween(begin: 0.9, end: bounceCorrect ? 1.15 : 1.0),
              duration: const Duration(milliseconds: 380),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  bounceCorrect ? '✨' : '🧠',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final opt in question!.options)
                  RecallOptionButton(
                    option: opt,
                    isSelected: selectedOptionId == opt.id,
                    isWrong: wrongOptionId == opt.id,
                    enabled: phase == RecallPicturePhase.input,
                    onTap: () => onAnswer(opt.id),
                  ),
              ],
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class RecallPictureVictoryOverlay extends StatelessWidget {
  const RecallPictureVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final RecallPictureResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFE8EAF6)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.softPurple.withValues(alpha: 0.35),
                blurRadius: 24,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🖼️🏆', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                  result.encouragement,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4527A0),
                  ),
                ),
                const SizedBox(height: 16),
                _row('Rounds', '${result.roundsCompleted}'),
                _row('Correct', '${result.correctCount}'),
                _row('Accuracy', '${(result.accuracy * 100).round()}%'),
                _row('Score', '${result.score}'),
                _row('Coins', '+${result.coins}'),
                _row('XP', '+${result.xp}'),
                _row('Stars', '⭐ ${result.stars}'),
                _row('Best combo', '${result.maxCombo}'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPlayAgain,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.softPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onHome,
                  child: const Text(
                    'Home',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
