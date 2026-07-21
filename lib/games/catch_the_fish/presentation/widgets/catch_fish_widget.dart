import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_fish/models/catch_the_fish_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_painter.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

class CatchFishWidget extends StatelessWidget {
  const CatchFishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.largerTouch = false,
  });

  final CatchFishEntity fish;
  final VoidCallback onTap;
  final bool largerTouch;

  static double layoutWidth(bool largerTouch, double lengthScale) =>
      (largerTouch ? 100.0 : 88.0) * lengthScale;

  static double layoutHeight(bool largerTouch, double lengthScale) =>
      layoutWidth(largerTouch, lengthScale) * 0.72;

  @override
  Widget build(BuildContext context) {
    if (fish.phase == CatchFishPhase.gone) return const SizedBox.shrink();

    final def = PondFishVarieties.byIndex(fish.varietyIndex);
    final touch = layoutWidth(largerTouch, def.lengthScale);
    final reeling = fish.phase == CatchFishPhase.reeling;
    final tappable = fish.canTap;

    return Positioned(
      left: fish.x - (touch + 16) / 2,
      top: fish.y - (touch * 0.72) / 2,
      child: GestureDetector(
        onTap: tappable ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: reeling ? 1.22 : (tappable ? 1.0 : 0.94),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: touch + 16,
            height: touch * 0.78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (fish.glow > 0 || reeling)
                  Container(
                    width: touch * 0.9,
                    height: touch * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFF176).withValues(
                            alpha: (0.3 + fish.glow * 0.5).clamp(0.25, 0.9),
                          ),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                Transform.scale(
                  scaleX: fish.facingRight ? 1 : -1,
                  child: CustomPaint(
                    size: Size(touch, touch * 0.62),
                    painter: PondFishPainter(
                      def: def,
                      wiggle: fish.pathT,
                      selected: reeling,
                      depth: fish.depth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
