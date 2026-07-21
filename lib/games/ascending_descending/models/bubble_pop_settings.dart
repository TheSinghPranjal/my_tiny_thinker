import 'package:equatable/equatable.dart';
import 'package:my_tiny_thinker/core/game_config/game_duration.dart';

/// Little Explorers — Bubble Number Pop (fixed 0–10 range).
class BubbleNumberPopSettings extends Equatable {
  const BubbleNumberPopSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
  });

  final int sessionSeconds;

  BubbleNumberPopSettings copyWith({int? sessionSeconds}) =>
      BubbleNumberPopSettings(
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      );

  Map<String, dynamic> toJson() => {'sessionSeconds': sessionSeconds};

  factory BubbleNumberPopSettings.fromJson(Map<String, dynamic> json) =>
      BubbleNumberPopSettings(
        sessionSeconds: GameDuration.snap(
          json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
        ),
      );

  @override
  List<Object?> get props => [sessionSeconds];
}

/// Tiny Learners — Ascending / Descending ordered bubble pop.
class OrderedBubblePopSettings extends Equatable {
  const OrderedBubblePopSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.minValue = 0,
    this.maxValue = 20,
    this.bubbleCount = 8,
    this.randomNumbers = false,
  });

  static const int absoluteMin = -9999;
  static const int absoluteMax = 9999;

  final int sessionSeconds;
  final int minValue;
  final int maxValue;
  final int bubbleCount;
  final bool randomNumbers;

  OrderedBubblePopSettings copyWith({
    int? sessionSeconds,
    int? minValue,
    int? maxValue,
    int? bubbleCount,
    bool? randomNumbers,
  }) {
    final nextMin = (minValue ?? this.minValue).clamp(absoluteMin, absoluteMax);
    final nextMax = (maxValue ?? this.maxValue).clamp(absoluteMin, absoluteMax);
    return OrderedBubblePopSettings(
      sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      minValue: nextMin <= nextMax ? nextMin : nextMax,
      maxValue: nextMin <= nextMax ? nextMax : nextMin,
      bubbleCount: (bubbleCount ?? this.bubbleCount).clamp(5, 10),
      randomNumbers: randomNumbers ?? this.randomNumbers,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'minValue': minValue,
        'maxValue': maxValue,
        'bubbleCount': bubbleCount,
        'randomNumbers': randomNumbers,
      };

  factory OrderedBubblePopSettings.fromJson(Map<String, dynamic> json) {
    final min = (json['minValue'] as int? ?? 0).clamp(absoluteMin, absoluteMax);
    final max = (json['maxValue'] as int? ?? 20).clamp(absoluteMin, absoluteMax);
    return OrderedBubblePopSettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
      minValue: min <= max ? min : max,
      maxValue: min <= max ? max : min,
      bubbleCount: (json['bubbleCount'] as int? ?? 8).clamp(5, 10),
      randomNumbers: json['randomNumbers'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        minValue,
        maxValue,
        bubbleCount,
        randomNumbers,
      ];
}

/// Tiny Learners — Number Word Pop (match written word to digit bubble).
class NumberWordPopSettings extends Equatable {
  const NumberWordPopSettings({
    this.sessionSeconds = GameDuration.defaultSeconds,
    this.minValue = 0,
    this.maxValue = 50,
    this.bubbleCount = 8,
    this.randomNumbers = true,
  });

  static const int absoluteMin = 0;
  static const int absoluteMax = 9999;

  final int sessionSeconds;
  final int minValue;
  final int maxValue;
  final int bubbleCount;
  final bool randomNumbers;

  NumberWordPopSettings copyWith({
    int? sessionSeconds,
    int? minValue,
    int? maxValue,
    int? bubbleCount,
    bool? randomNumbers,
  }) {
    final nextMin = (minValue ?? this.minValue).clamp(absoluteMin, absoluteMax);
    final nextMax = (maxValue ?? this.maxValue).clamp(absoluteMin, absoluteMax);
    return NumberWordPopSettings(
      sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      minValue: nextMin <= nextMax ? nextMin : nextMax,
      maxValue: nextMin <= nextMax ? nextMax : nextMin,
      bubbleCount: (bubbleCount ?? this.bubbleCount).clamp(5, 10),
      randomNumbers: randomNumbers ?? this.randomNumbers,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionSeconds': sessionSeconds,
        'minValue': minValue,
        'maxValue': maxValue,
        'bubbleCount': bubbleCount,
        'randomNumbers': randomNumbers,
      };

  factory NumberWordPopSettings.fromJson(Map<String, dynamic> json) {
    final min =
        (json['minValue'] as int? ?? 0).clamp(absoluteMin, absoluteMax);
    final max =
        (json['maxValue'] as int? ?? 50).clamp(absoluteMin, absoluteMax);
    return NumberWordPopSettings(
      sessionSeconds: GameDuration.snap(
        json['sessionSeconds'] as int? ?? GameDuration.defaultSeconds,
      ),
      minValue: min <= max ? min : max,
      maxValue: min <= max ? max : min,
      bubbleCount: (json['bubbleCount'] as int? ?? 8).clamp(5, 10),
      randomNumbers: json['randomNumbers'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        sessionSeconds,
        minValue,
        maxValue,
        bubbleCount,
        randomNumbers,
      ];
}
