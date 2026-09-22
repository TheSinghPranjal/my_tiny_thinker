import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_teddy_cupcake_party/models/hungry_teddy_models.dart';
import 'package:my_tiny_thinker/games/shared/teddy_bear_character.dart';

class TeddyWidget extends StatelessWidget {
  const TeddyWidget({
    super.key,
    required this.teddy,
    this.largerTouch = false,
  });

  final TeddyEntity teddy;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 250.0 : 230.0;
    final blink = (teddy.blinkTimer % 3.6) < 0.12;

    return Positioned(
      left: teddy.x - size / 2,
      top: teddy.y - size / 2,
      child: TeddyBearCharacter(
        size: size,
        animPhase: teddy.animPhase,
        blink: blink,
        eating: teddy.phase == TeddyPhase.eating,
        receiving: teddy.phase == TeddyPhase.receiving,
        celebrating: teddy.phase == TeddyPhase.celebrating ||
            teddy.phase == TeddyPhase.goldenCelebration,
        goldenCelebration: teddy.phase == TeddyPhase.goldenCelebration,
        excitedLevel: teddy.excitedLevel,
        celebrateProgress: teddy.celebrateProgress,
        actionTimer: teddy.actionTimer,
        eatProgress: teddy.eatProgress,
        headAngle: teddy.headAngle,
        mouthOpen: teddy.mouthOpen,
      ),
    );
  }
}
