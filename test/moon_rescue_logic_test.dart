import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/logic/moon_rescue_logic.dart';
import 'package:my_tiny_thinker/games/moon_rescue_adventure/models/moon_rescue_models.dart';

void main() {
  group('MoonRescueLogic', () {
    test('defaults to 60s, 5 astronauts, capacity 3', () {
      const s = MoonRescueSettings();
      expect(s.sessionSeconds, 60);
      expect(s.astronautCount, 5);
      expect(s.rocketCapacity, 3);
    });

    test('spawnInitial creates configured count', () {
      const area = Size(400, 800);
      final crew = MoonRescueLogic.spawnInitial(
        area,
        const MoonRescueSettings(astronautCount: 5),
      );
      expect(crew.length, 5);
      expect(crew.every((a) => a.phase == AstronautPhase.floating), isTrue);
    });

    test('tapPush moves astronaut into pushed phase', () {
      const a = MoonAstronaut(id: 'a', x: 0.5, y: 0.3, enterProgress: 1);
      final pushed = MoonRescueLogic.tapPush(a, const MoonRescueSettings());
      expect(pushed.phase, AstronautPhase.pushed);
      expect(pushed.vy, greaterThan(0));
    });

    test('full rocket sends arriving astronauts to waiting', () {
      const area = Size(400, 800);
      final running = MoonAstronaut(
        id: 'wait_me',
        x: 0.5,
        y: MoonRescueLogic.moonSurfaceY - 0.02,
        phase: AstronautPhase.running,
        runProgress: 0.99,
        enterProgress: 1,
      );
      final result = MoonRescueLogic.tick(
        astronauts: [running],
        rocket: const MoonRocket(
          phase: RocketPhase.ready,
          passengers: 3,
        ),
        settings: const MoonRescueSettings(rocketCapacity: 3),
        delta: 1 / 30,
        area: area,
      );
      expect(result.boardedIds, isEmpty);
      expect(result.astronauts.single.phase, AstronautPhase.waiting);
    });

    test('waiting astronauts board when new rocket is idle', () {
      const area = Size(400, 800);
      final waiting = MoonAstronaut(
        id: 'queued',
        x: 0.35,
        y: MoonRescueLogic.waitSpotY,
        phase: AstronautPhase.waiting,
        enterProgress: 1,
      );
      final result = MoonRescueLogic.tick(
        astronauts: [waiting],
        rocket: const MoonRocket(phase: RocketPhase.idle, passengers: 0),
        settings: const MoonRescueSettings(rocketCapacity: 3),
        delta: 1 / 60,
        area: area,
      );
      expect(result.boardedIds, contains('queued'));
      expect(result.rocket.passengers, 1);
    });

    test('rescue and launch rewards are positive', () {
      final r = MoonRescueLogic.rescueReward(const MoonRescueSettings());
      expect(r.points, 10);
      expect(r.coins, 5);
      expect(r.xp, 5);

      final b = MoonRescueLogic.launchBonus(const MoonRescueSettings());
      expect(b.points, 50);
      expect(b.coins, 25);
      expect(b.xp, 25);
    });

    test('tick advances floating astronauts', () {
      const area = Size(400, 800);
      final crew = [
        const MoonAstronaut(id: 'a', x: 0.5, y: 0.3, vx: 0.01, vy: 0.01),
      ];
      final result = MoonRescueLogic.tick(
        astronauts: crew,
        rocket: const MoonRocket(),
        settings: const MoonRescueSettings(),
        delta: 1 / 60,
        area: area,
      );
      expect(result.astronauts.single.x, isNot(0.5));
    });
  });
}
