import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

/// Shared in-game top bar used by every timed TinyThink game.
///
/// Layout: timer on the left; coins, stars (rewards), and pause on the right.
class GameSessionHud extends StatelessWidget {
  const GameSessionHud({
    super.key,
    required this.remainingSeconds,
    required this.coinsEarned,
    required this.starsEarned,
    required this.onPause,
    this.unlimitedTime = false,
    this.largerFonts = false,
    this.accentColor = const Color(0xFF5E35B1),
    this.highlightColor = AppColors.error,
  });

  final int remainingSeconds;
  final bool unlimitedTime;
  final int coinsEarned;
  final int starsEarned;
  final VoidCallback onPause;
  final bool largerFonts;
  final Color accentColor;
  final Color highlightColor;

  static const Color _navy = Color(0xFF2D1E5F);

  String get _timer {
    if (unlimitedTime) return '∞';
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _timerUrgent => !unlimitedTime && remainingSeconds <= 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Container(
        height: largerFonts ? 58 : 54,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAF7FF).withValues(alpha: 0.78),
              const Color(0xFFBFE8FF).withValues(alpha: 0.62),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.92),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.38),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: _BarGloss())),
            Row(
              children: [
                _StatPill(
                  label: _timer,
                  borderColor: _timerUrgent
                      ? highlightColor
                      : const Color(0xFFB388FF),
                  glowColor: _timerUrgent
                      ? highlightColor
                      : const Color(0xFF7C4DFF),
                  large: largerFonts,
                  leading: _TimerBadge(urgent: _timerUrgent),
                ),
                const Spacer(),
                _StatPill(
                  label: '+$coinsEarned',
                  borderColor: const Color(0xFFFFD54F),
                  glowColor: const Color(0xFFFFB300),
                  large: largerFonts,
                  leading: const _GoldCoin(),
                ),
                const SizedBox(width: 6),
                _StatPill(
                  label: '+$starsEarned',
                  borderColor: const Color(0xFFD1C4E9),
                  glowColor: const Color(0xFFB388FF),
                  large: largerFonts,
                  leading: const _SparkleCluster(),
                ),
                const SizedBox(width: 8),
                _GlossyPauseButton(onPause: onPause, large: largerFonts),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarGloss extends StatelessWidget {
  const _BarGloss();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BarGlossPainter());
  }
}

class _BarGlossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawArc(
      Rect.fromLTWH(6, 3, size.width - 12, r * 1.15),
      math.pi * 1.05,
      math.pi * 0.9,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.borderColor,
    required this.glowColor,
    required this.leading,
    required this.large,
  });

  final String label;
  final Color borderColor;
  final Color glowColor;
  final Widget leading;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: large ? 42 : 38,
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.38),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 15,
              color: GameSessionHud._navy,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.urgent});

  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: urgent
              ? const [Color(0xFFFF8A80), Color(0xFFE53935)]
              : const [Color(0xFFB388FF), Color(0xFF7C4DFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: (urgent ? const Color(0xFFE53935) : const Color(0xFF7C4DFF))
                .withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            child: Container(
              width: 12,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Icon(Icons.timer_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _GoldCoin extends StatelessWidget {
  const _GoldCoin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 3),
      child: CustomPaint(painter: _GoldCoinPainter()),
    );
  }
}

class _GoldCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;

    canvas.drawCircle(
      c.translate(0, 1.4),
      r,
      Paint()..color = const Color(0x66F9A825),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFF9A825)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFF57F17),
    );
    canvas.drawCircle(
      c,
      r - 3.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFFFF59D),
    );
    canvas.drawCircle(
      Offset(c.dx - 4, c.dy - 5),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          color: const Color(0xFFEF6C00),
          fontSize: r * 1.05,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleCluster extends StatelessWidget {
  const _SparkleCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 28,
      child: CustomPaint(painter: _SparkleClusterPainter()),
    );
  }
}

class _SparkleClusterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void star(Offset c, double r, Color color) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = -math.pi / 2 + i * math.pi / 2;
        final outer = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
        final innerA = a + math.pi / 4;
        final inner = Offset(
          c.dx + math.cos(innerA) * r * 0.28,
          c.dy + math.sin(innerA) * r * 0.28,
        );
        if (i == 0) {
          path.moveTo(outer.dx, outer.dy);
        } else {
          path.lineTo(outer.dx, outer.dy);
        }
        path.lineTo(inner.dx, inner.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    star(
      Offset(size.width * 0.32, size.height * 0.58),
      7.2,
      const Color(0xFF8E5AF7),
    );
    star(
      Offset(size.width * 0.68, size.height * 0.32),
      5.2,
      const Color(0xFFB388FF),
    );
    star(
      Offset(size.width * 0.72, size.height * 0.72),
      3.6,
      const Color(0xFF7C4DFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlossyPauseButton extends StatelessWidget {
  const _GlossyPauseButton({required this.onPause, required this.large});

  final VoidCallback onPause;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final side = large ? 42.0 : 38.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPause,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: side,
          height: side,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white, width: 2.4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB388FF), Color(0xFF8E5AF7), Color(0xFF6C3AE8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 4,
                left: 7,
                right: 7,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
