import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/ocean_fish_adventure/models/ocean_fish_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_painter.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

/// Ocean fish drawn with the shared pond fish (same fish as Hungry Duck Pond).
///
/// The game logic still drives [FishEntity.x]/[FishEntity.y]/[FishEntity.rotation]
/// and its phases; this widget only turns the heading into a side-on fish that
/// stays upright (mirrored when swimming left) instead of rotating it nose-down.
class FishWidget extends StatelessWidget {
  const FishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.highContrast = false,
  });

  final FishEntity fish;
  final VoidCallback onTap;
  final bool highContrast;

  static const _maxTilt = 0.55;

  @override
  Widget build(BuildContext context) {
    final def = PondFishVarieties.byIndex(fish.variantIndex);
    final touchSize = fish.size * 1.35;
    final fishWidth = fish.size * 1.3 * def.lengthScale;
    final canTap =
        fish.phase == FishPhase.waiting || fish.phase == FishPhase.entering;
    final happy = fish.phase == FishPhase.tapped;

    final (facingRight, tilt) = _pose();

    return Positioned(
      left: fish.x - touchSize / 2,
      top: fish.y - touchSize / 2,
      width: touchSize,
      height: touchSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canTap ? onTap : null,
        child: Center(
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scaleX: facingRight ? 1 : -1,
              child: Transform.scale(
                scale: 1.0 + fish.wiggle + (happy ? 0.12 : 0),
                child: CustomPaint(
                  size: Size(fishWidth, fishWidth * 0.62),
                  painter: PondFishPainter(
                    def: def,
                    wiggle: fish.pathT * 6 + fish.waitAngle * 2,
                    selected: happy,
                    depth: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Which way the fish faces and how much it tilts.
  ///
  /// While travelling (entering/exiting) the fish follows its heading. When it
  /// hovers or is tapped it keeps a steady side and gently bobs, so it doesn't
  /// flip around as it orbits its spot.
  (bool, double) _pose() {
    if (fish.phase == FishPhase.waiting || fish.phase == FishPhase.tapped) {
      final right = fish.id.hashCode.isEven;
      return (right, math.sin(fish.waitAngle * 2) * 0.12);
    }
    final cosR = math.cos(fish.rotation);
    final right = cosR >= 0;
    // Heading relative to horizontal (for a mirrored fish, relative to -x),
    // kept within +/- _maxTilt so the fish never turns nose-down.
    final raw = right
        ? math.atan2(math.sin(fish.rotation), cosR)
        : math.atan2(-math.sin(fish.rotation), -cosR);
    final tilt = raw.clamp(-_maxTilt, _maxTilt);
    return (right, tilt);
  }
}
