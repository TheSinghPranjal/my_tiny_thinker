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

/// Soothing loop tracks for TinyThink.
abstract final class AppMusic {
  /// Home, settings, parent zone, onboarding — everywhere outside games.
  /// Controlled by Settings → Music.
  static const home = 'audio/home_music.mp3';

  /// Shared background loop while any game is open.
  /// Controlled by Settings → Game sound.
  static const game = 'audio/game_music.mp3';
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

  /// Last requested loop track (kept so music can resume after toggle).
  String _activeTrack = AppMusic.home;
  String? _playingTrack;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.28);
    await _sfxPlayer.setVolume(0.7);
  }

  bool get _soundEnabled => _ref.read(settingsProvider).soundEnabled;
  bool get _musicEnabled => _ref.read(settingsProvider).musicEnabled;

  bool _isTrackAllowed(String asset) {
    if (asset == AppMusic.home) return _musicEnabled;
    if (asset == AppMusic.game) return _soundEnabled;
    return _musicEnabled;
  }

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

  Future<void> playHomeMusic() => playMusic(asset: AppMusic.home);

  Future<void> playGameMusic() => playMusic(asset: AppMusic.game);

  Future<void> playMusic({String asset = AppMusic.home}) async {
    await initialize();
    _activeTrack = asset;
    if (!_isTrackAllowed(asset)) {
      await stopMusic();
      return;
    }

    // Keep looping without restarting the same track.
    if (_playingTrack == asset &&
        _musicPlayer.state == PlayerState.playing) {
      return;
    }

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource(asset), volume: 0.28);
      _playingTrack = asset;
    } catch (e) {
      _playingTrack = null;
      if (kDebugMode) {
        debugPrint('AudioService: Could not play music: $e');
      }
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _playingTrack = null;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (!_isTrackAllowed(_activeTrack)) return;
    if (_playingTrack != null) {
      await _musicPlayer.resume();
      return;
    }
    await playMusic(asset: _activeTrack);
  }

  /// Settings → Music (home loop only).
  Future<void> onMusicEnabledChanged(bool enabled) async {
    if (_activeTrack != AppMusic.home) return;
    if (enabled) {
      await playHomeMusic();
    } else {
      await stopMusic();
    }
  }

  /// Settings → Game sound (in-game loop + SFX).
  Future<void> onGameSoundEnabledChanged(bool enabled) async {
    if (_activeTrack != AppMusic.game) return;
    if (enabled) {
      await playGameMusic();
    } else {
      await stopMusic();
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
