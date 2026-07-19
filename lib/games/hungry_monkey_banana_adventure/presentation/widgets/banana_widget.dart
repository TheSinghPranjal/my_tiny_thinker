import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_tiny_thinker/games/hungry_monkey_banana_adventure/models/hungry_monkey_models.dart';

const _bananaAsset = 'assets/images/banana.svg';

class BananaWidget extends StatelessWidget {
  const BananaWidget({
    super.key,
    required this.banana,
    required this.onTap,
    this.largerTouch = false,
  });

  final BananaEntity banana;
  final VoidCallback onTap;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    if (banana.phase == BananaPhase.gone) return const SizedBox.shrink();

    final touch = largerTouch ? 96.0 : 84.0;

    return GestureDetector(
      onTap: banana.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch,
        height: touch,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (banana.glow > 0)
              Container(
                width: touch * 0.85,
                height: touch * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFF176)
                          .withValues(alpha: banana.glow * 0.55),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            Transform.rotate(
              angle: banana.rotation,
              child: _BananaBunchSvg(banana: banana),
            ),
          ],
        ),
      ),
    );
  }
}

class FallingBananaWidget extends StatelessWidget {
  const FallingBananaWidget({super.key, required this.banana});

  final BananaEntity banana;

  @override
  Widget build(BuildContext context) {
    if (banana.phase != BananaPhase.falling && banana.phase != BananaPhase.tapped) {
      return const SizedBox.shrink();
    }

    return Transform.rotate(
      angle: banana.rotation,
      child: _BananaBunchSvg(
        banana: banana.copyWith(phase: BananaPhase.onTree, growProgress: 1),
      ),
    );
  }
}

/// Renders a shaded 4-banana bunch from SVG.
/// Growing bananas keep shading via [BlendMode.modulate] (not flat tint).
class _BananaBunchSvg extends StatelessWidget {
  const _BananaBunchSvg({required this.banana});

  final BananaEntity banana;

  @override
  Widget build(BuildContext context) {
    final grow = banana.phase == BananaPhase.growing ? banana.growProgress : 1.0;
    final ripe = grow.clamp(0.0, 1.0);
    final visualW = 56.0 * banana.sizeScale;
    final visualH = 68.0 * banana.sizeScale;
    final scale = 0.45 + grow * 0.55;

    // Preserve yellow/highlight shading; only shift toward green when unripe.
    final tint = Color.lerp(const Color(0xFF7CB342), Colors.white, ripe)!;

    Widget bunch = SvgPicture.asset(
      _bananaAsset,
      width: visualW,
      height: visualH,
      fit: BoxFit.contain,
    );

    if (ripe < 0.98) {
      bunch = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.modulate),
        child: bunch,
      );
    }

    return Transform.scale(scale: scale, child: bunch);
  }
}
