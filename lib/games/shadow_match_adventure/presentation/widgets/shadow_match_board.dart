import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';
import 'package:my_tiny_thinker/games/shared/education_vocabulary.dart';
import 'package:my_tiny_thinker/games/shadow_match_adventure/models/shadow_match_models.dart';

/// Grey silhouette tint applied to unmatched shadow targets.
const _shadowSilhouetteColor = Color(0xFF5A5A5A);

class ShadowSlotWidget extends StatelessWidget {
  const ShadowSlotWidget({
    super.key,
    required this.slot,
    required this.onAccept,
  });

  final ShadowSlot slot;
  final void Function(String itemId) onAccept;

  static const double size = 100;
  static const double emojiSize = 64;

  @override
  Widget build(BuildContext context) {
    final item = EducationVocabulary.byId(slot.itemId);
    final emoji = item?.emoji ?? '?';

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !slot.matched,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: active
                ? AppColors.lavender.withValues(alpha: 0.35)
                : AppColors.white.withValues(alpha: 0.55),
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
          child: Center(
            child: slot.matched
                ? Text(emoji, style: const TextStyle(fontSize: emojiSize))
                : _ShadowEmoji(emoji: emoji, size: emojiSize),
          ),
        );
      },
    );
  }
}

/// Renders an emoji as a solid grey silhouette so it reads as a "shadow".
class _ShadowEmoji extends StatelessWidget {
  const _ShadowEmoji({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        _shadowSilhouetteColor,
        BlendMode.srcIn,
      ),
      child: Text(
        emoji,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: size, height: 1),
      ),
    );
  }
}

class DraggableObjectWidget extends StatelessWidget {
  const DraggableObjectWidget({
    super.key,
    required this.itemState,
  });

  final DraggableItemState itemState;

  static const double size = 80;
  static const double emojiSize = 44;

  @override
  Widget build(BuildContext context) {
    final item = itemState.item;
    if (item == null || itemState.matched) {
      return const SizedBox(width: size, height: size);
    }

    final child = AnimatedScale(
      scale: itemState.shake ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: size,
        height: size,
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
          child: Text(item.emoji, style: const TextStyle(fontSize: emojiSize)),
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
            width: size + 8,
            height: size + 8,
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
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: emojiSize + 6),
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: child),
      child: child,
    );
  }
}
