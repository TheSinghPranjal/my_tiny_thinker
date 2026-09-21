import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PartyBackground extends StatelessWidget {
  const PartyBackground({
    super.key,
    required this.child,
    this.eveningFactor = 0,
    this.envPhase = 0,
    this.reducedMotion = false,
    this.intensity = 1.0,
  });

  final Widget child;
  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _PartyRoomPainter(
            eveningFactor: eveningFactor,
            envPhase: envPhase,
            reducedMotion: reducedMotion,
            intensity: intensity,
          ),
        ),
        child,
      ],
    );
  }
}

class _PartyRoomPainter extends CustomPainter {
  _PartyRoomPainter({
    required this.eveningFactor,
    required this.envPhase,
    required this.reducedMotion,
    required this.intensity,
  });

  final double eveningFactor;
  final double envPhase;
  final bool reducedMotion;
  final double intensity;

  static const _confettiColors = [
    0xFFF48FB1,
    0xFF81C4F5,
    0xFFFFE082,
    0xFFB39DDB,
    0xFFA5D6A7,
    0xFFFFAB91,
  ];

  // Layout helpers (fractions of the whole screen).
  double _floorY(Size s) => s.height * 0.415;

  @override
  void paint(Canvas canvas, Size size) {
    final evening = eveningFactor.clamp(0.0, 1.0);
    _drawWall(canvas, size, evening);
    _drawFloor(canvas, size, evening);
    _drawBunting(canvas, size);
    _drawPicture(canvas, size);
    _drawWindow(canvas, size, evening);
    _drawShelfPlant(canvas, size);
    _drawTopBalloons(canvas, size);
    _drawWallBalloons(canvas, size);
    _drawLowerBalloons(canvas, size);
    _drawGiftBox(canvas, Offset(size.width * 0.095, size.height * 0.635), size.width * 0.145);
    _drawRightShelf(canvas, size);
    _drawRug(canvas, size);
    _drawBall(canvas, Offset(size.width * 0.135, size.height * 0.805), size.width * 0.065);
    _drawBlocks(canvas, size);
    _drawFloorPlant(canvas, size);
    _drawConfetti(canvas, size);
    if (evening > 0.15) _drawWarmGlow(canvas, size, evening);
  }

  // --- Room ---------------------------------------------------------------

  void _drawWall(Canvas canvas, Size size, double evening) {
    final top = Color.lerp(const Color(0xFFFBE7D2), const Color(0xFF5D4037), evening * 0.45)!;
    final bottom = Color.lerp(const Color(0xFFF9D8B6), const Color(0xFF3E2723), evening * 0.5)!;
    final rect = Rect.fromLTWH(0, 0, size.width, _floorY(size) + 4);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    // Soft vignette on the sides.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
  }

  void _drawFloor(Canvas canvas, Size size, double evening) {
    final y = _floorY(size);
    final rect = Rect.fromLTWH(0, y, size.width, size.height - y);
    final top = Color.lerp(const Color(0xFFFCE3BF), const Color(0xFF6D4C41), evening * 0.4)!;
    final bottom = Color.lerp(const Color(0xFFF6CB99), const Color(0xFF4E342E), evening * 0.45)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    // Wood plank seams.
    final seam = Paint()
      ..color = const Color(0xFFB98A5E).withValues(alpha: 0.22)
      ..strokeWidth = 1.6;
    for (var i = 1; i < 24; i++) {
      final yy = y + i * size.height * 0.026;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), seam);
      // Staggered end joints.
      final off = (i.isOdd ? 0.28 : 0.68) * size.width;
      canvas.drawLine(Offset(off, yy), Offset(off, yy + size.height * 0.026), seam);
    }
    // Baseboard.
    canvas.drawRect(
      Rect.fromLTWH(0, y - 6, size.width, 12),
      Paint()..color = const Color(0xFFF2A3B6).withValues(alpha: 0.75),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, y - 6, size.width, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    // Subtle edge where the play area meets the lower floor.
    canvas.drawLine(
      Offset(0, size.height * 0.69),
      Offset(size.width, size.height * 0.69),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 2,
    );
  }

  void _drawBunting(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final y0 = h * 0.2;
    final rope = Path()..moveTo(w * 0.17, y0);
    rope.quadraticBezierTo(w * 0.5, y0 + h * 0.05, w * 1.02, y0 - h * 0.01);
    canvas.drawPath(
      rope,
      Paint()
        ..color = const Color(0xFFD9A07A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    // Flags sit along the rope (sampled from the curve).
    final metrics = rope.computeMetrics().first;
    const colors = [0xFFF48FB1, 0xFF81C4F5, 0xFFFFE082, 0xFFA5D6A7, 0xFFCE93D8];
    const n = 8;
    for (var i = 0; i < n; i++) {
      final tan = metrics.getTangentForOffset(metrics.length * (i + 0.5) / n)!;
      final p = tan.position;
      final flag = Path()
        ..moveTo(p.dx - 17, p.dy)
        ..lineTo(p.dx + 17, p.dy)
        ..lineTo(p.dx, p.dy + 38)
        ..close();
      final sway = reducedMotion ? 0.0 : math.sin(envPhase * 2 + i) * 0.03;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(tan.angle + sway);
      canvas.translate(-p.dx, -p.dy);
      canvas.drawPath(flag, Paint()..color = Color(colors[i % colors.length]));
      canvas.drawPath(
        flag,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  void _drawPicture(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(size.width * 0.053, size.height * 0.215, size.width * 0.19, size.height * 0.122);
    final frame = RRect.fromRectAndRadius(r, const Radius.circular(4));
    canvas.drawRRect(
      frame.shift(const Offset(2, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFFD8B78E));
    canvas.drawRRect(frame.deflate(4), Paint()..color = const Color(0xFFC79F72));
    canvas.drawRRect(frame.deflate(7), Paint()..color = const Color(0xFFF8E8D2));

    // Little teddy face.
    final c = Offset(r.center.dx, r.top + r.height * 0.28);
    const fur = Color(0xFFC79A7B);
    canvas.drawCircle(c + const Offset(-18, -15), 10, Paint()..color = fur);
    canvas.drawCircle(c + const Offset(18, -15), 10, Paint()..color = fur);
    canvas.drawCircle(c, 24, Paint()..color = fur);
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 8), width: 26, height: 19),
      Paint()..color = const Color(0xFFF3DDC2),
    );
    final ink = Paint()..color = const Color(0xFF5A3A2A);
    canvas.drawCircle(c + const Offset(-8, -3), 2.6, ink);
    canvas.drawCircle(c + const Offset(8, -3), 2.6, ink);
    canvas.drawOval(Rect.fromCenter(center: c + const Offset(0, 5), width: 7, height: 5), ink);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Be\nKind\nBe Happy!',
        style: TextStyle(
          color: Color(0xFFC1857C),
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: r.width - 16);
    tp.paint(canvas, Offset(r.center.dx - tp.width / 2, r.top + r.height * 0.5));
    _heart(canvas, Offset(r.center.dx, r.bottom - 14), 5, const Color(0xFFF2A7B5));
  }

  void _heart(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.2, c.dx - r * 0.9, c.dy - r * 1.3, c.dx, c.dy - r * 0.4)
      ..cubicTo(c.dx + r * 0.9, c.dy - r * 1.3, c.dx + r * 1.6, c.dy - r * 0.2, c.dx, c.dy + r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawWindow(Canvas canvas, Size size, double evening) {
    final w = size.width;
    final h = size.height;
    final glass = Rect.fromLTWH(w * 0.575, h * 0.222, w * 0.215, h * 0.16);
    // Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(glass.inflate(7), const Radius.circular(4)),
      Paint()..color = const Color(0xFF9E6B47),
    );
    // Sky + trees seen through the window
    canvas.save();
    canvas.clipRect(glass);
    canvas.drawRect(
      glass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF7CC3F2), const Color(0xFF1A237E), evening * 0.55)!,
            Color.lerp(const Color(0xFFBFE3F8), const Color(0xFF283593), evening * 0.55)!,
          ],
        ).createShader(glass),
    );
    canvas.drawCircle(
      Offset(glass.left + glass.width * 0.28, glass.top + glass.height * 0.25),
      16,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      Offset(glass.left + glass.width * 0.4, glass.top + glass.height * 0.22),
      12,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    for (final (dx, dy, r, c) in [
      (0.75, 0.86, 44.0, 0xFF63B85A),
      (0.9, 0.7, 36.0, 0xFF4FA24B),
      (0.55, 1.0, 40.0, 0xFF7CCB66),
    ]) {
      canvas.drawCircle(
        Offset(glass.left + glass.width * dx, glass.top + glass.height * dy),
        r,
        Paint()..color = Color(c),
      );
    }
    canvas.restore();
    // Window bars
    final bar = Paint()
      ..color = const Color(0xFF9E6B47)
      ..strokeWidth = 5;
    canvas.drawLine(Offset(glass.center.dx, glass.top), Offset(glass.center.dx, glass.bottom), bar);
    canvas.drawLine(Offset(glass.left, glass.center.dy), Offset(glass.right, glass.center.dy), bar);
    // Sill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(glass.left - 10, glass.bottom + 4, glass.width + 20, 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB98456),
    );

    // Curtain rod + curtains
    final rodY = h * 0.213;
    canvas.drawLine(
      Offset(w * 0.5, rodY),
      Offset(w * 0.9, rodY),
      Paint()
        ..color = const Color(0xFFB98456)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(w * 0.5, rodY), 5, Paint()..color = const Color(0xFFB98456));
    canvas.drawCircle(Offset(w * 0.9, rodY), 5, Paint()..color = const Color(0xFFB98456));
    _curtain(canvas, Rect.fromLTWH(w * 0.512, rodY, w * 0.085, h * 0.175), left: true);
    _curtain(canvas, Rect.fromLTWH(w * 0.78, rodY, w * 0.085, h * 0.175), left: false);
  }

  void _curtain(Canvas canvas, Rect r, {required bool left}) {
    // Gathered curtain pinched by a yellow tie-back.
    final tieY = r.top + r.height * 0.68;
    final inward = left ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(r.left, r.top)
      ..lineTo(r.right, r.top)
      ..lineTo(r.right - inward * r.width * 0.05, tieY - 6)
      ..quadraticBezierTo(
        left ? r.left + r.width * 0.2 : r.right - r.width * 0.2,
        tieY,
        left ? r.right - r.width * 0.05 : r.left + r.width * 0.05,
        tieY + 10,
      )
      ..lineTo(left ? r.right - r.width * 0.15 : r.left + r.width * 0.15, r.bottom)
      ..lineTo(left ? r.left + r.width * 0.05 : r.right - r.width * 0.05, r.bottom)
      ..quadraticBezierTo(r.center.dx, tieY + 14, r.left, tieY - 6)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: const [Color(0xFFF08A9C), Color(0xFFF6A9B6), Color(0xFFEE7F93)],
        ).createShader(r),
    );
    final fold = Paint()
      ..color = const Color(0xFFD86A80).withValues(alpha: 0.45)
      ..strokeWidth = 1.8;
    for (var i = 1; i < 4; i++) {
      final x = r.left + r.width * i / 4;
      canvas.drawLine(Offset(x, r.top + 4), Offset(x + inward * 2, tieY - 8), fold);
      canvas.drawLine(Offset(x, tieY + 14), Offset(x + inward * 3, r.bottom - 2), fold);
    }
    // Tie-back band
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(r.center.dx, tieY), width: r.width * 0.95, height: 11),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFF7CD62),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(r.center.dx, tieY - 2), width: r.width * 0.95, height: 3),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _drawShelfPlant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Small wooden stand + blue pot with a leafy plant (left wall).
    final stand = Rect.fromLTWH(-4, h * 0.398, w * 0.1, h * 0.012);
    canvas.drawRRect(
      RRect.fromRectAndRadius(stand, const Radius.circular(3)),
      Paint()..color = const Color(0xFFB98456),
    );
    final pot = Rect.fromLTWH(w * 0.003, h * 0.372, w * 0.062, h * 0.028);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pot, const Radius.circular(5)),
      Paint()..color = const Color(0xFF6FA8DC),
    );
    canvas.drawRect(
      Rect.fromLTWH(pot.left, pot.top, pot.width, 5),
      Paint()..color = const Color(0xFF8FC0EA),
    );
    _leaves(canvas, Offset(pot.center.dx, pot.top), 60, const Color(0xFF5FA85A));
  }

  void _leaves(Canvas canvas, Offset base, double len, Color c) {
    for (final (ang, l) in [(-1.0, 0.85), (-0.5, 1.0), (0.0, 0.95), (0.5, 1.0), (1.0, 0.85), (-1.4, 0.6), (1.4, 0.6)]) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(ang);
      final ll = len * l;
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-ll * 0.26, -ll * 0.5, 0, -ll)
        ..quadraticBezierTo(ll * 0.26, -ll * 0.5, 0, 0)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [Color.lerp(c, Colors.black, 0.2)!, Color.lerp(c, Colors.white, 0.15)!],
          ).createShader(Rect.fromLTWH(-ll * 0.3, -ll, ll * 0.6, ll)),
      );
      canvas.drawLine(
        Offset.zero,
        Offset(0, -ll * 0.9),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  // --- Balloons -----------------------------------------------------------

  void _balloon(Canvas canvas, Offset c, double w, double h, Color color, {double sway = 0, bool string = true}) {
    if (string) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy + h * 0.5)
          ..quadraticBezierTo(c.dx - 8 + sway, c.dy + h * 0.8, c.dx + 4 + sway, c.dy + h * 1.15),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
    final oval = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawOval(
      oval,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [
            Color.lerp(color, Colors.white, 0.5)!,
            color,
            Color.lerp(color, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(oval),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-w * 0.2, -h * 0.24), width: w * 0.2, height: h * 0.16),
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
    // Knot
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + h * 0.5)
        ..lineTo(c.dx - 4, c.dy + h * 0.5 + 6)
        ..lineTo(c.dx + 4, c.dy + h * 0.5 + 6)
        ..close(),
      Paint()..color = Color.lerp(color, Colors.black, 0.15)!,
    );
  }

  double _sway(double seed) =>
      reducedMotion ? 0 : math.sin(envPhase * 1.4 + seed) * 3 * intensity;

  void _drawTopBalloons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Around both ends of the banner.
    _balloon(canvas, Offset(w * 0.09, h * 0.128), w * 0.10, h * 0.062, const Color(0xFFF48FB1), sway: _sway(1));
    _balloon(canvas, Offset(w * 0.14, h * 0.098), w * 0.09, h * 0.056, const Color(0xFF7FB8EC), sway: _sway(2));
    _balloon(canvas, Offset(w * 0.16, h * 0.13), w * 0.075, h * 0.05, const Color(0xFFFFE07A), sway: _sway(3));
    _balloon(canvas, Offset(w * 0.88, h * 0.09), w * 0.085, h * 0.06, const Color(0xFFF07C98), sway: _sway(4));
    _balloon(canvas, Offset(w * 0.83, h * 0.115), w * 0.075, h * 0.05, const Color(0xFF7FB8EC), sway: _sway(5));
    _balloon(canvas, Offset(w * 0.91, h * 0.118), w * 0.07, h * 0.048, const Color(0xFFFFE07A), sway: _sway(6));
  }

  void _drawWallBalloons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _balloon(canvas, Offset(w * 0.906, h * 0.277), w * 0.09, h * 0.055, const Color(0xFFEC6A5E), sway: _sway(7));
    _balloon(canvas, Offset(w * 0.935, h * 0.33), w * 0.075, h * 0.05, const Color(0xFF5DBB90), sway: _sway(8));
  }

  void _drawLowerBalloons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _balloon(canvas, Offset(w * 0.088, h * 0.476), w * 0.11, h * 0.068, const Color(0xFF7FB8EC), sway: _sway(9));
    _balloon(canvas, Offset(w * 0.16, h * 0.526), w * 0.105, h * 0.062, const Color(0xFFFFE07A), sway: _sway(10));
    _balloon(canvas, Offset(w * 0.028, h * 0.522), w * 0.09, h * 0.06, const Color(0xFFF48FB1), sway: _sway(11));
  }

  // --- Furniture and props ------------------------------------------------

  void _drawGiftBox(Canvas canvas, Offset c, double width) {
    final h = width * 0.78;
    final body = Rect.fromCenter(center: c, width: width, height: h);
    final lid = Rect.fromCenter(center: c + Offset(0, -h * 0.5), width: width * 1.08, height: h * 0.22);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, h * 0.55), width: width * 1.1, height: h * 0.2),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    // Stripes (green / pink / blue) like the party box.
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(body, const Radius.circular(6)));
    final colors = [0xFF7CC576, 0xFFF48FB1, 0xFF7FB8EC];
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(body.left + body.width * i / 3, body.top, body.width / 3 + 1, body.height),
        Paint()..color = Color(colors[i]),
      );
    }
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(lid, const Radius.circular(6)),
      Paint()..color = const Color(0xFFFFD86B),
    );
    // Ribbons + bow
    final ribbon = Paint()..color = const Color(0xFFFFCB47);
    canvas.drawRect(Rect.fromCenter(center: c, width: width * 0.14, height: h), ribbon);
    for (final dir in [-1.0, 1.0]) {
      final bow = Path()
        ..moveTo(c.dx, c.dy - h * 0.56)
        ..quadraticBezierTo(c.dx + dir * width * 0.32, c.dy - h * 0.98, c.dx + dir * width * 0.26, c.dy - h * 0.62)
        ..quadraticBezierTo(c.dx + dir * width * 0.14, c.dy - h * 0.5, c.dx, c.dy - h * 0.56)
        ..close();
      canvas.drawPath(bow, ribbon);
      canvas.drawPath(
        bow,
        Paint()
          ..color = const Color(0xFFE0A21B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
    canvas.drawCircle(c + Offset(0, -h * 0.56), 5, ribbon);
  }

  void _drawRightShelf(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wood = Paint()..color = const Color(0xFFC8935E);
    final woodDark = Paint()..color = const Color(0xFFA9743F);
    final shelf = Rect.fromLTWH(w * 0.842, h * 0.607, w * 0.16, h * 0.116);
    // Legs + shelves
    canvas.drawRect(Rect.fromLTWH(shelf.left, shelf.top, 8, shelf.height), woodDark);
    canvas.drawRect(Rect.fromLTWH(shelf.right - 8, shelf.top, 8, shelf.height), woodDark);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(shelf.left - 4, shelf.top, shelf.width + 8, 10), const Radius.circular(3)),
      wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(shelf.left - 4, shelf.top + shelf.height * 0.5, shelf.width + 8, 8), const Radius.circular(3)),
      wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(shelf.left - 4, shelf.bottom - 8, shelf.width + 8, 8), const Radius.circular(3)),
      wood,
    );
    // Plant on top
    final pot = Rect.fromCenter(center: Offset(shelf.center.dx + 6, shelf.top - 16), width: 40, height: 28);
    canvas.drawRRect(RRect.fromRectAndRadius(pot, const Radius.circular(5)), Paint()..color = const Color(0xFFF0B98D));
    _leaves(canvas, Offset(pot.center.dx, pot.top + 2), 64, const Color(0xFF5FA85A));
    // Small striped gift in the middle
    final g = Rect.fromLTWH(shelf.left + 14, shelf.top + shelf.height * 0.52 - 4, 66, 52);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(g, const Radius.circular(4)));
    canvas.drawRect(g, Paint()..color = const Color(0xFF8FB3EA));
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(g.left + i * 22.0 + 8, g.top, 10, g.height),
        Paint()..color = const Color(0xFFF7B0C4),
      );
    }
    canvas.restore();
    canvas.drawRect(Rect.fromCenter(center: g.center, width: 9, height: g.height), Paint()..color = const Color(0xFFFFCB47));
    canvas.drawRect(Rect.fromCenter(center: g.center - const Offset(0, 4), width: g.width, height: 8), Paint()..color = const Color(0xFFFFCB47));
    canvas.drawCircle(g.topCenter + const Offset(0, -3), 7, Paint()..color = const Color(0xFFFFCB47));
  }

  void _drawRug(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.485, size.height * 0.873);
    final rx = size.width * 0.285;
    final ry = size.height * 0.048;
    final outer = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      outer.shift(const Offset(0, 8)),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawOval(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7B3C4), Color(0xFFF298AE)],
        ).createShader(outer),
    );
    canvas.drawOval(
      outer.deflate(rx * 0.1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawOval(
      outer.deflate(rx * 0.2),
      Paint()..color = const Color(0xFFF9C4D1),
    );
    canvas.drawOval(
      outer,
      Paint()
        ..color = const Color(0xFFE0788F).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawBall(Canvas canvas, Offset c, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 0.95), width: r * 1.9, height: r * 0.4),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawRect(Rect.fromCircle(center: c, radius: r), Paint()..color = const Color(0xFFF7F0E4));
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.5);
    const colors = [0xFFF48FB1, 0xFFFFE07A, 0xFF7CC576, 0xFF7FB8EC];
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-r, -r * 0.7 + i * r * 0.36, r * 2, r * 0.22),
        Paint()..color = Color(colors[i]),
      );
    }
    canvas.restore();
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-r * 0.35, -r * 0.4), width: r * 0.5, height: r * 0.3),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.16)],
          stops: const [0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    void block(Offset c, double s, Color face, Color top, Color side, bool star, double rot) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: s, height: s), const Radius.circular(6)),
        Paint()..color = face,
      );
      // top and side bevels
      canvas.drawPath(
        Path()
          ..moveTo(-s / 2, -s / 2)
          ..lineTo(s / 2, -s / 2)
          ..lineTo(s / 2 - 8, -s / 2 + 9)
          ..lineTo(-s / 2 + 8, -s / 2 + 9)
          ..close(),
        Paint()..color = top,
      );
      canvas.drawPath(
        Path()
          ..moveTo(s / 2, -s / 2)
          ..lineTo(s / 2, s / 2)
          ..lineTo(s / 2 - 8, s / 2 - 6)
          ..lineTo(s / 2 - 8, -s / 2 + 9)
          ..close(),
        Paint()..color = side,
      );
      if (star) {
        final p = Path();
        for (var i = 0; i < 5; i++) {
          final a = -math.pi / 2 + i * 4 * math.pi / 5;
          final pt = Offset(math.cos(a) * s * 0.28, math.sin(a) * s * 0.28 + 3);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
        canvas.drawPath(p, Paint()..color = const Color(0xFFFFD54F));
      } else {
        _heart(canvas, const Offset(0, 4), s * 0.2, const Color(0xFFFFD54F));
      }
      canvas.restore();
    }

    block(Offset(w * 0.1, h * 0.885), w * 0.095, const Color(0xFF6FA6DD), const Color(0xFF93BDEA), const Color(0xFF558FCB), false, -0.05);
    block(Offset(w * 0.16, h * 0.915), w * 0.095, const Color(0xFFB868C9), const Color(0xFFCE8BDB), const Color(0xFF9A4DAE), true, 0.05);
  }

  void _drawFloorPlant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pot = Path()
      ..moveTo(w * 0.83, h * 0.92)
      ..lineTo(w * 0.94, h * 0.92)
      ..lineTo(w * 0.925, h * 0.975)
      ..lineTo(w * 0.845, h * 0.975)
      ..close();
    canvas.drawPath(pot, Paint()..color = const Color(0xFFD9825B));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.822, h * 0.912, w * 0.128, h * 0.014), const Radius.circular(4)),
      Paint()..color = const Color(0xFFE79A72),
    );
    _leaves(canvas, Offset(w * 0.885, h * 0.914), h * 0.13, const Color(0xFF5FA85A));
  }

  void _drawConfetti(Canvas canvas, Size size) {
    final drift = reducedMotion ? 0.0 : math.sin(envPhase * 0.8) * 4;
    const spots = <(double, double, int, double)>[
      (0.29, 0.34, 0, 0.5), (0.37, 0.4, 3, 0.9), (0.06, 0.22, 1, -0.5),
      (0.96, 0.05, 1, 0.4), (0.75, 0.42, 3, 0.2), (0.44, 0.46, 3, -0.3),
      (0.56, 0.52, 1, 0.7), (0.28, 0.56, 0, 0.3), (0.76, 0.6, 4, 0.5),
      (0.53, 0.59, 2, 0.4), (0.25, 0.7, 2, 0.6), (0.8, 0.78, 3, -0.6),
      (0.76, 0.66, 4, 0.9), (0.07, 0.7, 1, 0.5), (0.34, 0.9, 1, 0.2),
      (0.68, 0.95, 5, 0.6), (0.68, 0.03, 1, 0.3), (0.55, 0.06, 2, 0.5),
      (0.93, 0.78, 3, 0.8), (0.2, 0.93, 0, 0.4),
    ];
    for (var i = 0; i < spots.length; i++) {
      final (nx, ny, ci, rot) = spots[i];
      final c = Offset(size.width * nx, size.height * ny + drift * (i.isEven ? 1 : -1));
      final color = Color(_confettiColors[ci % _confettiColors.length]);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      if (i % 5 == 0) {
        // Little star
        final p = Path();
        for (var k = 0; k < 5; k++) {
          final a = -math.pi / 2 + k * 4 * math.pi / 5;
          final pt = Offset(math.cos(a) * 7, math.sin(a) * 7);
          k == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
        canvas.drawPath(p, Paint()..color = color);
      } else if (i % 4 == 1) {
        canvas.drawPath(
          Path()
            ..moveTo(0, -6)
            ..lineTo(5, 0)
            ..lineTo(0, 6)
            ..lineTo(-5, 0)
            ..close(),
          Paint()..color = color,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 12, height: 7), const Radius.circular(1.5)),
          Paint()..color = color,
        );
      }
      canvas.restore();
    }
  }

  void _drawWarmGlow(Canvas canvas, Size size, double evening) {
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.5,
      Paint()..color = const Color(0xFFFFB74D).withValues(alpha: 0.08 * evening),
    );
  }

  @override
  bool shouldRepaint(covariant _PartyRoomPainter old) =>
      old.eveningFactor != eveningFactor ||
      old.envPhase != envPhase ||
      old.reducedMotion != reducedMotion;
}
