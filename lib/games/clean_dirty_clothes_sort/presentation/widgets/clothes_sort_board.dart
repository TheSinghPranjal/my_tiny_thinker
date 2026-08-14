import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/presentation/widgets/clothes_item_widget.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/presentation/widgets/laundry_target_widgets.dart';

class ClothesSortBoard extends StatelessWidget {
  const ClothesSortBoard({
    super.key,
    required this.items,
    required this.targets,
    required this.onDrop,
    required this.onHoverTarget,
    this.hoverTargetId,
    this.showNames = false,
    this.largerTouch = true,
    this.leftHanded = false,
  });

  final List<ClothesItem> items;
  final List<LaundryTarget> targets;
  final void Function({required String itemId, required String targetId})
  onDrop;
  final void Function(String? targetId) onHoverTarget;
  final String? hoverTargetId;
  final bool showNames;
  final bool largerTouch;
  final bool leftHanded;

  @override
  Widget build(BuildContext context) {
    final itemSize = largerTouch ? 108.0 : 92.0;
    final targetSize = largerTouch ? 168.0 : 148.0;

    return Column(
      children: [
        Expanded(flex: 6, child: _playArea(itemSize)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
            'Drag dirty clothes to the washer, clean clothes to the cupboard!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1565C0),
              shadows: [Shadow(color: Colors.white, blurRadius: 6)],
            ),
          ),
        ),
        Expanded(flex: 4, child: _targets(targetSize)),
      ],
    );
  }

  Widget _playArea(double itemSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotHeight =
            itemSize + (showNames ? ClothesItemWidget.nameHeight : 0);
        final freeWidth = math.max(0.0, constraints.maxWidth - itemSize);
        final freeHeight = math.max(0.0, constraints.maxHeight - slotHeight);

        return Stack(
          children: [
            for (final item in items)
              if (!item.hidden)
                Positioned(
                  left: item.x * freeWidth,
                  top: item.y * freeHeight,
                  child: _DraggableClothesItem(
                    item: item,
                    size: itemSize,
                    showName: showNames,
                    onDrop: onDrop,
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _targets(double targetSize) {
    final ordered = leftHanded ? targets.reversed.toList() : targets;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          for (final target in ordered)
            Expanded(
              child: DragTarget<String>(
                onWillAcceptWithDetails: (_) {
                  onHoverTarget(target.id);
                  return true;
                },
                onLeave: (_) => onHoverTarget(null),
                onAcceptWithDetails: (details) {
                  onHoverTarget(null);
                  onDrop(itemId: details.data, targetId: target.id);
                },
                builder: (context, candidate, rejected) {
                  final hovering =
                      candidate.isNotEmpty || hoverTargetId == target.id;
                  final draggedId = candidate.isNotEmpty
                      ? candidate.first
                      : null;
                  final dragged = draggedId == null
                      ? null
                      : items.where((i) => i.id == draggedId).firstOrNull;
                  final matching = dragged?.cleanliness == target.accepts;

                  return Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.transparent,
                    child: target.isWasher
                        ? WashingMachineWidget(
                            target: target.copyWith(
                              glow: target.glow || matching,
                            ),
                            size: targetSize,
                            hovering: hovering,
                          )
                        : CupboardWidget(
                            target: target.copyWith(
                              glow: target.glow || matching,
                            ),
                            size: targetSize,
                            hovering: hovering,
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DraggableClothesItem extends StatelessWidget {
  const _DraggableClothesItem({
    required this.item,
    required this.size,
    required this.showName,
    required this.onDrop,
  });

  final ClothesItem item;
  final double size;
  final bool showName;
  final void Function({required String itemId, required String targetId})
  onDrop;

  @override
  Widget build(BuildContext context) {
    final child = ClothesItemWidget(item: item, size: size, showName: showName);

    return Draggable<String>(
      data: item.id,
      dragAnchorStrategy: (draggable, context, position) =>
          Offset(size / 2, size * 0.75),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: ClothesItemWidget(
            item: item,
            size: size,
            glow: true,
            showName: showName,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      child: child,
    );
  }
}
