// ignore_for_file: prefer_const_declarations

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../audio/audio_manager.dart';
import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../effects/kill_effect.dart';
import '../managers/resource_manager.dart';
import '../neon_runner_game.dart';

/// Enemy types available
enum EnemyType {
  slime,
  bee,
  fly,
  snail,
}

/// Enemy component with multiple types and behaviors
class Enemy extends SpriteAnimationComponent
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  final EnemyType type;
  bool isDead = false;
  double deathAnimationTime = 0;
  late double speed;
  late double baseY;

  // Flying enemy properties
  double floatTime = 0;
  double floatAmplitude = 20;
  double floatSpeed = 3;

  // Behavior properties
  bool isAggressive = false;
  double aggressiveSpeed = 1.0;

  Enemy({
    required Vector2 position,
    this.type = EnemyType.slime,
  }) : super(
          position: position,
          size: _getSizeForType(type),
          anchor: Anchor.center,
        ) {
    baseY = position.y;
  }

  static Vector2 _getSizeForType(EnemyType type) {
    switch (type) {
      case EnemyType.slime:
        return Vector2(64, 64);
      case EnemyType.bee:
      case EnemyType.fly:
        return Vector2(56, 56);
      case EnemyType.snail:
        return Vector2(72, 56);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Get speed from difficulty settings
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    speed = settings.enemySpeed;

    // Set aggressive behavior on hard difficulty
    isAggressive = GameState().difficulty == Difficulty.hard;
    aggressiveSpeed = isAggressive ? 1.3 : 1.0;

    // Set animation based on type
    final resources = ResourceManager();
    switch (type) {
      case EnemyType.slime:
        animation =
            resources.enemyAnimations['slime_walk'] ?? resources.enemyWalk;
        break;
      case EnemyType.bee:
        animation = resources.enemyAnimations['bee_fly'] ?? resources.enemyWalk;
        // Bees float higher
        floatAmplitude = 40;
        break;
      case EnemyType.fly:
        animation = resources.enemyAnimations['fly_fly'] ?? resources.enemyWalk;
        floatAmplitude = 30;
        floatSpeed = 5;
        break;
      case EnemyType.snail:
        animation =
            resources.enemyAnimations['snail_walk'] ?? resources.enemyWalk;
        // Snails are slower
        speed *= 0.6;
        break;
    }

    // Add collision hitbox
    add(RectangleHitbox(
      size: Vector2(size.x * 0.6, size.y * 0.8),
      position: Vector2(size.x * 0.2, size.y * 0.1),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) {
      // Float up and fade when dead
      position.y -= 80 * dt;
      deathAnimationTime += dt;

      // Scale down
      final scale = 1.0 - (deathAnimationTime / 0.5);
      this.scale = Vector2.all(scale.clamp(0.1, 1));

      if (deathAnimationTime >= 0.5) {
        removeFromParent();
      }
      return;
    }

    // Move left towards player
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    position.x -= speed * settings.gameSpeed * aggressiveSpeed * dt;

    // Flying behavior for bee/fly
    if (type == EnemyType.bee || type == EnemyType.fly) {
      floatTime += dt * floatSpeed;
      position.y = baseY + sin(floatTime) * floatAmplitude;
    }

    // Remove if off screen
    if (position.x < -150) {
      removeFromParent();
    }
  }

  /// Take damage and die
  void takeDamage() {
    if (isDead) return;

    isDead = true;
    deathAnimationTime = 0;

    // Play death sound based on type
    if (type == EnemyType.slime) {
      AudioManager().playDisappear();
    } else {
      AudioManager().playEnemyDeath();
    }

    // Calculate score with combo
    final gameState = GameState();
    final comboCount = gameState.comboCount + 1;
    final baseScore = GameConfig.killPoints;
    final comboBonus = (comboCount - 1) * GameConfig.comboBonus;
    final totalScore = baseScore + comboBonus;

    // Create kill effect with score popup
    game.add(KillEffect(
      position: position.clone(),
      score: totalScore,
      comboCount: comboCount,
    ));

    // Trigger explosion effect
    game.particleSystem.createExplosion(position);

    // Add screen flash on high combos
    if (comboCount >= 5) {
      game.add(ScreenFlash());
    }

    // Notify game of kill
    game.onEnemyKilled();

    // Remove hitbox immediately
    children.whereType<RectangleHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });
  }

  /// Get points value for this enemy type
  int get pointValue {
    switch (type) {
      case EnemyType.slime:
        return 100;
      case EnemyType.bee:
        return 150; // Harder to hit
      case EnemyType.fly:
        return 125;
      case EnemyType.snail:
        return 75; // Easier target
    }
  }
}

/// Factory for spawning enemies
class EnemyFactory {
  static final Random _random = Random();

  /// Spawn a random enemy at the given position
  static Enemy spawnRandom({required Vector2 position}) {
    // Weight spawns based on difficulty
    final difficulty = GameState().difficulty;

    if (difficulty == Difficulty.hard) {
      // More flying enemies on hard
      final roll = _random.nextDouble();
      if (roll < 0.3) {
        return Enemy(position: position, type: EnemyType.bee);
      } else if (roll < 0.5) {
        return Enemy(position: position, type: EnemyType.fly);
      } else {
        return Enemy(position: position, type: EnemyType.slime);
      }
    } else {
      // Mostly slimes on easier difficulties
      final roll = _random.nextDouble();
      if (roll < 0.7) {
        return Enemy(position: position, type: EnemyType.slime);
      } else if (roll < 0.85) {
        return Enemy(position: position, type: EnemyType.snail);
      } else {
        return Enemy(position: position, type: EnemyType.fly);
      }
    }
  }

  /// Spawn a specific enemy type
  static Enemy spawn({required Vector2 position, required EnemyType type}) {
    return Enemy(position: position, type: type);
  }
}
