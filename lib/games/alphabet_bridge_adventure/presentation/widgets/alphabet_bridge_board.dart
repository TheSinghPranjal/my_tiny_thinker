import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/models/alphabet_bridge_models.dart';
import 'package:my_tiny_thinker/games/alphabet_bridge_adventure/presentation/widgets/alphabet_letter_card.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_board.dart';

class AlphabetBridgeBoard extends StatelessWidget {
  const AlphabetBridgeBoard({
    super.key,
    required this.lowerCards,
    required this.upperCards,
    required this.connections,
    required this.onConnect,
    this.largerTouch = true,
  });

  final List<BridgeCard> lowerCards;
  final List<BridgeCard> upperCards;
  final List<BridgeConnection> connections;
  final void Function({required String lowerId, required String upperId})
      onConnect;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final byId = <String, BridgeCard>{
      for (final c in lowerCards) c.id: c,
      for (final c in upperCards) c.id: c,
    };
    final cardSize = largerTouch ? 78.0 : 68.0;

    return BridgeMatchBoard(
      leftIds: [for (final c in lowerCards) c.id],
      rightIds: [for (final c in upperCards) c.id],
      connections: [
        for (final c in connections)
          (leftId: c.lowerId, rightId: c.upperId, colorKey: c.letterIndex),
      ],
      slotSize: cardSize,
      colorForConnection: AlphabetCatalog.colorFor,
      canDragLeft: (id) {
        final c = byId[id];
        return c != null && !c.matched && !c.isUppercase;
      },
      canTargetRight: (id) {
        final c = byId[id];
        return c != null && !c.matched && c.isUppercase;
      },
      leftBuilder: (id, {required selected}) {
        final card = byId[id]!;
        return AlphabetLetterCard(
          card: card,
          size: cardSize,
          selected: selected,
        );
      },
      rightBuilder: (id, {required highlighted}) {
        final card = byId[id]!;
        return AlphabetLetterCard(
          card: card,
          size: cardSize,
          highlighted: highlighted,
        );
      },
      onConnect: ({required leftId, required rightId}) {
        onConnect(lowerId: leftId, upperId: rightId);
      },
    );
  }
}
