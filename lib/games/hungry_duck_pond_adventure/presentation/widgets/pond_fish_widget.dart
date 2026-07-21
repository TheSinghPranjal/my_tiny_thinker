import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/hungry_duck_pond_adventure/models/hungry_duck_models.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_painter.dart';
import 'package:my_tiny_thinker/games/shared/pond_fish_varieties.dart';

class PondFishWidget extends StatelessWidget {
  const PondFishWidget({
    super.key,
    required this.fish,
    required this.onTap,
    this.largerTouch = false,
  });

  final PondFishEntity fish;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (fish.phase == FishPhase.gone) return const SizedBox.shrink();

    final def =
        PondFishVarieties.byIndex(fish.varietyIndex, isGolden: fish.isGolden);
    final touch = (largerTouch ? 84.0 : 76.0) * def.lengthScale;
    final alpha = fish.phase == FishPhase.sinking
        ? (1 - fish.sinkProgress).clamp(0.0, 1.0)
        : 1.0;
    final selected = fish.phase == FishPhase.selected;
    final tappable = fish.canTap;

    return GestureDetector(
      onTap: tappable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: alpha,
        child: AnimatedScale(
          scale: selected ? 1.18 : (tappable ? 1.0 : 0.95),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: touch + 20,
            height: touch * 0.78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (tappable)
                  _TapPulse(color: Color(def.bodyColor), active: !selected),
                if (fish.isGolden || fish.glow > 0)
                  Container(
                    width: touch * 0.9,
                    height: touch * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(fish.isGolden ? 0xFFFFD54F : 0xFFFFF176)
                              .withValues(
                                alpha: (fish.glow * 0.7).clamp(0.25, 0.85),
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
                      selected: selected,
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

class _TapPulse extends StatefulWidget {
  const _TapPulse({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  State<_TapPulse> createState() => _TapPulseState();
}

class _TapPulseState extends State<_TapPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return CustomPaint(
          size: const Size(72, 48),
          painter: _PulsePainter(progress: t, color: widget.color),
        );
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = 18 + progress * 16;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withValues(alpha: (1 - progress) * 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.progress != progress;
}
