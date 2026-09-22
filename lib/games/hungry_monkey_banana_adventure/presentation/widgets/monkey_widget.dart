import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';
import 'package:my_tiny_thinker/games/shared/monkey_character.dart';

class MonkeyWidget extends StatelessWidget {
  const MonkeyWidget({
    super.key,
    required this.monkey,
    this.largerTouch = false,
  });

  final MonkeyEntity monkey;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final size = largerTouch ? 160.0 : 140.0;
    final blink = (monkey.blinkTimer % 3.8) < 0.12;

    return MonkeyCharacter(
      size: size,
      animPhase: monkey.animPhase,
      blink: blink,
      eating: monkey.phase == MonkeyPhase.eating,
      clapping: monkey.phase == MonkeyPhase.clapping,
      reaching: monkey.phase == MonkeyPhase.reaching,
      catching: monkey.phase == MonkeyPhase.catching,
      idleScratching: monkey.idleAction == 3 && monkey.phase == MonkeyPhase.idle,
      reachProgress: monkey.reachProgress,
      sadProgress: monkey.sadProgress,
      eatProgress: monkey.eatProgress,
      actionTimer: monkey.actionTimer,
      tailWag: monkey.tailWag,
      headShake: monkey.headShake,
      earDroop: monkey.earDroop,
    );
  }
}
