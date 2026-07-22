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
  /// Home, settings, parent zone, onboarding — everywhere outside active gameplay.
  /// Controlled by Settings → Music.
  static const home = 'audio/home_music.mp3';

  /// Background loop while a game is actively running (not paused, not on home).
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
  final AudioPlayer _clipPlayer = AudioPlayer();
  bool _initialized = false;

  /// True while a game screen has entered gameplay (until [playHomeMusic]/exit).
  bool _inGameplay = false;

  /// True while the in-game pause menu is open (game BGM must stay silent).
  bool _gameAudioPaused = false;

  /// Last requested loop track.
  String _activeTrack = AppMusic.home;
  String? _playingTrack;

  bool get inGameplay => _inGameplay;
  bool get gameAudioPaused => _gameAudioPaused;

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
    if (asset == AppMusic.home) {
      // Home music only outside active gameplay.
      return !_inGameplay && _musicEnabled;
    }
    if (asset == AppMusic.game) {
      // Game BGM only while playing and not paused, and game sound is on.
      return _inGameplay && !_gameAudioPaused && _soundEnabled;
    }
    return false;
  }

  Future<void> playSfx(SoundEffect effect) async {
    if (!_soundEnabled) return;
    // Silence all game audio while the pause menu is open.
    if (_gameAudioPaused) return;
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

  /// Play a one-shot clip (mp3/wav) from assets, e.g. `audio/animals/dog.wav`.
  Future<void> playClip(String assetPath, {double volume = 0.9}) async {
    if (!_soundEnabled) return;
    if (_gameAudioPaused) return;
    try {
      await initialize();
      await _clipPlayer.stop();
      await _clipPlayer.setReleaseMode(ReleaseMode.stop);
      await _clipPlayer.play(AssetSource(assetPath), volume: volume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService: Could not play clip $assetPath: $e');
      }
    }
  }

  Future<void> stopClip() async {
    await _clipPlayer.stop();
  }

  /// Leave gameplay and start the home loop (if Music is enabled).
  Future<void> playHomeMusic() async {
    _inGameplay = false;
    _gameAudioPaused = false;
    await stopClip();
    await playMusic(asset: AppMusic.home);
  }

  /// Enter / resume active gameplay BGM (if Game sound is enabled).
  Future<void> playGameMusic() async {
    _inGameplay = true;
    _gameAudioPaused = false;
    await playMusic(asset: AppMusic.game);
  }

  /// Silence game BGM + SFX while the pause menu is open.
  Future<void> pauseGameplayAudio() async {
    if (!_inGameplay) return;
    _gameAudioPaused = true;
    await stopClip();
    await stopMusic();
  }

  /// Restore game BGM after Resume (respects Game sound toggle).
  Future<void> resumeGameplayAudio() async {
    if (!_inGameplay) return;
    _gameAudioPaused = false;
    await playMusic(asset: AppMusic.game);
  }

  Future<void> playMusic({String asset = AppMusic.home}) async {
    await initialize();
    _activeTrack = asset;
    if (!_isTrackAllowed(asset)) {
      await stopMusic();
      return;
    }

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

  /// Settings → Music (home loop only; ignored during gameplay).
  Future<void> onMusicEnabledChanged(bool enabled) async {
    if (_inGameplay) return;
    if (enabled) {
      await playHomeMusic();
    } else {
      await stopMusic();
    }
  }

  /// Settings → Game sound (SFX + in-game BGM only while actively playing).
  Future<void> onGameSoundEnabledChanged(bool enabled) async {
    // Never start game BGM on the home screen / settings.
    if (!_inGameplay || _gameAudioPaused) {
      if (_playingTrack == AppMusic.game) {
        await stopMusic();
      }
      return;
    }
    if (enabled) {
      await playGameMusic();
    } else {
      await stopMusic();
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _clipPlayer.dispose();
  }
}
