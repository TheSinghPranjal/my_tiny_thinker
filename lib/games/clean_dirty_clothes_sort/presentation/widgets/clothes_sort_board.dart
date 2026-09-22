import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';
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
        const _SortHeader(),
        Expanded(flex: 6, child: _playArea(itemSize)),
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

/// "Sort the clothes!" title, subtitle and a smiling sun — sits above the
/// play area, matching the other games' setup/game headers.
class _SortHeader extends StatelessWidget {
  const _SortHeader();

  static const _navy = Color(0xFF14224D);
  static const _greyBlue = Color(0xFF5F7290);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort the clothes!',
                  style: GoogleFonts.baloo2(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Dirty → washer  •  Clean → cupboard',
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _greyBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 52,
            height: 52,
            child: CustomPaint(painter: _SunPainter()),
          ),
        ],
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    paintSmilingSun(canvas, size.center(Offset.zero), size.width * 0.42);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
