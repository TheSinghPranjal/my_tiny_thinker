import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/theme/colors/app_colors.dart';

class ClassicMemoryFlipCard extends StatefulWidget {
  const ClassicMemoryFlipCard({
    super.key,
    required this.face,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
    this.isWrong = false,
  });

  final String face;
  final bool isFlipped;
  final bool isMatched;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  State<ClassicMemoryFlipCard> createState() => _ClassicMemoryFlipCardState();
}

class _ClassicMemoryFlipCardState extends State<ClassicMemoryFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: (widget.isFlipped || widget.isMatched) ? 1 : 0,
    );
  }

  bool get isFaceUp => widget.isFlipped || widget.isMatched;

  @override
  void didUpdateWidget(covariant ClassicMemoryFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasUp = oldWidget.isFlipped || oldWidget.isMatched;
    final isUp = isFaceUp;
    if (wasUp != isUp) {
      if (isUp) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * math.pi;
          final showFront = angle >= math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      matched: widget.isMatched,
                      wrong: widget.isWrong,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size =
                              (constraints.biggest.shortestSide * 0.48)
                                  .clamp(28.0, 72.0);
                          return Text(
                            widget.face,
                            style: TextStyle(fontSize: size),
                          );
                        },
                      ),
                    ),
                  )
                : const _CardBack(),
          );
        },
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7E57C2),
            Color(0xFF42A5F5),
            Color(0xFF26C6DA),
          ],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size =
              (constraints.biggest.shortestSide * 0.4).clamp(24.0, 56.0);
          return Center(
            child: Text('❓', style: TextStyle(fontSize: size)),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.child,
    required this.matched,
    required this.wrong,
  });

  final Widget child;
  final bool matched;
  final bool wrong;

  @override
  Widget build(BuildContext context) {
    final border = wrong
        ? AppColors.error
        : matched
            ? AppColors.mintGreen
            : Colors.white;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.95),
        border: Border.all(color: border, width: 3),
        boxShadow: [
          BoxShadow(
            color: (matched ? AppColors.mintGreen : AppColors.candyPink)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
