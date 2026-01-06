import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../../core/game_config.dart';

/// Manages shared game resources to optimize memory and performance
class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();
  factory ResourceManager() => _instance;
  ResourceManager._internal();

  // Player animations
  late SpriteAnimation playerRun;
  late SpriteAnimation playerJump;
  late SpriteAnimation playerAttack;
  late SpriteAnimation playerHit;
  late SpriteAnimation playerDeath;
  late SpriteAnimation playerIdle;

  // Enemy animations
  late SpriteAnimation enemyWalk;
  late SpriteAnimation enemyDeath;

  bool _initialized = false;

  /// Load all game assets
  Future<void> loadAssets() async {
    if (_initialized) return;

    // Preload images
    await Flame.images.loadAll([
      'Run__001.png', 'Run__002.png', 'Run__003.png',
      'Run__004.png', 'Run__005.png', 'Run__006.png',
      'Run__007.png', 'Run__008.png', 'Run__009.png',
      'Zombiz1.png', 'Zombiz2.png', 'Zombiz3.png',
      'Zombiz4.png', 'Zombiz5.png', 'Zombiz6.png', 'Zombiz7.png',
      'plx-1.png', 'plx-2.png', 'plx-3.png',
      'plx-4.png', 'plx-5.png', 'plx-6.png',
    ]);

    // Create Player Animations
    final runSprites = List.generate(8, (i) => Sprite(Flame.images.fromCache('Run__00${i + 1}.png')));
    playerRun = SpriteAnimation.spriteList(runSprites, stepTime: GameConfig.runAnimSpeed);

    final idleSprites = [
      Sprite(Flame.images.fromCache('Run__001.png')),
      Sprite(Flame.images.fromCache('Run__002.png')),
    ];
    playerIdle = SpriteAnimation.spriteList(idleSprites, stepTime: 0.3);

    playerJump = SpriteAnimation.spriteList(
      [Sprite(Flame.images.fromCache('Run__003.png'))],
      stepTime: 0.1,
      loop: false,
    );

    playerAttack = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('Run__005.png')),
        Sprite(Flame.images.fromCache('Run__006.png')),
        Sprite(Flame.images.fromCache('Run__007.png')),
      ],
      stepTime: GameConfig.attackAnimSpeed,
      loop: false,
    );

    playerHit = SpriteAnimation.spriteList(
      [Sprite(Flame.images.fromCache('Run__004.png'))],
      stepTime: 0.2,
      loop: false,
    );

    playerDeath = SpriteAnimation.spriteList(
      [
        Sprite(Flame.images.fromCache('Run__008.png')),
        Sprite(Flame.images.fromCache('Run__001.png')),
      ],
      stepTime: GameConfig.deathAnimSpeed,
      loop: false,
    );

    // Create Enemy Animations
    final zombieSprites = List.generate(7, (i) => Sprite(Flame.images.fromCache('Zombiz${i + 1}.png')));
    enemyWalk = SpriteAnimation.spriteList(zombieSprites, stepTime: 0.1);

    enemyDeath = SpriteAnimation.spriteList(
      zombieSprites.reversed.take(3).toList(),
      stepTime: 0.15,
      loop: false,
    );

    _initialized = true;
  }
}
