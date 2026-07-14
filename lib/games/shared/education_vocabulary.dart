import 'package:equatable/equatable.dart';

/// Shared vocabulary item used by Shadow Match and Alphabet Adventure.
class VocabItem extends Equatable {
  const VocabItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.letter,
  });

  final String id;
  final String name;
  final String emoji;
  final String letter;

  @override
  List<Object?> get props => [id, name, emoji, letter];
}

abstract final class EducationVocabulary {
  static const items = <VocabItem>[
    VocabItem(id: 'apple', name: 'Apple', emoji: '🍎', letter: 'A'),
    VocabItem(id: 'airplane', name: 'Airplane', emoji: '✈️', letter: 'A'),
    VocabItem(id: 'ball', name: 'Ball', emoji: '⚽', letter: 'B'),
    VocabItem(id: 'bicycle', name: 'Bicycle', emoji: '🚲', letter: 'B'),
    VocabItem(id: 'butterfly', name: 'Butterfly', emoji: '🦋', letter: 'B'),
    VocabItem(id: 'cat', name: 'Cat', emoji: '🐱', letter: 'C'),
    VocabItem(id: 'camera', name: 'Camera', emoji: '📷', letter: 'C'),
    VocabItem(id: 'car', name: 'Car', emoji: '🚗', letter: 'C'),
    VocabItem(id: 'cherry', name: 'Cherry', emoji: '🍒', letter: 'C'),
    VocabItem(id: 'clock', name: 'Clock', emoji: '🕐', letter: 'C'),
    VocabItem(id: 'christmas_tree', name: 'Christmas Tree', emoji: '🎄', letter: 'C'),
    VocabItem(id: 'dog', name: 'Dog', emoji: '🐶', letter: 'D'),
    VocabItem(id: 'dinosaur', name: 'Dinosaur', emoji: '🦕', letter: 'D'),
    VocabItem(id: 'dolphin', name: 'Dolphin', emoji: '🐬', letter: 'D'),
    VocabItem(id: 'duck', name: 'Duck', emoji: '🦆', letter: 'D'),
    VocabItem(id: 'elephant', name: 'Elephant', emoji: '🐘', letter: 'E'),
    VocabItem(id: 'egg', name: 'Egg', emoji: '🥚', letter: 'E'),
    VocabItem(id: 'fish', name: 'Fish', emoji: '🐟', letter: 'F'),
    VocabItem(id: 'fire_truck', name: 'Fire Truck', emoji: '🚒', letter: 'F'),
    VocabItem(id: 'flower', name: 'Flower', emoji: '🌸', letter: 'F'),
    VocabItem(id: 'frog', name: 'Frog', emoji: '🐸', letter: 'F'),
    VocabItem(id: 'girl', name: 'Girl', emoji: '👧', letter: 'G'),
    VocabItem(id: 'giraffe', name: 'Giraffe', emoji: '🦒', letter: 'G'),
    VocabItem(id: 'grapes', name: 'Grapes', emoji: '🍇', letter: 'G'),
    VocabItem(id: 'horse', name: 'Horse', emoji: '🐴', letter: 'H'),
    VocabItem(id: 'helicopter', name: 'Helicopter', emoji: '🚁', letter: 'H'),
    VocabItem(id: 'house', name: 'House', emoji: '🏠', letter: 'H'),
    VocabItem(id: 'ice_cream', name: 'Ice Cream', emoji: '🍦', letter: 'I'),
    VocabItem(id: 'jelly', name: 'Jelly', emoji: '🍮', letter: 'J'),
    VocabItem(id: 'kite', name: 'Kite', emoji: '🪁', letter: 'K'),
    VocabItem(id: 'kangaroo', name: 'Kangaroo', emoji: '🦘', letter: 'K'),
    VocabItem(id: 'lemon', name: 'Lemon', emoji: '🍋', letter: 'L'),
    VocabItem(id: 'lion', name: 'Lion', emoji: '🦁', letter: 'L'),
    VocabItem(id: 'mango', name: 'Mango', emoji: '🥭', letter: 'M'),
    VocabItem(id: 'monkey', name: 'Monkey', emoji: '🐵', letter: 'M'),
    VocabItem(id: 'moon', name: 'Moon', emoji: '🌙', letter: 'M'),
    VocabItem(id: 'nose', name: 'Nose', emoji: '👃', letter: 'N'),
    VocabItem(id: 'octopus', name: 'Octopus', emoji: '🐙', letter: 'O'),
    VocabItem(id: 'owl', name: 'Owl', emoji: '🦉', letter: 'O'),
    VocabItem(id: 'parrot', name: 'Parrot', emoji: '🦜', letter: 'P'),
    VocabItem(id: 'panda', name: 'Panda', emoji: '🐼', letter: 'P'),
    VocabItem(id: 'penguin', name: 'Penguin', emoji: '🐧', letter: 'P'),
    VocabItem(id: 'pig', name: 'Pig', emoji: '🐷', letter: 'P'),
    VocabItem(id: 'queen', name: 'Queen', emoji: '👸', letter: 'Q'),
    VocabItem(id: 'rabbit', name: 'Rabbit', emoji: '🐰', letter: 'R'),
    VocabItem(id: 'rainbow', name: 'Rainbow', emoji: '🌈', letter: 'R'),
    VocabItem(id: 'rocket', name: 'Rocket', emoji: '🚀', letter: 'R'),
    VocabItem(id: 'snail', name: 'Snail', emoji: '🐌', letter: 'S'),
    VocabItem(id: 'sheep', name: 'Sheep', emoji: '🐑', letter: 'S'),
    VocabItem(id: 'ship', name: 'Ship', emoji: '🚢', letter: 'S'),
    VocabItem(id: 'spider_web', name: 'Spider Web', emoji: '🕸️', letter: 'S'),
    VocabItem(id: 'star', name: 'Star', emoji: '⭐', letter: 'S'),
    VocabItem(id: 'strawberry', name: 'Strawberry', emoji: '🍓', letter: 'S'),
    VocabItem(id: 'sun', name: 'Sun', emoji: '☀️', letter: 'S'),
    VocabItem(id: 'turtle', name: 'Turtle', emoji: '🐢', letter: 'T'),
    VocabItem(id: 'tiger', name: 'Tiger', emoji: '🐯', letter: 'T'),
    VocabItem(id: 'train', name: 'Train', emoji: '🚂', letter: 'T'),
    VocabItem(id: 'tree', name: 'Tree', emoji: '🌳', letter: 'T'),
    VocabItem(id: 'umbrella', name: 'Umbrella', emoji: '☂️', letter: 'U'),
    VocabItem(id: 'violin', name: 'Violin', emoji: '🎻', letter: 'V'),
    VocabItem(id: 'whale', name: 'Whale', emoji: '🐋', letter: 'W'),
    VocabItem(id: 'windmill', name: 'Windmill', emoji: '💨', letter: 'W'),
    VocabItem(id: 'yoyo', name: 'Yo-Yo', emoji: '🪀', letter: 'Y'),
    VocabItem(id: 'zebra', name: 'Zebra', emoji: '🦓', letter: 'Z'),
  ];

  static VocabItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<VocabItem> forLetter(String letter) =>
      items.where((i) => i.letter == letter.toUpperCase()).toList(growable: false);

  static const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
}
