import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/models/color_shape_bridge_models.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/widgets/color_shape_bridge_card.dart';
import 'package:my_tiny_thinker/games/color_shape_bridge_adventure/presentation/widgets/shape_color_visual.dart';
import 'package:my_tiny_thinker/games/shared/bridge_match/bridge_match_board.dart';

class ColorShapeBridgeBoard extends StatelessWidget {
  const ColorShapeBridgeBoard({
    super.key,
    required this.promptCards,
    required this.visualCards,
    required this.connections,
    required this.onConnect,
    this.largerTouch = true,
  });

  final List<ColorShapePairCard> promptCards;
  final List<ColorShapePairCard> visualCards;
  final List<ColorShapeBridgeConnection> connections;
  final void Function({required String promptId, required String visualId})
      onConnect;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final byId = <String, ColorShapePairCard>{
      for (final c in promptCards) c.id: c,
      for (final c in visualCards) c.id: c,
    };
    final cardSize = largerTouch ? 86.0 : 74.0;

    return BridgeMatchBoard(
      leftIds: [for (final c in promptCards) c.id],
      rightIds: [for (final c in visualCards) c.id],
      connections: [
        for (final c in connections)
          (
            leftId: c.promptId,
            rightId: c.visualId,
            colorKey: ColorShapeBridgePalette.colorKeyFor(c.matchKey),
          ),
      ],
      slotSize: cardSize,
      colorForConnection: (key) =>
          ColorShapeBridgePalette.colors[key % ColorShapeBridgePalette.colors.length],
      canDragLeft: (id) {
        final c = byId[id];
        return c != null && !c.matched && c.isPrompt;
      },
      canTargetRight: (id) {
        final c = byId[id];
        return c != null && !c.matched && !c.isPrompt;
      },
      leftBuilder: (id, {required selected}) {
        final card = byId[id]!;
        return ColorShapeBridgeCard(
          card: card,
          size: cardSize,
          selected: selected,
        );
      },
      rightBuilder: (id, {required highlighted}) {
        final card = byId[id]!;
        return ColorShapeBridgeCard(
          card: card,
          size: cardSize,
          highlighted: highlighted,
        );
      },
      onConnect: ({required leftId, required rightId}) {
        onConnect(promptId: leftId, visualId: rightId);
      },
    );
  }
}
