import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MoonRescuePhase { ready, playing, paused, celebrating, finished }

enum AstronautPhase {
  floating,
  pushed,
  landing,
  running,
  waiting,
  boarding,
  boarded,
}

enum RocketPhase { idle, ready, launching, arriving }

class MoonAstronaut extends Equatable {
  const MoonAstronaut({
    required this.id,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.rotation = 0,
    this.spin = 0,
    this.phase = AstronautPhase.floating,
    this.variety = 0,
    this.wavePhase = 0,
    this.landProgress = 0,
    this.runProgress = 0,
    this.enterProgress = 1,
    this.trail = false,
  });

  final String id;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double spin;
  final AstronautPhase phase;
  final int variety;
  final double wavePhase;
  final double landProgress;
  final double runProgress;
  /// 0 → 1 fade/slide-in when a replacement astronaut appears.
  final double enterProgress;
  final bool trail;

  bool get isActive =>
      phase != AstronautPhase.boarded && phase != AstronautPhase.boarding;

  MoonAstronaut copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? rotation,
    double? spin,
    AstronautPhase? phase,
    int? variety,
    double? wavePhase,
    double? landProgress,
    double? runProgress,
    double? enterProgress,
    bool? trail,
  }) =>
      MoonAstronaut(
        id: id,
        x: x ?? this.x,
        y: y ?? this.y,
        vx: vx ?? this.vx,
        vy: vy ?? this.vy,
        rotation: rotation ?? this.rotation,
        spin: spin ?? this.spin,
        phase: phase ?? this.phase,
        variety: variety ?? this.variety,
        wavePhase: wavePhase ?? this.wavePhase,
        landProgress: landProgress ?? this.landProgress,
        runProgress: runProgress ?? this.runProgress,
        enterProgress: enterProgress ?? this.enterProgress,
        trail: trail ?? this.trail,
      );

  @override
  List<Object?> get props => [
        id,
        x,
        y,
        vx,
        vy,
        rotation,
        spin,
        phase,
        variety,
        wavePhase,
        landProgress,
        runProgress,
        enterProgress,
        trail,
      ];
}

class MoonRocket extends Equatable {
  const MoonRocket({
    this.phase = RocketPhase.idle,
    this.passengers = 0,
    this.x = 0.5,
    this.y = 0.82,
    this.bobPhase = 0,
    this.launchProgress = 0,
    this.arriveProgress = 1,
    this.lightBlink = 0,
  });

  final RocketPhase phase;
  final int passengers;
  final double x;
  final double y;
  final double bobPhase;
  final double launchProgress;
  final double arriveProgress;
  final double lightBlink;

  MoonRocket copyWith({
    RocketPhase? phase,
    int? passengers,
    double? x,
    double? y,
    double? bobPhase,
    double? launchProgress,
    double? arriveProgress,
    double? lightBlink,
  }) =>
      MoonRocket(
        phase: phase ?? this.phase,
        passengers: passengers ?? this.passengers,
        x: x ?? this.x,
        y: y ?? this.y,
        bobPhase: bobPhase ?? this.bobPhase,
        launchProgress: launchProgress ?? this.launchProgress,
        arriveProgress: arriveProgress ?? this.arriveProgress,
        lightBlink: lightBlink ?? this.lightBlink,
      );

  @override
  List<Object?> get props => [
        phase,
        passengers,
        x,
        y,
        bobPhase,
        launchProgress,
        arriveProgress,
        lightBlink,
      ];
}

class MoonRescueSettings extends Equatable {
  const MoonRescueSettings({
    this.sessionSeconds = 60,
    this.astronautCount = 5,
    this.rocketCapacity = 3,
    this.floatSpeed = 1.0,
    this.driftIntensity = 1.0,
    this.rewardMultiplier = 1.0,
    this.soundEnabled = true,
    this.narrationEnabled = true,
    this.musicEnabled = true,
    this.rocketSoundsEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.largerTouchTargets = true,
  });

  final int sessionSeconds;
  final int astronautCount;
  final int rocketCapacity;
  final double floatSpeed;
  final double driftIntensity;
  final double rewardMultiplier;
  final bool soundEnabled;
  final bool narrationEnabled;
  final bool musicEnabled;
  final bool rocketSoundsEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool largerTouchTargets;

  bool get unlimitedTime => sessionSeconds <= 0;

  MoonRescueSettings copyWith({
    int? sessionSeconds,
    int? astronautCount,
    int? rocketCapacity,
    double? floatSpeed,
    double? driftIntensity,
    double? rewardMultiplier,
    bool? soundEnabled,
    bool? narrationEnabled,
    bool? musicEnabled,
    bool? rocketSoundsEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? largerTouchTargets,
  }) =>
      MoonRescueSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
        astronautCount: astronautCount ?? this.astronautCount,
        rocketCapacity: rocketCapacity ?? this.rocketCapacity,
        floatSpeed: floatSpeed ?? this.floatSpeed,
        driftIntensity: driftIntensity ?? this.driftIntensity,
        rewardMultiplier: rewardMultiplier ?? this.rewardMultiplier,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        narrationEnabled: narrationEnabled ?? this.narrationEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        rocketSoundsEnabled: rocketSoundsEnabled ?? this.rocketSoundsEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        reducedMotion: reducedMotion ?? this.reducedMotion,
        largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      );

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'astronautCount': astronautCount,
        'rocketCapacity': rocketCapacity,
        'floatSpeed': floatSpeed,
        'driftIntensity': driftIntensity,
        'rewardMultiplier': rewardMultiplier,
        'soundEnabled': soundEnabled,
        'narrationEnabled': narrationEnabled,
        'musicEnabled': musicEnabled,
        'rocketSoundsEnabled': rocketSoundsEnabled,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'largerTouchTargets': largerTouchTargets,
      };

  factory MoonRescueSettings.fromJson(Map<String, dynamic> json) =>
      MoonRescueSettings(
        sessionSeconds: (json['sessionSeconds'] as int? ?? 60).clamp(0, 1800),
        astronautCount: (json['astronautCount'] as int? ?? 5).clamp(5, 12),
        rocketCapacity: (json['rocketCapacity'] as int? ?? 3).clamp(2, 5),
        floatSpeed: (json['floatSpeed'] as num? ?? 1.0).toDouble().clamp(0.5, 2),
        driftIntensity:
            (json['driftIntensity'] as num? ?? 1.0).toDouble().clamp(0.5, 2),
        rewardMultiplier:
            (json['rewardMultiplier'] as num? ?? 1.0).toDouble(),
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        narrationEnabled: json['narrationEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        rocketSoundsEnabled: json['rocketSoundsEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        largerTouchTargets: json['largerTouchTargets'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        sessionSeconds,
        astronautCount,
        rocketCapacity,
        floatSpeed,
        driftIntensity,
        rewardMultiplier,
        soundEnabled,
        narrationEnabled,
        musicEnabled,
        rocketSoundsEnabled,
        hapticsEnabled,
        reducedMotion,
        largerTouchTargets,
      ];
}

class MoonRescueState extends Equatable {
  const MoonRescueState({
    this.phase = MoonRescuePhase.ready,
    this.settings = const MoonRescueSettings(),
    this.astronauts = const [],
    this.rocket = const MoonRocket(),
    this.playArea = Size.zero,
    this.remainingSeconds = 0,
    this.score = 0,
    this.astronautsRescued = 0,
    this.rocketsLaunched = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.starsEarned = 0,
    this.feedbackMessage,
    this.lastRewardText,
    this.spokenPhrase,
    this.showSparkles = false,
    this.showMascot = false,
    this.showEarthCelebration = false,
    this.pendingEnd = false,
    this.envPhase = 0,
    this.spawnCounter = 0,
  });

  final MoonRescuePhase phase;
  final MoonRescueSettings settings;
  final List<MoonAstronaut> astronauts;
  final MoonRocket rocket;
  final Size playArea;
  final int remainingSeconds;
  final int score;
  final int astronautsRescued;
  final int rocketsLaunched;
  final int streak;
  final int maxStreak;
  final int coinsEarned;
  final int xpEarned;
  final int starsEarned;
  final String? feedbackMessage;
  final String? lastRewardText;
  final String? spokenPhrase;
  final bool showSparkles;
  final bool showMascot;
  final bool showEarthCelebration;
  final bool pendingEnd;
  final double envPhase;
  final int spawnCounter;

  bool get playAreaReady => playArea.width > 0 && playArea.height > 0;

  bool get hasActiveRescue => astronauts.any(
        (a) =>
            a.phase == AstronautPhase.pushed ||
            a.phase == AstronautPhase.landing ||
            a.phase == AstronautPhase.running ||
            a.phase == AstronautPhase.waiting ||
            a.phase == AstronautPhase.boarding,
      );

  bool get hasActiveLaunch =>
      rocket.phase == RocketPhase.launching ||
      rocket.phase == RocketPhase.arriving;

  MoonRescueState copyWith({
    MoonRescuePhase? phase,
    MoonRescueSettings? settings,
    List<MoonAstronaut>? astronauts,
    MoonRocket? rocket,
    Size? playArea,
    int? remainingSeconds,
    int? score,
    int? astronautsRescued,
    int? rocketsLaunched,
    int? streak,
    int? maxStreak,
    int? coinsEarned,
    int? xpEarned,
    int? starsEarned,
    String? feedbackMessage,
    String? lastRewardText,
    String? spokenPhrase,
    bool? showSparkles,
    bool? showMascot,
    bool? showEarthCelebration,
    bool? pendingEnd,
    double? envPhase,
    int? spawnCounter,
    bool clearFeedback = false,
    bool clearSpoken = false,
  }) =>
      MoonRescueState(
        phase: phase ?? this.phase,
        settings: settings ?? this.settings,
        astronauts: astronauts ?? this.astronauts,
        rocket: rocket ?? this.rocket,
        playArea: playArea ?? this.playArea,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        score: score ?? this.score,
        astronautsRescued: astronautsRescued ?? this.astronautsRescued,
        rocketsLaunched: rocketsLaunched ?? this.rocketsLaunched,
        streak: streak ?? this.streak,
        maxStreak: maxStreak ?? this.maxStreak,
        coinsEarned: coinsEarned ?? this.coinsEarned,
        xpEarned: xpEarned ?? this.xpEarned,
        starsEarned: starsEarned ?? this.starsEarned,
        feedbackMessage:
            clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
        lastRewardText:
            clearFeedback ? null : (lastRewardText ?? this.lastRewardText),
        spokenPhrase: clearSpoken ? null : (spokenPhrase ?? this.spokenPhrase),
        showSparkles: showSparkles ?? this.showSparkles,
        showMascot: showMascot ?? this.showMascot,
        showEarthCelebration:
            showEarthCelebration ?? this.showEarthCelebration,
        pendingEnd: pendingEnd ?? this.pendingEnd,
        envPhase: envPhase ?? this.envPhase,
        spawnCounter: spawnCounter ?? this.spawnCounter,
      );

  @override
  List<Object?> get props => [
        phase,
        settings,
        astronauts,
        rocket,
        playArea,
        remainingSeconds,
        score,
        astronautsRescued,
        rocketsLaunched,
        streak,
        maxStreak,
        coinsEarned,
        xpEarned,
        starsEarned,
        feedbackMessage,
        lastRewardText,
        spokenPhrase,
        showSparkles,
        showMascot,
        showEarthCelebration,
        pendingEnd,
        envPhase,
        spawnCounter,
      ];
}

class MoonRescueResult extends Equatable {
  const MoonRescueResult({
    required this.score,
    required this.astronautsRescued,
    required this.rocketsLaunched,
    required this.maxStreak,
    required this.coins,
    required this.xp,
    required this.stars,
  });

  final int score;
  final int astronautsRescued;
  final int rocketsLaunched;
  final int maxStreak;
  final int coins;
  final int xp;
  final int stars;

  @override
  List<Object?> get props => [
        score,
        astronautsRescued,
        rocketsLaunched,
        maxStreak,
        coins,
        xp,
        stars,
      ];
}

const kMoonRescueSkills = [
  'Hand-Eye Coordination',
  'Visual Tracking',
  'Spatial Awareness',
  'Cause & Effect',
  'Fine Motor Skills',
  'Planning',
];

const kMoonRescueSessionPresets = [60, 120, 180, 300, 600, 900, 1800];

const kMoonRescueReadyPhrases = [
  'Rocket Ready!',
  'Mission Complete!',
  'Tap the Rocket to Launch!',
];

abstract final class MoonRescuePalette {
  static const spaceTop = Color(0xFF1A237E);
  static const spaceMid = Color(0xFF4A148C);
  static const spaceBottom = Color(0xFF311B92);
  static const moon = Color(0xFFECEFF1);
  static const moonShadow = Color(0xFFB0BEC5);
  static const earthBlue = Color(0xFF42A5F5);
  static const earthGreen = Color(0xFF66BB6A);
  static const rocketBody = Color(0xFFFFF8E1);
  static const rocketAccent = Color(0xFFEF5350);
  static const suit = Color(0xFFFAFAFA);
}
