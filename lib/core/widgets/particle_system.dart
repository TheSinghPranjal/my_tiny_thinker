import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
    required this.maxLife,
  });

  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double life;
  double maxLife;
}

class ParticleSystem extends StatefulWidget {
  const ParticleSystem({
    super.key,
    required this.particleCount,
    this.colors = AppColors.bubbleColors,
    this.duration = const Duration(milliseconds: 800),
    this.origin,
    this.autoStart = true,
  });

  final int particleCount;
  final List<Color> colors;
  final Duration duration;
  final Offset? origin;
  final bool autoStart;

  @override
  State<ParticleSystem> createState() => ParticleSystemState();
}

class ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.autoStart) {
      _emit();
    }
  }

  void emit({Offset? origin}) {
    _emit(origin: origin);
  }

  void _emit({Offset? origin}) {
    _particles.clear();
    final ox = origin?.dx ?? 0;
    final oy = origin?.dy ?? 0;
    for (var i = 0; i < widget.particleCount; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 2 + _random.nextDouble() * 6;
      final life = 0.5 + _random.nextDouble() * 0.5;
      _particles.add(
        Particle(
          x: ox,
          y: oy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: widget.colors[_random.nextInt(widget.colors.length)],
          size: 4 + _random.nextDouble() * 8,
          life: life,
          maxLife: life,
        ),
      );
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        for (final p in _particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.15;
          p.life -= 0.016;
        }
        _particles.removeWhere((p) => p.life <= 0);
        return CustomPaint(
          painter: _ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles);

  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * opacity, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 80,
  });

  final Duration duration;
  final int particleCount;

  @override
  State<ConfettiWidget> createState() => ConfettiWidgetState();
}

class ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _initPieces();
  }

  void _initPieces() {
    _pieces = List.generate(widget.particleCount, (i) {
      return _ConfettiPiece(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        speed: 0.3 + _random.nextDouble() * 0.5,
        wobble: _random.nextDouble() * math.pi * 2,
        color: AppColors.rainbow[_random.nextInt(AppColors.rainbow.length)],
        size: 6 + _random.nextDouble() * 8,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
      );
    });
  }

  void restart() {
    _initPieces();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiPiece {
  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.speed,
    required this.wobble,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  double x;
  double y;
  final double speed;
  final double wobble;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_ConfettiPiece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final y = (piece.y + progress * piece.speed) * size.height;
      if (y > size.height) continue;
      final x = piece.x * size.width +
          math.sin(progress * math.pi * 4 + piece.wobble) * 20;
      piece.rotation += piece.rotationSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation);
      final paint = Paint()..color = piece.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
