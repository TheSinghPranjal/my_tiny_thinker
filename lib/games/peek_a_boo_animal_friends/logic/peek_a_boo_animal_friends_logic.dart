import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/peek_a_boo_animal_friends/models/peek_a_boo_animal_friends_models.dart';
import 'package:my_tiny_thinker/games/shared/peek_a_boo_animals.dart';

abstract final class PeekABooLogic {
  static final random = math.Random();

  static List<BushEntity> spawnBushes(Size area, int count) {
    final bushCount = count.clamp(2, 10);
    final bushWidth = area.width / (bushCount + 0.5);
    final bushHeight = math.min(area.height * 0.38, bushWidth * 1.15);
    final baseY = area.height * 0.72;
    final bushes = <BushEntity>[];

    for (var i = 0; i < bushCount; i++) {
      final cx = (i + 0.75) * (area.width / bushCount);
      bushes.add(
        BushEntity(
          id: 'bush_$i',
          centerX: cx,
          centerY: baseY,
          width: bushWidth * 0.88,
          height: bushHeight,
          colorIndex: i,
          shakeTimer: 3 + random.nextDouble() * 2,
          swayPhase: random.nextDouble() * math.pi * 2,
        ),
      );
    }
    return bushes;
  }

  static List<AnimalEntity> assignHiddenAnimals({
    required List<BushEntity> bushes,
    required int animalCount,
    Set<String> excludeAnimalIds = const {},
  }) {
    if (bushes.isEmpty) return [];

    final availableBushes = bushes
        .where((b) => !b.hasAnimal && b.visualPhase != BushVisualPhase.opening)
        .toList();
    if (availableBushes.isEmpty) return [];

    final count = animalCount.clamp(1, availableBushes.length);
    final pickedBushes = List<BushEntity>.from(availableBushes)..shuffle(random);
    final animals = <AnimalEntity>[];

    for (var i = 0; i < count && i < pickedBushes.length; i++) {
      final bush = pickedBushes[i];
      final animalDef = _pickRandomAnimal(excludeAnimalIds);
      animals.add(
        AnimalEntity(
          id: 'animal_${DateTime.now().microsecondsSinceEpoch}_$i',
          bushId: bush.id,
          animalId: animalDef.id,
          phase: AnimalPhase.hidden,
          x: bush.centerX,
          y: bush.centerY - bush.height * 0.15,
          exitAngle: random.nextDouble() * math.pi * 2,
        ),
      );
    }
    return animals;
  }

  static PeekAnimalDef _pickRandomAnimal(Set<String> exclude) {
    final pool = PeekABooAnimals.all
        .where((a) => !exclude.contains(a.id))
        .toList(growable: false);
    if (pool.isEmpty) return PeekABooAnimals.all[random.nextInt(PeekABooAnimals.all.length)];
    return pool[random.nextInt(pool.length)];
  }

  static List<BushEntity> syncBushAnimalFlags(
    List<BushEntity> bushes,
    List<AnimalEntity> animals,
  ) {
    return bushes.map((b) {
      final hasHidden = animals.any(
        (a) =>
            a.bushId == b.id &&
            (a.phase == AnimalPhase.hidden ||
                a.phase == AnimalPhase.popping ||
                a.phase == AnimalPhase.visible),
      );
      return b.copyWith(hasAnimal: hasHidden);
    }).toList();
  }

  static BushEntity updateBush(
    BushEntity bush,
    double delta,
    PeekABooSettings settings,
  ) {
    final intensity = settings.reducedMotion ? 0.4 : settings.animationIntensity;
    var updated = bush.copyWith(
      swayPhase: bush.swayPhase + delta * 1.2 * intensity,
    );

    if (updated.bounceProgress > 0) {
      final bounce = (updated.bounceProgress - delta * 2.5 * settings.animSpeedMult)
          .clamp(0.0, 1.0);
      updated = updated.copyWith(
        bounceProgress: bounce,
        visualPhase: bounce > 0 ? BushVisualPhase.bouncing : BushVisualPhase.swaying,
      );
    }

    if (updated.openProgress > 0 && updated.visualPhase == BushVisualPhase.opening) {
      final open = (updated.openProgress + delta * 1.8 * settings.animSpeedMult)
          .clamp(0.0, 1.0);
      updated = updated.copyWith(openProgress: open);
    }

    if (!updated.hasAnimal ||
        updated.visualPhase == BushVisualPhase.bouncing ||
        updated.visualPhase == BushVisualPhase.opening) {
      return updated.copyWith(visualPhase: updated.bounceProgress > 0
          ? BushVisualPhase.bouncing
          : BushVisualPhase.swaying);
    }

    var timer = updated.shakeTimer - delta;
    var phase = updated.visualPhase;
    var shakePhase = updated.shakePhase;
    var intensityShake = updated.shakeIntensity;

    if (phase == BushVisualPhase.hintShaking) {
      shakePhase += delta * 14 * intensity * intensityShake;
      timer -= delta * 0.5;
      if (timer <= 0) {
        phase = BushVisualPhase.swaying;
        intensityShake = 1;
        timer = 3 + random.nextDouble() * 2;
      }
    } else if (timer <= 0) {
      phase = BushVisualPhase.shaking;
      shakePhase += delta * 10 * intensity * intensityShake;
      if (shakePhase > math.pi * 2) {
        phase = BushVisualPhase.swaying;
        shakePhase = 0;
        timer = (3 + random.nextDouble() * 2) * settings.shakeIntervalMult;
      }
    }

    return updated.copyWith(
      shakeTimer: timer,
      shakePhase: shakePhase,
      visualPhase: phase,
      shakeIntensity: intensityShake,
    );
  }

  static AnimalEntity updateAnimal(
    AnimalEntity animal,
    BushEntity? bush,
    double delta,
    Size area,
    PeekABooSettings settings,
  ) {
    if (animal.phase == AnimalPhase.gone || animal.phase == AnimalPhase.hidden) {
      return animal.copyWith(animPhase: animal.animPhase + delta * 2);
    }

    final speed = settings.animSpeedMult * settings.animationIntensity;
    final bx = bush?.centerX ?? animal.x;
    final by = bush?.centerY ?? animal.y;
    final bushH = bush?.height ?? 80;

    return switch (animal.phase) {
      AnimalPhase.popping => _updatePopping(animal, bx, by, bushH, delta, speed),
      AnimalPhase.visible => _updateVisible(animal, bx, by, bushH, delta, speed),
      AnimalPhase.exiting => _updateExiting(animal, area, delta, speed),
      _ => animal,
    };
  }

  static AnimalEntity _updatePopping(
    AnimalEntity a,
    double bx,
    double by,
    double bushH,
    double delta,
    double speed,
  ) {
    final pop = (a.popProgress + delta * 1.6 * speed).clamp(0.0, 1.0);
    final y = by - bushH * 0.15 - pop * bushH * 0.55;
    if (pop >= 1) {
      return a.copyWith(
        phase: AnimalPhase.visible,
        popProgress: 1,
        x: bx,
        y: y,
        visibleTimer: 2.8,
        wavePhase: 0,
        animPhase: a.animPhase + delta * 3,
      );
    }
    return a.copyWith(
      popProgress: pop,
      x: bx,
      y: y,
      animPhase: a.animPhase + delta * 4,
      wavePhase: a.wavePhase + delta * 6,
    );
  }

  static AnimalEntity _updateVisible(
    AnimalEntity a,
    double bx,
    double by,
    double bushH,
    double delta,
    double speed,
  ) {
    final timer = a.visibleTimer - delta;
    final bounce = math.sin(a.animPhase * 4) * 4;
    if (timer <= 0) {
      return a.copyWith(
        phase: AnimalPhase.exiting,
        exitProgress: 0,
        x: bx,
        y: by - bushH * 0.7 + bounce,
      );
    }
    return a.copyWith(
      visibleTimer: timer,
      x: bx,
      y: by - bushH * 0.7 + bounce,
      animPhase: a.animPhase + delta * 3,
      wavePhase: a.wavePhase + delta * 8,
    );
  }

  static AnimalEntity _updateExiting(
    AnimalEntity a,
    Size area,
    double delta,
    double speed,
  ) {
    final def = a.def;
    final exitSpeed = switch (def?.exitStyle) {
      AnimalExitStyle.walk => 140.0,
      AnimalExitStyle.hop => 180.0,
      AnimalExitStyle.fly => 220.0,
      AnimalExitStyle.swim => 160.0,
      AnimalExitStyle.waddle => 150.0,
      _ => 160.0,
    };

    final progress = a.exitProgress + delta * exitSpeed * speed / 400;
    final dist = progress * math.max(area.width, area.height) * 0.65;
    final nx = a.x + math.cos(a.exitAngle) * dist;
    final ny = a.y + math.sin(a.exitAngle) * dist * 0.6;

    if (progress >= 1.2 ||
        nx < -80 ||
        nx > area.width + 80 ||
        ny < -80 ||
        ny > area.height + 80) {
      return a.copyWith(phase: AnimalPhase.gone, exitProgress: 1.2);
    }

    final hop = def?.exitStyle == AnimalExitStyle.hop
        ? math.sin(progress * 18) * 12
        : 0.0;

    return a.copyWith(
      exitProgress: progress,
      x: nx,
      y: ny - hop,
      animPhase: a.animPhase + delta * 5,
    );
  }

  static ({int points, int coins, int xp, int stars}) discoveryReward(
    PeekABooSettings settings,
    int discoveries,
  ) {
    final m = settings.rewardMultiplier;
    final points = (10 * m).round().clamp(5, 20);
    final coins = (5 * m).round().clamp(2, 12);
    final xp = (5 * m).round().clamp(2, 12);
    final star = discoveries % 3 == 0 ? 1 : 0;
    return (points: points, coins: coins, xp: xp, stars: star);
  }

  static PeekABooResult buildResult(PeekABooState state) => PeekABooResult(
        discoveriesCount: state.discoveriesCount,
        bushesExplored: state.bushesExplored,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickMissMessage(int missed) =>
      kPeekMissMessages[missed % kPeekMissMessages.length];

  static String pickEncouragement(int discoveries) =>
      kPeekEncouragements[discoveries % kPeekEncouragements.length];
}
