import 'package:flutter/material.dart';

/// Cosy nursery-style room: peach wall with an arched window, a wooden floor
/// and a big pink rug for Teddy.
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
          painter: _PartyRoomPainter(eveningFactor: eveningFactor),
        ),
        child,
      ],
    );
  }
}

class _PartyRoomPainter extends CustomPainter {
  _PartyRoomPainter({required this.eveningFactor});

  final double eveningFactor;

  static const _floorFrac = 0.415;
  static const _stepFrac = 0.615;

  @override
  void paint(Canvas canvas, Size size) {
    final evening = eveningFactor.clamp(0.0, 1.0);
    _wall(canvas, size, evening);
    _window(canvas, size, evening);
    _floor(canvas, size, evening);
    _rug(canvas, size);
    if (evening > 0.15) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.45),
        size.width * 0.5,
        Paint()..color = const Color(0xFFFFB74D).withValues(alpha: 0.08 * evening),
      );
    }
  }

  void _wall(Canvas canvas, Size size, double evening) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * _floorFrac + 4);
    final top = Color.lerp(const Color(0xFFFCE8D5), const Color(0xFF5D4037), evening * 0.45)!;
    final bottom = Color.lerp(const Color(0xFFF8DBBC), const Color(0xFF3E2723), evening * 0.5)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
  }

  void _window(Canvas canvas, Size size, double evening) {
    final w = size.width;
    final h = size.height;
    final glass = Rect.fromLTWH(w * 0.445, h * 0.165, w * 0.375, h * 0.225);
    final arch = Path()
      ..moveTo(glass.left, glass.bottom)
      ..lineTo(glass.left, glass.top + glass.width / 2)
      ..arcToPoint(
        Offset(glass.right, glass.top + glass.width / 2),
        radius: Radius.circular(glass.width / 2),
      )
      ..lineTo(glass.right, glass.bottom)
      ..close();

    // Soft frame glow
    canvas.drawPath(
      arch,
      Paint()
        ..color = const Color(0xFFF1D9C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.save();
    canvas.clipPath(arch);
    canvas.drawRect(
      glass.inflate(4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF9CCBF0), const Color(0xFF1A237E), evening * 0.55)!,
            Color.lerp(const Color(0xFFCFE8F8), const Color(0xFF283593), evening * 0.55)!,
          ],
        ).createShader(glass),
    );
    // Clouds and blurred trees outside.
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(glass.left + glass.width * 0.28, glass.top + glass.height * 0.34), 24, cloud);
    canvas.drawCircle(Offset(glass.left + glass.width * 0.4, glass.top + glass.height * 0.3), 30, cloud);
    canvas.drawCircle(Offset(glass.left + glass.width * 0.78, glass.top + glass.height * 0.5), 20, cloud);
    canvas.drawCircle(Offset(glass.left + glass.width * 0.88, glass.top + glass.height * 0.48), 26, cloud);
    for (final (dx, dy, r, c) in [
      (0.28, 0.9, 50.0, 0xFF6DBB62),
      (0.5, 1.02, 60.0, 0xFF5FAE58),
      (0.85, 0.92, 46.0, 0xFF7CC66E),
    ]) {
      canvas.drawCircle(
        Offset(glass.left + glass.width * dx, glass.top + glass.height * dy),
        r,
        Paint()
          ..color = Color(c)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.restore();
    // Centre mullion
    canvas.drawLine(
      Offset(glass.center.dx, glass.top + 20),
      Offset(glass.center.dx, glass.bottom),
      Paint()
        ..color = const Color(0xFFF1D9C0)
        ..strokeWidth = 7,
    );
    // Sill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(glass.left - 14, glass.bottom + 2, glass.width + 28, 14),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF1D9C0),
    );

    // Sheer curtains on each side.
    for (final left in [true, false]) {
      final x0 = left ? glass.left - 34 : glass.right + 4;
      final r = Rect.fromLTWH(x0, glass.top + 30, 32, glass.height + 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(14)),
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFFF7D9D2).withValues(alpha: left ? 0.35 : 0.85),
              const Color(0xFFF2C6BE).withValues(alpha: left ? 0.15 : 0.6),
            ],
          ).createShader(r),
      );
    }
  }

  void _floor(Canvas canvas, Size size, double evening) {
    final w = size.width;
    final h = size.height;
    final y = h * _floorFrac;
    final rect = Rect.fromLTWH(0, y, w, h - y);
    final top = Color.lerp(const Color(0xFFF6D3A2), const Color(0xFF6D4C41), evening * 0.4)!;
    final bottom = Color.lerp(const Color(0xFFE7B47C), const Color(0xFF4E342E), evening * 0.45)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    // Baseboard with a soft shadow beneath.
    canvas.drawRect(
      Rect.fromLTWH(0, y - 14, w, 16),
      Paint()..color = const Color(0xFFFBEBD8),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, y + 2, w, 18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB98A5E).withValues(alpha: 0.28),
            const Color(0xFFB98A5E).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y, w, 20)),
    );
    // Faint plank seams
    final seam = Paint()
      ..color = const Color(0xFFB98A5E).withValues(alpha: 0.14)
      ..strokeWidth = 1.4;
    for (var i = 1; i < 16; i++) {
      final yy = y + i * (h - y) / 16;
      canvas.drawLine(Offset(0, yy), Offset(w, yy), seam);
    }
    // A gentle step: lighter top edge and a darker lower floor.
    final step = h * _stepFrac;
    canvas.drawRect(
      Rect.fromLTWH(0, step, w, h - step),
      Paint()..color = const Color(0xFFD9A46B).withValues(alpha: 0.35),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, step - 3, w, 6),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _rug(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.878);
    final rx = size.width * 0.455;
    final ry = size.height * 0.068;
    final outer = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      outer.shift(const Offset(0, 9)),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawOval(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6B3C5), Color(0xFFF09DB4)],
        ).createShader(outer),
    );
    canvas.drawOval(
      outer.deflate(rx * 0.09),
      Paint()..color = const Color(0xFFF9C6D3),
    );
    canvas.drawOval(
      outer.deflate(rx * 0.16),
      Paint()..color = const Color(0xFFF4A9BE),
    );
    canvas.drawOval(
      outer,
      Paint()
        ..color = const Color(0xFFE38AA4).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PartyRoomPainter old) =>
      old.eveningFactor != eveningFactor;
}
