import 'package:flame_audio/flame_audio.dart';
import '../core/game_state.dart';

/// Audio manager for background music and sound effects
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;

  /// Audio file names
  static const String menuMusic = 'menu_music.mp3';
  static const String gameMusic = 'game_music.mp3';
  static const String gameOverMusic = 'game_over.mp3';
  
  static const String jumpSound = 'jump.wav';
  static const String attackSound = 'attack.wav';
  static const String enemyDeathSound = 'enemy_death.wav';
  static const String buttonSound = 'button.wav';
  static const String hitSound = 'hit.wav';
  static const String comboSound = 'combo.wav';

  /// Initialize audio system
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Preload audio files
      await FlameAudio.audioCache.loadAll([
        menuMusic,
        gameMusic,
        gameOverMusic,
        jumpSound,
        attackSound,
        enemyDeathSound,
        buttonSound,
        hitSound,
        comboSound,
      ]);
      _initialized = true;
    } catch (e) {
      // Audio files may not exist yet, that's okay
      print('Audio initialization warning: $e');
    }
  }

  /// Play background music for menu
  void playMenuMusic() {
    if (!GameState().musicEnabled) return;
    try {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play(menuMusic, volume: 0.5);
    } catch (e) {
      print('Menu music error: $e');
    }
  }

  /// Play background music for gameplay
  void playGameMusic() {
    if (!GameState().musicEnabled) return;
    try {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play(gameMusic, volume: 0.6);
    } catch (e) {
      print('Game music error: $e');
    }
  }

  /// Play game over music
  void playGameOverMusic() {
    if (!GameState().musicEnabled) return;
    try {
      FlameAudio.bgm.stop();
      FlameAudio.bgm.play(gameOverMusic, volume: 0.5);
    } catch (e) {
      print('Game over music error: $e');
    }
  }

  /// Stop all music
  void stopMusic() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      print('Stop music error: $e');
    }
  }

  /// Play jump sound effect
  void playJump() {
    _playSfx(jumpSound);
  }

  /// Play attack sound effect
  void playAttack() {
    _playSfx(attackSound);
  }

  /// Play enemy death sound effect
  void playEnemyDeath() {
    _playSfx(enemyDeathSound);
  }

  /// Play button click sound effect
  void playButton() {
    _playSfx(buttonSound);
  }

  /// Play hit sound effect
  void playHit() {
    _playSfx(hitSound);
  }

  /// Play combo sound effect
  void playCombo() {
    _playSfx(comboSound);
  }

  /// Internal helper to play sound effects
  void _playSfx(String sound) {
    if (!GameState().soundEnabled) return;
    try {
      FlameAudio.play(sound, volume: 0.7);
    } catch (e) {
      print('SFX error ($sound): $e');
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
