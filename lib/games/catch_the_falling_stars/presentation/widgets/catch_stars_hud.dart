import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/widgets/game_celebration_card.dart';
import 'package:my_tiny_thinker/games/catch_the_falling_stars/models/catch_the_falling_stars_models.dart';

class CatchStarsProgressMeter extends StatelessWidget {
  const CatchStarsProgressMeter({
    super.key,
    required this.progress,
    required this.constellationEmoji,
    required this.pieces,
  });

  final double progress;
  final String constellationEmoji;
  final int pieces;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 26,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: math.max(14.0, w * p),
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFE680), Color(0xFFFFCB47)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      // Milestone stars at 1/6, 1/2 and 5/6 along the bar.
                      for (final (frac, threshold) in [(0.17, 0.0), (0.5, 0.5), (0.86, 0.85)])
                        Positioned(
                          left: w * frac - 13,
                          top: -1,
                          child: _MilestoneStar(lit: p > threshold),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2A6E).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(constellationEmoji, style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 6),
                Text(
                  '$pieces/5',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneStar extends StatelessWidget {
  const _MilestoneStar({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _MilestoneStarPainter(lit: lit)),
    );
  }
}

class _MilestoneStarPainter extends CustomPainter {
  _MilestoneStarPainter({required this.lit});

  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? 12.0 : 5.6;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: lit ? 1.0 : 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()..color = lit ? const Color(0xFFFFD54F) : const Color(0xFF8E96B8),
    );
  }

  @override
  bool shouldRepaint(covariant _MilestoneStarPainter old) => old.lit != lit;
}

class CatchStarsVictoryOverlay extends StatelessWidget {
  const CatchStarsVictoryOverlay({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final CatchTheFallingStarsResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return GameCelebrationOverlay(
      title: 'Catch the Falling Stars Celebration!',
      stats: [
        CelebrationStat(
          icon: '⭐',
          label: 'Stars Collected',
          value: '${result.starsCollected}',
        ),
        CelebrationStat(icon: '🪙', label: 'Coins', value: '+${result.coins}'),
        CelebrationStat(
          icon: '🌟',
          label: 'Happy Stars',
          value: '+${result.stars}',
        ),
        CelebrationStat(
          icon: '🏅',
          label: 'TinyThink Points',
          value: '+${result.rewardPoints}',
        ),
        CelebrationStat(
          icon: '🔥',
          label: 'Highest Streak',
          value: '${result.longestStreak}',
        ),
        CelebrationStat(
          icon: '🌌',
          label: 'Longest Constellation',
          value: '${result.longestConstellation}',
        ),
        CelebrationStat(
          icon: '🧩',
          label: 'Constellation Pieces',
          value: '${result.constellationPieces}',
        ),
      ],
      onPlayAgain: onPlayAgain,
      onHome: onHome,
    );
  }
}
