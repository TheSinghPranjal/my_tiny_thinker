import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';

class FoodBubbleWidget extends StatelessWidget {
  const FoodBubbleWidget({
    super.key,
    required this.food,
    required this.size,
    this.glow = false,
    this.showName = false,
  });

  final FloatingFood food;
  final double size;
  final bool glow;
  final bool showName;

  /// Height the name pill adds below the bubble, so callers can reserve space.
  static const nameHeight = 26.0;

  @override
  Widget build(BuildContext context) {
    final floatY = math.sin(food.floatPhase) * 6;
    final rotation = math.sin(food.rotationPhase) * 0.06;
    final shakeX = food.shake ? math.sin(food.floatPhase * 12) * 6 : 0.0;

    return Transform.translate(
      offset: Offset(shakeX, floatY),
      child: Transform.rotate(
        angle: rotation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bubble(),
            if (showName) _name(),
          ],
        ),
      ),
    );
  }

  Widget _name() {
    final accent = food.category == FoodCategory.healthy
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return SizedBox(
      height: nameHeight,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.65), width: 2),
          ),
          child: Text(
            food.foodDef.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: glow
                ? const Color(0xFF66BB6A).withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: glow ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.12,
            left: size * 0.18,
            child: Container(
              width: size * 0.22,
              height: size * 0.14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Text(
            food.foodDef.emoji,
            style: TextStyle(fontSize: size * 0.48),
          ),
        ],
      ),
    );
  }
}
