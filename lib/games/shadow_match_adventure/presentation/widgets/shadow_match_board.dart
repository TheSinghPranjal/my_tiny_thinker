import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';

class ShadowSlotWidget extends StatelessWidget {
  const ShadowSlotWidget({
    super.key,
    required this.slot,
    required this.onAccept,
  });

  final ShadowSlot slot;
  final void Function(String itemId) onAccept;

  @override
  Widget build(BuildContext context) {
    final item = EducationVocabulary.byId(slot.itemId);
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !slot.matched,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: active
                ? AppColors.lavender.withValues(alpha: 0.35)
                : AppColors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: slot.glow
                  ? AppColors.sunYellow
                  : active
                      ? AppColors.candyPink
                      : Colors.black26,
              width: slot.glow ? 3 : 2,
            ),
            boxShadow: slot.glow
                ? [
                    BoxShadow(
                      color: AppColors.sunYellow.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: slot.matched
              ? Center(
                  child: Text(
                    item?.emoji ?? '?',
                    style: const TextStyle(fontSize: 36),
                  ),
                )
              : Center(
                  child: Text(
                    item?.emoji ?? '?',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.black.withValues(alpha: 0.85),
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 0,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class DraggableObjectWidget extends StatelessWidget {
  const DraggableObjectWidget({
    super.key,
    required this.itemState,
  });

  final DraggableItemState itemState;

  @override
  Widget build(BuildContext context) {
    final item = itemState.item;
    if (item == null || itemState.matched) {
      return const SizedBox(width: 72, height: 72);
    }

    final child = AnimatedScale(
      scale: itemState.shake ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.candyPink.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(item.emoji, style: const TextStyle(fontSize: 38)),
        ),
      ),
    );

    return Draggable<String>(
      data: item.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sunYellow.withValues(alpha: 0.4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      child: child,
    );
  }
}
