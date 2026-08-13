import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/core/models/reward_model.dart';
import 'package:my_tiny_thinker/games/whack_a_mole/models/whack_a_mole_models.dart';

abstract final class WhackAMoleLogic {
  static final random = math.Random();

  /// Layout grids for 4–8 holes, returning (cols, rows) and per-index cell.
  static (int cols, int rows) gridForCount(int count) {
    return switch (count.clamp(4, 8)) {
      4 => (2, 2),
      5 => (3, 2),
      6 => (3, 2),
      7 => (4, 2),
      8 => (4, 2),
      _ => (2, 2),
    };
  }

  static List<MoleHoleEntity> spawnHoles(
    Size area,
    int count, {
    bool leftHanded = false,
  }) {
    final holeCount = count.clamp(4, 8);
    final (cols, rows) = gridForCount(holeCount);
    final holes = <MoleHoleEntity>[];

    final padX = area.width * 0.06;
    final padTop = area.height * 0.08;
    final padBottom = area.height * 0.06;
    final usableW = area.width - padX * 2;
    final usableH = area.height - padTop - padBottom;
    final cellW = usableW / cols;
    final cellH = usableH / rows;
    final radius = math.min(cellW, cellH) * 0.36;

    // Row occupancy for uneven counts (5, 7).
    final topCount = switch (holeCount) {
      5 => 3,
      7 => 4,
      _ => cols,
    };
    final bottomCount = holeCount - topCount;

    var index = 0;
    for (var row = 0; row < rows; row++) {
      final rowCount = row == 0 ? topCount : bottomCount;
      if (rowCount <= 0) continue;
      final rowOffsetX = (usableW - rowCount * cellW) / 2;
      for (var col = 0; col < rowCount; col++) {
        final visualCol = leftHanded ? (rowCount - 1 - col) : col;
        final cx = padX + rowOffsetX + (visualCol + 0.5) * cellW;
        final cy = padTop + (row + 0.55) * cellH;
        holes.add(
          MoleHoleEntity(
            id: 'hole_$index',
            index: index,
            centerX: cx,
            centerY: cy,
            radius: radius,
            swayPhase: random.nextDouble() * math.pi * 2,
            sparklePhase: random.nextDouble() * math.pi * 2,
            decorSeed: random.nextInt(10000),
          ),
        );
        index++;
      }
    }
    return holes;
  }

  static double randomDelay(WhackAMoleSettings settings) {
    final min = settings.delayMin;
    final max = settings.delayMax;
    return min + random.nextDouble() * (max - min);
  }

  static String pickHoleId(List<MoleHoleEntity> holes, String? lastHoleId) {
    if (holes.isEmpty) return 'hole_0';
    if (holes.length == 1) return holes.first.id;
    final pool = holes.where((h) => h.id != lastHoleId).toList();
    final chosen = pool.isEmpty
        ? holes[random.nextInt(holes.length)]
        : pool[random.nextInt(pool.length)];
    return chosen.id;
  }

  static MoleEntity createMole(String holeId) {
    final accessories = MoleAccessory.values;
    final accessory = accessories[random.nextInt(accessories.length)];
    final idles = MoleIdleAnim.values;
    return MoleEntity(
      id: 'mole_${DateTime.now().microsecondsSinceEpoch}',
      holeId: holeId,
      phase: MolePhase.peeking,
      accessory: accessory,
      idleAnim: idles[random.nextInt(idles.length)],
      popProgress: 0,
      furTone: random.nextInt(kFurTones.length),
    );
  }

  static MoleHoleEntity updateHole(
    MoleHoleEntity hole,
    double delta,
    WhackAMoleSettings settings,
  ) {
    final intensity = settings.reducedMotion ? 0.3 : 1.0;
    return hole.copyWith(
      swayPhase: hole.swayPhase + delta * 1.4 * intensity,
      sparklePhase: hole.sparklePhase + delta * 2.2 * intensity,
    );
  }

  static MoleEntity updateMole(
    MoleEntity mole,
    double delta,
    WhackAMoleSettings settings,
  ) {
    final speed = settings.appearSpeedMult;
    final intensity = settings.reducedMotion ? 0.6 : 1.0;

    return switch (mole.phase) {
      MolePhase.peeking => _updatePeeking(mole, delta, speed),
      MolePhase.visible => _updateVisible(mole, delta, settings),
      MolePhase.hit => _updateHit(mole, delta, speed),
      MolePhase.hiding => _updateHiding(mole, delta, speed),
      MolePhase.hidden || MolePhase.gone => mole.copyWith(
          animPhase: mole.animPhase + delta * 2 * intensity,
        ),
    };
  }

  static MoleEntity _updatePeeking(MoleEntity m, double delta, double speed) {
    final pop = (m.popProgress + delta * 2.2 * speed).clamp(0.0, 1.0);
    if (pop >= 1) {
      return m.copyWith(
        phase: MolePhase.visible,
        popProgress: 1,
        animPhase: m.animPhase + delta * 3,
      );
    }
    return m.copyWith(
      popProgress: pop,
      animPhase: m.animPhase + delta * 4,
    );
  }

  static MoleEntity _updateVisible(
    MoleEntity m,
    double delta,
    WhackAMoleSettings settings,
  ) {
    final timer = m.visibleTimer - delta;
    if (timer <= 0) {
      return m.copyWith(phase: MolePhase.hiding, hideProgress: 0);
    }
    return m.copyWith(
      visibleTimer: timer,
      animPhase: m.animPhase + delta * 3,
    );
  }

  static MoleEntity _updateHit(MoleEntity m, double delta, double speed) {
    final hit = (m.hitProgress + delta * 2.8 * speed).clamp(0.0, 1.0);
    if (hit >= 1) {
      return m.copyWith(phase: MolePhase.gone, hitProgress: 1);
    }
    return m.copyWith(hitProgress: hit, animPhase: m.animPhase + delta * 8);
  }

  static MoleEntity _updateHiding(MoleEntity m, double delta, double speed) {
    final hide = (m.hideProgress + delta * 2.4 * speed).clamp(0.0, 1.0);
    if (hide >= 1) {
      return m.copyWith(phase: MolePhase.gone, hideProgress: 1);
    }
    return m.copyWith(hideProgress: hide, animPhase: m.animPhase + delta * 3);
  }

  static CheerEntity? maybeSpawnCheer(int taps, bool celebrationsEnabled) {
    if (!celebrationsEnabled || taps == 0 || taps % 4 != 0) return null;
    final animals = CheerAnimal.values;
    return CheerEntity(
      id: 'cheer_${DateTime.now().microsecondsSinceEpoch}',
      animal: animals[random.nextInt(animals.length)],
      side: random.nextBool(),
      progress: 0,
    );
  }

  static CheerEntity updateCheer(CheerEntity cheer, double delta) {
    final p = (cheer.progress + delta * 0.55).clamp(0.0, 1.0);
    return cheer.copyWith(progress: p);
  }

  static TapSparkle updateSparkle(TapSparkle s, double delta) {
    return s.copyWith(progress: (s.progress + delta * 1.8).clamp(0.0, 1.0));
  }

  static ({int coins, int xp, int stars, int rewardPoints}) tapReward(
    WhackAMoleSettings settings,
    int streak,
  ) {
    final m = settings.rewardMultiplier;
    final streakBonus = (streak / 5).floor().clamp(0, 3);
    final coins = settings.coinRewardsEnabled
        ? ((4 + streakBonus) * m).round().clamp(2, 14)
        : 0;
    final xp = ((5 + streakBonus) * m).round().clamp(2, 16);
    final rewardPoints = ((3 + streakBonus) * m).round().clamp(1, 12);
    final stars = streak > 0 && streak % 5 == 0 ? 1 : 0;
    return (coins: coins, xp: xp, stars: stars, rewardPoints: rewardPoints);
  }

  static String pickEncouragement(int taps) =>
      kWhackEncouragements[taps % kWhackEncouragements.length];

  static String pickEndMessage(int taps) =>
      kWhackEndMessages[taps % kWhackEndMessages.length];

  static WhackAMoleResult buildResult(WhackAMoleState state) {
    final played = state.settings.practiceMode
        ? state.settings.sessionSeconds
        : (state.settings.sessionSeconds - state.remainingSeconds)
            .clamp(0, state.settings.sessionSeconds);
    return WhackAMoleResult(
      molesTapped: state.molesTapped,
      coins: state.coinsEarned,
      stars: state.starsEarned,
      xp: state.xpEarned,
      rewardPoints: state.rewardPoints,
      longestStreak: state.longestStreak,
      fastestReactionMs: state.fastestReactionMs,
      accuracy: state.accuracy,
      sessionSeconds: played,
      encouragement: pickEndMessage(state.molesTapped),
    );
  }

  static GameRewardResult toReward(WhackAMoleResult result) => GameRewardResult(
        coins: result.coins,
        stars: result.stars.clamp(0, 5),
        xp: result.xp,
        isPerfect: result.accuracy >= 0.9 && result.molesTapped >= 5,
      );

  /// Rise amount 0..1 based on mole phase for drawing.
  static double riseAmount(MoleEntity mole) {
    return switch (mole.phase) {
      MolePhase.peeking => _easeOutBack(mole.popProgress),
      MolePhase.visible => 1.0,
      MolePhase.hit => 1.0 - mole.hitProgress * 0.85,
      MolePhase.hiding => 1.0 - _easeIn(mole.hideProgress),
      MolePhase.hidden || MolePhase.gone => 0.0,
    };
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final p = t - 1;
    return 1 + c3 * p * p * p + c1 * p * p;
  }

  static double _easeIn(double t) => t * t;
}
