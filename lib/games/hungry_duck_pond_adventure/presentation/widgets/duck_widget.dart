import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/shared/duck_character.dart';

class DuckWidget extends StatelessWidget {
  const DuckWidget({super.key, required this.duck, this.largerTouch = false});

  final DuckEntity duck;
  final bool largerTouch;

  /// Visual size of the duck sprite; [duck.x]/[duck.y] is the center point.
  static double layoutSize(bool largerTouch) => largerTouch ? 128.0 : 116.0;

  @override
  Widget build(BuildContext context) {
    final blink = (duck.blinkTimer % 3.5) < 0.12;
    final bob = duck.phase == DuckPhase.idleSwim
        ? math.sin(duck.animPhase * 2) * 3.5
        : duck.phase == DuckPhase.celebrating
            ? math.sin(duck.animPhase * 8) * 4
            : 0.0;

    return DuckCharacter(
      size: layoutSize(largerTouch),
      facingRight: duck.facingRight,
      blink: blink,
      bob: bob,
      wingFlap: duck.wingFlap,
      ripplePhase: duck.ripplePhase,
      eating: duck.phase == DuckPhase.eating,
      celebrating: duck.phase == DuckPhase.celebrating,
      chasing: duck.phase == DuckPhase.chasing,
    );
  }
}
