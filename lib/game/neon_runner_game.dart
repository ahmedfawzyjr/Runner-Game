import 'dart:async' as async;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../core/game_config.dart';
import '../core/game_state.dart';
import '../audio/audio_manager.dart';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/parallax_background.dart';
import 'components/hud.dart';
import 'managers/score_manager.dart';
import 'managers/resource_manager.dart';
import 'effects/particle_system.dart';
import 'effects/camera_effects.dart';

/// Main game class for Neon Runner
class NeonRunnerGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Player player;
  late ParallaxBackgroundComponent background;
  late HudComponent hud;
  late ScoreManager scoreManager;
  late ParticleSystem particleSystem;
  late CameraShake cameraShake;
  
  async.Timer? enemySpawnTimer;
  bool isGameOver = false;
  bool isPaused = false;
  
  final VoidCallback onGameOver;
  final VoidCallback? onPause;
  
  NeonRunnerGame({
    required this.onGameOver,
    this.onPause,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load resources
    await ResourceManager().loadAssets();

    // Reset game state
    GameState().resetGame();
    
    // Add parallax background
    background = ParallaxBackgroundComponent();
    await add(background);
    
    // Add player
    player = Player(
      position: Vector2(size.x * 0.15, size.y * GameConfig.groundY - GameConfig.playerSize / 2),
      onDeath: gameOver,
    );
    await add(player);
    
    // Add HUD
    hud = HudComponent();
    await add(hud);
    
    // Initialize score manager
    scoreManager = ScoreManager();

    // Add particle system
    particleSystem = ParticleSystem();
    await add(particleSystem);

    // Add camera shake
    cameraShake = CameraShake();
    await add(cameraShake);
    
    // Start spawning enemies
    startEnemySpawner();
    
    // Play game music
    AudioManager().playGameMusic();
    
    // Add fade-in transition
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.black,
        priority: 100, // Ensure it's on top
      )..add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.5),
          onComplete: () => removeFromParent(),
        ),
      ),
    );
  }

  /// Start the enemy spawner based on difficulty
  void startEnemySpawner() {
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    final interval = settings.enemySpawnInterval;
    
    enemySpawnTimer?.cancel();
    enemySpawnTimer = async.Timer.periodic(
      Duration(milliseconds: (interval * 1000).round()),
      (_) => spawnEnemy(),
    );
  }

  /// Spawn a new enemy
  void spawnEnemy() {
    if (isGameOver || isPaused) return;
    
    final enemy = Enemy(
      position: Vector2(size.x + 50, size.y * GameConfig.groundY - 40),
    );
    add(enemy);
  }

  @override
  void update(double dt) {
    if (isGameOver || isPaused) return;
    
    super.update(dt);
    
    // Update distance traveled
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    GameState().distanceTraveled += dt * 100 * settings.gameSpeed;
    GameState().timeSurvived += dt;
    
    // Add distance points
    scoreManager.addDistancePoints(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    
    // If player is on ground, jump
    if (player.isOnGround) {
      player.jump();
    } else {
      // If in air, attack
      player.performAttack();
    }
  }

  /// Called when an enemy is killed
  void onEnemyKilled() {
    scoreManager.registerKill();
    hud.showComboText(GameState().comboCount);
    
    // Visual effects
    cameraShake.shake(intensity: 2);
    // Particle effects are handled by the enemy component before removal
  }

  /// Called when player dies
  void gameOver() {
    isGameOver = true;
    enemySpawnTimer?.cancel();
    AudioManager().stopMusic();
    AudioManager().playGameOverMusic();
    
    // Save stats
    GameState().endGame().then((isNewHighScore) {
      onGameOver();
    });
  }

  /// Pause the game
  void pause() {
    isPaused = true;
    pauseEngine();
    onPause?.call();
  }

  /// Resume the game
  void resume() {
    isPaused = false;
    resumeEngine();
  }

  @override
  void onRemove() {
    enemySpawnTimer?.cancel();
    super.onRemove();
  }
}
