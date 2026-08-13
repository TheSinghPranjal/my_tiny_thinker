import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_basket_widget.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_bubble_widget.dart';

const _healthyAccent = Color(0xFF43A047);
const _junkAccent = Color(0xFFFB8C00);

/// Foods drift in bubbles across the top; the two baskets below are drop zones.
class FoodSortBoard extends StatelessWidget {
  const FoodSortBoard({
    super.key,
    required this.foods,
    required this.baskets,
    required this.onDrop,
    required this.onHoverBasket,
    this.hoverBasketId,
    this.wrongHintText,
    this.announcedName,
    this.announcedCategory,
    this.showFoodNames = true,
    this.largerTouch = true,
  });

  final List<FloatingFood> foods;
  final List<SortBasket> baskets;
  final void Function({required String foodId, required String basketId}) onDrop;
  final void Function(String? basketId) onHoverBasket;
  final String? hoverBasketId;
  final String? wrongHintText;
  final String? announcedName;
  final String? announcedCategory;
  final bool showFoodNames;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final bubbleSize = largerTouch ? 132.0 : 116.0;
    final basketSize = largerTouch ? 176.0 : 156.0;

    return Column(
      children: [
        Expanded(flex: 6, child: _sky(bubbleSize)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
            'Drag each food into the right basket!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1565C0),
              shadows: [Shadow(color: Colors.white, blurRadius: 6)],
            ),
          ),
        ),
        Expanded(flex: 4, child: _baskets(basketSize)),
      ],
    );
  }

  Widget _sky(double bubbleSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotHeight =
            bubbleSize + (showFoodNames ? FoodBubbleWidget.nameHeight : 0);
        // Normalised positions map into the space a bubble can occupy without
        // any part of it leaving the sky.
        final freeWidth = math.max(0.0, constraints.maxWidth - bubbleSize);
        final freeHeight = math.max(0.0, constraints.maxHeight - slotHeight);

        return Stack(
          children: [
            for (final food in foods)
              if (!food.hidden)
                Positioned(
                  left: food.x * freeWidth,
                  top: food.y * freeHeight,
                  child: _DraggableFoodBubble(
                    food: food,
                    size: bubbleSize,
                    showName: showFoodNames,
                    onDrop: onDrop,
                  ),
                ),
            if (wrongHintText != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(child: _WrongHint(text: wrongHintText!)),
              ),
            if (showFoodNames && announcedName != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: _Announcement(
                    name: announcedName!,
                    categoryLabel: announcedCategory,
                    accent: announcedCategory != null &&
                            announcedCategory!.startsWith('Junk')
                        ? _junkAccent
                        : _healthyAccent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _baskets(double basketSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          for (final basket in baskets)
            Expanded(
              child: DragTarget<String>(
                onWillAcceptWithDetails: (details) {
                  onHoverBasket(basket.id);
                  return true;
                },
                onLeave: (_) => onHoverBasket(null),
                onAcceptWithDetails: (details) {
                  onHoverBasket(null);
                  onDrop(foodId: details.data, basketId: basket.id);
                },
                builder: (context, candidate, rejected) {
                  final hovering =
                      candidate.isNotEmpty || hoverBasketId == basket.id;
                  final draggedId =
                      candidate.isNotEmpty ? candidate.first : null;
                  final dragged = draggedId == null
                      ? null
                      : foods.where((f) => f.id == draggedId).firstOrNull;
                  final matching = dragged?.category == basket.category;

                  // Filling the half means a toddler only has to drop the food
                  // on the correct side, not precisely onto the basket.
                  return Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.transparent,
                    child: FoodBasketWidget(
                      basket: basket.copyWith(glow: basket.glow || matching),
                      size: basketSize,
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

class _WrongHint extends StatelessWidget {
  const _WrongHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF42A5F5), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1565C0),
          ),
        ),
      ),
    );
  }
}

/// Names the food that was just sorted, then its category, so toddlers pair the
/// picture with the words.
class _Announcement extends StatelessWidget {
  const _Announcement({
    required this.name,
    required this.categoryLabel,
    required this.accent,
  });

  final String name;
  final String? categoryLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent, width: 3),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$name!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
        if (categoryLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              categoryLabel!,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: accent,
                shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
              ),
            ),
          ),
      ],
    );
  }
}

class _DraggableFoodBubble extends StatelessWidget {
  const _DraggableFoodBubble({
    required this.food,
    required this.size,
    required this.showName,
    required this.onDrop,
  });

  final FloatingFood food;
  final double size;
  final bool showName;
  final void Function({required String foodId, required String basketId}) onDrop;

  @override
  Widget build(BuildContext context) {
    final bubble = FoodBubbleWidget(
      food: food,
      size: size,
      showName: showName,
    );

    return Draggable<String>(
      data: food.id,
      // Lifts the bubble clear of the finger so the child can see the food.
      dragAnchorStrategy: (draggable, context, position) =>
          Offset(size / 2, size * 0.75),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.12,
          child: FoodBubbleWidget(
            food: food,
            size: size,
            glow: true,
            showName: showName,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: bubble),
      child: bubble,
    );
  }
}
