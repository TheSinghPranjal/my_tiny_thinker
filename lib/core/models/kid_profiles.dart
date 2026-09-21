/// The five built-in kid profiles a child can switch between.
class KidProfilePreset {
  const KidProfilePreset({
    required this.id,
    required this.emoji,
    required this.defaultName,
  });

  /// Also used as the profile's `avatarId`.
  final String id;
  final String emoji;
  final String defaultName;
}

abstract final class KidProfilePresets {
  /// Bunny is selected by default.
  static const defaultId = 'rabbit';

  static const all = <KidProfilePreset>[
    KidProfilePreset(id: 'rabbit', emoji: '🐰', defaultName: 'Bunny'),
    KidProfilePreset(id: 'panda', emoji: '🐼', defaultName: 'Panda'),
    KidProfilePreset(id: 'fox', emoji: '🦊', defaultName: 'Fox'),
    KidProfilePreset(id: 'lion', emoji: '🦁', defaultName: 'Lion'),
    KidProfilePreset(id: 'penguin', emoji: '🐧', defaultName: 'Penguin'),
  ];

  static KidProfilePreset byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}
