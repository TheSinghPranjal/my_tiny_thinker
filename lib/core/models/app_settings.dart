import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.highContrast = false,
    this.difficulty = 'medium',
    this.languageCode = 'en',
    this.parentLockEnabled = true,
    this.hintsEnabled = true,
  });

  final bool musicEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool highContrast;
  final String difficulty;
  final String languageCode;
  final bool parentLockEnabled;
  final bool hintsEnabled;

  AppSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? highContrast,
    String? difficulty,
    String? languageCode,
    bool? parentLockEnabled,
    bool? hintsEnabled,
  }) =>
      AppSettings(
        musicEnabled: musicEnabled ?? this.musicEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        highContrast: highContrast ?? this.highContrast,
        difficulty: difficulty ?? this.difficulty,
        languageCode: languageCode ?? this.languageCode,
        parentLockEnabled: parentLockEnabled ?? this.parentLockEnabled,
        hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      );

  Map<String, dynamic> toJson() => {
        'musicEnabled': musicEnabled,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'highContrast': highContrast,
        'difficulty': difficulty,
        'languageCode': languageCode,
        'parentLockEnabled': parentLockEnabled,
        'hintsEnabled': hintsEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        highContrast: json['highContrast'] as bool? ?? false,
        difficulty: json['difficulty'] as String? ?? 'medium',
        languageCode: json['languageCode'] as String? ?? 'en',
        parentLockEnabled: json['parentLockEnabled'] as bool? ?? true,
        hintsEnabled: json['hintsEnabled'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
        musicEnabled,
        soundEnabled,
        hapticsEnabled,
        highContrast,
        difficulty,
        languageCode,
        parentLockEnabled,
        hintsEnabled,
      ];
}
