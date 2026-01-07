import 'dart:async' as async;
import 'dart:math';
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
import 'components/collectible.dart';
import 'components/parallax_background.dart';
import 'components/hud.dart';
import 'managers/score_manager.dart';
import 'managers/resource_manager.dart';
import 'effects/particle_system.dart';
import 'effects/camera_effects.dart';
import 'effects/gameplay_effects.dart';

/// Main game class for Neon Runner with collectibles and power-ups
class NeonRunnerGame extends FlameGame 
    with TapCallbacks, DragCallbacks, HasCollisionDetection {
  late Player player;
  late ParallaxBackgroundComponent background;
  late HudComponent hud;
  late ScoreManager scoreManager;
  late ParticleSystem particleSystem;
  late CameraShake cameraShake;
  
  async.Timer? enemySpawnTimer;
  async.Timer? coinSpawnTimer;
  async.Timer? powerUpSpawnTimer;
  
  bool isGameOver = false;
  bool isPaused = false;
  
  final VoidCallback onGameOver;
  final VoidCallback? onPause;
  
  // Swipe detection
  Vector2? dragStart;
  static const double swipeThreshold = 50;
  
  // Spawning
  final Random _random = Random();
  int enemiesSpawned = 0;
  double spawnSpeedupTimer = 0;
  
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
    
    // Add speed lines overlay for motion effect
    add(SpeedLinesOverlay());
    
    // Add controls tutorial (shows for first 5 seconds)
    add(ControlsTutorial());
    
    // Start spawners
    startEnemySpawner();
    startCoinSpawner();
    startPowerUpSpawner();
    
    // Play game music
    AudioManager().playGameMusic();
    
    // Add fade-in transition
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.black,
        priority: 100,
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

  /// Start spawning coins
  void startCoinSpawner() {
    coinSpawnTimer?.cancel();
    coinSpawnTimer = async.Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => spawnCoins(),
    );
  }

  /// Start spawning power-ups
  void startPowerUpSpawner() {
    powerUpSpawnTimer?.cancel();
    powerUpSpawnTimer = async.Timer.periodic(
      const Duration(seconds: 15),
      (_) => spawnPowerUp(),
    );
  }

  /// Spawn coins
  void spawnCoins() {
    if (isGameOver || isPaused) return;
    
    // Random chance to spawn
    if (_random.nextDouble() > 0.7) return;
    
    final groundY = size.y * GameConfig.groundY - 60;
    final flyingY = size.y * 0.35;
    
    // Random position (ground or air)
    final spawnY = _random.nextBool() ? groundY : flyingY;
    
    // Spawn single coin or line
    if (_random.nextDouble() > 0.6) {
      // Spawn line of coins
      final coins = CollectibleFactory.spawnCoinLine(
        Vector2(size.x + 50, spawnY),
        3 + _random.nextInt(3),
      );
      for (final coin in coins) {
        add(coin);
      }
    } else {
      // Single coin
      add(CollectibleFactory.spawnCoin(Vector2(size.x + 50, spawnY)));
    }
  }

  /// Spawn power-up
  void spawnPowerUp() {
    if (isGameOver || isPaused) return;
    
    // Random position
    final spawnY = size.y * 0.4 + _random.nextDouble() * (size.y * 0.3);
    
    add(CollectibleFactory.spawnRandomPowerUp(Vector2(size.x + 50, spawnY)));
  }

  /// Spawn a new enemy with variety
  void spawnEnemy() {
    try {
      if (isGameOver || isPaused) return;
      
      enemiesSpawned++;
      final difficulty = GameState().difficulty;
      
      // Determine spawn position and type
      final groundY = size.y * GameConfig.groundY - 40;
      final flyingY = size.y * 0.45;
      
      // Spawn flying enemies more often on hard difficulty
      final flyingChance = difficulty == Difficulty.hard ? 0.4 : 
                           difficulty == Difficulty.medium ? 0.25 : 0.15;
      final spawnFlying = _random.nextDouble() < flyingChance && enemiesSpawned > 5;
      
      Enemy enemy;
      if (spawnFlying) {
        final type = _random.nextBool() ? EnemyType.bee : EnemyType.fly;
        enemy = EnemyFactory.spawn(
          position: Vector2(size.x + 50, flyingY),
          type: type,
        );
      } else {
        enemy = EnemyFactory.spawnRandom(
          position: Vector2(size.x + 50, groundY),
        );
      }
      
      add(enemy);
      
      // Wave spawning on hard
      if (difficulty == Difficulty.hard && 
          enemiesSpawned > 10 && 
          _random.nextDouble() < 0.2) {
        Future.delayed(const Duration(milliseconds: 400), () {
          try {
            if (!isGameOver && !isPaused) {
              add(EnemyFactory.spawnRandom(
                position: Vector2(size.x + 50, groundY),
              ));
            }
          } catch (e) {
            print('Error spawning wave enemy: $e');
          }
        });
      }
    } catch (e) {
      print('Error in spawnEnemy: $e');
    }
  }

  @override
  void update(double dt) {
    try {
      if (isGameOver || isPaused) return;
      
      super.update(dt);
      
      // Update distance traveled
      final settings = GameConfig.difficulties[GameState().difficulty]!;
      GameState().distanceTraveled += dt * 100 * settings.gameSpeed;
      GameState().timeSurvived += dt;
      
      // Add distance points
      scoreManager.addDistancePoints(dt);
      
      // Speed up spawning over time
      spawnSpeedupTimer += dt;
      if (spawnSpeedupTimer > 30) {
        spawnSpeedupTimer = 0;
        _speedUpSpawning();
      }
      
      // Magnet effect - attract coins to player
      if (GameState().hasMagnet) {
        _attractCoins(dt);
      }
    } catch (e) {
      print('Error in game update: $e');
    }
  }
  
  void _attractCoins(double dt) {
    final coins = children.whereType<Coin>();
    for (final coin in coins) {
      if (coin.isCollected) continue;
      
      final distance = (coin.position - player.position).length;
      if (distance < 200) {
        // Move coin towards player
        final direction = (player.position - coin.position).normalized();
        coin.position += direction * 300 * dt;
        
        // Collect if close
        if (distance < 30) {
          coin.collect();
        }
      }
    }
  }
  
  void _speedUpSpawning() {
    enemySpawnTimer?.cancel();
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    final newInterval = (settings.enemySpawnInterval * 0.9).clamp(1.0, 5.0);
    
    enemySpawnTimer = async.Timer.periodic(
      Duration(milliseconds: (newInterval * 1000).round()),
      (_) => spawnEnemy(),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    
    final tapX = event.localPosition.x;
    final isRightSide = tapX > size.x * 0.5;
    
    if (isRightSide) {
      player.performAttack();
    } else {
      player.jump();
    }
  }
  
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStart = event.localPosition;
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (dragStart == null || isGameOver) return;
    
    final delta = event.localDelta;
    
    if (delta.y.abs() > 15) {
      if (delta.y > 0) {
        player.startSlide();
      } else {
        player.jump();
      }
      dragStart = null;
    }
  }
  
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dragStart = null;
  }
  
  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    dragStart = null;
  }

  /// Called when an enemy is killed
  void onEnemyKilled() {
    scoreManager.registerKill();
    hud.showComboText(GameState().comboCount);
    cameraShake.shake(intensity: 3, duration: 0.15);
  }

  /// Called when player dies
  void gameOver() {
    isGameOver = true;
    enemySpawnTimer?.cancel();
    coinSpawnTimer?.cancel();
    powerUpSpawnTimer?.cancel();
    AudioManager().stopMusic();
    AudioManager().playGameOverMusic();
    
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
    coinSpawnTimer?.cancel();
    powerUpSpawnTimer?.cancel();
    super.onRemove();
  }
}
