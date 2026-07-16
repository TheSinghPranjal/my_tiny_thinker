import 'package:equatable/equatable.dart';

enum GardenButterflyPattern { solid, spotted, striped, rainbow }

class GardenButterflyDef extends Equatable {
  const GardenButterflyDef({
    required this.name,
    required this.primaryColor,
    required this.wingColor,
    required this.pattern,
    this.spotColor = 0xFFFFFFFF,
    this.bodyColor = 0xFF37474F,
  });

  final String name;
  final int primaryColor;
  final int wingColor;
  final GardenButterflyPattern pattern;
  final int spotColor;
  final int bodyColor;

  @override
  List<Object?> get props =>
      [name, primaryColor, wingColor, pattern, spotColor, bodyColor];
}

abstract final class GardenButterflies {
  static const golden = GardenButterflyDef(
    name: 'Golden Butterfly',
    primaryColor: 0xFFFFD54F,
    wingColor: 0xFFFFB300,
    pattern: GardenButterflyPattern.rainbow,
    spotColor: 0xFFFFF8E1,
    bodyColor: 0xFF5D4037,
  );

  static const varieties = <GardenButterflyDef>[
    GardenButterflyDef(
      name: 'Blue Butterfly',
      primaryColor: 0xFF42A5F5,
      wingColor: 0xFF1E88E5,
      pattern: GardenButterflyPattern.solid,
    ),
    GardenButterflyDef(
      name: 'Yellow Butterfly',
      primaryColor: 0xFFFFEE58,
      wingColor: 0xFFFFCA28,
      pattern: GardenButterflyPattern.spotted,
      spotColor: 0xFFFF7043,
    ),
    GardenButterflyDef(
      name: 'Pink Butterfly',
      primaryColor: 0xFFEC407A,
      wingColor: 0xFFAB47BC,
      pattern: GardenButterflyPattern.solid,
    ),
    GardenButterflyDef(
      name: 'Orange Butterfly',
      primaryColor: 0xFFFFB74D,
      wingColor: 0xFFFF7043,
      pattern: GardenButterflyPattern.striped,
    ),
    GardenButterflyDef(
      name: 'Purple Butterfly',
      primaryColor: 0xFFAB47BC,
      wingColor: 0xFF7E57C2,
      pattern: GardenButterflyPattern.spotted,
      spotColor: 0xFFE1BEE7,
    ),
    GardenButterflyDef(
      name: 'Green Butterfly',
      primaryColor: 0xFF66BB6A,
      wingColor: 0xFF26A69A,
      pattern: GardenButterflyPattern.solid,
    ),
    GardenButterflyDef(
      name: 'Rainbow Butterfly',
      primaryColor: 0xFFEF5350,
      wingColor: 0xFF42A5F5,
      pattern: GardenButterflyPattern.rainbow,
    ),
    GardenButterflyDef(
      name: 'Spotted Butterfly',
      primaryColor: 0xFFFF8A65,
      wingColor: 0xFFFFCC80,
      pattern: GardenButterflyPattern.spotted,
      spotColor: 0xFF5D4037,
    ),
  ];

  static GardenButterflyDef byIndex(int index, {bool isGolden = false}) =>
      isGolden ? golden : varieties[index % varieties.length];
}
