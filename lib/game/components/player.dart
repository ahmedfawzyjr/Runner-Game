import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../../audio/audio_manager.dart';
import '../managers/resource_manager.dart';
import '../neon_runner_game.dart';
import 'enemy.dart';

/// Player component with animations and physics
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  
  final VoidCallback onDeath;
  
  double velocityY = 0;
  bool isOnGround = true;
  bool isAttacking = false;
  bool isInvincible = false;
  int health = GameConfig.playerMaxHealth;
  double attackCooldown = 0;
  double attackAnimationTime = 0;
  
  late SpriteAnimation runAnimation;
  late SpriteAnimation jumpAnimation;
  late SpriteAnimation attackAnimation;
  late SpriteAnimation hitAnimation;
  late SpriteAnimation deathAnimation;
  late SpriteAnimation idleAnimation;
  
  Player({
    required Vector2 position,
    required this.onDeath,
  }) : super(
    position: position,
    size: Vector2.all(GameConfig.playerSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final resources = ResourceManager();
    
    animations = {
      PlayerState.idle: resources.playerIdle,
      PlayerState.running: resources.playerRun,
      PlayerState.jumping: resources.playerJump,
      PlayerState.attacking: resources.playerAttack,
      PlayerState.hit: resources.playerHit,
      PlayerState.death: resources.playerDeath,
    };
    
    current = PlayerState.running;
    
    // Add collision hitbox
    add(RectangleHitbox(
      size: Vector2(50, 70),
      position: Vector2(15, 5),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply gravity
    if (!isOnGround) {
      velocityY += GameConfig.gravity * dt;
      position.y += velocityY * dt;
      
      // Check if landed
      final groundY = game.size.y * GameConfig.groundY - size.y / 2;
      if (position.y >= groundY) {
        position.y = groundY;
        velocityY = 0;
        isOnGround = true;
        if (current == PlayerState.jumping) {
          current = PlayerState.running;
        }
      }
    }
    
    // Update attack cooldown
    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }
    
    // Reset attack state after animation duration
    if (isAttacking) {
      attackAnimationTime += dt;
      final attackDuration = GameConfig.attackAnimSpeed * 3;
      if (attackAnimationTime >= attackDuration) {
        isAttacking = false;
        attackAnimationTime = 0;
        current = isOnGround ? PlayerState.running : PlayerState.jumping;
      }
    }
  }

  /// Make the player jump
  void jump() {
    if (!isOnGround) return;
    
    isOnGround = false;
    velocityY = -GameConfig.playerJumpForce;
    current = PlayerState.jumping;
    AudioManager().playJump();
    game.particleSystem.createSpeedLines(position);
  }

  /// Perform attack
  void performAttack() {
    if (isAttacking || attackCooldown > 0) return;
    
    isAttacking = true;
    attackCooldown = GameConfig.attackCooldown;
    attackAnimationTime = 0;
    current = PlayerState.attacking;
    AudioManager().playAttack();
    
    // Check for enemies in range
    game.children.whereType<Enemy>().forEach((enemy) {
      final distance = (position.x - enemy.position.x).abs();
      if (distance < GameConfig.attackRange + 30) {
        enemy.takeDamage();
      }
    });
  }

  /// Take damage from enemy
  void takeDamage() {
    if (isInvincible) return;
    
    health--;
    AudioManager().playHit();
    game.cameraShake.shake(intensity: 10, duration: 0.4);
    game.particleSystem.createHitEffect(position);
    
    if (health <= 0) {
      die();
    } else {
      // Brief invincibility
      isInvincible = true;
      current = PlayerState.hit;
      
      Future.delayed(const Duration(milliseconds: 500), () {
        isInvincible = false;
        if (current == PlayerState.hit) {
          current = PlayerState.running;
        }
      });
    }
  }

  /// Player death
  void die() {
    current = PlayerState.death;
    isInvincible = true;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      onDeath();
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy && !other.isDead) {
      takeDamage();
    }
    super.onCollision(intersectionPoints, other);
  }
}

/// Player animation states
enum PlayerState {
  idle,
  running,
  jumping,
  attacking,
  hit,
  death,
}
