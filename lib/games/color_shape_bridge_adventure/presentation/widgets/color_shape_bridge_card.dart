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
    final isPrompt = card.isPrompt;
    final comboLabel = card.mode == ColorShapeBridgeMode.colorShape;
    final width = isPrompt ? (comboLabel ? size * 2.1 : size * 1.55) : size;

    return BridgeMatchCard(
      size: size,
      width: width,
      color: card.accent,
      selected: selected || card.selected,
      matched: card.matched,
      shake: card.shake,
      hintPulse: card.hintPulse || highlighted,
      celebrate: card.celebrate,
      shakePhase: card.animPhase,
      child: isPrompt
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  card.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: comboLabel ? size * 0.22 : size * 0.26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF37474F),
                    fontFamily: 'Baloo2',
                    height: 1.1,
                  ),
                ),
              ),
            )
          : ShapeColorVisual(
              mode: card.mode,
              colorKind: card.colorKind,
              shapeKind: card.shapeKind,
              size: size * 0.72,
            ),
    );
  }
}
