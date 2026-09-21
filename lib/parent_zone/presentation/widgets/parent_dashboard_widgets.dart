import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF14224D);
const _greyBlue = Color(0xFF5F7290);

/// Sky, sun, soft clouds, a faint rainbow and meadow edges behind the dashboard.
class ParentDashboardBackground extends StatelessWidget {
  const ParentDashboardBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashScenePainter(), child: child);
  }
}

class _DashScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD0F6), Color(0xFFB9E3FA), Color(0xFFDCF1FB)],
        ).createShader(r),
    );
    // Faint rainbow
    const colors = [Color(0xFFF7B2C4), Color(0xFFFBD9A8), Color(0xFFF6F2A5), Color(0xFFB9EBC0), Color(0xFFB7DDF8)];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.42),
          width: w * 1.3 - i * 56,
          height: h * 0.55 - i * 60,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = colors[i].withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 54,
      );
    }
    // Sun
    final c = Offset(w * 0.86, h * 0.085);
    canvas.drawCircle(
      c,
      70,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99FFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: c, radius: 70)),
    );
    for (var i = 0; i < 14; i++) {
      final a = i * math.pi * 2 / 14;
      canvas.drawLine(
        c + Offset(math.cos(a) * 38, math.sin(a) * 38),
        c + Offset(math.cos(a) * 52, math.sin(a) * 52),
        Paint()
          ..color = const Color(0xFFFFD84A).withValues(alpha: 0.9)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, 36, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(c + const Offset(-9, -9), 15, Paint()..color = Colors.white.withValues(alpha: 0.35));
    final face = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawCircle(c + const Offset(-11, -4), 2.8, face);
    canvas.drawCircle(c + const Offset(11, -4), 2.8, face);
    canvas.drawArc(
      Rect.fromCenter(center: c + const Offset(0, 6), width: 22, height: 14),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFFE4553A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    final cheek = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawCircle(c + const Offset(-21, 6), 5.5, cheek);
    canvas.drawCircle(c + const Offset(21, 6), 5.5, cheek);

    void cloud(Offset o, double s) {
      final p = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: o + Offset(0, 12 * s), width: 96 * s, height: 26 * s),
          Radius.circular(13 * s),
        ),
        p,
      );
      canvas.drawCircle(o + Offset(-22 * s, 3 * s), 19 * s, p);
      canvas.drawCircle(o + Offset(4 * s, -8 * s), 25 * s, p);
      canvas.drawCircle(o + Offset(30 * s, 5 * s), 17 * s, p);
    }

    cloud(Offset(w * 0.06, h * 0.135), 1.2);
    cloud(Offset(w * 0.96, h * 0.13), 0.9);
    // Meadow at the bottom corners
    for (final (nx, ny, rad) in [(0.0, 0.93, 60.0), (1.0, 0.94, 66.0), (0.1, 1.0, 50.0), (0.92, 1.0, 54.0)]) {
      canvas.drawCircle(Offset(w * nx, h * ny), rad, Paint()..color = const Color(0xFF7CC552).withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Back button + centred title/subtitle.
class ParentDashboardHeader extends StatelessWidget {
  const ParentDashboardHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 4,
            top: 6,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9BE8).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 34, color: _navy),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                Text(
                  'Parent Dashboard',
                  style: GoogleFonts.baloo2(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Monitor progress and support their learning',
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: _greyBlue,
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

/// Purple "TinyThink Premium" promo card with a golden crown.
class ParentPremiumCard extends StatelessWidget {
  const ParentPremiumCard({super.key, required this.onSeePremium});

  final VoidCallback onSeePremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA48BF0), Color(0xFFD08CF0)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A5BD8).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _PremiumArtPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        'TinyThink Premium',
                        style: GoogleFonts.baloo2(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.78,
                    child: Text(
                      'Unlock unlimited play, parent controls, and Learning Path sessions.',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.96),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onSeePremium,
                    child: Container(
                      height: 44,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'See Premium',
                            style: GoogleFonts.baloo2(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3F9CF0),
                              height: 1.1,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF3F9CF0), size: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Lavender clouds at the bottom.
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(w * 0.72, h * 1.05), h * 0.32, cloud);
    canvas.drawCircle(Offset(w * 0.9, h * 0.98), h * 0.28, cloud);
    canvas.drawCircle(Offset(w * 0.56, h * 1.12), h * 0.26, cloud);
    // Sparkles
    void sparkle(Offset c, double r, double a) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r),
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }

    sparkle(Offset(w * 0.79, h * 0.14), 7, 0.9);
    sparkle(Offset(w * 0.93, h * 0.25), 11, 0.95);
    sparkle(Offset(w * 0.85, h * 0.34), 5, 0.7);

    // Gold crown, tilted
    canvas.save();
    canvas.translate(w * 0.83, h * 0.56);
    canvas.rotate(0.22);
    final crown = Path()
      ..moveTo(-38, 26)
      ..lineTo(-46, -22)
      ..lineTo(-22, -2)
      ..lineTo(0, -34)
      ..lineTo(22, -2)
      ..lineTo(46, -22)
      ..lineTo(38, 26)
      ..close();
    canvas.drawPath(
      crown,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE680), Color(0xFFFFC21F), Color(0xFFE59F12)],
        ).createShader(const Rect.fromLTWH(-46, -34, 92, 60)),
    );
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFC98A0F).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in [const Offset(-46, -24), const Offset(0, -36), const Offset(46, -24)]) {
      canvas.drawCircle(p, 6, Paint()..color = const Color(0xFFFFD84A));
    }
    // Band + star
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-38, 18, 76, 12), const Radius.circular(6)),
      Paint()..color = const Color(0xFFF2AE1A),
    );
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? 11.0 : 5.0;
      final pt = Offset(math.cos(a) * rad, math.sin(a) * rad + 4);
      i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// One tile of the statistics grid.
class ParentStatTile extends StatelessWidget {
  const ParentStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final Widget icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.6),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _greyBlue,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.baloo2(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      height: 1.1,
                    ),
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

class StatIcon extends StatelessWidget {
  const StatIcon({super.key, required this.child, required this.colors, this.shape = BoxShape.circle});

  final Widget child;
  final List<Color> colors;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(12) : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// Section card shell (rounded, soft shadow) used by Statistics and Game Scores.
class ParentSectionCard extends StatelessWidget {
  const ParentSectionCard({
    super.key,
    required this.title,
    required this.leading,
    required this.trailing,
    required this.child,
    this.background = const Color(0xFFFFFCF4),
  });

  final String title;
  final Widget leading;
  final Widget trailing;
  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B9BE8).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.baloo2(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                    height: 1.1,
                  ),
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class ParentPill extends StatelessWidget {
  const ParentPill({super.key, required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1FC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: _navy,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 19, color: _navy),
          ],
        ),
      ),
    );
  }
}

/// Little rising bars icon next to "Statistics".
class BarsIcon extends StatelessWidget {
  const BarsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double h, Color a, Color b) => Container(
          width: 9,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a, b]),
          ),
        );
    return SizedBox(
      width: 34,
      height: 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bar(14, const Color(0xFF6C8BF5), const Color(0xFF4E6EE8)),
          bar(22, const Color(0xFF7A6CF0), const Color(0xFF9A67F0)),
          bar(32, const Color(0xFF39A8F0), const Color(0xFF2F86E6)),
        ],
      ),
    );
  }
}

/// One row of the Game Scores list.
class ParentScoreRow extends StatelessWidget {
  const ParentScoreRow({
    super.key,
    required this.emoji,
    required this.name,
    required this.best,
    required this.played,
    required this.stars,
    this.showDivider = true,
  });

  final String emoji;
  final String name;
  final int best;
  final int played;
  final int stars;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final sub = GoogleFonts.nunito(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: _greyBlue,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFE3EAF3), width: 1.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 26, height: 1.1)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.baloo2(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    height: 1.15,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('Best: $best   |   Played: ${played}x   |   ⭐ $stars', style: sub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
