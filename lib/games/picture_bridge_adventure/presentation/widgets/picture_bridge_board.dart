import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/models/picture_bridge_models.dart';
import 'package:my_tiny_thinker/games/picture_bridge_adventure/presentation/widgets/picture_bridge_card.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_board.dart';

class PictureBridgeBoard extends StatelessWidget {
  const PictureBridgeBoard({
    super.key,
    required this.pictureCards,
    required this.wordCards,
    required this.connections,
    required this.onConnect,
    this.largerTouch = true,
  });

  final List<PicturePairCard> pictureCards;
  final List<PicturePairCard> wordCards;
  final List<PictureBridgeConnection> connections;
  final void Function({required String pictureId, required String wordId})
      onConnect;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final byId = <String, PicturePairCard>{
      for (final c in pictureCards) c.id: c,
      for (final c in wordCards) c.id: c,
    };
    final cardSize = largerTouch ? 78.0 : 68.0;

    return BridgeMatchBoard(
      leftIds: [for (final c in pictureCards) c.id],
      rightIds: [for (final c in wordCards) c.id],
      connections: [
        for (final c in connections)
          (
            leftId: c.pictureId,
            rightId: c.wordId,
            colorKey: PictureBridgePalette.colorKeyFor(c.vocabId),
          ),
      ],
      slotSize: cardSize,
      colorForConnection: (key) =>
          PictureBridgePalette.colors[key % PictureBridgePalette.colors.length],
      canDragLeft: (id) {
        final c = byId[id];
        return c != null && !c.matched && c.isPicture;
      },
      canTargetRight: (id) {
        final c = byId[id];
        return c != null && !c.matched && !c.isPicture;
      },
      leftBuilder: (id, {required selected}) {
        final card = byId[id]!;
        return PictureBridgeCard(
          card: card,
          size: cardSize,
          selected: selected,
        );
      },
      rightBuilder: (id, {required highlighted}) {
        final card = byId[id]!;
        return PictureBridgeCard(
          card: card,
          size: cardSize,
          highlighted: highlighted,
        );
      },
      onConnect: ({required leftId, required rightId}) {
        onConnect(pictureId: leftId, wordId: rightId);
      },
    );
  }
}
