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
    double topPadding = 100,
    double bottomPadding = 40,
  }) {
    final bubbles = <BubbleEntity>[];
    final minDim = math.min(playArea.width, playArea.height);
    final baseRadius =
        BubbleNumberGenerator.radiusForDifficulty(difficulty, minDim);
    final speed = BubbleNumberGenerator.speedForDifficulty(difficulty) *
        speedMultiplier;

    for (var i = 0; i < numbers.length; i++) {
      var placed = false;
      var attempts = 0;
      while (!placed && attempts < 50) {
        final radius = difficulty == Difficulty.expert
            ? baseRadius * (0.7 + _random.nextDouble() * 0.6)
            : baseRadius;
        final x = radius +
            _random.nextDouble() * (playArea.width - radius * 2);
        final y = topPadding +
            radius +
            _random.nextDouble() *
                (playArea.height - topPadding - bottomPadding - radius * 2);

        final overlaps = bubbles.any((b) {
          final dx = b.x - x;
          final dy = b.y - y;
          final dist = math.sqrt(dx * dx + dy * dy);
          return dist < b.radius + radius + 8;
        });

        if (!overlaps) {
          final angle = _random.nextDouble() * math.pi * 2;
          final vel = speed * (0.5 + _random.nextDouble() * 0.5);
          bubbles.add(
            BubbleEntity(
              id: _nextId(),
              number: numbers[i],
              x: x,
              y: y,
              vx: math.cos(angle) * vel,
              vy: math.sin(angle) * vel,
              radius: radius,
              colorIndex: i % 6,
              rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
            ),
          );
          placed = true;
        }
        attempts++;
      }
    }
    return bubbles;
  }

  List<BubbleEntity> update({
    required List<BubbleEntity> bubbles,
    required Size playArea,
    required double deltaTime,
    double topPadding = 100,
    double bottomPadding = 40,
  }) {
    final updated = <BubbleEntity>[];
    final active = bubbles.where((b) => !b.isPopping).toList();

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
        vx = -vx * 0.95;
        x = x.clamp(minX, maxX);
      }
      if (y <= minY || y >= maxY) {
        vy = -vy * 0.95;
        y = y.clamp(minY, maxY);
      }

      // Soft repulsion
      for (final other in active) {
        if (other.id == bubble.id) continue;
        final dx = other.x - x;
        final dy = other.y - y;
        final dist = math.sqrt(dx * dx + dy * dy);
        final minDist = bubble.radius + other.radius + 4;
        if (dist < minDist && dist > 0) {
          final overlap = minDist - dist;
          final nx = dx / dist;
          final ny = dy / dist;
          x -= nx * overlap * 0.3;
          y -= ny * overlap * 0.3;
          vx -= nx * 0.5;
          vy -= ny * 0.5;
        }
      }

      // Gradual velocity smoothing
      vx *= 0.999;
      vy *= 0.999;
      final speed = math.sqrt(vx * vx + vy * vy);
      if (speed < 0.3) {
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

    // Keep popping bubbles briefly
    updated.addAll(bubbles.where((b) => b.isPopping));
    return updated;
  }
}
