// ignore_for_file: avoid_print, unused_field, depend_on_referenced_packages

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../core/game_state.dart';

/// Robust audio manager for sound effects
/// Uses audioplayers directly with persistent audio pool and auto-recovery
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _loadFailed = false;
  bool _isRefreshing = false;

  /// Audio pool - multiple players for overlapping sounds
  final List<AudioPlayer> _audioPool = [];
  static const int _poolSize = 10;
  int _currentPoolIndex = 0;

  /// Health check timer
  Timer? _healthCheckTimer;
  int _playAttempts = 0;
  int _playFailures = 0;

  /// Last successful play time
  DateTime? _lastSuccessfulPlay;

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

  /// All sound files for easy iteration
  static const List<String> _allSounds = [
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

  /// Initialize audio system
  Future<void> init() async {
    if (_initialized && _audioPool.isNotEmpty) return;

    try {
      // Dispose existing players first
      await _disposePool();

      // Create audio pool with error handling for each player
      for (int i = 0; i < _poolSize; i++) {
        try {
          final player = AudioPlayer();
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(0.8);
          await player.setPlayerMode(PlayerMode.lowLatency);
          _audioPool.add(player);
        } catch (e) {
          print('Failed to create audio player $i: $e');
        }
      }

      // Start health check timer
      _startHealthCheck();

      _initialized = true;
      _loadFailed = _audioPool.isEmpty;
      _playAttempts = 0;
      _playFailures = 0;

      print('Audio manager initialized with ${_audioPool.length} players');
    } catch (e) {
      print('Audio initialization failed: $e');
      _loadFailed = true;
      _initialized = true;
    }
  }

  /// Start periodic health check
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performHealthCheck(),
    );
  }

  /// Check audio health and recover if needed
  Future<void> _performHealthCheck() async {
    if (_isRefreshing) return;

    // Check failure rate
    if (_playAttempts > 10) {
      final failureRate = _playFailures / _playAttempts;
      if (failureRate > 0.3) {
        print(
            'Audio health check: High failure rate ($failureRate), refreshing...');
        await refreshSounds();
      }
      // Reset counters
      _playAttempts = 0;
      _playFailures = 0;
    }

    // Check if audio hasn't played successfully for too long
    if (_lastSuccessfulPlay != null) {
      final timeSinceLastPlay = DateTime.now().difference(_lastSuccessfulPlay!);
      if (timeSinceLastPlay.inMinutes > 2 && _playAttempts > 5) {
        print(
            'Audio health check: No successful plays recently, refreshing...');
        await refreshSounds();
      }
    }
  }

  /// Refresh sounds - reinitialize pool if needed
  Future<void> refreshSounds() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      // Reset all players in pool
      for (int i = 0; i < _audioPool.length; i++) {
        try {
          final player = _audioPool[i];
          await player.stop();
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(0.8);
        } catch (e) {
          // Replace broken player
          try {
            await _audioPool[i].dispose();
            final newPlayer = AudioPlayer();
            await newPlayer.setReleaseMode(ReleaseMode.stop);
            await newPlayer.setVolume(0.8);
            await newPlayer.setPlayerMode(PlayerMode.lowLatency);
            _audioPool[i] = newPlayer;
          } catch (_) {}
        }
      }

      // If pool is too small, add more players
      while (_audioPool.length < _poolSize) {
        try {
          final player = AudioPlayer();
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(0.8);
          await player.setPlayerMode(PlayerMode.lowLatency);
          _audioPool.add(player);
        } catch (_) {
          break;
        }
      }

      _loadFailed = _audioPool.isEmpty;
      _playFailures = 0;
      _playAttempts = 0;

      print('Audio pool refreshed: ${_audioPool.length} players ready');
    } catch (e) {
      print('Audio refresh failed: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Ensure audio is ready - call before playing
  Future<void> ensureReady() async {
    if (!_initialized || _audioPool.isEmpty) {
      _initialized = false;
      await init();
    }
  }

  /// Dispose audio pool
  Future<void> _disposePool() async {
    for (final player in _audioPool) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _audioPool.clear();
  }

  /// Play background music for menu (no music files available)
  void playMenuMusic() {
    // Music files not available
    // Ensure audio is ready
    ensureReady();
  }

  /// Play background music for gameplay
  void playGameMusic() {
    // Music files not available
    // Ensure audio is ready when game starts
    ensureReady();
  }

  /// Play game over music
  void playGameOverMusic() {
    // Music files not available
  }

  /// Stop all music
  void stopMusic() {
    // No music to stop
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

  /// Internal helper to play sound effects using audio pool
  void _playSfx(String sound) {
    if (_loadFailed) return;
    if (!GameState().soundEnabled) return;

    _playAttempts++;

    if (_audioPool.isEmpty) {
      _playFailures++;
      ensureReady();
      return;
    }

    // Try to find a working player
    int attempts = 0;
    while (attempts < _poolSize) {
      try {
        // Get next player from pool (round-robin)
        final player = _audioPool[_currentPoolIndex];
        _currentPoolIndex = (_currentPoolIndex + 1) % _audioPool.length;

        // Play the sound
        player.play(AssetSource('audio/$sound')).then((_) {
          _lastSuccessfulPlay = DateTime.now();
        }).catchError((e) {
          _playFailures++;
          print('SFX async error: $sound - $e');
        });

        return; // Success, exit
      } catch (e) {
        attempts++;
        _currentPoolIndex = (_currentPoolIndex + 1) % _audioPool.length;
      }
    }

    // All attempts failed
    _playFailures++;
    print('SFX play failed after $attempts attempts: $sound');

    // Schedule recovery
    _scheduleRecovery();
  }

  /// Schedule async recovery
  void _scheduleRecovery() {
    if (_isRefreshing) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      refreshSounds();
    });
  }

  /// Toggle sound effects
  void toggleSound() {
    final state = GameState();
    state.soundEnabled = !state.soundEnabled;
    state.saveData();

    // Play feedback sound if enabled
    if (state.soundEnabled) {
      playSelect();
    }
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

  /// Dispose all audio players
  void dispose() {
    _healthCheckTimer?.cancel();
    _disposePool();
    _initialized = false;
  }
}
