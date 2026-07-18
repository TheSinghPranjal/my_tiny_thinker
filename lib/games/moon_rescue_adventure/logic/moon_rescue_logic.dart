import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

abstract final class MoonRescueLogic {
  static final random = math.Random();

  /// Moon surface Y as a fraction of play area height.
  static const moonSurfaceY = 0.78;

  static const earthX = 0.5;
  static const earthY = 0.12;

  static const rocketPadX = 0.5;
  static const rocketPadY = 0.82;

  /// Waiting astronauts stand just beside the pad.
  static const waitSpotY = moonSurfaceY - 0.02;

  static List<MoonAstronaut> spawnInitial(Size area, MoonRescueSettings settings) {
    return [
      for (var i = 0; i < settings.astronautCount; i++)
        spawnAstronaut(
          area,
          settings,
          idSuffix: i,
          // First crew fades in gently too.
          smoothEntrance: true,
        ),
    ];
  }

  static MoonAstronaut spawnAstronaut(
    Size area,
    MoonRescueSettings settings, {
    required int idSuffix,
    bool smoothEntrance = true,
  }) {
    final edge = random.nextInt(3);
    late double x;
    late double y;
    late double targetX;
    late double targetY;

    switch (edge) {
      case 0: // top
        x = 0.15 + random.nextDouble() * 0.7;
        y = -0.12;
        targetX = x + (random.nextDouble() - 0.5) * 0.15;
        targetY = 0.18 + random.nextDouble() * 0.25;
      case 1: // left
        x = -0.14;
        y = 0.15 + random.nextDouble() * 0.4;
        targetX = 0.18 + random.nextDouble() * 0.25;
        targetY = y + (random.nextDouble() - 0.5) * 0.1;
      default: // right
        x = 1.14;
        y = 0.15 + random.nextDouble() * 0.4;
        targetX = 0.55 + random.nextDouble() * 0.25;
        targetY = y + (random.nextDouble() - 0.5) * 0.1;
    }

    // Very gentle drift into the scene (zero-g).
    final speedScale = 0.012 * settings.floatSpeed;
    final vx = (targetX - x) * speedScale;
    final vy = (targetY - y) * speedScale;

    return MoonAstronaut(
      id: 'astro_${DateTime.now().microsecondsSinceEpoch}_$idSuffix',
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      rotation: random.nextDouble() * math.pi * 2,
      spin: (random.nextDouble() - 0.5) * 0.25,
      variety: random.nextInt(6),
      wavePhase: random.nextDouble() * math.pi * 2,
      enterProgress: smoothEntrance ? 0 : 1,
    );
  }

  static MoonAstronaut pushAstronaut(
    MoonAstronaut a,
    Offset localDelta,
    MoonRescueSettings settings,
  ) {
    if (a.phase != AstronautPhase.floating || a.enterProgress < 0.85) {
      return a;
    }

    var dx = localDelta.dx.clamp(-60.0, 60.0);
    var dy = localDelta.dy.clamp(-20.0, 90.0);
    if (dy < 16) dy = 28 + random.nextDouble() * 20;

    // Slow, floaty push toward the moon.
    final mult = 0.0016 * settings.floatSpeed;
    return a.copyWith(
      phase: AstronautPhase.pushed,
      vx: dx * mult,
      vy: dy * mult * 1.05,
      spin: (random.nextDouble() - 0.5) * 0.5,
      trail: true,
    );
  }

  static MoonAstronaut tapPush(MoonAstronaut a, MoonRescueSettings settings) {
    if (a.phase != AstronautPhase.floating || a.enterProgress < 0.85) {
      return a;
    }
    final targetX = rocketPadX + (random.nextDouble() - 0.5) * 0.18;
    final dx = (targetX - a.x) * 0.028 * settings.floatSpeed;
    final dy = 0.045 + random.nextDouble() * 0.02;
    return a.copyWith(
      phase: AstronautPhase.pushed,
      vx: dx,
      vy: dy,
      spin: (random.nextDouble() - 0.5) * 0.35,
      trail: true,
    );
  }

  static bool rocketCanBoard(MoonRocket rocket, int capacity) {
    if (rocket.phase != RocketPhase.idle && rocket.phase != RocketPhase.ready) {
      return false;
    }
    return rocket.passengers < capacity;
  }

  static ({
    List<MoonAstronaut> astronauts,
    MoonRocket rocket,
    List<String> boardedIds,
    bool becameReady,
  }) tick({
    required List<MoonAstronaut> astronauts,
    required MoonRocket rocket,
    required MoonRescueSettings settings,
    required double delta,
    required Size area,
  }) {
    if (area == Size.zero) {
      return (
        astronauts: astronauts,
        rocket: rocket,
        boardedIds: const <String>[],
        becameReady: false,
      );
    }

    final reduced = settings.reducedMotion;
    final speed = settings.floatSpeed;
    final drift = settings.driftIntensity;
    var nextRocket = rocket;
    final boarded = <String>[];
    final next = <MoonAstronaut>[];

    if (rocket.phase == RocketPhase.idle || rocket.phase == RocketPhase.ready) {
      nextRocket = nextRocket.copyWith(
        bobPhase: rocket.bobPhase + delta * (reduced ? 0.4 : 1.6),
        lightBlink:
            rocket.lightBlink + delta * (rocket.phase == RocketPhase.ready ? 5 : 2.2),
        x: rocketPadX,
        y: rocketPadY,
      );
    }

    if (rocket.phase == RocketPhase.launching) {
      final p = (rocket.launchProgress + delta * 0.32).clamp(0.0, 1.0);
      final ease = _easeOutCubic(p);
      nextRocket = nextRocket.copyWith(
        launchProgress: p,
        y: rocketPadY - ease * (rocketPadY - earthY + 0.02),
        x: rocketPadX + math.sin(p * math.pi * 2) * 0.01,
      );
    }

    if (rocket.phase == RocketPhase.arriving) {
      final p = (rocket.arriveProgress + delta * 0.55).clamp(0.0, 1.0);
      nextRocket = nextRocket.copyWith(
        arriveProgress: p,
        x: 1.15 - p * (1.15 - rocketPadX),
        y: rocketPadY,
        passengers: 0,
      );
      if (p >= 1) {
        nextRocket = nextRocket.copyWith(
          phase: RocketPhase.idle,
          passengers: 0,
          launchProgress: 0,
          arriveProgress: 1,
          x: rocketPadX,
          y: rocketPadY,
        );
      }
    }

    var becameReady = false;
    var seatsLeft = rocketCanBoard(nextRocket, settings.rocketCapacity)
        ? settings.rocketCapacity - nextRocket.passengers
        : 0;

    for (final a in astronauts) {
      if (a.phase == AstronautPhase.boarded) continue;

      switch (a.phase) {
        case AstronautPhase.floating:
          next.add(_tickFloating(a, delta, speed, drift, reduced));
        case AstronautPhase.pushed:
          next.add(_tickPushed(a, delta, speed));
        case AstronautPhase.landing:
          next.add(_tickLanding(a, delta));
        case AstronautPhase.running:
          final running = _tickRunning(a, delta, rocketPadX);
          if (running.runProgress >= 1) {
            if (seatsLeft > 0) {
              seatsLeft -= 1;
              boarded.add(running.id);
            } else {
              next.add(running.copyWith(
                phase: AstronautPhase.waiting,
                runProgress: 1,
                x: _waitX(running.x, next.length),
                y: waitSpotY,
                rotation: 0,
              ));
            }
          } else {
            next.add(running);
          }
        case AstronautPhase.waiting:
          next.add(_tickWaiting(a, delta, next.length));
        case AstronautPhase.boarding:
          // Should not linger; treat as boarded.
          boarded.add(a.id);
        case AstronautPhase.boarded:
          break;
      }
    }

    // New rocket ready — waiting astronauts board one seat at a time.
    seatsLeft = rocketCanBoard(nextRocket, settings.rocketCapacity)
        ? settings.rocketCapacity - nextRocket.passengers - boarded.length
        : 0;
    if (seatsLeft < 0) seatsLeft = 0;

    final kept = <MoonAstronaut>[];
    for (final a in next) {
      if (a.phase == AstronautPhase.waiting && seatsLeft > 0) {
        seatsLeft -= 1;
        boarded.add(a.id);
      } else {
        kept.add(a);
      }
    }

    if (boarded.isNotEmpty &&
        (nextRocket.phase == RocketPhase.idle ||
            nextRocket.phase == RocketPhase.ready)) {
      final passengers = (nextRocket.passengers + boarded.length)
          .clamp(0, settings.rocketCapacity);
      nextRocket = nextRocket.copyWith(passengers: passengers);
      if (passengers >= settings.rocketCapacity &&
          nextRocket.phase != RocketPhase.ready) {
        nextRocket = nextRocket.copyWith(phase: RocketPhase.ready);
        becameReady = true;
      }
    }

    return (
      astronauts: kept,
      rocket: nextRocket,
      boardedIds: boarded,
      becameReady: becameReady,
    );
  }

  static double _waitX(double preferred, int index) {
    final slots = [0.32, 0.38, 0.62, 0.68, 0.28, 0.72];
    return slots[index % slots.length];
  }

  static MoonAstronaut _tickWaiting(MoonAstronaut a, double delta, int index) {
    final targetX = _waitX(a.x, index);
    final x = a.x + (targetX - a.x) * math.min(1.0, delta * 2.5);
    return a.copyWith(
      x: x,
      y: waitSpotY,
      vx: 0,
      vy: 0,
      rotation: math.sin(a.wavePhase) * 0.05,
      wavePhase: a.wavePhase + delta * 2.2,
      trail: false,
    );
  }

  static MoonAstronaut _tickFloating(
    MoonAstronaut a,
    double delta,
    double speed,
    double drift,
    bool reduced,
  ) {
    // Soft zero-g motion (~3–4× slower than before).
    final move = delta * 60 * speed * 0.12;
    var x = a.x + a.vx * move;
    var y = a.y + a.vy * move;
    var vx = a.vx + (random.nextDouble() - 0.5) * 0.00055 * drift;
    var vy = a.vy + (random.nextDouble() - 0.5) * 0.00055 * drift;

    if (x < 0.06) {
      x = 0.06;
      vx = vx.abs() * 0.25;
    } else if (x > 0.94) {
      x = 0.94;
      vx = -vx.abs() * 0.25;
    }
    if (y < 0.06) {
      y = 0.06;
      vy = vy.abs() * 0.25;
    } else if (y > moonSurfaceY - 0.14) {
      y = moonSurfaceY - 0.14;
      vy = -vy.abs() * 0.25;
    }

    vx = vx.clamp(-0.035, 0.035);
    vy = vy.clamp(-0.03, 0.03);

    final enter = a.enterProgress >= 1
        ? 1.0
        : (a.enterProgress + delta * 0.55).clamp(0.0, 1.0);

    return a.copyWith(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      rotation: a.rotation + a.spin * delta * (reduced ? 0.2 : 0.55),
      wavePhase: a.wavePhase + delta * 1.6,
      enterProgress: enter,
      trail: false,
    );
  }

  static MoonAstronaut _tickPushed(
    MoonAstronaut a,
    double delta,
    double speed,
  ) {
    // Slow coast toward the moon (no snappy gravity).
    final move = delta * 60 * 0.55;
    var x = a.x + a.vx * move;
    var y = a.y + a.vy * move;
    final vy = a.vy + 0.012 * delta * speed;
    final vx = a.vx * (1 - delta * 0.08);

    if (y >= moonSurfaceY - 0.04) {
      return a.copyWith(
        x: x.clamp(0.08, 0.92),
        y: moonSurfaceY - 0.02,
        vx: 0,
        vy: 0,
        phase: AstronautPhase.landing,
        landProgress: 0,
        rotation: 0,
        trail: false,
      );
    }

    return a.copyWith(
      x: x.clamp(-0.05, 1.05),
      y: y,
      vx: vx,
      vy: vy.clamp(-0.02, 0.14),
      rotation: a.rotation + a.spin * delta * 0.6,
      wavePhase: a.wavePhase + delta * 2,
    );
  }

  static MoonAstronaut _tickLanding(MoonAstronaut a, double delta) {
    final p = (a.landProgress + delta * 1.4).clamp(0.0, 1.0);
    final bounce = math.sin(p * math.pi) * 0.012;
    if (p >= 1) {
      return a.copyWith(
        phase: AstronautPhase.running,
        landProgress: 1,
        runProgress: 0,
        y: moonSurfaceY - 0.02,
        rotation: 0,
      );
    }
    return a.copyWith(
      landProgress: p,
      y: moonSurfaceY - 0.02 - bounce,
      rotation: 0,
    );
  }

  static MoonAstronaut _tickRunning(
    MoonAstronaut a,
    double delta,
    double rocketX,
  ) {
    final p = (a.runProgress + delta * 0.7).clamp(0.0, 1.0);
    final x = a.x + (rocketX - a.x) * math.min(1.0, delta * 2.4);
    return a.copyWith(
      x: x,
      y: moonSurfaceY - 0.02,
      runProgress: p,
      wavePhase: a.wavePhase + delta * 8,
      rotation: math.sin(p * math.pi * 8) * 0.08,
    );
  }

  static ({int points, int coins, int xp, int stars}) rescueReward(
    MoonRescueSettings settings,
  ) {
    final m = settings.rewardMultiplier;
    return (
      points: (10 * m).round(),
      coins: math.max(1, (5 * m).round()),
      xp: math.max(2, (5 * m).round()),
      stars: 1,
    );
  }

  static ({int points, int coins, int xp, int stars}) launchBonus(
    MoonRescueSettings settings,
  ) {
    final m = settings.rewardMultiplier;
    return (
      points: (50 * m).round(),
      coins: math.max(5, (25 * m).round()),
      xp: math.max(5, (25 * m).round()),
      stars: 2,
    );
  }

  static String readyPhrase() => 'Tap to Launch!';

  static MoonRescueResult calculate(MoonRescueState state) => MoonRescueResult(
        score: state.score,
        astronautsRescued: state.astronautsRescued,
        rocketsLaunched: state.rocketsLaunched,
        maxStreak: state.maxStreak,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
      );

  static GameRewardResult toReward(MoonRescueResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 8),
        xp: result.xp,
        isPerfect: result.rocketsLaunched > 0 && result.maxStreak >= 3,
      );
}

double _easeOutCubic(double t) {
  final u = 1 - t;
  return 1 - u * u * u;
}
