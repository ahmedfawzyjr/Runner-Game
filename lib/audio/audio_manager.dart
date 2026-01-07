// ignore_for_file: avoid_print

import 'package:flame_audio/flame_audio.dart';

import '../core/game_state.dart';

/// Audio manager for sound effects
/// Uses platform pack sounds which are the only available audio files
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _loadFailed = false;

  /// Platform pack sound effects (in assets/audio/platform/Sounds/)
  static const String sfxCoin = 'platform/Sounds/sfx_coin.ogg';
  static const String sfxGem = 'platform/Sounds/sfx_gem.ogg';
  static const String sfxHurt = 'platform/Sounds/sfx_hurt.ogg';
  static const String sfxJump = 'platform/Sounds/sfx_jump.ogg';
  static const String sfxJumpHigh = 'platform/Sounds/sfx_jump-high.ogg';
  static const String sfxBump = 'platform/Sounds/sfx_bump.ogg';
  static const String sfxSelect = 'platform/Sounds/sfx_select.ogg';
  static const String sfxMagic = 'platform/Sounds/sfx_magic.ogg';
  static const String sfxThrow = 'platform/Sounds/sfx_throw.ogg';
  static const String sfxDisappear = 'platform/Sounds/sfx_disappear.ogg';

  /// Initialize audio system
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Clear cache first
      FlameAudio.audioCache.clearAll();

      // Preload platform pack sounds
      final sounds = [
        sfxCoin,
        sfxGem,
        sfxHurt,
        sfxJump,
        sfxJumpHigh,
        sfxBump,
        sfxSelect,
        sfxMagic,
        sfxThrow,
        sfxDisappear,
      ];

      for (final sound in sounds) {
        try {
          await FlameAudio.audioCache.load(sound);
          print('✓ Loaded: $sound');
        } catch (e) {
          print('✗ Failed to load: $sound - $e');
        }
      }

      _initialized = true;
      _loadFailed = false;
      print('Audio manager initialized successfully');
    } catch (e) {
      print('Audio initialization failed: $e');
      _loadFailed = true;
      _initialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Play background music for menu (no music files available)
  void playMenuMusic() {
    // Music files not available
  }

  /// Play background music for gameplay
  void playGameMusic() {
    // Music files not available
  }

  /// Play game over music
  void playGameOverMusic() {
    // Music files not available
  }

  /// Stop all music
  void stopMusic() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  /// Play jump sound effect
  void playJump() {
    _playSfx(sfxJump);
  }

  /// Play high jump sound effect
  void playHighJump() {
    _playSfx(sfxJumpHigh);
  }

  /// Play attack sound effect
  void playAttack() {
    _playSfx(sfxThrow);
  }

  /// Play enemy death sound effect
  void playEnemyDeath() {
    _playSfx(sfxDisappear);
  }

  /// Play button click sound effect
  void playButton() {
    _playSfx(sfxSelect);
  }

  /// Play hit sound effect
  void playHit() {
    _playSfx(sfxHurt);
  }

  /// Play combo sound effect
  void playCombo() {
    _playSfx(sfxMagic);
  }

  /// Play coin pickup sound
  void playCoinPickup() {
    _playSfx(sfxCoin);
  }

  /// Play gem pickup sound
  void playGemPickup() {
    _playSfx(sfxGem);
  }

  /// Play select/UI sound
  void playSelect() {
    _playSfx(sfxSelect);
  }

  /// Play magic/power-up sound
  void playMagic() {
    _playSfx(sfxMagic);
  }

  /// Play disappear sound (enemy defeat, item vanish)
  void playDisappear() {
    _playSfx(sfxDisappear);
  }

  /// Internal helper to play sound effects
  void _playSfx(String sound) {
    if (_loadFailed) return;
    if (!GameState().soundEnabled) return;
    
    try {
      FlameAudio.play(sound, volume: 0.8);
    } catch (e) {
      print('SFX play error: $sound - $e');
    }
  }

  /// Toggle sound effects
  void toggleSound() {
    final state = GameState();
    state.soundEnabled = !state.soundEnabled;
    state.saveData();
  }

  /// Toggle background music
  void toggleMusic() {
    final state = GameState();
    state.musicEnabled = !state.musicEnabled;
    if (!state.musicEnabled) {
      stopMusic();
    }
    state.saveData();
  }
}
