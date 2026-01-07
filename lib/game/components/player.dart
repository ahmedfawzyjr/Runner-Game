// ignore_for_file: unused_import

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../../audio/audio_manager.dart';
import '../managers/resource_manager.dart';
import '../neon_runner_game.dart';
import 'enemy.dart';

/// Player component with double jump, slide, and stomp mechanics
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  
  final VoidCallback onDeath;
  
  double velocityY = 0;
  bool isOnGround = true;
  bool isAttacking = false;
  bool isInvincible = false;
  bool isSliding = false;
  int health = GameConfig.playerMaxHealth;
  double attackCooldown = 0;
  double attackAnimationTime = 0;
  double slideDuration = 0;
  
  // Double jump
  int jumpCount = 0;
  static const int maxJumps = 2;
  
  // Slide
  static const double slideMaxDuration = 0.6;
  static const double slideCooldown = 0.3;
  double slideTimer = 0;
  
  // Original hitbox size for restoring after slide
  late Vector2 originalHitboxSize;
  late Vector2 originalHitboxPosition;
  
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
    originalHitboxSize = Vector2(50, 70);
    originalHitboxPosition = Vector2(15, 5);
    add(RectangleHitbox(
      size: originalHitboxSize.clone(),
      position: originalHitboxPosition.clone(),
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
        jumpCount = 0; // Reset double jump
        if (current == PlayerState.jumping && !isSliding) {
          current = PlayerState.running;
        }
      }
    }
    
    // Update attack cooldown
    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }
    
    // Update slide timer
    if (slideTimer > 0) {
      slideTimer -= dt;
    }
    
    // Handle sliding
    if (isSliding) {
      slideDuration += dt;
      if (slideDuration >= slideMaxDuration) {
        endSlide();
      }
    }
    
    // Reset attack state after animation duration
    if (isAttacking) {
      attackAnimationTime += dt;
      const attackDuration = GameConfig.attackAnimSpeed * 3;
      if (attackAnimationTime >= attackDuration) {
        isAttacking = false;
        attackAnimationTime = 0;
        if (!isSliding) {
          current = isOnGround ? PlayerState.running : PlayerState.jumping;
        }
      }
    }
  }

  /// Make the player jump (supports double jump)
  void jump() {
    if (jumpCount >= maxJumps) return;
    
    jumpCount++;
    isOnGround = false;
    
    // Second jump is slightly weaker
    final jumpForce = jumpCount == 1 
        ? GameConfig.playerJumpForce 
        : GameConfig.playerJumpForce * 0.8;
    
    velocityY = -jumpForce;
    current = PlayerState.jumping;
    
    // Different sound for double jump
    if (jumpCount == 2) {
      AudioManager().playHighJump();
      game.particleSystem.createSpeedLines(position);
      game.particleSystem.createSpeedLines(position + Vector2(0, 20));
    } else {
      AudioManager().playJump();
      game.particleSystem.createSpeedLines(position);
    }
    
    // End slide if jumping
    if (isSliding) {
      endSlide();
    }
  }

  /// Start sliding (duck under obstacles)
  void startSlide() {
    if (isSliding || slideTimer > 0 || !isOnGround) return;
    
    isSliding = true;
    slideDuration = 0;
    
    // Shrink hitbox for sliding
    final hitbox = children.whereType<RectangleHitbox>().firstOrNull;
    if (hitbox != null) {
      hitbox.size = Vector2(50, 35);
      hitbox.position = Vector2(15, 40);
    }
    
    // Visual: scale down vertically
    scale = Vector2(1, 0.5);
    position.y += size.y * 0.25;
    
    AudioManager().playSelect();
  }

  /// End sliding
  void endSlide() {
    if (!isSliding) return;
    
    isSliding = false;
    slideTimer = slideCooldown;
    
    // Restore hitbox
    final hitbox = children.whereType<RectangleHitbox>().firstOrNull;
    if (hitbox != null) {
      hitbox.size = originalHitboxSize.clone();
      hitbox.position = originalHitboxPosition.clone();
    }
    
    // Restore visual
    scale = Vector2.all(1);
    position.y -= size.y * 0.25;
    
    if (isOnGround && !isAttacking) {
      current = PlayerState.running;
    }
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
      if (distance < GameConfig.attackRange + 40) {
        enemy.takeDamage();
      }
    });
  }

  /// Stomp on enemy - bounce up and kill enemy
  void stompEnemy(Enemy enemy) {
    if (enemy.isDead) return;
    
    // Kill the enemy
    enemy.takeDamage();
    
    // Bounce up (smaller jump, doesn't use jump count)
    velocityY = -GameConfig.playerJumpForce * 0.65;
    isOnGround = false;
    current = PlayerState.jumping;
    
    // Play stomp sound and effects
    AudioManager().playJump();
    game.particleSystem.createExplosion(enemy.position);
    game.cameraShake.shake(intensity: 3, duration: 0.2);
  }

  /// Take damage from enemy
  void takeDamage() {
    if (isInvincible || isSliding) return;
    
    health--;
    AudioManager().playHit();
    game.cameraShake.shake(intensity: 12, duration: 0.4);
    game.particleSystem.createHitEffect(position);
    
    if (health <= 0) {
      die();
    } else {
      // Brief invincibility
      isInvincible = true;
      current = PlayerState.hit;
      
      // Visual flash effect
      _flashEffect();
      
      Future.delayed(const Duration(milliseconds: 800), () {
        isInvincible = false;
        if (current == PlayerState.hit) {
          current = PlayerState.running;
        }
      });
    }
  }

  void _flashEffect() async {
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!isMounted) return;
      opacity = 0.3;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!isMounted) return;
      opacity = 1.0;
    }
  }

  /// Player death
  void die() {
    current = PlayerState.death;
    isInvincible = true;
    
    // Death particles
    game.particleSystem.createExplosion(position);
    game.cameraShake.shake(intensity: 15, duration: 0.5);
    
    Future.delayed(const Duration(milliseconds: 600), () {
      onDeath();
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy && !other.isDead) {
      // Check if player is falling onto enemy (stomp)
      final playerBottom = position.y + size.y / 2;
      final enemyTop = other.position.y - other.size.y / 2;
      final isAboveEnemy = playerBottom < enemyTop + 25;
      final isFalling = velocityY > 50;
      
      if (!isOnGround && isFalling && isAboveEnemy) {
        // Stomp - kill enemy and bounce
        stompEnemy(other);
      } else if (!isSliding) {
        // Regular collision - take damage (sliding makes you invulnerable)
        takeDamage();
      }
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
