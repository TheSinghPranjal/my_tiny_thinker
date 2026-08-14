import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

class ClothesItemWidget extends StatelessWidget {
  const ClothesItemWidget({
    super.key,
    required this.item,
    required this.size,
    this.glow = false,
    this.showName = false,
  });

  final ClothesItem item;
  final double size;
  final bool glow;
  final bool showName;

  static const nameHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    final floatY = math.sin(item.floatPhase) * 5;
    final shakeX = item.shake ? math.sin(item.floatPhase * 10) * 7 : 0.0;
    final isClean = item.isClean;

    return Transform.translate(
      offset: Offset(shakeX, floatY),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isClean
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFEFEBE9),
              borderRadius: BorderRadius.circular(size * 0.22),
              border: Border.all(
                color: isClean
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFF8D6E63),
                width: glow ? 4 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isClean
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFF8D6E63))
                      .withValues(alpha: glow ? 0.45 : 0.2),
                  blurRadius: glow ? 18 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isClean)
                  Positioned(
                    top: size * 0.08,
                    right: size * 0.1,
                    child: Text('✨', style: TextStyle(fontSize: size * 0.16)),
                  ),
                if (!isClean) ...[
                  Positioned(
                    bottom: size * 0.18,
                    left: size * 0.12,
                    child: Text('💧', style: TextStyle(fontSize: size * 0.14)),
                  ),
                  Positioned(
                    top: size * 0.2,
                    right: size * 0.15,
                    child: Text('🟤', style: TextStyle(fontSize: size * 0.12)),
                  ),
                ],
                Text(
                  item.def.emoji,
                  style: TextStyle(fontSize: size * 0.44),
                ),
              ],
            ),
          ),
          if (showName)
            SizedBox(
              height: nameHeight,
              child: Center(
                child: Text(
                  item.def.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isClean
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF5D4037),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
