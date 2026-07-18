import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/models/number_bridge_models.dart';
import 'package:my_tiny_thinker/games/number_bridge_adventure/presentation/widgets/number_bridge_card.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_board.dart';

class NumberBridgeBoard extends StatelessWidget {
  const NumberBridgeBoard({
    super.key,
    required this.digitCards,
    required this.wordCards,
    required this.connections,
    required this.onConnect,
    this.largerTouch = true,
  });

  final List<NumberPairCard> digitCards;
  final List<NumberPairCard> wordCards;
  final List<NumberBridgeConnection> connections;
  final void Function({required String digitId, required String wordId})
      onConnect;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final byId = <String, NumberPairCard>{
      for (final c in digitCards) c.id: c,
      for (final c in wordCards) c.id: c,
    };
    final cardSize = largerTouch ? 78.0 : 68.0;

    return BridgeMatchBoard(
      leftIds: [for (final c in digitCards) c.id],
      rightIds: [for (final c in wordCards) c.id],
      connections: [
        for (final c in connections)
          (leftId: c.digitId, rightId: c.wordId, colorKey: c.value),
      ],
      slotSize: cardSize,
      colorForConnection: NumberBridgePalette.colorFor,
      canDragLeft: (id) {
        final c = byId[id];
        return c != null && !c.matched && c.isDigit;
      },
      canTargetRight: (id) {
        final c = byId[id];
        return c != null && !c.matched && !c.isDigit;
      },
      leftBuilder: (id, {required selected}) {
        final card = byId[id]!;
        return NumberBridgeCard(
          card: card,
          size: cardSize,
          selected: selected,
        );
      },
      rightBuilder: (id, {required highlighted}) {
        final card = byId[id]!;
        return NumberBridgeCard(
          card: card,
          size: cardSize,
          highlighted: highlighted,
        );
      },
      onConnect: ({required leftId, required rightId}) {
        onConnect(digitId: leftId, wordId: rightId);
      },
    );
  }
}
