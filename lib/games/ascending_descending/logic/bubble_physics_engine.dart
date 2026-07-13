import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/ascending_descending/logic/bubble_game_logic.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_game_models.dart';

class BubblePhysicsEngine {
  BubblePhysicsEngine({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;
  int _idCounter = 0;

  String _nextId() => 'bubble_${_idCounter++}_${_random.nextInt(99999)}';

  List<BubbleEntity> spawnBubbles({
    required List<int> numbers,
    required Size playArea,
    required Difficulty difficulty,
    required double speedMultiplier,
    bool toddlerMode = false,
    double topPadding = 16,
    double bottomPadding = 16,
  }) {
    if (playArea.width <= 0 || playArea.height <= 0) return [];
    if (numbers.isEmpty) return [];

    final count = numbers.length;
    final cols = toddlerMode
        ? 2
        : count <= 6
            ? 3
            : count <= 12
                ? 4
                : 5;
    final rows = (count / cols).ceil();

    final usableW = playArea.width;
    final usableH = playArea.height - topPadding - bottomPadding;
    final cellW = usableW / cols;
    final cellH = usableH / rows;

    // Size bubbles to fit the grid with padding between cells.
    final maxFromCell = math.min(cellW, cellH) * 0.42;
    final minDim = math.min(playArea.width, playArea.height);
    final baseRadius =
        BubbleNumberGenerator.radiusForDifficulty(difficulty, minDim);
    final radius = toddlerMode
        ? math.min(maxFromCell, baseRadius * 1.15).clamp(36.0, 72.0)
        : math.min(maxFromCell, baseRadius).clamp(28.0, 56.0);

    final speed = (toddlerMode ? 0.4 : 1.0) *
        BubbleNumberGenerator.speedForDifficulty(difficulty) *
        speedMultiplier;

    final bubbles = <BubbleEntity>[];

    for (var i = 0; i < count; i++) {
      final col = i % cols;
      final row = i ~/ cols;

      // Grid center + small jitter so bubbles feel alive but stay separated.
      final jitterX = toddlerMode ? 0 : (_random.nextDouble() - 0.5) * cellW * 0.15;
      final jitterY = toddlerMode ? 0 : (_random.nextDouble() - 0.5) * cellH * 0.15;

      final x = (col + 0.5) * cellW + jitterX;
      final y = topPadding + (row + 0.5) * cellH + jitterY;

      bubbles.add(
        _createBubble(
          number: numbers[i],
          x: x.clamp(radius, usableW - radius),
          y: y.clamp(topPadding + radius, playArea.height - bottomPadding - radius),
          radius: radius,
          speed: speed,
          colorIndex: i % 6,
        ),
      );
    }

    return bubbles;
  }

  BubbleEntity _createBubble({
    required int number,
    required double x,
    required double y,
    required double radius,
    required double speed,
    required int colorIndex,
  }) {
    final angle = _random.nextDouble() * math.pi * 2;
    final vel = speed * (0.6 + _random.nextDouble() * 0.4);
    return BubbleEntity(
      id: _nextId(),
      number: number,
      x: x,
      y: y,
      vx: math.cos(angle) * vel,
      vy: math.sin(angle) * vel,
      radius: radius,
      colorIndex: colorIndex,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.015,
    );
  }

  List<BubbleEntity> update({
    required List<BubbleEntity> bubbles,
    required Size playArea,
    required double deltaTime,
    double topPadding = 16,
    double bottomPadding = 16,
  }) {
    if (playArea.width <= 0 || playArea.height <= 0) return bubbles;

    final updated = <BubbleEntity>[];
    final active = bubbles.where((b) => !b.isPopping).toList(growable: false);

    for (final bubble in active) {
      var x = bubble.x + bubble.vx * deltaTime * 60;
      var y = bubble.y + bubble.vy * deltaTime * 60;
      var vx = bubble.vx;
      var vy = bubble.vy;

      final minY = topPadding + bubble.radius;
      final maxY = playArea.height - bottomPadding - bubble.radius;
      final minX = bubble.radius;
      final maxX = playArea.width - bubble.radius;

      if (x <= minX || x >= maxX) {
        vx = -vx * 0.92;
        x = x.clamp(minX, maxX);
      }
      if (y <= minY || y >= maxY) {
        vy = -vy * 0.92;
        y = y.clamp(minY, maxY);
      }

      // Gentle separation so bubbles don't stack on top of each other.
      for (final other in active) {
        if (other.id == bubble.id) continue;
        final dx = other.x - x;
        final dy = other.y - y;
        final distSq = dx * dx + dy * dy;
        final minDist = bubble.radius + other.radius + 6;
        if (distSq < minDist * minDist && distSq > 0.01) {
          final dist = math.sqrt(distSq);
          final overlap = (minDist - dist) * 0.35;
          final nx = dx / dist;
          final ny = dy / dist;
          x -= nx * overlap;
          y -= ny * overlap;
        }
      }

      x = x.clamp(minX, maxX);
      y = y.clamp(minY, maxY);

      vx *= 0.998;
      vy *= 0.998;
      final speed = math.sqrt(vx * vx + vy * vy);
      if (speed < 0.2) {
        final angle = _random.nextDouble() * math.pi * 2;
        vx = math.cos(angle) * 0.5;
        vy = math.sin(angle) * 0.5;
      }

      updated.add(
        bubble.copyWith(
          x: x,
          y: y,
          vx: vx,
          vy: vy,
          rotation: bubble.rotation + bubble.rotationSpeed,
        ),
      );
    }

    updated.addAll(bubbles.where((b) => b.isPopping));
    return updated;
  }
}
