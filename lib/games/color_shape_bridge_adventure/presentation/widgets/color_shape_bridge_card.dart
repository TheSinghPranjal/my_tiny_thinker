import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/widgets/shape_color_visual.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_card.dart';

class ColorShapeBridgeCard extends StatelessWidget {
  const ColorShapeBridgeCard({
    super.key,
    required this.card,
    this.size = 72,
    this.selected = false,
    this.highlighted = false,
  });

  final ColorShapePairCard card;
  final double size;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    if (card.isPrompt) {
      return _PromptWordCard(
        card: card,
        size: size,
        selected: selected,
      );
    }
    return _VisualShapeCard(
      card: card,
      size: size,
      highlighted: highlighted,
    );
  }
}

class _PromptWordCard extends StatelessWidget {
  const _PromptWordCard({
    required this.card,
    required this.size,
    required this.selected,
  });

  final ColorShapePairCard card;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final comboLabel = card.mode == ColorShapeBridgeMode.colorShape;
    final width = comboLabel ? size * 2.1 : size * 1.55;
    final fill = card.accent;
    final onFill = _contrastingInk(fill);

    return BridgeMatchCard(
      size: size,
      width: width,
      color: fill,
      vividFill: true,
      selected: selected || card.selected,
      matched: card.matched,
      shake: card.shake,
      hintPulse: card.hintPulse,
      celebrate: card.celebrate,
      shakePhase: card.animPhase,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            card.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: comboLabel ? size * 0.24 : size * 0.28,
              fontWeight: FontWeight.w800,
              color: onFill,
              fontFamily: 'Baloo2',
              height: 1.1,
              shadows: onFill == Colors.white
                  ? const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Right-side shape only — no outer square frame, larger glyph.
class _VisualShapeCard extends StatelessWidget {
  const _VisualShapeCard({
    required this.card,
    required this.size,
    required this.highlighted,
  });

  final ColorShapePairCard card;
  final double size;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final active = highlighted || card.selected || card.celebrate || card.hintPulse;
    final shakeX = card.shake ? math.sin(card.animPhase * 18) * 5 : 0.0;
    final scale = card.celebrate || card.selected || highlighted
        ? 1.08
        : (card.hintPulse ? 1.04 : 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Transform.translate(
        offset: Offset(shakeX, 0),
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (active || card.matched)
                  BoxShadow(
                    color: card.accent.withValues(
                      alpha: card.celebrate || highlighted ? 0.45 : 0.28,
                    ),
                    blurRadius: card.celebrate || highlighted ? 16 : 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: ShapeColorVisual(
                mode: card.mode,
                colorKind: card.colorKind,
                shapeKind: card.shapeKind,
                size: size * 0.98,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _contrastingInk(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.55 ? const Color(0xFF37474F) : Colors.white;
}
