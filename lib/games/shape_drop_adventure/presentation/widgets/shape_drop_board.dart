import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/models/shape_drop_models.dart';
import 'package:my_tiny_thinker/games/shape_drop_adventure/presentation/widgets/shape_painter.dart';

class ShapeDropBoard extends StatelessWidget {
  const ShapeDropBoard({
    super.key,
    required this.target,
    required this.options,
    required this.filled,
    required this.outlineGlow,
    required this.onDrop,
    this.largerTouch = true,
    this.envPhase = 0,
  });

  final ShapeDef target;
  final List<ShapeOption> options;
  final bool filled;
  final bool outlineGlow;
  final void Function(String optionId) onDrop;
  final bool largerTouch;
  final double envPhase;

  @override
  Widget build(BuildContext context) {
    final left = options.take(2).toList();
    final right = options.skip(2).take(2).toList();
    final optionSize = largerTouch ? 100.0 : 88.0;
    final centerSize = largerTouch ? 160.0 : 140.0;
    final blink = (envPhase % 3.5) < 0.12;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Learning board
            Container(
              width: math.min(constraints.maxWidth * 0.55, 280),
              height: math.min(constraints.maxHeight * 0.55, 280),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF8E1), Color(0xFFE1F5FE), Color(0xFFF3E5F5)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  if (outlineGlow)
                    BoxShadow(
                      color: const Color(0xFFFFEB3B).withValues(alpha: 0.55),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: DragTarget<String>(
                onWillAcceptWithDetails: (_) => !filled,
                onAcceptWithDetails: (d) => onDrop(d.data),
                builder: (context, candidate, rejected) {
                  final hovering = candidate.isNotEmpty;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      FriendlyShapeView(
                        def: target,
                        size: centerSize,
                        pastelTint: true,
                        showFace: false,
                        showObjectEmoji: false,
                      ),
                      FriendlyShapeView(
                        def: target,
                        size: centerSize,
                        outlineOnly: !filled,
                        filled: filled,
                        showFace: filled,
                        glow: hovering || outlineGlow,
                        blink: blink && filled,
                        showObjectEmoji: filled,
                      ),
                      if (!filled)
                        Positioned(
                          bottom: 16,
                          child: Text(
                            'Drop here!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: hovering
                                  ? const Color(0xFFEC407A)
                                  : const Color(0xFF7E57C2),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Left options
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final o in left)
                    _DraggableShapeOption(
                      option: o,
                      size: optionSize,
                      envPhase: envPhase,
                    ),
                ],
              ),
            ),
            // Right options
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final o in right)
                    _DraggableShapeOption(
                      option: o,
                      size: optionSize,
                      envPhase: envPhase,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DraggableShapeOption extends StatelessWidget {
  const _DraggableShapeOption({
    required this.option,
    required this.size,
    required this.envPhase,
  });

  final ShapeOption option;
  final double size;
  final double envPhase;

  @override
  Widget build(BuildContext context) {
    if (option.matched) {
      return SizedBox(width: size + 12, height: size + 12);
    }

    final bob = math.sin(envPhase * 2 + option.id.hashCode) * 4;
    final blink = ((envPhase + option.id.hashCode % 5) % 3.6) < 0.12;

    final child = Transform.translate(
      offset: Offset(0, bob),
      child: AnimatedScale(
        scale: option.shake ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: size + 8,
          height: size + 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(option.def.color).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FriendlyShapeView(
            def: option.def,
            size: size * 0.85,
            blink: blink,
            showObjectEmoji: option.presentation == ShapePresentation.object,
          ),
        ),
      ),
    );

    return Draggable<String>(
      data: option.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Container(
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFEB3B).withValues(alpha: 0.55),
                  blurRadius: 16,
                ),
              ],
            ),
            child: FriendlyShapeView(
              def: option.def,
              size: size * 0.9,
              glow: true,
              showObjectEmoji: option.presentation == ShapePresentation.object,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.2, child: child),
      child: child,
    );
  }
}
