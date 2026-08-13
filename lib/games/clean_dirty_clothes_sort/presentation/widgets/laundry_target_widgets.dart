import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/clean_dirty_clothes_sort/models/clean_dirty_clothes_sort_models.dart';

class WashingMachineWidget extends StatelessWidget {
  const WashingMachineWidget({
    super.key,
    required this.target,
    required this.size,
    this.hovering = false,
  });

  final LaundryTarget target;
  final double size;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    final highlighted = hovering || target.glow || target.happy;
    final bounce = target.happy ? -math.sin(target.idlePhase * 4).abs() * 8 : 0.0;
    final wobble = target.wobble ? math.sin(target.idlePhase * 8) * 0.04 : 0.0;
    final scale = 1.0 + (highlighted ? 0.05 : 0) + math.sin(target.idlePhase) * 0.01;

    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.rotate(
        angle: wobble,
        child: Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label('Dirty Clothes', const Color(0xFF42A5F5)),
              SizedBox(height: size * 0.04),
              SizedBox(
                width: size,
                height: size * 0.72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size * 0.72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(size * 0.08),
                        border: Border.all(
                          color: highlighted
                              ? const Color(0xFF42A5F5)
                              : const Color(0xFF90A4AE),
                          width: highlighted ? 4 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF42A5F5)
                                .withValues(alpha: highlighted ? 0.35 : 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(size * 0.04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _dot(const Color(0xFFEF5350)),
                                _dot(const Color(0xFFFFEE58)),
                                _dot(const Color(0xFF66BB6A)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: size * 0.45,
                                height: size * 0.45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFB3E5FC)
                                      .withValues(alpha: 0.6),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: target.washing
                                      ? Text(
                                          '🫧',
                                          style: TextStyle(
                                            fontSize: size * 0.2,
                                          ),
                                        )
                                      : Text(
                                          '😊',
                                          style: TextStyle(
                                            fontSize: size * 0.18,
                                          ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.08,
        vertical: size * 0.025,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.075,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: size * 0.06,
        height: size * 0.06,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class CupboardWidget extends StatelessWidget {
  const CupboardWidget({
    super.key,
    required this.target,
    required this.size,
    this.hovering = false,
  });

  final LaundryTarget target;
  final double size;
  final bool hovering;

  @override
  Widget build(BuildContext context) {
    final highlighted = hovering || target.glow || target.happy;
    final bounce = target.happy ? -math.sin(target.idlePhase * 4).abs() * 8 : 0.0;
    final wobble = target.wobble ? math.sin(target.idlePhase * 8) * 0.04 : 0.0;
    final scale = 1.0 + (highlighted ? 0.05 : 0) + math.sin(target.idlePhase) * 0.01;
    final doorOpen = target.happy ? 0.12 : 0.0;

    return Transform.translate(
      offset: Offset(0, bounce),
      child: Transform.rotate(
        angle: wobble,
        child: Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _label('Clean Clothes', const Color(0xFF66BB6A)),
              SizedBox(height: size * 0.04),
              SizedBox(
                width: size,
                height: size * 0.72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size * 0.72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8D6E63),
                        borderRadius: BorderRadius.circular(size * 0.06),
                        border: Border.all(
                          color: highlighted
                              ? const Color(0xFF66BB6A)
                              : const Color(0xFF5D4037),
                          width: highlighted ? 4 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF66BB6A)
                                .withValues(alpha: highlighted ? 0.35 : 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: size * 0.08,
                            top: size * 0.12,
                            child: Transform.rotate(
                              angle: -doorOpen,
                              child: _door(size, left: true),
                            ),
                          ),
                          Positioned(
                            right: size * 0.08,
                            top: size * 0.12,
                            child: Transform.rotate(
                              angle: doorOpen,
                              child: _door(size, left: false),
                            ),
                          ),
                          if (target.happy)
                            Center(
                              child: Text(
                                '✨',
                                style: TextStyle(fontSize: size * 0.16),
                              ),
                            ),
                        ],
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

  Widget _door(double size, {required bool left}) {
    return Container(
      width: size * 0.38,
      height: size * 0.52,
      decoration: BoxDecoration(
        color: const Color(0xFFA1887F),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(left ? 8 : 2),
          right: Radius.circular(left ? 2 : 8),
        ),
        border: Border.all(color: const Color(0xFF5D4037), width: 2),
      ),
      child: Align(
        alignment: left ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEE58),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.08,
        vertical: size * 0.025,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.075,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
