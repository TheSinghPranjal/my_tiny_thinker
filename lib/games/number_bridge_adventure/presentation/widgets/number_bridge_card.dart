import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_card.dart';

class NumberBridgeCard extends StatelessWidget {
  const NumberBridgeCard({
    super.key,
    required this.card,
    this.size = 72,
    this.selected = false,
    this.highlighted = false,
  });

  final NumberPairCard card;
  final double size;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isDigit = card.isDigit;
    return BridgeMatchCard(
      size: size,
      width: isDigit ? size : size * 1.55,
      color: card.color,
      selected: selected || card.selected,
      matched: card.matched,
      shake: card.shake,
      hintPulse: card.hintPulse || highlighted,
      celebrate: card.celebrate,
      shakePhase: card.animPhase,
      child: isDigit
          ? Text(
              card.label,
              style: TextStyle(
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF37474F),
                fontFamily: 'Baloo2',
                height: 1,
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  card.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size * 0.26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF37474F),
                    fontFamily: 'Baloo2',
                    height: 1.1,
                  ),
                ),
              ),
            ),
    );
  }
}
