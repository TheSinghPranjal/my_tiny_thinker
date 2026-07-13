import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';

enum SoundEffect {
  bubblePop('bubble_pop'),
  correct('correct'),
  wrong('wrong'),
  buttonTap('button_tap'),
  coin('coin'),
  reward('reward'),
  victory('victory'),
  levelComplete('level_complete'),
  combo('combo');

  const SoundEffect(this.fileName);
  final String fileName;
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class AudioService {
  AudioService(this._ref);

  final Ref _ref;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.3);
    await _sfxPlayer.setVolume(0.7);
  }

  bool get _soundEnabled => _ref.read(settingsProvider).soundEnabled;
  bool get _musicEnabled => _ref.read(settingsProvider).musicEnabled;

  Future<void> playSfx(SoundEffect effect) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(
        AssetSource('audio/${effect.fileName}.mp3'),
        volume: 0.7,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService: Could not play ${effect.fileName}: $e');
      }
    }
  }

  Future<void> playMusic({String asset = 'audio/ambient_music.mp3'}) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(asset), volume: 0.3);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService: Could not play music: $e');
      }
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      await _musicPlayer.resume();
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
