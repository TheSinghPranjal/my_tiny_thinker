import 'dart:math' as math;
import 'dart:ui';

import 'package:my_tiny_thinker/games/frog_pond_adventure/models/frog_pond_models.dart';
import 'package:my_tiny_thinker/games/shared/frog_varieties.dart';

abstract final class FrogPondLogic {
  static final random = math.Random();

  static List<LilyPadEntity> spawnPads(Size area, int count) {
    final padCount = count.clamp(2, 8);
    final pads = <LilyPadEntity>[];
    final cols = padCount <= 4 ? padCount : 4;
    final rows = (padCount / cols).ceil();
    final cellW = area.width / cols;
    final cellH = area.height * 0.42 / rows;
    final baseY = area.height * 0.52;

    for (var i = 0; i < padCount; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final cx = cellW * (col + 0.5) + (row.isOdd ? cellW * 0.08 : 0);
      final cy = baseY + row * cellH + cellH * 0.35;
      final radius = math.min(cellW, cellH) * 0.34;
      pads.add(
        LilyPadEntity(
          id: 'pad_$i',
          centerX: cx.clamp(radius + 8, area.width - radius - 8),
          centerY: cy.clamp(area.height * 0.38, area.height * 0.82),
          radius: radius,
          swayPhase: random.nextDouble() * math.pi * 2,
        ),
      );
    }
    return pads;
  }

  static List<FrogEntity> spawnFrogsForPads(List<LilyPadEntity> pads) =>
      pads.map((pad) => createFrog(pad, isKing: false)).toList();

  static FrogEntity createFrog(
    LilyPadEntity pad, {
    required bool isKing,
    int? varietyIndex,
    Size? area,
  }) {
    final idx = varietyIndex ?? random.nextInt(FrogVarieties.all.length);
    final fromEdge = area != null ? _edgeEntryPoint(area, pad) : (pad.centerX, pad.centerY);
    return FrogEntity(
      id: 'frog_${DateTime.now().microsecondsSinceEpoch}_${pad.id}',
      padId: pad.id,
      varietyIndex: idx,
      isKing: isKing,
      phase: area != null ? FrogPhase.entering : FrogPhase.idle,
      x: area != null ? fromEdge.$1 : pad.centerX,
      y: area != null ? fromEdge.$2 : pad.centerY - pad.radius * 0.15,
      enterFromX: fromEdge.$1,
      enterFromY: fromEdge.$2,
      enterProgress: area != null ? 0 : 1,
      crownGems: isKing ? FrogEntity.kingTapRequired : 0,
    );
  }

  static (double, double) _edgeEntryPoint(Size area, LilyPadEntity pad) {
    final fromLeft = pad.centerX < area.width / 2;
    return (
      fromLeft ? -40.0 : area.width + 40,
      pad.centerY + random.nextDouble() * 40 - 20,
    );
  }

  static double randomReplacementDelay(FrogPondSettings settings) {
    final min = settings.replacementDelayMin;
    final max = settings.replacementDelayMax;
    return min + random.nextDouble() * (max - min);
  }

  static LilyPadEntity updatePad(
    LilyPadEntity pad,
    double delta,
    FrogPondSettings settings,
  ) {
    final intensity = settings.reducedMotion ? 0.35 : settings.animationIntensity;
    var updated = pad.copyWith(
      swayPhase: pad.swayPhase + delta * 1.1 * intensity,
      ripplePhase: pad.ripplePhase + delta * 2.2,
    );

    if (updated.showSplash) {
      final splash = updated.splashProgress + delta * 1.8 * settings.moveSpeedMult;
      if (splash >= 1) {
        updated = updated.copyWith(showSplash: false, splashProgress: 0);
      } else {
        updated = updated.copyWith(splashProgress: splash);
      }
    }

    if (updated.state == PadState.waiting) {
      final timer = updated.emptyTimer - delta;
      if (timer <= 0) {
        return updated.copyWith(state: PadState.empty, emptyTimer: 0);
      }
      return updated.copyWith(emptyTimer: timer);
    }

    return updated;
  }

  static FrogEntity updateFrog(
    FrogEntity frog,
    LilyPadEntity? pad,
    double delta,
    FrogPondSettings settings,
  ) {
    if (frog.phase == FrogPhase.gone || pad == null) return frog;

    final speed = settings.moveSpeedMult * settings.animationIntensity;
    final blink = frog.blinkTimer + delta;
    var updated = frog.copyWith(
      animPhase: frog.animPhase + delta * 2.5,
      blinkTimer: blink,
    );

    return switch (frog.phase) {
      FrogPhase.idle => updated.copyWith(
          x: pad.centerX + math.sin(pad.swayPhase) * 3,
          y: pad.centerY - pad.radius * 0.15 + math.sin(frog.animPhase * 2) * 2,
        ),
      FrogPhase.reacting => _updateReacting(updated, pad, delta, speed),
      FrogPhase.jumping => _updateJumping(updated, pad, delta, speed),
      FrogPhase.entering => _updateEntering(updated, pad, delta, speed),
      FrogPhase.gone => updated,
    };
  }

  static FrogEntity _updateReacting(
    FrogEntity f,
    LilyPadEntity pad,
    double delta,
    double speed,
  ) {
    final react = (f.reactProgress + delta * 3 * speed).clamp(0.0, 1.0);
    if (react >= 1) {
      return f.copyWith(
        phase: FrogPhase.idle,
        reactProgress: 0,
        x: pad.centerX,
        y: pad.centerY - pad.radius * 0.15,
      );
    }
    final wobble = math.sin(react * math.pi * 4) * 8;
    return f.copyWith(
      reactProgress: react,
      x: pad.centerX + wobble,
      y: pad.centerY - pad.radius * 0.15 - react * 6,
    );
  }

  static FrogEntity _updateJumping(
    FrogEntity f,
    LilyPadEntity pad,
    double delta,
    double speed,
  ) {
    final jump = (f.jumpProgress + delta * (f.isKing ? 1.2 : 1.6) * speed)
        .clamp(0.0, 1.0);
    final arc = math.sin(jump * math.pi);
    final scale = 1 + arc * (f.isKing ? 0.35 : 0.2);
    return f.copyWith(
      jumpProgress: jump,
      x: pad.centerX,
      y: pad.centerY - pad.radius * 0.15 - arc * pad.radius * (f.isKing ? 2.2 : 1.6) * scale,
      phase: jump >= 1 ? FrogPhase.gone : FrogPhase.jumping,
    );
  }

  static FrogEntity _updateEntering(
    FrogEntity f,
    LilyPadEntity pad,
    double delta,
    double speed,
  ) {
    final enter = (f.enterProgress + delta * 1.4 * speed).clamp(0.0, 1.0);
    final tx = pad.centerX;
    final ty = pad.centerY - pad.radius * 0.15;
    final hop = math.sin(enter * math.pi * 3) * 12 * (1 - enter);
    if (enter >= 1) {
      return f.copyWith(
        phase: FrogPhase.idle,
        enterProgress: 1,
        x: tx,
        y: ty,
      );
    }
    return f.copyWith(
      enterProgress: enter,
      x: f.enterFromX + (tx - f.enterFromX) * enter,
      y: f.enterFromY + (ty - f.enterFromY) * enter - hop,
    );
  }

  static ({int points, int coins, int xp, int stars}) tapReward(
    FrogPondSettings settings, {
    required bool isKing,
    required int tapCount,
  }) {
    final m = settings.rewardMultiplier * (isKing ? 2.0 : 1.0);
    if (isKing && tapCount < FrogEntity.kingTapRequired) {
      return (points: 0, coins: 0, xp: 0, stars: 0);
    }
    final points = ((isKing ? 20 : 10) * m).round().clamp(5, 40);
    final coins = ((isKing ? 10 : 5) * m).round().clamp(2, 24);
    final xp = ((isKing ? 10 : 5) * m).round().clamp(2, 24);
    final star = isKing ? 2 : (tapCount % 3 == 0 ? 1 : 0);
    return (points: points, coins: coins, xp: xp, stars: star);
  }

  static bool shouldMarkKingDue(int elapsed, int nextKingAt) => elapsed >= nextKingAt;

  static FrogPondResult buildResult(FrogPondState state) => FrogPondResult(
        frogsTapped: state.frogsTapped,
        kingFrogsRemoved: state.kingFrogsRemoved,
        points: state.pointsEarned,
        coins: state.coinsEarned,
        xp: state.xpEarned,
        stars: state.starsEarned,
        longestStreak: state.longestStreak,
        sessionSeconds: state.settings.sessionSeconds - state.remainingSeconds,
      );

  static String pickEncouragement(int count) =>
      kFrogEncouragements[count % kFrogEncouragements.length];

  static String pickKingMessage(int count) =>
      kKingMessages[count % kKingMessages.length];
}
