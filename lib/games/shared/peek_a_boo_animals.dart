import 'package:equatable/equatable.dart';

enum AnimalExitStyle { walk, hop, fly, swim, waddle }

/// Expandable animal definition for Peek-a-Boo Animal Friends.
class PeekAnimalDef extends Equatable {
  const PeekAnimalDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.soundText,
    required this.exitStyle,
    this.primaryColor = 0xFFFFB74D,
    this.secondaryColor = 0xFF8D6E63,
  });

  final String id;
  final String name;
  final String emoji;
  final String soundText;
  final AnimalExitStyle exitStyle;
  final int primaryColor;
  final int secondaryColor;

  String get announcement => '$name! $soundText';

  @override
  List<Object?> get props =>
      [id, name, emoji, soundText, exitStyle, primaryColor, secondaryColor];
}

abstract final class PeekABooAnimals {
  static const all = <PeekAnimalDef>[
    PeekAnimalDef(
      id: 'dog',
      name: 'Dog',
      emoji: '🐶',
      soundText: 'Woof Woof!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFBCAAA4,
    ),
    PeekAnimalDef(
      id: 'cat',
      name: 'Cat',
      emoji: '🐱',
      soundText: 'Meow!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFFFCC80,
    ),
    PeekAnimalDef(
      id: 'cow',
      name: 'Cow',
      emoji: '🐮',
      soundText: 'Moo!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFE0E0E0,
      secondaryColor: 0xFF424242,
    ),
    PeekAnimalDef(
      id: 'duck',
      name: 'Duck',
      emoji: '🦆',
      soundText: 'Quack Quack!',
      exitStyle: AnimalExitStyle.waddle,
      primaryColor: 0xFFFFF176,
    ),
    PeekAnimalDef(
      id: 'rabbit',
      name: 'Rabbit',
      emoji: '🐰',
      soundText: 'Hop Hop!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFF8BBD0,
    ),
    PeekAnimalDef(
      id: 'lion',
      name: 'Lion',
      emoji: '🦁',
      soundText: 'Roar!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFFFB74D,
    ),
    PeekAnimalDef(
      id: 'tiger',
      name: 'Tiger',
      emoji: '🐯',
      soundText: 'Grrr!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFFF9800,
    ),
    PeekAnimalDef(
      id: 'monkey',
      name: 'Monkey',
      emoji: '🐵',
      soundText: 'Oo Oo Aa Aa!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFBCAAA4,
    ),
    PeekAnimalDef(
      id: 'elephant',
      name: 'Elephant',
      emoji: '🐘',
      soundText: 'Trumpet!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFB0BEC5,
    ),
    PeekAnimalDef(
      id: 'panda',
      name: 'Panda',
      emoji: '🐼',
      soundText: 'Chomp Chomp!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFEEEEEE,
      secondaryColor: 0xFF212121,
    ),
    PeekAnimalDef(
      id: 'bear',
      name: 'Bear',
      emoji: '🐻',
      soundText: 'Growl!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFF8D6E63,
    ),
    PeekAnimalDef(
      id: 'horse',
      name: 'Horse',
      emoji: '🐴',
      soundText: 'Neigh!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFBCAAA4,
    ),
    PeekAnimalDef(
      id: 'pig',
      name: 'Pig',
      emoji: '🐷',
      soundText: 'Oink Oink!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFF48FB1,
    ),
    PeekAnimalDef(
      id: 'sheep',
      name: 'Sheep',
      emoji: '🐑',
      soundText: 'Baa Baa!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFECEFF1,
    ),
    PeekAnimalDef(
      id: 'chicken',
      name: 'Chicken',
      emoji: '🐔',
      soundText: 'Cluck Cluck!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFFFCC80,
    ),
    PeekAnimalDef(
      id: 'frog',
      name: 'Frog',
      emoji: '🐸',
      soundText: 'Ribbit!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFF81C784,
    ),
    PeekAnimalDef(
      id: 'penguin',
      name: 'Penguin',
      emoji: '🐧',
      soundText: 'Honk Honk!',
      exitStyle: AnimalExitStyle.waddle,
      primaryColor: 0xFF37474F,
      secondaryColor: 0xFFECEFF1,
    ),
    PeekAnimalDef(
      id: 'fish',
      name: 'Fish',
      emoji: '🐟',
      soundText: 'Blub Blub!',
      exitStyle: AnimalExitStyle.swim,
      primaryColor: 0xFF4FC3F7,
    ),
    PeekAnimalDef(
      id: 'owl',
      name: 'Owl',
      emoji: '🦉',
      soundText: 'Hoo Hoo!',
      exitStyle: AnimalExitStyle.fly,
      primaryColor: 0xFF8D6E63,
    ),
    PeekAnimalDef(
      id: 'fox',
      name: 'Fox',
      emoji: '🦊',
      soundText: 'Yip Yip!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFFF7043,
    ),
    PeekAnimalDef(
      id: 'giraffe',
      name: 'Giraffe',
      emoji: '🦒',
      soundText: 'Munch!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFFFCA28,
    ),
    PeekAnimalDef(
      id: 'kangaroo',
      name: 'Kangaroo',
      emoji: '🦘',
      soundText: 'Boing!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFBCAAA4,
    ),
    PeekAnimalDef(
      id: 'zebra',
      name: 'Zebra',
      emoji: '🦓',
      soundText: 'Neigh!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFFEEEEEE,
      secondaryColor: 0xFF212121,
    ),
    PeekAnimalDef(
      id: 'turtle',
      name: 'Turtle',
      emoji: '🐢',
      soundText: 'Slow!',
      exitStyle: AnimalExitStyle.walk,
      primaryColor: 0xFF66BB6A,
    ),
    PeekAnimalDef(
      id: 'dolphin',
      name: 'Dolphin',
      emoji: '🐬',
      soundText: 'Squeak!',
      exitStyle: AnimalExitStyle.swim,
      primaryColor: 0xFF4DD0E1,
    ),
    PeekAnimalDef(
      id: 'whale',
      name: 'Whale',
      emoji: '🐋',
      soundText: 'Splash!',
      exitStyle: AnimalExitStyle.swim,
      primaryColor: 0xFF42A5F5,
    ),
    PeekAnimalDef(
      id: 'parrot',
      name: 'Parrot',
      emoji: '🦜',
      soundText: 'Squawk!',
      exitStyle: AnimalExitStyle.fly,
      primaryColor: 0xFF66BB6A,
    ),
    PeekAnimalDef(
      id: 'peacock',
      name: 'Peacock',
      emoji: '🦚',
      soundText: 'Tweet!',
      exitStyle: AnimalExitStyle.fly,
      primaryColor: 0xFF26A69A,
    ),
    PeekAnimalDef(
      id: 'deer',
      name: 'Deer',
      emoji: '🦌',
      soundText: 'Snort!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFFBCAAA4,
    ),
    PeekAnimalDef(
      id: 'squirrel',
      name: 'Squirrel',
      emoji: '🐿️',
      soundText: 'Chitter!',
      exitStyle: AnimalExitStyle.hop,
      primaryColor: 0xFF8D6E63,
    ),
  ];

  static PeekAnimalDef? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
