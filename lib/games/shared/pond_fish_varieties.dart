import 'package:equatable/equatable.dart';

enum PondFishPattern { solid, striped, spotted, rainbow, tropical }

class PondFishDef extends Equatable {
  const PondFishDef({
    required this.name,
    required this.bodyColor,
    required this.finColor,
    required this.pattern,
    this.spotColor = 0xFFFFFFFF,
    this.lengthScale = 1.0,
  });

  final String name;
  final int bodyColor;
  final int finColor;
  final PondFishPattern pattern;
  final int spotColor;
  final double lengthScale;

  @override
  List<Object?> get props =>
      [name, bodyColor, finColor, pattern, spotColor, lengthScale];
}

abstract final class PondFishVarieties {
  static const golden = PondFishDef(
    name: 'Golden Fish',
    bodyColor: 0xFFFFD54F,
    finColor: 0xFFFFB300,
    pattern: PondFishPattern.rainbow,
    spotColor: 0xFFFFF8E1,
    lengthScale: 1.1,
  );

  static const all = <PondFishDef>[
    PondFishDef(name: 'Orange Fish', bodyColor: 0xFFFF7043, finColor: 0xFFFFAB91, pattern: PondFishPattern.solid),
    PondFishDef(name: 'Blue Fish', bodyColor: 0xFF42A5F5, finColor: 0xFF1E88E5, pattern: PondFishPattern.solid),
    PondFishDef(name: 'Yellow Fish', bodyColor: 0xFFFFEE58, finColor: 0xFFFFCA28, pattern: PondFishPattern.spotted, spotColor: 0xFFFF7043),
    PondFishDef(name: 'Purple Fish', bodyColor: 0xFFAB47BC, finColor: 0xFF7E57C2, pattern: PondFishPattern.solid),
    PondFishDef(name: 'Green Fish', bodyColor: 0xFF66BB6A, finColor: 0xFF43A047, pattern: PondFishPattern.striped),
    PondFishDef(name: 'Rainbow Fish', bodyColor: 0xFFEF5350, finColor: 0xFF42A5F5, pattern: PondFishPattern.rainbow),
    PondFishDef(name: 'Spotted Fish', bodyColor: 0xFFFF8A65, finColor: 0xFFFFCC80, pattern: PondFishPattern.spotted, spotColor: 0xFF5D4037),
    PondFishDef(name: 'Tiny Fish', bodyColor: 0xFF4DD0E1, finColor: 0xFF00ACC1, pattern: PondFishPattern.solid, lengthScale: 0.75),
    PondFishDef(name: 'Round Fish', bodyColor: 0xFFEC407A, finColor: 0xFFF48FB1, pattern: PondFishPattern.solid, lengthScale: 0.9),
    PondFishDef(name: 'Long Fish', bodyColor: 0xFF26A69A, finColor: 0xFF00897B, pattern: PondFishPattern.striped, lengthScale: 1.25),
    PondFishDef(name: 'Tropical Fish', bodyColor: 0xFFFFB74D, finColor: 0xFF7E57C2, pattern: PondFishPattern.tropical),
  ];

  static PondFishDef byIndex(int index, {bool isGolden = false}) =>
      isGolden ? golden : all[index % all.length];
}
