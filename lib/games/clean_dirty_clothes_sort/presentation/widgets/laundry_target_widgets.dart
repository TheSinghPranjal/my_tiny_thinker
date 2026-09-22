import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

/// Shared "drop target" card shell: the artwork fills a rounded, glowing
/// card, with an optional title/subtitle pill overlaid on top (for art that
/// doesn't already have its own title baked in).
class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.size,
    required this.hovering,
    required this.asset,
    required this.accent,
    this.titlePill,
  });

  final LaundryTarget target;
  final double size;
  final bool hovering;
  final String asset;
  final Color accent;

  /// Overlaid at the top of the card for artwork without a baked-in title.
  final Widget? titlePill;

  @override
  Widget build(BuildContext context) {
    final highlighted = hovering || target.glow || target.happy;
    final bounce = target.happy ? -math.sin(target.idlePhase * 4).abs() * 8 : 0.0;
    final wobble = target.wobble ? math.sin(target.idlePhase * 8) * 0.04 : 0.0;
    final scale = 1.0 + (highlighted ? 0.05 : 0) + math.sin(target.idlePhase) * 0.01;
    final aspect = 853 / 700; // laundry_washer_art.png / laundry_cupboard_art.png

    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.rotate(
        angle: wobble,
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: size,
            height: size / aspect,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size * 0.1),
                    border: Border.all(
                      color: highlighted ? accent : Colors.white,
                      width: highlighted ? 4 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: highlighted ? 0.45 : 0.22),
                        blurRadius: highlighted ? 20 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size * 0.1 - 2),
                    child: Image.asset(asset, fit: BoxFit.cover),
                  ),
                ),
                if (titlePill != null)
                  Positioned(top: size * 0.05, left: 0, right: 0, child: titlePill!),
                if (target.happy)
                  Positioned(
                    right: size * 0.06,
                    bottom: size * 0.08,
                    child: Text('✨', style: TextStyle(fontSize: size * 0.14)),
                  ),
                if (target.washing)
                  Positioned(
                    left: size * 0.08,
                    top: size * 0.42,
                    child: Text('🫧', style: TextStyle(fontSize: size * 0.16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

/// Washing machine drop target ("Dirty clothes"). The artwork (a photoreal
/// washer scene) has no title baked in, so a "DIRTY" pill is overlaid to
/// match the cupboard card's built-in "CLEAN" title.
class WashingMachineWidget extends StatelessWidget {
  const WashingMachineWidget({
    super.key,
    required this.target,
    required this.size,
    this.hovering = false,
  });

  final LaundryTarget target;
  final double size;
  final bool hovering;

  static const accent = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    return _TargetCard(
      target: target,
      size: size,
      hovering: hovering,
      asset: 'assets/images/laundry_washer_art.png',
      accent: accent,
      titlePill: const _TitlePill(label: 'DIRTY', color: accent),
    );
  }
}

/// Cupboard drop target ("Clean clothes"). The artwork already has its own
/// "CLEAN" title baked in, so nothing is overlaid on top of it.
class CupboardWidget extends StatelessWidget {
  const CupboardWidget({
    super.key,
    required this.target,
    required this.size,
    this.hovering = false,
  });

  final LaundryTarget target;
  final double size;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    return _TargetCard(
      target: target,
      size: size,
      hovering: hovering,
      asset: 'assets/images/laundry_cupboard_art.png',
      accent: const Color(0xFF66BB6A),
    );
  }
}
