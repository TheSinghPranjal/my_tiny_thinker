import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_card.dart';

class AlphabetLetterCard extends StatelessWidget {
  const AlphabetLetterCard({
    super.key,
    required this.card,
    this.size = 72,
    this.selected = false,
    this.highlighted = false,
  });

  final BridgeCard card;
  final double size;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return BridgeMatchCard(
      size: size,
      color: card.color,
      selected: selected || card.selected,
      matched: card.matched,
      shake: card.shake,
      hintPulse: card.hintPulse || highlighted,
      celebrate: card.celebrate,
      shakePhase: card.floatPhase,
      child: Text(
        card.glyph,
        style: TextStyle(
          fontSize: size * 0.52,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF37474F),
          fontFamily: 'Baloo2',
          height: 1,
        ),
      ),
    );
  }
}
