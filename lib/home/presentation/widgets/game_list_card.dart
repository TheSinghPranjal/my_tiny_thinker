import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour theme of a game card (background, Play button, accent).
class GameCardTheme {
  const GameCardTheme({
    required this.top,
    required this.bottom,
    required this.button,
    required this.buttonDark,
    required this.accent,
  });

  final Color top;
  final Color bottom;
  final Color button;
  final Color buttonDark;
  final Color accent;

  static const blue = GameCardTheme(
    top: Color(0xFFD3ECFC),
    bottom: Color(0xFFA9D8F7),
    button: Color(0xFF3F8DF0),
    buttonDark: Color(0xFF2569D8),
    accent: Color(0xFFFFC928),
  );
  static const pink = GameCardTheme(
    top: Color(0xFFFBD3E3),
    bottom: Color(0xFFF6B5CF),
    button: Color(0xFFEE5C7E),
    buttonDark: Color(0xFFD63E63),
    accent: Color(0xFFFFC928),
  );
  static const green = GameCardTheme(
    top: Color(0xFFD5F5E0),
    bottom: Color(0xFFB2EAC7),
    button: Color(0xFF4CBF6B),
    buttonDark: Color(0xFF34A254),
    accent: Color(0xFF4CBF6B),
  );
  static const purple = GameCardTheme(
    top: Color(0xFFE0D6FA),
    bottom: Color(0xFFC6B5F3),
    button: Color(0xFF7657DE),
    buttonDark: Color(0xFF5D3FC4),
    accent: Color(0xFFFFC928),
  );
  static const orange = GameCardTheme(
    top: Color(0xFFFFE9C9),
    bottom: Color(0xFFFFD09B),
    button: Color(0xFFF59A2A),
    buttonDark: Color(0xFFDD7F0E),
    accent: Color(0xFFFF7A59),
  );

  static const all = [blue, pink, green, purple, orange];
  static GameCardTheme byIndex(int i) => all[i % all.length];
}

/// Wide game card: icon tile, title, description, Play button and a big
/// illustration on the right.
class GameListCard extends StatelessWidget {
  const GameListCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.theme,
    this.subtitle,
    this.starsEarned = 0,
    this.comingSoon = false,
    this.onPlay,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final GameCardTheme theme;
  final int starsEarned;
  final bool comingSoon;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: comingSoon ? null : onPlay,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.top, theme.bottom],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: theme.button.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _CloudsPainter())),
              // Illustration on the right.
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: _Illustration(emoji: emoji, accent: theme.accent),
              ),
              if (starsEarned > 0)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⭐ $starsEarned',
                      style: GoogleFonts.baloo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15245A),
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 104, 12),
                child: Row(
                  children: [
                    _IconTile(emoji: emoji),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) => FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: c.maxWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF14224D),
                                    height: 1.08,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12.5,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF5A6A8C),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                comingSoon
                                    ? _SoonPill(theme: theme)
                                    : _PlayButton(theme: theme),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFEFF7FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 34, height: 1.1)),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.theme});

  final GameCardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.button, theme.buttonDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: theme.buttonDark.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 4),
          Text(
            'Play',
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoonPill extends StatelessWidget {
  const _SoonPill({required this.theme});

  final GameCardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        'Coming soon',
        style: GoogleFonts.baloo2(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: theme.buttonDark,
          height: 1.1,
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.emoji, required this.accent});

  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 58, height: 1.1)),
          Positioned.fill(child: CustomPaint(painter: _SparklePainter(accent))),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    // Two little dashes at the top-left and one at the top-right.
    canvas.drawLine(Offset(size.width * 0.12, size.height * 0.3), Offset(size.width * 0.02, size.height * 0.24), p);
    canvas.drawLine(Offset(size.width * 0.16, size.height * 0.2), Offset(size.width * 0.1, size.height * 0.1), p);
    canvas.drawLine(Offset(size.width * 0.9, size.height * 0.24), Offset(size.width * 1.0, size.height * 0.32), p);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.color != color;
}

/// Soft white clouds in the bottom-left/right corners of the card.
class _CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(size.width * 0.06, size.height * 1.02), size.height * 0.34, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 1.08), size.height * 0.3, paint);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.05), size.height * 0.36, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * -0.02), size.height * 0.26, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
