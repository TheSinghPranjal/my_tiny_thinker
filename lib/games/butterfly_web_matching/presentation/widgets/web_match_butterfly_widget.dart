import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/models/butterfly_web_matching_models.dart';
import 'package:my_tiny_thinker/games/butterfly_web_matching/presentation/widgets/magical_web_widget.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterflies.dart';
import 'package:my_tiny_thinker/games/shared/garden_butterfly_painter.dart';

class WebMatchButterflyWidget extends StatelessWidget {
  const WebMatchButterflyWidget({
    super.key,
    required this.butterfly,
    required this.onTap,
    this.largerTouch = true,
    this.selected = false,
  });

  final WebButterflyEntity butterfly;
  final VoidCallback onTap;
  final bool largerTouch;
  final bool selected;

  static double layoutSize(bool largerTouch) => largerTouch ? 100.0 : 88.0;

  @override
  Widget build(BuildContext context) {
    if (butterfly.phase == WebButterflyPhase.gone) {
      return const SizedBox.shrink();
    }

    final touch = layoutSize(largerTouch);
    final def = GardenButterflies.byIndex(
      butterfly.varietyIndex,
      isGolden: butterfly.isGolden,
    );
    final fastFlap = butterfly.phase == WebButterflyPhase.flyingToWeb ||
        butterfly.phase == WebButterflyPhase.matchedDance ||
        butterfly.phase == WebButterflyPhase.flyingAway ||
        butterfly.phase == WebButterflyPhase.entering ||
        butterfly.phase == WebButterflyPhase.fluttering;

    return GestureDetector(
      onTap: butterfly.canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: touch + 24,
        height: touch + 48,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Magical web under butterfly when selected / approaching.
            if (butterfly.webOpacity > 0.05)
              Positioned(
                bottom: 0,
                child: MagicalWebWidget(
                  opacity: butterfly.webOpacity,
                  size: touch * 1.15,
                  phase: butterfly.hoverPhase,
                ),
              ),
            if (butterfly.glow > 0 || butterfly.isGolden || selected)
              Container(
                width: touch * 0.85,
                height: touch * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                        butterfly.isGolden ? 0xFFFFD54F : 0xFFF8BBD0,
                      ).withValues(
                        alpha: (0.3 + butterfly.glow * 0.45).clamp(0.2, 0.85),
                      ),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            if (selected || butterfly.phase == WebButterflyPhase.onWeb)
              Container(
                width: touch,
                height: touch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 2.5,
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(0, butterfly.phase == WebButterflyPhase.onWeb ? -8 : 0),
              child: CustomPaint(
                size: Size(touch, touch),
                painter: GardenButterflyPainter(
                  def: def,
                  wingPhase: butterfly.wingPhase,
                  isGolden: butterfly.isGolden,
                  fastFlap: fastFlap,
                ),
              ),
            ),
            if (butterfly.accessory != ButterflyAccessory.none)
              Positioned(
                top: 4,
                child: Text(
                  _accessoryEmoji(butterfly.accessory),
                  style: TextStyle(fontSize: touch * 0.22),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _accessoryEmoji(ButterflyAccessory a) => switch (a) {
        ButterflyAccessory.crown => '👑',
        ButterflyAccessory.flowerGarland => '🌸',
        ButterflyAccessory.bow => '🎀',
        ButterflyAccessory.heart => '💖',
        ButterflyAccessory.star => '⭐',
        ButterflyAccessory.ribbon => '🌈',
        ButterflyAccessory.none => '',
      };
}
