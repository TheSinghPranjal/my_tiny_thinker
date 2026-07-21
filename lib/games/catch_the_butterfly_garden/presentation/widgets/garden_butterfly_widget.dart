import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/catch_the_butterfly_garden/models/butterfly_garden_models.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterflies.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterfly_painter.dart';

class GardenButterflyWidget extends StatelessWidget {
  const GardenButterflyWidget({
    super.key,
    required this.butterfly,
    required this.onTap,
    this.largerTouch = false,
  });

  final ButterflyEntity butterfly;
  final VoidCallback onTap;
  final bool largerTouch;

  static double layoutSize(bool largerTouch, double sizeScale) =>
      (largerTouch ? 108.0 : 96.0) * sizeScale;

  @override
  Widget build(BuildContext context) {
    if (butterfly.phase == ButterflyPhase.gone) return const SizedBox.shrink();

    final touch = layoutSize(largerTouch, butterfly.sizeScale);
    final def = GardenButterflies.byIndex(
      butterfly.varietyIndex,
      isGolden: butterfly.isGolden,
    );
    final fastFlap = butterfly.phase == ButterflyPhase.tapped ||
        butterfly.phase == ButterflyPhase.collecting;

    return GestureDetector(
      onTap: butterfly.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch + 16,
        height: touch + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (butterfly.isGolden || butterfly.glow > 0)
              Container(
                width: touch * 0.9,
                height: touch * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(butterfly.isGolden ? 0xFFFFD54F : 0xFFFFF176)
                          .withValues(
                            alpha: (0.35 + butterfly.glow * 0.4).clamp(0.2, 0.85),
                          ),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            if (butterfly.highlight > 0)
              Container(
                width: touch,
                height: touch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.85 * butterfly.highlight),
                    width: 3,
                  ),
                ),
              ),
            CustomPaint(
              size: Size(touch, touch),
              painter: GardenButterflyPainter(
                def: def,
                wingPhase: butterfly.wingPhase,
                isGolden: butterfly.isGolden,
                fastFlap: fastFlap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
