import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum BalloonPhase { rising, bobbing, popping, leaving, gone }

enum BalloonPattern { solid, polkaDots, stars, hearts, confetti, stripes }

enum BalloonFace { smile, wink, happy, starEyes }

enum BalloonRibbon { curly, straight, zigZag }

/// Glossy balloon hues used by Balloon Parade and Color Balloon Pop.
enum BalloonHue {
  red,
  blue,
  green,
  yellow,
  orange,
  pink,
  purple,
  skyBlue,
  white,
  rainbow,
  gold,
  silver;

  String get displayName => switch (this) {
        BalloonHue.red => 'Red',
        BalloonHue.blue => 'Blue',
        BalloonHue.green => 'Green',
        BalloonHue.yellow => 'Yellow',
        BalloonHue.orange => 'Orange',
        BalloonHue.pink => 'Pink',
        BalloonHue.purple => 'Purple',
        BalloonHue.skyBlue => 'Sky Blue',
        BalloonHue.white => 'White',
        BalloonHue.rainbow => 'Rainbow',
        BalloonHue.gold => 'Gold',
        BalloonHue.silver => 'Silver',
      };

  /// Primary fill used for solid balloons and instruction cards.
  Color get primaryColor => switch (this) {
        BalloonHue.red => const Color(0xFFEF5350),
        BalloonHue.blue => const Color(0xFF42A5F5),
        BalloonHue.green => const Color(0xFF66BB6A),
        BalloonHue.yellow => const Color(0xFFFFEE58),
        BalloonHue.orange => const Color(0xFFFFA726),
        BalloonHue.pink => const Color(0xFFF48FB1),
        BalloonHue.purple => const Color(0xFFAB47BC),
        BalloonHue.skyBlue => const Color(0xFF81D4FA),
        BalloonHue.white => const Color(0xFFF5F5F5),
        BalloonHue.rainbow => const Color(0xFFFF7043),
        BalloonHue.gold => const Color(0xFFFFD54F),
        BalloonHue.silver => const Color(0xFFB0BEC5),
      };

  Color get accentColor => switch (this) {
        BalloonHue.red => const Color(0xFFC62828),
        BalloonHue.blue => const Color(0xFF1565C0),
        BalloonHue.green => const Color(0xFF2E7D32),
        BalloonHue.yellow => const Color(0xFFF9A825),
        BalloonHue.orange => const Color(0xFFEF6C00),
        BalloonHue.pink => const Color(0xFFC2185B),
        BalloonHue.purple => const Color(0xFF6A1B9A),
        BalloonHue.skyBlue => const Color(0xFF0277BD),
        BalloonHue.white => const Color(0xFF90A4AE),
        BalloonHue.rainbow => const Color(0xFF7E57C2),
        BalloonHue.gold => const Color(0xFFFF8F00),
        BalloonHue.silver => const Color(0xFF607D8B),
      };

  /// Colors suitable as Color Balloon Pop targets (clear for toddlers).
  static const learningTargets = <BalloonHue>[
    BalloonHue.red,
    BalloonHue.blue,
    BalloonHue.green,
    BalloonHue.yellow,
    BalloonHue.orange,
    BalloonHue.pink,
    BalloonHue.purple,
    BalloonHue.skyBlue,
  ];
}

class BalloonEntity extends Equatable {
  const BalloonEntity({
    required this.id,
    required this.lane,
    required this.hue,
    required this.x,
    required this.y,
    required this.size,
    this.phase = BalloonPhase.rising,
    this.pattern = BalloonPattern.solid,
    this.face = BalloonFace.smile,
    this.ribbon = BalloonRibbon.curly,
    this.swayPhase = 0,
    this.bobPhase = 0,
    this.popProgress = 0,
    this.wobbleTimer = 0,
    this.bounceTimer = 0,
    this.scale = 1,
    this.shineSeed = 0,
    this.targetY,
    this.wave = false,
  });

  final String id;
  final int lane;
  final BalloonHue hue;
  final double x;
  final double y;
  final double size;
  final BalloonPhase phase;
  final BalloonPattern pattern;
  final BalloonFace face;
  final BalloonRibbon ribbon;
  final double swayPhase;
  final double bobPhase;
  final double popProgress;
  final double wobbleTimer;
  final double bounceTimer;
  final double scale;
  final double shineSeed;
  final double? targetY;
  final bool wave;

  bool get isTappable =>
      phase == BalloonPhase.rising || phase == BalloonPhase.bobbing;

  BalloonEntity copyWith({
    double? x,
    double? y,
    BalloonPhase? phase,
    double? swayPhase,
    double? bobPhase,
    double? popProgress,
    double? wobbleTimer,
    double? bounceTimer,
    double? scale,
    double? targetY,
    bool? wave,
    bool clearTargetY = false,
  }) =>
      BalloonEntity(
        id: id,
        lane: lane,
        hue: hue,
        x: x ?? this.x,
        y: y ?? this.y,
        size: size,
        phase: phase ?? this.phase,
        pattern: pattern,
        face: face,
        ribbon: ribbon,
        swayPhase: swayPhase ?? this.swayPhase,
        bobPhase: bobPhase ?? this.bobPhase,
        popProgress: popProgress ?? this.popProgress,
        wobbleTimer: wobbleTimer ?? this.wobbleTimer,
        bounceTimer: bounceTimer ?? this.bounceTimer,
        scale: scale ?? this.scale,
        shineSeed: shineSeed,
        targetY: clearTargetY ? null : (targetY ?? this.targetY),
        wave: wave ?? this.wave,
      );

  @override
  List<Object?> get props => [
        id,
        lane,
        hue,
        x,
        y,
        size,
        phase,
        pattern,
        face,
        ribbon,
        swayPhase,
        bobPhase,
        popProgress,
        wobbleTimer,
        bounceTimer,
        scale,
        shineSeed,
        targetY,
        wave,
      ];
}

class BalloonPopReward extends Equatable {
  const BalloonPopReward({
    required this.points,
    required this.coins,
    required this.xp,
    required this.stars,
  });

  final int points;
  final int coins;
  final int xp;
  final int stars;

  @override
  List<Object?> get props => [points, coins, xp, stars];
}

const kBalloonPopPhrases = [
  'Great!',
  'Pop!',
  'Amazing!',
  'Wonderful!',
  'Yay!',
  'Super!',
  'So Fun!',
];

const kBalloonColorSuccessPhrases = [
  'Excellent!',
  'Wonderful!',
  'Great Job!',
  'You Found It!',
  'Amazing!',
];

const kBalloonColorTryPhrases = [
  'Good Try!',
  'Almost!',
  'Keep Looking!',
  'You Can Do It!',
];
