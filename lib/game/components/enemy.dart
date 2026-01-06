import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../core/game_config.dart';
import '../../core/game_state.dart';
import '../../audio/audio_manager.dart';
import '../managers/resource_manager.dart';
import '../neon_runner_game.dart';

/// Enemy (Zombie) component
class Enemy extends SpriteAnimationComponent
    with HasGameReference<NeonRunnerGame>, CollisionCallbacks {
  
  bool isDead = false;
  double deathAnimationTime = 0;
  late double speed;
  
  Enemy({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(80),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Get speed from difficulty settings
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    speed = settings.enemySpeed;
    
    // Use cached animation
    animation = ResourceManager().enemyWalk;
    
    // Add collision hitbox
    add(RectangleHitbox(
      size: Vector2(40, 60),
      position: Vector2(20, 10),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDead) {
      // Float up and fade when dead
      position.y -= 50 * dt;
      deathAnimationTime += dt;
      if (deathAnimationTime >= 0.5) {
        removeFromParent();
      }
      return;
    }
    
    // Move left towards player
    final settings = GameConfig.difficulties[GameState().difficulty]!;
    position.x -= speed * settings.gameSpeed * dt;
    
    // Remove if off screen
    if (position.x < -100) {
      removeFromParent();
    }
  }

  /// Take damage and die
  void takeDamage() {
    if (isDead) return;
    
    isDead = true;
    deathAnimationTime = 0;
    AudioManager().playEnemyDeath();
    
    // Trigger explosion effect
    game.particleSystem.createExplosion(position);
    
    // Notify game of kill
    game.onEnemyKilled();
    
    // Remove hitbox
    children.whereType<RectangleHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });
  }
}
