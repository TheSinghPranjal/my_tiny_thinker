import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/feed_the_frog_adventure/models/feed_frog_models.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/frog_widget.dart';
import 'package:my_tiny_thinker/games/frog_pond_adventure/presentation/widgets/lily_pad_widget.dart';

class FeedFrogHero extends StatelessWidget {
  const FeedFrogHero({
    super.key,
    required this.frogX,
    required this.frogY,
    required this.animPhase,
    required this.blinkTimer,
    required this.phase,
    this.highContrast = false,
  });

  final double frogX;
  final double frogY;
  final double animPhase;
  final double blinkTimer;
  final FrogFeedPhase phase;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final padRadius = 110.0;
    final pad = LilyPadEntity(
      id: 'hero_pad',
      centerX: frogX,
      centerY: frogY + 8,
      radius: padRadius,
    );

    final frog = FrogEntity(
      id: 'hero_frog',
      padId: pad.id,
      varietyIndex: 3,
      phase: phase == FrogFeedPhase.chewing ? FrogPhase.reacting : FrogPhase.idle,
      x: frogX,
      y: frogY,
      animPhase: animPhase,
      blinkTimer: blinkTimer,
      reactProgress: phase == FrogFeedPhase.chewing ? 0.5 : 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          left: frogX - padRadius * 1.1,
          top: frogY + 8 - padRadius * 0.7,
          child: LilyPadWidget(pad: pad),
        ),
        Positioned(
          left: frogX - 50,
          top: frogY - 58,
          child: IgnorePointer(
            child: FrogWidget(
              frog: frog,
              onTap: () {},
              largerTouch: false,
              highContrast: highContrast,
            ),
          ),
        ),
      ],
    );
  }
}
