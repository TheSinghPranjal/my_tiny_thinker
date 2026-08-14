import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CelebrationStat {
  const CelebrationStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  bool get isRewardValue => value.trim().startsWith('+');
}

/// Shared end-of-game popup used by every game.
///
/// Visuals match the Balloon Parade celebration card: cream rounded card,
/// purple wavy ribbon banner, dashed stat rows, and pill action buttons.
class GameCelebrationCard extends StatelessWidget {
  const GameCelebrationCard({
    super.key,
    required this.title,
    required this.stats,
    required this.onPlayAgain,
    required this.onHome,
    this.playAgainLabel = 'Play Again!',
    this.homeLabel = 'Home',
    this.showHomeButton = true,
  });

  final String title;
  final List<CelebrationStat> stats;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final String playAgainLabel;
  final String homeLabel;
  final bool showHomeButton;

  static const Color navy = Color(0xFF2D3686);
  static const Color purple = Color(0xFF8E5AF7);
  static const Color purpleDeep = Color(0xFF6C3AE8);
  static const Color lavender = Color(0xFFF3EFFF);
  static const Color cardFill = Color(0xFFFFFDFB);
  static const Color cardBorder = Color(0xFFD7C8F8);
  static const Color rewardBrown = Color(0xFFC47A3A);
  static const Color dash = Color(0xFFE4DDF2);

  @override
  Widget build(BuildContext context) {
    final titleSize = title.length > 32
        ? 15.0
        : title.length > 24
        ? 17.0
        : 20.0;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 28),
              padding: const EdgeInsets.fromLTRB(18, 46, 18, 18),
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(42),
                border: Border.all(color: cardBorder, width: 2.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E5AF7).withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const _DashedDivider(),
                    _StatRow(stat: stats[i]),
                  ],
                  const SizedBox(height: 18),
                  _PlayAgainButton(
                    label: playAgainLabel,
                    onPressed: onPlayAgain,
                  ),
                  if (showHomeButton) ...[
                    const SizedBox(height: 10),
                    _HomeButton(label: homeLabel, onPressed: onHome),
                  ],
                ],
              ),
            ),
            const Positioned(top: -6, child: _BannerPeekDecor()),
            Positioned(
              top: 4,
              left: -10,
              right: -10,
              child: _RibbonBanner(title: title, fontSize: titleSize),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen dimmed overlay that centers [GameCelebrationCard].
class GameCelebrationOverlay extends StatelessWidget {
  const GameCelebrationOverlay({
    super.key,
    required this.title,
    required this.stats,
    required this.onPlayAgain,
    required this.onHome,
    this.playAgainLabel = 'Play Again!',
    this.homeLabel = 'Home',
  });

  final String title;
  final List<CelebrationStat> stats;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final String playAgainLabel;
  final String homeLabel;

  static Future<void> showDialog(
    BuildContext context, {
    required String title,
    required List<CelebrationStat> stats,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
    String playAgainLabel = 'Play Again!',
    String homeLabel = 'Home',
    bool showHomeButton = true,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'celebration',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
              child: GameCelebrationCard(
                title: title,
                stats: stats,
                playAgainLabel: playAgainLabel,
                homeLabel: homeLabel,
                showHomeButton: showHomeButton,
                onPlayAgain: () {
                  Navigator.of(context).pop();
                  onPlayAgain();
                },
                onHome: () {
                  Navigator.of(context).pop();
                  onHome();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.22),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
              child: GameCelebrationCard(
                title: title,
                stats: stats,
                playAgainLabel: playAgainLabel,
                homeLabel: homeLabel,
                onPlayAgain: onPlayAgain,
                onHome: onHome,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final CelebrationStat stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              stat.icon,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stat.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: GameCelebrationCard.navy,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: GameCelebrationCard.lavender,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              stat.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: stat.isRewardValue
                    ? GameCelebrationCard.rewardBrown
                    : GameCelebrationCard.purpleDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.4,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = GameCelebrationCard.dash
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dashWidth, size.width), y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayAgainButton extends StatelessWidget {
  const _PlayAgainButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB07CFF), Color(0xFF8E5AF7), Color(0xFF6C3AE8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C3AE8).withValues(alpha: 0.38),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF7C3AED),
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    const _Sparkles(),
                  ],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD7C8F8), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3EFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Color(0xFF6C3AE8),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    const _ConfettiDots(),
                  ],
                ),
              ),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GameCelebrationCard.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkles extends StatelessWidget {
  const _Sparkles();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 28,
      child: CustomPaint(painter: _SparklePainter()),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFE082);
    void star(Offset c, double r) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = -math.pi / 2 + i * math.pi / 2;
        final outer = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
        final innerA = a + math.pi / 4;
        final inner = Offset(
          c.dx + math.cos(innerA) * r * 0.32,
          c.dy + math.sin(innerA) * r * 0.32,
        );
        if (i == 0) {
          path.moveTo(outer.dx, outer.dy);
        } else {
          path.lineTo(outer.dx, outer.dy);
        }
        path.lineTo(inner.dx, inner.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    star(Offset(size.width * 0.28, size.height * 0.42), 5.5);
    star(Offset(size.width * 0.72, size.height * 0.28), 4);
    star(Offset(size.width * 0.62, size.height * 0.78), 3.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiDots extends StatelessWidget {
  const _ConfettiDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 22,
      child: Stack(
        children: const [
          Positioned(
            left: 4,
            top: 3,
            child: _Dot(color: Color(0xFFFF8A80), size: 5),
          ),
          Positioned(
            left: 16,
            top: 10,
            child: _Dot(color: Color(0xFFFFD54F), size: 6, square: true),
          ),
          Positioned(
            left: 26,
            top: 2,
            child: _Dot(color: Color(0xFFFF80AB), size: 4, square: true),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size, this.square = false});

  final Color color;
  final double size;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(square ? 1.5 : 99),
      ),
    );
  }
}

class _BannerPeekDecor extends StatelessWidget {
  const _BannerPeekDecor();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 46,
      child: CustomPaint(painter: _PeekDecorPainter()),
    );
  }
}

class _PeekDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    final leafDark = Paint()..color = const Color(0xFF43A047);

    Path leaf(Offset tip, Offset ctrl, Offset end) {
      return Path()
        ..moveTo(tip.dx, tip.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy + 6, tip.dx, tip.dy)
        ..close();
    }

    canvas.drawPath(
      leaf(Offset(cx - 28, 18), Offset(cx - 18, 8), Offset(cx - 8, 22)),
      leafPaint,
    );
    canvas.drawPath(
      leaf(Offset(cx + 28, 18), Offset(cx + 18, 8), Offset(cx + 8, 22)),
      leafDark,
    );

    final balloon = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, 16), width: 22, height: 28));
    canvas.drawPath(
      balloon,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - 8, 2),
          Offset(cx + 8, 30),
          const [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFFCA28)],
        ),
    );
    canvas.drawPath(
      balloon,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFF9A825)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      Offset(cx - 4, 10),
      3.2,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    final knot = Path()
      ..moveTo(cx, 30)
      ..lineTo(cx - 4, 34)
      ..lineTo(cx + 4, 34)
      ..close();
    canvas.drawPath(knot, Paint()..color = const Color(0xFFFFCA28));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RibbonBanner extends StatelessWidget {
  const _RibbonBanner({required this.title, required this.fontSize});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      width: double.infinity,
      child: CustomPaint(
        painter: _RibbonPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 16),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.05,
                shadows: const [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const fold = 14.0;

    final shadow = Path()
      ..moveTo(fold, 10)
      ..quadraticBezierTo(w * 0.25, 2, w * 0.5, 4)
      ..quadraticBezierTo(w * 0.75, 2, w - fold, 10)
      ..lineTo(w - 4, h - 6)
      ..quadraticBezierTo(w * 0.75, h - 2, w * 0.5, h - 8)
      ..quadraticBezierTo(w * 0.25, h - 2, 4, h - 6)
      ..close();
    canvas.drawPath(
      shadow,
      Paint()
        ..color = const Color(0xFF5B21B6).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final body = Path()
      ..moveTo(fold, 8)
      ..quadraticBezierTo(w * 0.18, -2, w * 0.5, 2)
      ..quadraticBezierTo(w * 0.82, -2, w - fold, 8)
      ..lineTo(w - 8, h * 0.62)
      ..quadraticBezierTo(w * 0.78, h - 4, w * 0.5, h - 10)
      ..quadraticBezierTo(w * 0.22, h - 4, 8, h * 0.62)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(w / 2, 0),
          Offset(w / 2, h),
          const [Color(0xFFB07CFF), Color(0xFF8E5AF7), Color(0xFF7C3AED)],
        ),
    );

    final highlight = Path()
      ..moveTo(fold + 8, 12)
      ..quadraticBezierTo(w * 0.5, 4, w - fold - 8, 12)
      ..quadraticBezierTo(w * 0.5, 10, fold + 8, 12);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final leftFold = Path()
      ..moveTo(fold, 8)
      ..lineTo(0, h * 0.42)
      ..lineTo(10, h * 0.58)
      ..lineTo(8, h * 0.62)
      ..close();
    canvas.drawPath(leftFold, Paint()..color = const Color(0xFF6D28D9));

    final rightFold = Path()
      ..moveTo(w - fold, 8)
      ..lineTo(w, h * 0.42)
      ..lineTo(w - 10, h * 0.58)
      ..lineTo(w - 8, h * 0.62)
      ..close();
    canvas.drawPath(rightFold, Paint()..color = const Color(0xFF6D28D9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
