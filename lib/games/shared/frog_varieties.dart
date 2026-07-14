import 'package:equatable/equatable.dart';

enum FrogPattern { smooth, spotted, striped, leafy, mossy, shiny }

/// Expandable frog appearance definitions for Frog Pond Adventure.
class FrogVariety extends Equatable {
  const FrogVariety({
    required this.id,
    required this.name,
    required this.bodyColor,
    required this.bellyColor,
    required this.spotColor,
    this.pattern = FrogPattern.smooth,
  });

  final String id;
  final String name;
  final int bodyColor;
  final int bellyColor;
  final int spotColor;
  final FrogPattern pattern;

  @override
  List<Object?> get props => [id, name, bodyColor, bellyColor, spotColor, pattern];
}

abstract final class FrogVarieties {
  static const all = <FrogVariety>[
    FrogVariety(id: 'mint', name: 'Mint', bodyColor: 0xFF81C784, bellyColor: 0xFFC8E6C9, spotColor: 0xFF388E3C, pattern: FrogPattern.smooth),
    FrogVariety(id: 'lime', name: 'Lime', bodyColor: 0xFFAED581, bellyColor: 0xFFDCEDC8, spotColor: 0xFF689F38, pattern: FrogPattern.spotted),
    FrogVariety(id: 'emerald', name: 'Emerald', bodyColor: 0xFF43A047, bellyColor: 0xFFA5D6A7, spotColor: 0xFF1B5E20, pattern: FrogPattern.smooth),
    FrogVariety(id: 'olive', name: 'Olive', bodyColor: 0xFF827717, bellyColor: 0xFFDCE775, spotColor: 0xFF558B2F, pattern: FrogPattern.mossy),
    FrogVariety(id: 'moss', name: 'Moss', bodyColor: 0xFF558B2F, bellyColor: 0xFFC5E1A5, spotColor: 0xFF33691E, pattern: FrogPattern.mossy),
    FrogVariety(id: 'forest', name: 'Forest', bodyColor: 0xFF2E7D32, bellyColor: 0xFFA5D6A7, spotColor: 0xFF1B5E20, pattern: FrogPattern.leafy),
    FrogVariety(id: 'jade', name: 'Jade', bodyColor: 0xFF26A69A, bellyColor: 0xFFB2DFDB, spotColor: 0xFF00695C, pattern: FrogPattern.shiny),
    FrogVariety(id: 'tropical', name: 'Tropical', bodyColor: 0xFF66BB6A, bellyColor: 0xFFFFF176, spotColor: 0xFF1565C0, pattern: FrogPattern.spotted),
    FrogVariety(id: 'spring', name: 'Spring', bodyColor: 0xFF9CCC65, bellyColor: 0xFFF0F4C3, spotColor: 0xFF689F38, pattern: FrogPattern.striped),
    FrogVariety(id: 'meadow', name: 'Meadow', bodyColor: 0xFF7CB342, bellyColor: 0xFFDCEDC8, spotColor: 0xFF33691E, pattern: FrogPattern.spotted),
    FrogVariety(id: 'leaf', name: 'Leafy', bodyColor: 0xFF689F38, bellyColor: 0xFFC5E1A5, spotColor: 0xFF33691E, pattern: FrogPattern.leafy),
    FrogVariety(id: 'pond', name: 'Pond', bodyColor: 0xFF4CAF50, bellyColor: 0xFFE8F5E9, spotColor: 0xFF2E7D32, pattern: FrogPattern.smooth),
  ];

  static FrogVariety byIndex(int i) => all[i % all.length];
}
