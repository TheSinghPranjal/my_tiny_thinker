import 'package:equatable/equatable.dart';

enum InsectKind { butterfly, firefly }

class InsectDef extends Equatable {
  const InsectDef({
    required this.kind,
    required this.name,
    required this.primaryColor,
    required this.wingColor,
    this.glowColor = 0xFFFFF176,
    this.bodyColor = 0xFF37474F,
  });

  final InsectKind kind;
  final String name;
  final int primaryColor;
  final int wingColor;
  final int glowColor;
  final int bodyColor;

  bool get isFirefly => kind == InsectKind.firefly;

  @override
  List<Object?> get props =>
      [kind, name, primaryColor, wingColor, glowColor, bodyColor];
}

abstract final class FlyingInsects {
  /// Daytime — butterflies only (multiple color variants).
  static const butterflies = <InsectDef>[
    InsectDef(
      kind: InsectKind.butterfly,
      name: 'Butterfly',
      primaryColor: 0xFFEC407A,
      wingColor: 0xFFAB47BC,
      bodyColor: 0xFF37474F,
    ),
    InsectDef(
      kind: InsectKind.butterfly,
      name: 'Butterfly',
      primaryColor: 0xFF42A5F5,
      wingColor: 0xFF7E57C2,
      bodyColor: 0xFF37474F,
    ),
    InsectDef(
      kind: InsectKind.butterfly,
      name: 'Butterfly',
      primaryColor: 0xFFFFB74D,
      wingColor: 0xFFFF7043,
      bodyColor: 0xFF37474F,
    ),
    InsectDef(
      kind: InsectKind.butterfly,
      name: 'Butterfly',
      primaryColor: 0xFF66BB6A,
      wingColor: 0xFF26A69A,
      bodyColor: 0xFF37474F,
    ),
    InsectDef(
      kind: InsectKind.butterfly,
      name: 'Butterfly',
      primaryColor: 0xFFFFEE58,
      wingColor: 0xFFFFCA28,
      bodyColor: 0xFF37474F,
    ),
  ];

  static const fireflies = <InsectDef>[
    InsectDef(
      kind: InsectKind.firefly,
      name: 'Firefly',
      primaryColor: 0xFF5D4037,
      wingColor: 0xFFB3E5FC,
      glowColor: 0xFFFFF176,
      bodyColor: 0xFF3E2723,
    ),
    InsectDef(
      kind: InsectKind.firefly,
      name: 'Firefly',
      primaryColor: 0xFF4E342E,
      wingColor: 0xFF80DEEA,
      glowColor: 0xFFCCFF90,
      bodyColor: 0xFF33691E,
    ),
    InsectDef(
      kind: InsectKind.firefly,
      name: 'Firefly',
      primaryColor: 0xFF455A64,
      wingColor: 0xFFB2EBF2,
      glowColor: 0xFF80DEEA,
      bodyColor: 0xFF263238,
    ),
  ];

  static InsectDef pickButterfly(int seed) => butterflies[seed % butterflies.length];

  static InsectDef pickFirefly(int seed) => fireflies[seed % fireflies.length];

  static InsectDef forEntity({required bool isFirefly, required int seed}) =>
      isFirefly ? pickFirefly(seed) : pickButterfly(seed);
}
