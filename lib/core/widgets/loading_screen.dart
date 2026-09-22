import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tiny_thinker/core/art/sky_elements.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.onComplete,
    this.messages = const [
      'Counting bubbles...',
      'Finding rainbows...',
      'Warming up your brain...',
      'Getting games ready...',
    ],
  });

  final VoidCallback onComplete;
  final List<String> messages;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _runController;
  int _messageIndex = 0;
  double _progress = 0;
  Timer? _messageTimer;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _messageTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % widget.messages.length;
        });
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() => _progress = math.min(_progress + 0.02, 1.0));
      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _runController.dispose();
    _messageTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF14286E);
    return Scaffold(
      backgroundColor: const Color(0xFF8FD0F6),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _runController,
                  builder: (context, _) => CustomPaint(
                    painter: _SplashScenePainter(bob: _runController.value),
                  ),
                ),
              ),
              // Wordmark
              Positioned(
                top: h * 0.565,
                left: 0,
                right: 0,
                child: const Center(child: _SplashTitle()),
              ),
              Positioned(
                top: h * 0.655,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Little Games. Big Futures.',
                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B5A94),
                    ),
                  ),
                ),
              ),
              // Progress bar
              Positioned(
                top: h * 0.7,
                left: w * 0.176,
                right: w * 0.176,
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA9C9E6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, bc) => Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 60),
                        width: math.max(16.0, bc.maxWidth * _progress),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFD75A), Color(0xFFF2B32C)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: h * 0.746,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      widget.messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: navy.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "TinyThink" wordmark: colourful "Tiny", navy "Think", white outline, star.
class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  static const _tiny = [
    Color(0xFF3FA0F0),
    Color(0xFFF56FA8),
    Color(0xFFFFB92E),
    Color(0xFF4CBF4A),
  ];

  List<TextSpan> _spans({required bool outline}) {
    const fontSize = 62.0;
    TextStyle base(Color c) {
      final st = GoogleFonts.baloo2(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1.0,
      );
      return outline
          ? st.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 12
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.white,
            )
          : st.copyWith(color: c);
    }

    const think = 'Think';
    return [
      for (var i = 0; i < 4; i++) TextSpan(text: 'Tiny'[i], style: base(_tiny[i])),
      for (var i = 0; i < think.length; i++)
        TextSpan(
          text: think[i],
          style: base(Color.lerp(const Color(0xFF2E63D6), const Color(0xFF14286E), i / 4)!),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text.rich(TextSpan(children: _spans(outline: true))),
          Text.rich(TextSpan(children: _spans(outline: false))),
          const Positioned(
            left: 6,
            top: -6,
            child: Icon(Icons.star_rounded, size: 24, color: Color(0xFFFFC928)),
          ),
        ],
      ),
    );
  }
}

class _SplashScenePainter extends CustomPainter {
  _SplashScenePainter({required this.bob});

  final double bob;

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
          colors: [Color(0xFF8CCFF6), Color(0xFFB4E1F9), Color(0xFFD9F1FC)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(r),
    );

    _sun(canvas, Offset(w * 0.8, h * 0.14), w);
    for (final (nx, ny, sc) in [
      (0.12, 0.125, 1.15),
      (0.57, 0.205, 0.95),
      (0.02, 0.25, 0.8),
      (0.03, 0.42, 0.75),
      (0.94, 0.42, 0.7),
    ]) {
      _cloud(canvas, Offset(w * nx, h * ny), sc);
    }
    canvas.save();
    // A cloud tucked in front of the sun's lower right.
    _cloud(canvas, Offset(w * 0.9, h * 0.19), 1.05);
    canvas.restore();

    for (final (nx, ny, sc) in [(0.55, 0.107, 1.0), (0.13, 0.198, 0.8), (0.11, 0.362, 1.0), (0.92, 0.257, 0.6)]) {
      _star(canvas, Offset(w * nx, h * ny), 9 * sc);
    }
    _butterfly(canvas, Offset(w * 0.325, h * 0.19), const Color(0xFFFF9248), const Color(0xFFF2604A), 0.0);
    _butterfly(canvas, Offset(w * 0.18, h * 0.278), const Color(0xFF58A8F2), const Color(0xFF3A7FD8), 0.3);
    _butterfly(canvas, Offset(w * 0.865, h * 0.295), const Color(0xFFB868E8), const Color(0xFF8E45D0), 0.6);
    // Dotted flight trail
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.9, h * 0.318)
        ..cubicTo(w * 0.97, h * 0.31, w * 0.96, h * 0.34, w * 0.9, h * 0.335)
        ..cubicTo(w * 0.94, h * 0.35, w * 0.98, h * 0.345, w, h * 0.34),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    _rainbowAndMascot(canvas, size);
    _endClouds(canvas, size);
    _hills(canvas, size);
  }

  void _sun(Canvas canvas, Offset c, double w) {
    canvas.drawCircle(
      c,
      w * 0.28,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99FFF59D), Color(0x00FFF59D)],
        ).createShader(Rect.fromCircle(center: c, radius: w * 0.28)),
    );
    final rr = w * 0.125;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6 - 0.3;
      canvas.drawLine(
        c + Offset(math.cos(a) * rr * 1.1, math.sin(a) * rr * 1.1),
        c + Offset(math.cos(a) * rr * 1.5, math.sin(a) * rr * 1.5),
        Paint()
          ..color = const Color(0xFFFFE066)
          ..strokeWidth = w * 0.03
          ..strokeCap = StrokeCap.round,
      );
    }
    final disc = Rect.fromCircle(center: c, radius: rr);
    canvas.drawCircle(
      c,
      rr,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFFF3A0), Color(0xFFFFE566), SharedArtColors.sparkle],
        ).createShader(disc),
    );
    final ink = Paint()
      ..color = SharedArtColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final dx in [-0.36, 0.36]) {
      canvas.drawArc(
        Rect.fromCenter(center: c + Offset(rr * dx, -rr * 0.08), width: rr * 0.34, height: rr * 0.26),
        math.pi + 0.3,
        math.pi - 0.6,
        false,
        ink,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(center: c + Offset(0, rr * 0.28), width: rr * 0.5, height: rr * 0.3),
      0.2,
      math.pi - 0.4,
      false,
      ink,
    );
    final cheek = Paint()..color = const Color(0xFFFF9AA0).withValues(alpha: 0.7);
    canvas.drawCircle(c + Offset(-rr * 0.62, rr * 0.26), rr * 0.16, cheek);
    canvas.drawCircle(c + Offset(rr * 0.62, rr * 0.26), rr * 0.16, cheek);
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final shade = Paint()..color = const Color(0xFFCFE6F7);
    final body = Paint()..color = Colors.white;
    void puffs(Paint p, double dy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, 14 * s + dy), width: 110 * s, height: 30 * s),
          Radius.circular(15 * s),
        ),
        p,
      );
      canvas.drawCircle(c + Offset(-26 * s, 4 * s + dy), 22 * s, p);
      canvas.drawCircle(c + Offset(4 * s, -9 * s + dy), 30 * s, p);
      canvas.drawCircle(c + Offset(34 * s, 5 * s + dy), 20 * s, p);
    }

    puffs(shade, 4 * s);
    puffs(body, 0);
  }

  void _star(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rad = i.isEven ? r : r * 0.45;
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = SharedArtColors.sparkle);
  }

  void _butterfly(Canvas canvas, Offset c, Color a, Color b, double phase) {
    final flap = 0.75 + 0.25 * math.sin((bob + phase) * math.pi * 2);
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(dir * flap, 1);
      canvas.drawOval(Rect.fromCenter(center: const Offset(11, -8), width: 22, height: 26), Paint()..color = a);
      canvas.drawOval(Rect.fromCenter(center: const Offset(9, 9), width: 16, height: 18), Paint()..color = b);
      canvas.restore();
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 5, height: 28), const Radius.circular(2.5)),
      Paint()..color = const Color(0xFF6B4A3A),
    );
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        c + const Offset(0, -12),
        c + Offset(dir * 8, -22),
        Paint()
          ..color = const Color(0xFFE0A93A)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _rainbowAndMascot(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    const bands = [
      Color(0xFFF58E9C),
      Color(0xFFFFB878),
      Color(0xFFFFE27A),
      Color(0xFFB6EBA0),
      Color(0xFF9DD3F5),
      Color(0xFFA997EE),
    ];
    final top = h * 0.378;
    final outerR = w * 0.6;
    final bandW = w * 0.043;
    final cy = top + outerR;

    // Mascot dome peeks over the rainbow.
    final mr = w * 0.155;
    final mc = Offset(cx + w * 0.02, top - mr * 0.32 - bob * 4 + 8);
    _mascot(canvas, mc, mr, w, h);

    for (var i = 0; i < bands.length; i++) {
      final rad = outerR - i * bandW - bandW / 2;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: rad),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = bands[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = bandW + 1.5
          ..strokeCap = StrokeCap.butt,
      );
    }
    // Soft highlight along the outer band.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: outerR - 4),
      math.pi + 0.35,
      math.pi - 0.7,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Little hands gripping the rainbow.
    for (final dx in [-0.135, 0.135]) {
      final o = Offset(mc.dx + w * dx, top + w * 0.005);
      final hand = Rect.fromCenter(center: o, width: w * 0.085, height: w * 0.06);
      canvas.drawOval(hand, Paint()..color = const Color(0xFFFFE070));
      canvas.drawOval(
        hand,
        Paint()
          ..color = const Color(0xFFF2C64A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      for (final fx in [-0.018, 0.0, 0.018]) {
        canvas.drawCircle(o + Offset(w * fx, -w * 0.024), w * 0.014, Paint()..color = const Color(0xFFFFE070));
      }
    }
  }

  void _mascot(Canvas canvas, Offset c, double r, double w, double h) {
    // Colourful dashes above the head.
    void dash(Offset a, Offset b, Color col) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = col
          ..strokeWidth = w * 0.028
          ..strokeCap = StrokeCap.round,
      );
    }

    dash(c + Offset(-r * 1.02, -r * 0.5), c + Offset(-r * 0.78, -r * 0.42), const Color(0xFFFFE066));
    dash(c + Offset(-r * 0.66, -r * 1.02), c + Offset(-r * 0.58, -r * 0.82), const Color(0xFF5AAAF0));
    dash(c + Offset(r * 0.74, -r * 0.9), c + Offset(r * 0.9, -r * 0.7), const Color(0xFFFF7FA8));
    dash(c + Offset(r * 0.96, -r * 0.55), c + Offset(r * 1.22, -r * 0.6), const Color(0xFFFFE066));
    dash(c + Offset(r * 0.88, -r * 0.3), c + Offset(r * 1.2, -r * 0.3), const Color(0xFF5AAAF0));

    final body = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.0,
          colors: [Color(0xFFFFF29A), Color(0xFFFFE566), Color(0xFFFFD34A)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(body),
    );
    // Face
    final ink = Paint()..color = const Color(0xFF1B1B26);
    for (final dx in [-0.3, 0.3]) {
      final e = c + Offset(r * dx, r * 0.18);
      canvas.drawCircle(e, r * 0.115, ink);
      canvas.drawCircle(e + Offset(r * 0.035, -r * 0.04), r * 0.04, Paint()..color = Colors.white);
    }
    final cheek = Paint()..color = const Color(0xFFFF9AA0).withValues(alpha: 0.7);
    canvas.drawCircle(c + Offset(-r * 0.55, r * 0.4), r * 0.15, cheek);
    canvas.drawCircle(c + Offset(r * 0.55, r * 0.4), r * 0.15, cheek);
    final mouth = Path()
      ..moveTo(c.dx - r * 0.2, c.dy + r * 0.38)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.78, c.dx + r * 0.2, c.dy + r * 0.38)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF7A2A35));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 0.68), width: r * 0.26, height: r * 0.2),
      Paint()..color = const Color(0xFFFF7A8A),
    );
    canvas.restore();
  }

  void _endClouds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _cloud(canvas, Offset(w * 0.07, h * 0.6), 1.55);
    _cloud(canvas, Offset(w * 0.92, h * 0.6), 1.55);
  }

  void _hills(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Soft clouds behind the hills
    _cloud(canvas, Offset(w * 0.92, h * 0.78), 1.4);
    _cloud(canvas, Offset(w * 0.12, h * 0.8), 1.2);

    final back = Path()
      ..moveTo(0, h * 0.88)
      ..quadraticBezierTo(w * 0.25, h * 0.85, w * 0.5, h * 0.9)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF9ED58B));
    final right = Path()
      ..moveTo(w * 0.2, h * 1.0)
      ..quadraticBezierTo(w * 0.55, h * 0.9, w * 0.85, h * 0.865)
      ..quadraticBezierTo(w * 0.95, h * 0.855, w, h * 0.87)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      right,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FCB6E), Color(0xFF6CB84F)],
        ).createShader(Rect.fromLTWH(w * 0.2, h * 0.85, w * 0.8, h * 0.15)),
    );
    final left = Path()
      ..moveTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.3, h * 0.925, w * 0.5, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFF6FBB52));

    // Bushes at the bottom-left
    for (final (nx, ny, rad, col) in [
      (0.0, 0.86, 58.0, 0xFF52A84D),
      (0.1, 0.9, 46.0, 0xFF63B85A),
      (0.02, 0.96, 60.0, 0xFF48A046),
    ]) {
      canvas.drawCircle(Offset(w * nx, h * ny), rad, Paint()..color = Color(col));
    }

    void leafPair(Offset base, double s) {
      canvas.drawLine(
        base,
        base + Offset(0, -26 * s),
        Paint()
          ..color = const Color(0xFF4E9A45)
          ..strokeWidth = 3 * s
          ..strokeCap = StrokeCap.round,
      );
      for (final dir in [-1.0, 1.0]) {
        final o = base + Offset(0, -24 * s);
        canvas.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..quadraticBezierTo(o.dx + dir * 10 * s, o.dy - 16 * s, o.dx + dir * 24 * s, o.dy - 6 * s)
            ..quadraticBezierTo(o.dx + dir * 14 * s, o.dy + 6 * s, o.dx, o.dy)
            ..close(),
          Paint()..color = const Color(0xFF63B85A),
        );
      }
    }

    leafPair(Offset(w * 0.28, h * 0.925), 1.3);
    leafPair(Offset(w * 0.6, h * 0.915), 0.9);
    leafPair(Offset(w * 0.86, h * 0.9), 0.8);
    leafPair(Offset(w * 0.4, h * 0.985), 0.8);

    void daisy(Offset c, double rad) {
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        canvas.drawCircle(c + Offset(math.cos(a) * rad, math.sin(a) * rad), rad * 0.68, Paint()..color = Colors.white);
      }
      canvas.drawCircle(c, rad * 0.55, Paint()..color = const Color(0xFFFFB300));
    }

    daisy(Offset(w * 0.09, h * 0.93), 15);
    daisy(Offset(w * 0.34, h * 0.965), 12);
    daisy(Offset(w * 0.9, h * 0.94), 15);
  }

  @override
  bool shouldRepaint(covariant _SplashScenePainter old) => old.bob != bob;
}
