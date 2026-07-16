import 'package:equatable/equatable.dart';

enum CupcakeTopping { cherry, strawberry, sprinkles, star, heart, whipped, chocolateChip, rainbow }

class CupcakeDef extends Equatable {
  const CupcakeDef({
    required this.name,
    required this.frostingColor,
    required this.wrapperColor,
    required this.topping,
    this.accentColor = 0xFFFFFFFF,
    this.sizeScale = 1.0,
  });

  final String name;
  final int frostingColor;
  final int wrapperColor;
  final CupcakeTopping topping;
  final int accentColor;
  final double sizeScale;

  @override
  List<Object?> get props =>
      [name, frostingColor, wrapperColor, topping, accentColor, sizeScale];
}

abstract final class CupcakeVarieties {
  static const golden = CupcakeDef(
    name: 'Golden Cupcake',
    frostingColor: 0xFFFFD54F,
    wrapperColor: 0xFFFFB300,
    topping: CupcakeTopping.rainbow,
    accentColor: 0xFFFFF8E1,
    sizeScale: 1.15,
  );

  static const all = <CupcakeDef>[
    CupcakeDef(name: 'Pink Cherry', frostingColor: 0xFFF48FB1, wrapperColor: 0xFFEC407A, topping: CupcakeTopping.cherry),
    CupcakeDef(name: 'Blue Berry', frostingColor: 0xFF90CAF9, wrapperColor: 0xFF42A5F5, topping: CupcakeTopping.strawberry, accentColor: 0xFFE53935),
    CupcakeDef(name: 'Yellow Star', frostingColor: 0xFFFFF176, wrapperColor: 0xFFFFCA28, topping: CupcakeTopping.star),
    CupcakeDef(name: 'Purple Heart', frostingColor: 0xFFCE93D8, wrapperColor: 0xFFAB47BC, topping: CupcakeTopping.heart),
    CupcakeDef(name: 'Green Sprinkles', frostingColor: 0xFFA5D6A7, wrapperColor: 0xFF66BB6A, topping: CupcakeTopping.sprinkles, accentColor: 0xFFFF7043),
    CupcakeDef(name: 'Chocolate Chip', frostingColor: 0xFFBCAAA4, wrapperColor: 0xFF8D6E63, topping: CupcakeTopping.chocolateChip),
    CupcakeDef(name: 'Rainbow Swirl', frostingColor: 0xFFFFAB91, wrapperColor: 0xFFFF7043, topping: CupcakeTopping.rainbow),
    CupcakeDef(name: 'Whipped Cream', frostingColor: 0xFFFFFDE7, wrapperColor: 0xFFFFCC80, topping: CupcakeTopping.whipped),
    CupcakeDef(name: 'Tiny Pink', frostingColor: 0xFFF8BBD0, wrapperColor: 0xFFF06292, topping: CupcakeTopping.cherry, sizeScale: 0.88),
    CupcakeDef(name: 'Big Blue', frostingColor: 0xFF64B5F6, wrapperColor: 0xFF1E88E5, topping: CupcakeTopping.star, sizeScale: 1.12),
    CupcakeDef(name: 'Orange Fun', frostingColor: 0xFFFFCC80, wrapperColor: 0xFFFF9800, topping: CupcakeTopping.sprinkles, accentColor: 0xFF7E57C2),
  ];

  static CupcakeDef byIndex(int index, {bool isGolden = false}) =>
      isGolden ? golden : all[index % all.length];
}
