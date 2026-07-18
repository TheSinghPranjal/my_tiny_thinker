import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_card.dart';

class PictureBridgeCard extends StatelessWidget {
  const PictureBridgeCard({
    super.key,
    required this.card,
    this.size = 72,
    this.selected = false,
    this.highlighted = false,
  });

  final PicturePairCard card;
  final double size;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return BridgeMatchCard(
      size: size,
      width: card.isPicture ? size : size * 1.55,
      color: card.color,
      selected: selected || card.selected,
      matched: card.matched,
      shake: card.shake,
      hintPulse: card.hintPulse || highlighted,
      celebrate: card.celebrate,
      shakePhase: card.animPhase,
      child: card.isPicture
          ? Text(
              card.label,
              style: TextStyle(fontSize: size * 0.48, height: 1),
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
